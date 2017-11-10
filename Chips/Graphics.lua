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

  -- Clears the window
  function api.cls(c)
    c = api.color(c)

    -- TODO: poke into the RAM
  end

  -- Sets one pixel to given color
  function api.pset(x, y, c)
    x = api.flr(x)
    y = api.flr(y)
    c = api.color(c)

    -- todo: call RAM.poke1
  end

  -- Returns pixel value at given position
  function api.pget(x, y)
    x = api.flr(x)
    y = api.flr(y)

    return 0 -- TODO: peek value from the RAM
  end

  -- Draws a line
  function api.line(x0, y0, x1, y1, c)
    x0 = api.flr(x0)
    x1 = api.flr(x1)
    y0 = api.flr(y0)
    y1 = api.flr(y1)
    c = api.color(c)

    if x0 > x1 then -- Make sure, that x0 is smaller
      x0, x1 = x1, x0
    end

    if y0 > y1 then -- Make sure, that y0 is smaller
      y0, y1 = y1, y0
    end

    local dx = x1 - x0
    local dy = y1 - y0

    if dx < 1 and dy < 1 then
      -- The line is just a point
    	api.pset(x0, y1, c)
    	return
    end

    if dx > dy then
    	for x = x0, x1 do
    		local y = y0 + dy * (x - x0) / dx
    		api.pset(x, y, c)
    	end
    else
    	for y = y0, y1 do
    		local x = x0 + dx * (y - y0) / dy
    		api.pset(x, y, c)
    	end
    end
  end

  -- Draws a rect
  function api.rect(x0, y0, x1, y1, c)
    x0 = api.flr(x0)
    y0 = api.flr(y0)
    x1 = api.flr(x1)
    y1 = api.flr(y1)
    c = api.color(c)

    if x0 > x1 then
    	x0, x1 = x1, x0
    end

    if y0 > y1 then
    	y0, y1 = y1, y0
    end

    api.line(x0, y0, x1, y0, c)
    api.line(x0, y1, x1, y1, c)
    api.line(x0, y0, x0, y1, c)
    api.line(x1, y0, x1, y1, c)
  end

  -- Fills a rect
  function api.rectfill(x0, y0, x1, y1, c)
    x0 = api.flr(x0)
    y0 = api.flr(y0)
    x1 = api.flr(x1)
    y1 = api.flr(y1)
    c = api.color(c)

    if x0 > x1 then
    	x0, x1 = x1, x0
    end

    if y0 > y1 then
    	y0, y1 = y1, y0
    end

    for x = x0, x1 do
    	for y = y0, y1 do
    		api.pset(x, y, c)
    	end
    end
  end

  return api, {"Graphics"}, devkit
end