--[[
--==Contributers==--
- Rami Sabbagh (RamiLego4Game)
- Egor Dorichev (egordorichev)
]]

-- NutOS Boot File (First file loaded by the bootloader).

local events = require("Engine.events")

print("Loading NutOS...")

events:registerEvent("love:graphics", function()
  -- Draw windows and stuff here
end)