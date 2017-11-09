--The bootloader of TREE-2

print("--==Bootloader Start==--")

print("Compiling Chips Loaders...")
--Step 1: Load the Chips chunks.
local ChipsLoaders = {}

for _,ChipName in ipairs(love.filesystem.getDirectoryItems("/Chips/")) do
  if ChipName:sub(-4,-1) == ".lua" then ChipName = ChipName:sub(1,-5) end
  ChipsLoaders[ChipName] = require("Chips."..ChipName)
end

--Step 2: Initialize the chips.
local config = require("BootLoader.config")

print("--==Bootloader End==--")