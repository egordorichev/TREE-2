--[[
--==Contributers==--
- Rami Sabbagh (RamiLego4Game)
]]

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
    Chip = "RAM",
    Size = 19264
  },
  
  {
    Chip = "Processor"
  },

  {
    Chip = "Graphics",
    Title = "TREE-2 "..conf.VersionStr,
    Width = 480,
    Height = 320,
    VRAMAddress = 0,
    DSRAMAddress = 19200,
    Scale = 1,
    PixelPerfect = true
  },

  {
    Chip = "FileSystem",
    Size = 25*1024*1024, --25mb.
    ROM = true, --Make the rom folder read-only

    RootDir = "/Storage/"
  },

  {
    Chip = "Audio",
    SampleRate = 22050
  }
}

return conf