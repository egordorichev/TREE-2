--[[
--==Contributers==--
- Rami Sabbagh (RamiLego4Game)
- Egor Dorichev (egordorichev)
]]

--The Graphics CHIP

local events = require("Engine.events")

return function(config)
  local devkit = {} -- The graphics devkit
  local api = {} -- The graphics API

  events:registerEvent("love:graphics", function()
    love.graphics.clear()
  end)

  return api, {"Graphics"}, devkit
end