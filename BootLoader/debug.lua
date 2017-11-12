local APIS, DevKits = ...

local RAM = APIS.RAM

local PatternA = tonumber(10101010, 2)
local PatternB = tonumber(01010101, 2)

local VLine = 480 / 8

for Y=0,319 do
  local Pattern = (Y % 2 == 0) and PatternA or PatternB
  for A=Y*VLine, Y*VLine+VLine-1 do
    RAM.poke(A, Pattern)
  end
end