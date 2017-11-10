--[[
--==Contributers==--
=- Egor Dorichev (egordorichev)
]]

--The RAM CHIP

return function(config)
  local devkit = {} -- The RAM devkit
  local api = {} -- The RAM API

  local ram = {} -- RAM array
  local ramSize = 10000 -- Tmp value, must be replaced with real one
  -- once the real RAM layout is ready

  -- Init RAM array
  for i = 0, ramSize - 1 do
    ram[i] = 0
  end

  --  Checks, if RAM address is invalid
  local function addrIsInvalid(addr)
    return not addr or addr < 0 or addr >= ramSize
  end

  -- Returns byte from RAM at given position
  function ram.peek(addr)
    if addrIsInvalid(addr) then
      return 0
    end

    return ram[math.floor(addr)]
  end

  -- Sets RAM slot at given position to value
  function ram.poke(addr, value)
    if addrIsInvalid(addr) then
      return
    end

    ram[math.floor(addr)] = math.floor(addr % 256) -- Make sure, value
    -- is a number from 0 to 255
  end

  -- Returns one bit from RAM at given position
  function ram.peek1(addr)
    -- TODO
  end

  -- Sets one bit in RAM at given position
  function ram.poke1(addr, value)
    -- TODO
  end

  -- Inverts byte in RAM at given position
  function ram.invert(addr)
    -- TODO
    -- Can be used in graphics
  end

  -- Sets RAM at given interval to given value
  function ram.memset(addr, value, length)
    -- TODO
  end

  -- Copies part of the RAM to another
  function ram.memcpy(to, from, length)
    -- TODO
  end
end