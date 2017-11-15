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
local pid = 0

local patterns = {
  {
    11111000,
    01110100,
    00100010,
    01000111,
    10001111,
    00010111,
    00100010,
    01110001
  }
  ,
  {
    00100000,
    01010000,
    10001000,
    10001000,
    10001000,
    10001000,
    00000101,
    00000010
  }
  ,
  {
    10111111,
    00000000,
    10111111,
    10111111,
    10110000,
    10110000,
    10110000,
    10110000
  }
  ,
  {
    10000000,
    10000000,
    01000001,
    00111110,
    00001000,
    00001000,
    00010100,
    11100011
  }
  ,
  {
    01110111,
    10001001,
    10001111,
    10001111,
    01110111,
    10011000,
    11111000,
    11111000,
    11111000
  }
}

for id,pat in ipairs(patterns) do
  for bid, byte in ipairs(pat) do
    pat[bid] = tonumber(byte,2)
  end
end

while true do

  if inc then
    r = r + speed
  else
    r = r - speed
  end
  
  if inc and r >= t then inc = false
  elseif r <= 0 and not inc then
    inc = true
    pid = (pid + 1) % (#patterns + 1)
    Graphics.pattern(patterns[pid],1)
  end
  
  Graphics.clear(true)
  
  Graphics.circle(240,160,r)
  Graphics.circle(240,160,r+8,true)
  Graphics.circle(240,160,r+7,true)
  
  --Graphics.triangle(5,5,5,30,30,5,true)
  --Graphics.triangle(8,8,27,8,8,27,false)
  
  --Graphics.rect(240-r/2,160-r/2,r,r)
  --Graphics.rect(240-r/2-2,160-r/2-2,r+4,r+4,true)
  
  Graphics.flip()
end