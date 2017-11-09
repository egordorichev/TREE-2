local conf = {}

conf.Version = {
  Magor = 0,
  Minor = 0,
  Patch = 0,
  Tag = "DEV"
}

conf.VersionStr = "V"..conf.Version.Magor.."."..conf.Version.Minor.."."..conf.Version.Patch.." "..conf.Version.Tag

conf.Chips = {
  --The chips are loaded in this order:
  {
    Chip = "Graphics",
    Title = "TREE-2 "..conf.VersionStr,
    Width = 480,
    Height = 320,
    Scale = 2,
    PerfectScale = false
  },
  
  {
    Chip = "FileSystem",
    Size = 25*1024*1024, --25mb.
    
    RootDir = "/Storage/"
  }
}

return conf