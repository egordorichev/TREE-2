--The virtual filesystem CHIP
return function(config)
  
  local RootDir = config.RootDir
  
  local devkit = {} --The filesystem devkit
  
  local api = {} --The filesystem API
  
  return api, {"FileSystem","fs"}, devkit
  
end