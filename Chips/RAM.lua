--[[
--==Contributers==--
- Rami Sabbagh (RamiLego4Game)
- Egor Dorichev (egordorichev)
]]

--[[
#Events:
- 'RAM:poke' (address, value, oldvalue): Triggered when the memory is poked.
]]

--The RAM CHIP

local bit = require("bit")
local lshift,rshift,band,bor,bxor = bit.lshift, bit.rshift, bit.band, bit.bor, bit.bxor

local floor = math.floor

local events = require("Engine.events")

local function tohex(v) return string.format("0x%X",v) end

--Value, expected Type, Variable Name
local function Verify(v,t,n)
  if type(v) ~= t then
    error(n.." should be a "..t.." provided: "..type(v),3)
  end
end

return function(Config)
  
  local devkit = {} -- The RAM devkit
  local api = {} -- The RAM API

  local ram = {} -- RAM array
  local ramSize = Config.Size -- The current ram size.
  
  --Build the binary ram.
  for addr=0,ramSize-1 do
    ram[addr] = 0
  end
  
  --Helping functions
  local function VerifyAddress(addr,name)
    addr = floor(addr)
    
    if addr < 0 or addr > ramSize-1 then
      error(name.." is out of range ("..addr.."), must be [0,"..(ramSize-1).."]",3)
    end
    
    return addr
  end
  
  local function VerifyValue(value)
    value = floor(value)
    
    if value < 0 or value > 255 then
      error("Value is out of range ("..value.."), must be [0,255]",3)
    end
    
    return value
  end
  
  local function VerifyBitNum(bn)
    bn = floor(bn)
    
    if bn < 0 or bn > 7 then
      error("Bit Number is out of range ("..bn.."), must be [0,7]",3)
    end
    
    return bn
  end

  -- Returns byte from RAM at given position
  function api.peek(addr)
    Verify(addr,"number","Address")
    
    addr = VerifyAddress(addr,"Address")
    
    return ram[addr]
  end

  -- Sets RAM slot at given position to value
  function api.poke(addr, value)
    Verify(addr,"number","Address")
    Verify(value,"number","Value")
    
    addr = VerifyAddress(addr,"Address")
    value = VerifyValue(value)
    
    if value == ram[addr] then return end --The same value, nothing to change.
     events:triggerEvent("RAM:poke",addr,value,ram[addr])
    
    ram[addr] = value
  end

  -- Returns one bit from RAM at given position
  function api.getBit(addr,bn)
    Verify(addr,"number","Address")
    Verify(bn,"number","Bit Number")
    
    addr = VerifyAddress(addr,"Address")
    bn = VerifyBitNum(bn)
    
    return (band( ram[addr], lshift(1,bn) ) > 0)
  end

  -- Sets one bit in RAM at given position
  function api.setBit(addr,bn,value)
    Verify(addr,"number","Address")
    Verify(bn,"number","Bit Number")
    
    addr = VerifyAddress(addr,"Address")
    bn = VerifyBitNum(bn)
    
    local b = lshift(1,bn)
    if not value then b = bxor(255,b) end
    
    local new --The new value
    if value then
      new = bor(ram[addr], b)
    else
      new = band(ram[addr], b)
    end
    
    if new == ram[addr] then return end --The same value, nothing to change.
    
    events:triggerEvent("RAM:setBit",addr,bn,value, new, ram[addr])
    
    ram[addr] = new
  end
  
  -- Get RAM at given interval
  function api.memget(addr, length)
    -- TODO
  end

  -- Sets RAM at given interval to given value
  function api.memset(addr, value, length)
    -- TODO
  end

  -- Copies part of the RAM to another
  function api.memcpy(to, from, length)
    -- TODO
  end
  
  return api, {"RAM"}, devkit
end