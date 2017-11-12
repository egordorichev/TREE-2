--[[
--==Contributers==--
- Rami Sabbagh (RamiLego4Game)
]]

--The bootloader of TREE-2

--[[
#Special Events:

- Chip:PreInitialize, Triggered after loading the chips, with 2 arguments passed:
-- APIS: All chips APIS merged in one table.
-- DevKits: The devkits of all Chips in one table.

- Chip:PostInitialize, Triggered after Chip:PostInitialize, with 2 arguments passed:
-- APIS: All chips APIS merged in one table.
-- DevKits: The devkits of all Chips in one table.

#Devkits:

Devkits are a table that can be returned by a Chip, which contains special functions for other chips to use.
]]


--Requirements
local events = require("Engine.events")

print("--==Bootloader Start==--")

print("Compiling Chips Loaders...")
--Step 1: Load the Chips chunks.
local ChipsLoaders = {}

for _,ChipName in ipairs(love.filesystem.getDirectoryItems("/Chips/")) do
  if ChipName:sub(-4,-1) == ".lua" then ChipName = ChipName:sub(1,-5) end
  ChipsLoaders[ChipName] = require("Chips."..ChipName)
end

--Step 2: Initialize the chips.
local Config = require("BootLoader.config")
local DevKits, APIS = {}, {}

--Config verification
if not Config.Chips then error("Config.Chips is not defined !!!") end

print("Loading Chips")
print("---")

--Chips Loading
for id,Chip in ipairs(Config.Chips) do
  local CName = Chip.Chip

  if not ChipsLoaders[CName] then error(CName.." Chip doesn't exist !") end

  print(CName.."-Chip","Load")

  local API, APINames, DevKit = ChipsLoaders[CName](Chip)
  if API and APINames then
    for _, AName in ipairs(APINames) do
      APIS[AName] = API
    end
  end

  if Devkit then
    DevKits[CName] = DevKit
  end
end

print("---")

-- Chips Pre-Initialization
print("Pre Initialize Chips")
events:triggerEvent("Chip:PreInitialize",APIS,DevKits)
print("---")

-- Chips Post-Initialization
print("Post Initialize Chips")
events:triggerEvent("Chip:PostInitialize",APIS,DevKits)
print("--==Bootloader End==--")

-- Run debug script
love.filesystem.load("/BootLoader/debug.lua")(APIS,DevKits)

-- Run the OS
--require("OS.boot")