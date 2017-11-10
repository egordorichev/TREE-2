--[[
--==Contributers==--
- Rami Sabbagh (RamiLego4Game)
- Egor Dorichev (egordorichev)
]]

--The Graphics CHIP

local events = require("Engine.events")

return function(config)
  events:registerEvent("love:graphics", function()
    love.graphics.clear()
  end)

  local devkit = {} -- The graphics devkit
  local api = {} -- The graphics API

  -- Wrapper around math.floor
  function api.flr(a)
    return math.floor(a or 0)
  end

  -- Sets current color
  function api.color(c)
    if c then
      -- TODO: support 0x10 for fill patterns
      c = api.flr(c)
      -- TODO: poke it to memory
    end

    -- TODO: return color from mem
  end

  -- Sets one pixel to given color
  function api.pset(x, y, c)
    x = api.flr(a)
    y = api.flr(a)
    c = api.color(c)

    -- todo: call RAM.poke1
  end

  return api, {"Graphics"}, devkit
end