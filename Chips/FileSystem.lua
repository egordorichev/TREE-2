--The virtual filesystem CHIP
--[[
--==Contributers==--
- Rami Sabbagh (RamiLego4Game)
]]

local events = require("Engine.events")

--Helping functions
--A usefull split function
local function split(inputstr, sep)
  if sep == nil then sep = "%s" end
  local t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

local function sanitizePath(path,wild)
  --Allow windowsy slashes
  path = path:gsub("\\","/")
  
  --Clean the path or illegal characters.
  local specialChars = {
    "\"", ":", "<", ">", "%?", "|" --Sorted by ascii value (important)
  }
  
  if not wild then table.insert(specialChars,"%*") end
  
  for k, char in ipairs(specialChars) do
    path = path:gsub(char,"")
  end
  
  --Collapse the string into its component parts, removing ..'s
  local parts = split(path,"/")
  local output = {}
  for k, part in ipairs(parts) do
    if part:len() > 0 and part ~= "." then
      
      if part == ".." or part == "..." then
        --.. or ... can cancel out the last folder entered
        if #output > 0 and output[#output] ~= ".." then
          output[#output] = nil
        else
          table.insert(output,"..")
        end
      elseif part:len() > 255 then
        --If part length > 255 and it is the last part
        table.insert(output,part:sub(1,255))
      else
        --Anyhing else we add to the stack
        table.insert(output,part)
      end
      
    end
  end
  
  --Recombine the output parts into a new string
  return table.concat(output,"/")
end

local function lastIndexOf(str,of)
  local lastIndex = 0
  local lastEnd = 0
  while true do
    local cstart,cend = string.find(str,of,lastEnd+1)
    if cstart then
      lastIndex, lastEnd = cstart, cend
    else
      break
    end
  end
  
  return lastIndex
end

local function indexOf(str,of)
  local cstart,cend = string.find(str,of)
  if cstart then return cstart else return 0 end
end

--Value, expected Type, Variable Name
local function Verify(v,t,n)
  if type(v) ~= t then
    error(n.." should be a "..t.." provided: "..type(v),3)
  end
end

return function(Config)
  local RootDir = Config.RootDir
  local Size = Config.Size
  local Usage = 0
  local ROM = false --The ROM folder can be written on before post-initialization
  
  events:registerEvent("Chip:PostInitialize",function(APIS,DevKits)
    ROM = Config.ROM --Make the rom folder readonly if needed.
  end)
  
  --Create the root directory if it doesn't exists.
  if not love.filesystem.exists(RootDir) then
    love.filesystem.createDirectory(RootDir)
  end

  local devkit = {} --The filesystem devkit
  local fs = {} --The filesystem API
  
  --Helping functions
  local function createPath(path)
    local parts = split(path,"/")
    local totalPath = ""
    for k, part in ipairs(parts) do
      if k == #parts then break end
      totalPath = totalPath.."/"..part
      
      if love.filesystem.exists(RootDir..totalPath) then
        if love.filesystem.isFile(RootDir..totalPath) then
          error("Can't create a directory in a file !",3)
        end
      else
        love.filesystem.createDirectory(RootDir..totalPath)
      end
    end
  end

  local function findIn( startDir, matches, wildPattern )
    local list = fs.directoryItems(startDir)
    for k, entry in ipairs(list) do
      local entryPath = (startDir:len() == 0) and entry or startDir.."/"..entry
      if string.match(entryPath, wildPattern) then
        table.insert(matches,entryPath)
      end
      
      if fs.isDirectory( entryPath) then
        findIn( entryPath, matches, wildPattern )
      end
    end
  end
  
  local function readonly(path)
    if not ROM then return false end
    
    local i = indexOf(path,"/")
    
    if i == 0 then
      if path == "rom" then
        return true
      end
    end
    
    return (path:sub(1,i-1) == "rom")
  end
  
  local function copyRecursive(from, to)
    if not love.filesystem.exists(RootDir..from) then return end
    
    if love.filesystem.isDirectory(RootDir..from) then
      --Copy a directory:
      --Make the new directory
      love.filesystem.newDirectory(RootDir..to)
      
      --Copy the source contents into it
      local files = love.filesystem.getDirectoryItems(RootDir..from)
      for k,file in ipairs(files) do
        copyRecursive(
          fs.combine(from,file),
          fs.combine(to,file)
        )
      end
    else
      --Copy a file
      local data = love.filesystem.read(RootDir..from)
      love.filesystem.write(RootDir..to,data)
    end
  end
  
  local function deleteRecursive(path)
    if not love.filesystem.exists(RootDir..path) then return end
    
    if love.filesystem.isDirectory(RootDir..path) then
      --Delete a directory:
      
      local files = love.filesystem.getDirectoryItems(RootDir..path)
      for k,file in ipairs(files) do
        deleteRecursive(fs.combine(path,file))
      end
      
      love.filesystem.remove(RootDir..path) --Delete the directory
    else
      --Delete a file
      
      love.filesystem.remove(RootDir..path)
    end
  end
  
  local function getSizeRecursive(path)
    if not love.filesystem.exists(RootDir..path) then return 0 end
    
    if love.filesystem.isDirectory(RootDir..path) then
      --Index a directory:
      local total = 0
      local files = love.filesystem.getDirectoryItems(RootDir..path)
      for k,file in ipairs(files) do
        total = total + getSizeRecursive(fs.combine(path,file))
      end
      return true
    else
      return love.filesystem.getSize(RootDir..path)
    end
  end
  
  local function recurse_spec(results, path, spec)
    local segment = spec:match('([^/]*)'):gsub('/', '')
    local pattern = '^' .. segment:gsub("[%.%[%]%(%)%%%+%-%?%^%$]","%%%1"):gsub("%z","%%z"):gsub("%*","[^/]-") .. '$'

    if fs.isDir(path) then
      for _, file in ipairs(fs.list(path)) do
        if file:match(pattern) then
          local f = fs.combine(path, file)

          if spec == segment then
            table.insert(results, f)
          end
          if fs.isDir(f) then
            recurse_spec(results, f, spec:sub(#segment + 2))
          end
        end
      end
    end
  end
  
  --API
  
  --List directory items.
  function fs.list(path)
    Verify(path,"string","Path")
    
    path = sanitizePath(path)
    
    if not love.filesystem.exists(RootDir..path) then return error("Folder doesn't exists !") end
    if love.filesystem.isFile(RootDir..path) then return error("The path must be a directory, not a file !") end
    
    return assert(love.filesystem.getDirectoryItems(RootDir..path))
  end
  
  --Combine 2 paths.
  function fs.combine(path, childPath)
    Verify(path,"string","Path")
    Verify(childPath,"string","Child Path")
    
    path = sanitizePath(path,true)
    childPath = sanitizePath(childPath,true)
    
    if path:len() == 0 then
      return childPath
    elseif childPath:len() == 0 then
      return path
    else
      return sanitizePath( path.."/"..childPath, true )
    end
  end
  
  --Get the last part of the path.
  function fs.getName(path)
    Verify(path,"string","Path")
    
    path = sanitizePath(path,true)
    if path:len() == 0 then
      return "root"
    end
    
    local lastSlash = lastIndexOf(path,"/")
    if lastSlash > 0 then
      return path:sub(lastSlash+1,-1)
    else
      return path
    end
  end
  
  --Get the file size.
  function fs.getSize(path)
    Verify(path,"string","Path")
    
    path = sanitizePath(path)
    
    if not love.filesystem.exists(RootDir..path) then return error("File doesn't exists !") end
    if love.filesystem.isDirectory(RootDir..path) then return error("Can't get size of a directory !") end
    
    return assert(love.filesystem.getSize(RootDir..path))
  end
  
  --Check if a file exists or not.
  function fs.exists(path)
    Verify(path,"string","Path")
    
    path = sanitizePath(path)
    return love.filesystem.exists(RootDir..path)
  end
  
  --Check if it's a directory or not.
  function fs.isDir(path)
    Verify(path,"string","Path")
    
    path = sanitizePath(path)
    if not love.filesystem.exists(RootDir..path) then return false end
    return love.filesystem.isDirectory(RootDir..path)
  end
  
  --Check if the path is readonly or not.
  function fs.isReadOnly(path)
    Verify(path,"string","Path")
    
    path = sanitizePath(path)
    return readonly(path)
  end
  
  --Create a new directory
  function fs.makeDir(path)
    Verify(path,"string","Path")
    
    path = sanitizePath(path)
    
    if readonly(path) then return error("Access denied.") end
    if love.filesystem.exists(RootDir..path) then return error("Path already exists 1") end
    
    createPath(path)
  end
  
  --Move files/file from path to another (supports directories)
  function fs.move(from,to)
    Verify(from,"string","From Path")
    Verify(to,"string","To Path")
    
    from = sanitizePath(from)
    to = sanitizePath(to)
    
    if not love.filesystem.exists(RootDir..from) then return error("From Path doesn't exists !") end
    if readonly(from) then return error("From Path: Access denied.") end
    if readonly(to) then return error("To Path: Access denied.") end
    
    createPath(to)
    
    copyRecursive(from,to)
    deleteRecursive(from)
  end
  
  --Copy files/file from path to another (supports directories)
  function fs.copy(from,to)
    Verify(from,"string","From Path")
    Verify(to,"string","To Path")
    
    from = sanitizePath(from)
    to = sanitizePath(to)
    
    if not love.filesystem.exists(RootDir..from) then return error("From Path doesn't exists !") end
    if readonly(to) then return error("To Path: Access denied.") end
    
    local csize = getSizeRecursive(from)
    if Usage + csize > Size then return error("No enough space !") end
    
    createPath(RootDir..to)
    
    copyRecursive(from,to)
    
    Usage = Usage + csize
  end
  
  --Delete file/files (supports directories)
  function fs.delete(path)
    Verify(path,"string","Path")
    
    path = sanitizePath(path)
    
    if not love.filesystem.exists(RootDir..path) then return error("Path doesn't exists !") end
    if readonly(path) then return error("Access denied.") end
    
    local dsize = getSizeRecursive(path)
    Usage = Usage - dsize
    
    deleteRecursive(path)
  end
  
  --Return the remaining free space
  function fs.getFreeSpace()
    return Size-Usage
  end
  
  --Match files with a specific wildPath, and return their names.
  function fs.find(wildPath)
    Verify(wildPath,"string","wildPath")
    
    wildPath = sanitizePath(wildPath, true)
    local results = {}
    recurse_spec(results,'',wildPath)
    return results
  end
  
  --Get the directory path of a file
  function fs.getDir(path)
    Verify(path,"string","path")
    
    path = sanitizePath(path)
    if path:len() == 0 then return ".." end
    
    local lastSlash = lastIndexOf(path,"/")
    if lastSlash > 0 then
      return path:sub(1,lastSlash)
    else
      return ""
    end
  end
  
  --Read a file content
  function fs.read(path)
    Verify(path,"string","Path")
    
    path = sanitizePath(path)
    
    if not love.filesystem.exists(RootDir..path) then return error("File doesn't exists.") end
    if love.filesystem.isDirectory(RootDir..path) then return error("Can't read content of a directory.") end
    
    return love.filesystem.read(RootDir..path)
  end
  
  --Return an iterator for file content
  function fs.lines(path)
    Verify(path,"string","Path")
    
    path = sanitizePath(path)
    
    if not love.filesystem.exists(RootDir..path) then return error("File doesn't exists.") end
    if love.filesystem.isDirectory(RootDir..path) then return error("Can't read content of a directory.") end
    
    return love.filesystem.lines(RootDir..path)
  end
  
  --Write a file
  function fs.write(path,data)
    Verify(path,"string","Path")
    Verify(path,"string","Data")
    
    path = sanitizePath(path)
    
    if love.filesystem.isDirectory(RootDir..path) then return error("Can't write on a directory.") end
    
    local fsize = data:len()
    if Usage + fsize > Size then error("No enough space.") end
    
    createPath(fs.getDir(path))
    love.filesystem.write(RootDir..path,data)
    
    Usage = Usage + fsize
  end
  
  --Append data to a file
  function fs.append(path,data)
    Verify(path,"string","Path")
    Verify(path,"string","Data")
    
    path = sanitizePath(path)
    
    if love.filesystem.isDirectory(RootDir..path) then return error("Can't append data on a directory.") end
    
    local asize = data:len()
    if Usage + fsize > Size then error("No enough space.") end
    
    createPath(fs.getDir(path))
    
    if love.filesystem.exists(RootDir..path) then
      love.filesystem.append(RootDir..path,data)
    else
      love.filesystem.write(RootDir..path,data)
    end
    
    Usage = Usage + fsize
  end
  
  events:registerEvent("Chip:PreInitialize",function(APIS,DevKit)
    Usage = getSizeRecursive("") --Get the disk usage
  end)

  return fs, {"FileSystem","fs"}, devkit
end