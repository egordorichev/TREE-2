--[[
--==Contributers==--
- Rami Sabbagh (RamiLego4Game)
- Egor Dorichev (egordorichev)
]]

--The Graphics CHIP

local bit = require("bit")
local lshift,rshift,band,bor,bxor = bit.lshift, bit.rshift, bit.band, bit.bor, bit.bxor

local min,max,floor = math.min, math.max, math.floor
local function mid(x, y, z)
  if x > y then x, y = y, x end
  
  return max(x, min(y, z))
end

local events = require("Engine.events")

local onOS = love.system.getOS()
local onMobile = (onOS == "Android" or onOS == "iOS")

--Value, expected Type, Variable Name
local function Verify(v,t,n)
  if type(v) ~= t then
    error(n.." should be a "..t.." provided: "..type(v),3)
  end
end

return function(Config)
  
  --The screen resolution.
  local SWidth, SHeight = Config.Width, Config.Height
  local SScale = Config.Scale
  local PixelPerfect = Config.PixelPerfect
  
  if floor(SWidth/8) ~= SWidth/8 then error("Screen width should be dividable by 8 !") end
  
  --The RAM Variables
  local VRAMSAddress = Config.RAMAddress
  local VRAMLine = SWidth/8
  local VRAMSize = SHeight*VRAMLine
  local VRAMEAddress = VRAMSAddress + VRAMSize - 1
  
  --The color palette
  local Palette = {
    {255, 255, 255, 255} --1: White
  }
  Palette[0] = {0, 0, 0, 255} --0: Black
  
  --The screen image
  love.graphics.setDefaultFilter("nearest")
  local BufferImage = love.image.newImageData(SWidth,SHeight)
  local Image = love.graphics.newImage(BufferImage)
  local _ShouldDraw = true --The draw flag if changes have been made.
  
  local function setPixel(x,y,c)
    if c then
      BufferImage:setPixel(x,y,255,255,255,255)
    else
      BufferImage:setPixel(x,y,0,0,0,0)
    end
  end

  --Font image data for printing
  local FontImage = love.image.newImageData("assets/treetypemono.png")
  
  events:registerEvent("RAM:poke",function(addr,value, oldvalue)
    
    if addr < VRAMSAddress or addr > VRAMEAddress then return end
    addr = addr - VRAMSAddress
    
    local x = (addr % VRAMLine) * 8
    local y = floor(addr / VRAMLine)
    
    for px=x+7,x,-1 do
      local b = band(value,1)
      setPixel(px,y, (b == 1))
      value = rshift(value,1)
    end
    
    _ShouldDraw = true -- Changes have been made.
  end)
  
  events:registerEvent("RAM:setBit",function(addr,bn,value,new,old)
    
    if addr < VRAMSAddress or addr > VRAMEAddress then return end
    addr = addr - VRAMSAddress
    
    local x = (addr % VRAMLine) * 8
    local y = floor(addr / VRAMLine)
    
    setPixel(x+7-bn,y,value)
    
    _ShouldDraw = true -- Changes have been made.
  end)
  
  --Window creation
  local WWidth, WHeight = SWidth*SScale, SHeight*SScale
  local WTitle = Config.Title
  
  if not love.window.isOpen() then
    love.window.setMode(WWidth,WHeight,{
      resizable = true,
      minwidth = SWidth,
      minheight = SHeight
    })
  end
  
  WWidth, WHeight = love.graphics.getDimensions() --Update the window size
  
  love.window.setTitle(WTitle)
  --love.window.setIcon(love.image.newImageData("icon.png"))
  
  --Buffer Variables
  local WX, WY, WSWidth, WSHeight, WScale = 0,0, 0,0, 1
   events:registerEvent("love:resize",function(nw,nh)
    WWidth, WHeight = nw, nh
    if WWidth > WHeight then
      WScale = WHeight/SHeight
    else
      WScale = WWidth/SWidth
    end
    
    if PixelPerfect then WScale = floor(WScale) end
    
    WSWidth, WSHeight = SWidth*WScale, SHeight*WScale
    
    WX = (WWidth - WSWidth)/2 + 0.5
    WY = (WHeight - WSHeight)/2 + 0.5
    
    if onMobile then WY = 0.5 end
    
    _ShouldDraw = true
  end)
  
  --Calculate the buffer position variables for the first time
  events:triggerEvent("love:resize", WWidth, WHeight)
  
  --Draw the buffer
  events:registerEvent("love:graphics", function()
    if not _ShouldDraw then return end
    
    love.graphics.clear(0,0,0,255) --Clear the screen
    
    --Draw the back color plate
    love.graphics.setColor(Palette[0])
    love.graphics.rectangle("fill",WX, WY, WSWidth,WSHeight)
    
    --Draw the buffer
    Image:refresh()
    
    love.graphics.setColor(Palette[1])
    love.graphics.draw(Image,WX,WY, 0, WScale,WScale)
  end)
  
  --== Userfriendly functions ==--
  
  local function VerifyPos(x,y,prefex)
    local x, y, prefex = floor(x), floor(y), prefex or ""
    
    if x < 0 or x >= SWidth then error(prefex.."X is out of range ("..x..") Should be [0,"..(SWidth-1).."]",3) end
    if y < 0 or y >= SHeight then error(prefex.."Y is out of range ("..y..") Should be [0,"..(SHeight-1).."]",3) end
    
    return x, y
  end
  
  local function onScreen(x,y)
    if x < 0 or y < 0 or x >= SWidth or y >= SHeight then
      return false
    end
    return true
  end
  
  local poke , peek, setBit, getBit, memget, memset, memcpy
  
  events:registerEvent("Chip:PreInitialize", function(APIS, DevKits)
    --Get the RAM functions
    poke, peek = APIS.RAM.poke, APIS.RAM.peek
    setBit, getBit = APIS.RAM.setBit, APIS.RAM.getBit
    memget, memset, memcpy = APIS.RAM.memget, APIS.RAM.memset, APIS.RAM.memcpy
  end)
  
  local devkit = {} -- The graphics devkit
  local api = {} -- The graphics API

  -- Clears the window
  function api.clear(white)
    local Value = white and 255 or 0
    for Addr = VRAMSAddress, VRAMEAddress do
      poke(Addr,Value)
    end
  end

  -- Sets one pixel to white or black
  function api.pset(x, y, white)
    Verify(x,"number","X Pos")
    Verify(y,"number","Y Pos")
    
    x, y = VerifyPos(x,y)
    
    local addr = VRAMSAddress
    addr = addr + y * VRAMLine
    addr = addr + floor(x / 8)
    
    local bn = 7 - (x % 8)
    
    setBit(addr,bn,white)
  end
  
  local function pset(x,y,w)
    if onScreen(x,y) then
      api.pset(x,y,w)
    end
  end

  -- Returns pixel value at given position
  function api.pget(x, y)
    Verify(x,"number","X Pos")
    Verify(y,"number","Y Pos")
    
    x, y = VerifyPos(x,y)
    
    local addr = VRAMSAddres
    addr = addr + y * VRAMLine
    addr = addr + floor(x / 8)
    
    local bn = 7 - (x % 8)
    
    return getBit(addr,bn)
  end

  -- Draws a line
  function api.line(x0, y0, x1, y1, white)
    Verify(x0,"number","X0")
    Verify(y0,"number","Y0")
    Verify(x1,"number","X1")
    Verify(y1,"number","Y1")
    
    x0, y0 = floor(x0), floor(y0)
    x1, y1 = floor(x1), floor(y1)

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
      pset(x0, y1, white)
      return
    end

    if dx > dy then
     	for x = x0, x1 do
       	local y = y0 + dy * (x - x0) / dx
    	  	pset(x, y, white)
     	end
    else
     	for y = y0, y1 do
    	  	local x = x0 + dx * (y - y0) / dy
     		pset(x, y, white)
     	end
    end
  end

  -- Draws a rect
  function api.rect(x,y, w,h, line, white)
    Verify(x,"number","X")
    Verify(y,"number","Y")
    Verify(w,"number","Width")
    Verify(h,"number","Height")
    
    x,y = floor(x), floor(y)
    w,h = floor(w), floor(h)
    
    if line then
      api.line(x,y, x+w-2,y, white)
      api.line(x+w-1,y, x+w-1,y+h-2, white)
      api.line(x+w-1,y+h-1, x,y+h-1, white)
      api.line(x,y+h-1, x,y+1, white)
    else
      for px=x,x+w-1 do
        for py=y,y+h-1 do
          pset(px,py,white)
        end
      end
    end
  end
  
  -----

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
  function api.print(s, x, y, white)
    if not s then
      return
    end

    x = floor(x)
    y = floor(y)

    local line = 0
    
    for char = 1, #s do
      local code = string.byte(s, char)

      for x1 = 0, 5 do
        for y1 = 0, 7 do
          if code <32 or code > 126 then break end

          --We only need to check red. green and blue are irrelevant for 1-bit
          local r = FontImage:getPixel(x1 + ((code - 32) * 6), y1)

          if r == 0 then
            pset(x + (char * 6) + x1, y + y1 + (line * 8), white or true)
          end

        end
      end
    end
  end

  return api, {"Graphics"}, devkit
end
