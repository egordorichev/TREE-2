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

while true do
  Graphics.clear()

  for i, app in ipairs(apps) do
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

  Graphics.flip()
end