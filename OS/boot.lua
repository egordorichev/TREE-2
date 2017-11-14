--[[
--==Contributers==--
- Rami Sabbagh (RamiLego4Game)
- Egor Dorichev (egordorichev)
]]

-- NutOS Boot File (First file loaded by the bootloader).

-- Print the logo ;)
--[=[print([[

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
end)]=]

local r = 0
local inc = true
local t = 64
local speed = 1

while true do

  if inc then
    r = r + speed
  else
    r = r - speed
  end
  
  if inc and r >= t then inc = false
  elseif r <= 0 and not inc then inc = true
  end
  
  Graphics.clear(true)
  
  Graphics.circle(240,160,r)
  Graphics.circle(240,160,r+8,true)
  
  Graphics.flip()
end

--[[local P = tonumber(10101010,2)

local VRAMLine = 480/8
local A=0

for Y=0,319 do
  for i=1,VRAMLine do
    RAM.poke(A,math.random(0,255))
    A = A + 1
  end
  Graphics.flip()
end]]

--Graphics.flip()