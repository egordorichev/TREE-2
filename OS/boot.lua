--[[
--==Contributers==--
- Rami Sabbagh (RamiLego4Game)
]]

--White color
RAM.poke(19203,255) --RED
RAM.poke(19204,255) --GREEN
RAM.poke(19205,255) --BLUE

--Splash Image--
local splash = fs.read("/rom/Boot/Splash.nbin")
RAM.memset(0,splash) --Draw the splash
Graphics.flip()

--File loading functions--
function loadfile(path)
  if not fs.exists(path) then return error("File doesn't exists !") end
  if fs.isDir(path) then return error("Can't load a folder !") end

  local lines = fs.lines(path)

  local function iter()
    local line = lines()
    if line then
      return line.."\n"
    end
  end

  local ok, chunk = pcall(load,iter,path)
  if ok then
    return chunk
  else
    return false, chunk
  end
end

function dofile(path,...)
  if not fs.exists(path) then return error("File doesn't exists !") end
  if fs.isDir(path) then return error("Can't load a folder !") end

  local lines = fs.lines(path)

  local function iter()
    local line = lines()
    if line then
      return line.."\n"
    end
  end

  local ok, chunk = pcall(load,iter,path)
  if not ok then return error(chunk) end

  local ret = {pcall(chunk,...)}
  if not ret[1] then return error(ret[2]) end
  return select(2,unpack(ret))
end

--Load the Package System--
dofile("/rom/Boot/package.lua")
dofile("/rom/terminal.lua")