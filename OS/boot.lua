--[[
--==Contributers==--
- Rami Sabbagh (RamiLego4Game)
- Egor Dorichev (egordorichev)
]]

-- NutOS Boot File (First file loaded by the bootloader).

-- Print the logo ;)
print([[

       %#
          %
   (%######%%(
&&%%#(###((##(((((,
@&&%&&%%#(#(#(((/(#
 (&@@@&%&%&&&&%%%%&
 .%&&&%#((((((%#/(
  #%%%##(//**,,,*
  ,%%%##((//**,*,
   /%%%%#((////
     %&&%####.
       .&&.
]])

print("Loading NutOS...")

local events = require("Engine.events")
local openedApps = {}

-- Opens an app window
local function openApp(class)
  local app = class()

  print("Loading " .. (app.name or "untitled app") .. "...")
  table.insert(openedApps, app)
end

openApp(require("OS.Apps.CodeEditor"))

events:registerEvent("love:graphics", function()
  -- Draw windows
  for _, a in pairs(openedApps) do
    -- TODO: draw the window
    if a.draw then
      -- TODO: allign camera pos, clip, etc...
      a.draw(a)
    end
  end
end)