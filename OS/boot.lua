--[[
--==Contributers==--
- Rami Sabbagh (RamiLego4Game)
- Egor Dorichev (egordorichev)
]]

-- NutOS Boot File (First file loaded by the bootloader).

local apps = {}
-- local CodeEditor = require("OS.Apps.CodeEditor")

local function triggerCallback(app, name, ...)
  --[[ if type(app.sandbox[name]) == "function" then
    app.sandbox[name](...)
  end]]
end

local function registerApp(class)
  -- local app = class()

  --[[
  local w = app.sandbox.width
  local h = app.sandbox.height
  ]]

  local holder = {
    app = app,
    x = (480 - (w or 128)) / 2,
    y = (320 - (h or 128)) / 2,
    t = "Utitled",
    w = w or 128,
    h = h or 128,
    sandbox = nil -- TODO: make one
  }

  -- TODO: do this in thread
  triggerCallback(app, "_init")
  table.insert(apps, holder)
end

registerApp()

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
  ,
  {
    01010101,
    10101010,
    01010101,
    10101010,
    01010101,
    10101010,
    01010101,
    10101010
  }
}

for id,pat in ipairs(patterns) do
  for bid, byte in ipairs(pat) do
    pat[bid] = tonumber(byte,2)
  end
end

local function renderVM()
  Graphics.rect(0, 0, 480, 9, false, true)
  Graphics.line(0, 9, 480, 9, false)
  Graphics.print("TREE-2", 1, 1, false)

  local time = os.date("%I:%M %p")
  Graphics.print(time, 479 - #time * 6, 1, false)
end

while true do
  Graphics.pattern(patterns[6], 1)
  Graphics.rect(0, 0, 480, 320, false, true)
  Graphics.pattern()

  for i, app in ipairs(apps) do
    Graphics.rect(app.x - 3, app.y - 12, app.w + 6, app.h + 15, true, false)
    Graphics.rect(app.x - 2, app.y - 11, app.w + 4, app.h + 13, false, true)
    Graphics.rect(app.x, app.y, app.w, app.h, false, false)
    Graphics.print(app.t, app.x, app.y - 9, false)

    Graphics.icon({
      "10001",
      "01010",
      "00100",
      "01010",
      "10001"
    }, app.x + app.w - 7, app.y - 9, false)

    -- TODO: focus the camera
    triggerCallback(app, "_update")
    triggerCallback(app, "_draw")
  end

  renderVM()

  Graphics.flip()
end