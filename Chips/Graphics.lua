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

  -- The font
  local font = {
    "011110001111000111110011110001111100111110011111001000100100000100100010010000010001001000100111100011110001111000111100011111011011100100010010001001000100100010010001011111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111000001000011110011111000100010111111001111001111110011110001111000000000000011100100000000000000001010001010010011000001010011011010100000000000000111100010000000000000000000000001000000000",
    "110001011000101100000110001011000001100000110000011000101100001101100010110000111011011100101100010110001011000101100010110000000110001100010110001011000101100010110001000001100111100011110001111100111100011111001111100111110010001001000001001000100100000100010010001001111000111100011110001111000111110110111001000100100010010001001000100100010111110010001100011000100011000001101100010110000011000000000110110011010001100000000000100110100000000000000011111010100100100100010001010001010010000101000001000010101000000000000000111000111100000000",
    "110001011000101100000110001011000001100000110000011000101100001101100100110000110101011010101100010110001011000101100010110000000110001100010110001011000101100010110001000011001100010110001011000001100010110000011000001100000110001011000011011000101100001110110111001011000101100010110001011000101100000001100011000101100010110001011000101100010000110010011100111000000011000001101100010110000011000000000110110011010001100000000010000110100000000001000001010000000000110100010001010001010000001000100010011100010001001110101001000101101000010100",
    "111111011111001100000110001011111001111100110111011111101100001101111100110000110001011001101100010111110011010101111100011110000110001100010110001011010100111100011110001100001111110111110011000001100010111110011111001101110111111011000011011111001100001101010110101011000101111100110101011111000111100001100011000101100010110101001111000111100011000010101100011000011110001111100111110011110011111000001110011110001111100000001000001100101110000010101001010000000000011101010001010001010000010000010010110010000011100000010011110000111100100010",
    "110001011000101100000110001011000001100000110001011000101100001101100010110000110001011000101100010110000011001101101000000011000110001100010011010011010101100010001100011000001100010110001011000001100010110000011000001100010110001011000011011000101100001100010110011011000101100000110011011010000000110001100011000100110100110101011000100011000110000011001100011000110000000001100000110000011011001100011100110011000001100000000010000000000000000000010011111000000000100110010001010001010000100000001010111110000001001110101001000100001010010100",
    "110001011111100111110111111011111101100000111111011000101101111001100010111110110001011000100111100110000001111101100110111111000110000111100001100001111001100010001100011111101100010111111001111101111110111111011000001111110110001011011110011000101111101100010110001001111001100000011111011001101111110001100001111000011000011110011000100011000111111001111001111110111111011111100000110111111001111100011000011110000111001001001000001000100000000000000001010000000000111011001010011011010000000000000010110010000000000000000000111001111100000000"
  }

  -- Returns smallest numer
  local function min(a, b)
  	return a < b and a or b
  end

  -- Returns largerst number
  local function max(a, b)
  	return a > b and a or b
  end

  -- Returns mid number
  local function mid(x, y, z)
  	x, y, z = x or 0, y or 0, z or 0
  	if x > y then
  		x, y = y, x
  	end

  	return max(x, min(y, z))
  end

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

  -- Draws a circle
  function api.circ(ox, oy, r, c)
  	ox = api.flr(ox)
  	oy = api.flr(oy)
  	r = api.flr(r)
  	c = api.color(c)

  	local x = r
  	local y = 0
  	local decisionOver2 = 1 - x

  	while y <= x do
  		api.pset(ox + x, oy + y, c)
  		api.pset(ox + y, oy + x, c)
  		api.pset(ox - x, oy + y, c)
  		api.pset(ox - y, oy + x, c)
  		api.pset(ox - x, oy - y, c)
  		api.pset(ox - y, oy - x, c)
  		api.pset(ox + x, oy - y, c)
  		api.pset(ox + y, oy - x, c)

  		y = y + 1

  		if decisionOver2 < 0 then
  			decisionOver2 = decisionOver2 + 2 * y + 1
  		else
  			x = x - 1
  			decisionOver2 = decisionOver2 + 2 * (y - x) + 1
  		end
  	end
  end

  local function horizontalLine(x0, y, x1, c)
  	for x = max(0, x0), min(WIDTH - 1, x1) do
  		api.pset(x, y, c)
  	end
  end

  local function plotPoints(cx, cy, x, y, c)
  	horizontalLine(cx - x, cy + y, cx + x, c)

  	if y ~= 0 then
  		horizontalLine(cx - x, cy - y, cx + x, c)
  	end
  end

  -- Fills a circle
  function api.circfill(cx, cy, r, c)
  	cx = api.flr(cx)
  	cy = api.flr(cy)
  	r = api.flr(r)
  	c = api.color(c)

  	local x = r
  	local y = 0
  	local err = 1 - r

  	while y <= x do
  		plotPoints(cx, cy, x, y, c)

  		if err < 0 then
  			err = err + 2 * y + 3
  		else
  			if x ~= y then
  				plotPoints(cx, cy, y, x, c)
  			end

  			x = x - 1
  			err = err + 2 * (y - x) + 3
  		end

  		y = y + 1
  	end
  end

  -- Draws a triangle
  function api.tri(x1, y1, x2, y2, x3, y3, c)
    x1 = api.flr(x1)
    y1 = api.flr(y1)
    x2 = api.flr(x2)
    y2 = api.flr(y2)
    x3 = api.flr(x3)
    y3 = api.flr(y3)
    c = api.color(c)

    api.line(x1, y1, x2, y2, c)
    api.line(x2, y2, x3, y3, c)
    api.line(x1, y1, x3, y3, c)
  end

  -- Fills a triangle
  function api.trifill(x1, y1, x2, y2, x3, y3, c)
    x1 = api.flr(x1)
    y1 = api.flr(y1)
    x2 = api.flr(x2)
    y2 = api.flr(y2)
    x3 = api.flr(x3)
    y3 = api.flr(y3)
    c = api.color(c)

    local hy = max(y1, max(y2, y3))
    local hx

    if y1 == hy then
      hx = x1
    elseif y2 == hy then
      hx = x2
    else
      hx = x3
    end

    local ly = min(y1, min(y2, y3))
    local lx

    if y1 == ly then
      lx = x1
    elseif y2 == ly then
      lx = x2
    else
      lx = x3
    end

    local my = mid(y1, y2, y3)
    local mx

    if y1 == my then
      mx = x1
    elseif y2 == my then
      mx = x2
    else
      mx = x3
    end

    local k = my - ly

    for i = 0, k do
      local xa, xb,y
      y = ly + i
      xa = lx + (i / k) * (mx - lx)
      xb = lx + (i / (hy - ly)) * (hx - lx)

      api.line(xa, y, xb, y, c)
    end

    local k2 = hy - my

    for i = 0, k2 do
      local xa, xb ,y
      y = my + i
      xa = mx + (i / k2) * (hx - mx)
      xb = lx + ((i + k) / (hy - ly)) * (hx - lx)
      api.line(xa, y, xb, y, c)
    end
  end

  -- Draws a polygon
  function api.poly(...)
    local points = { ... }

    for i = 1, #points / 2 do
      local x0 = api.fl(points[i])
      local y0 = api.fl(points[i + 1])

      local x1, y1

      if i + 3 == #points then
        x1, y1 = points[1], points[2]
      else
        x1, y1 = points[i + 2], points[i + 3]
      end

      api.line(x0, y0, x1, y1)
    end
  end

  -- Fills a polygon
  function api.polyfill(...)
    local triangles = love.math.triangulate(...)

    for i, t in ipairs(triangles) do
      trifill(t[1], t[2], t[3], t[4], t[5], t[6])
    end
  end

  -- Prints a string
  function api.print(s, x, y, c)
    if not s then
      return
    end

    x = api.flr(x)
    y = api.flr(y)
    c = api.color(c)

    -- TODO: print it
    -- Requires trelear's font
  end

  return api, {"Graphics"}, devkit
end