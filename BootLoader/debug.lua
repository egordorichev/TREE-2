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

local G = APIS.Graphics
G.clear()
--[[
G.rect(10,10,100,100, true, true)
G.rect(10,150,100,100, false, true)

G.line(0,0,479,319, true)
G.line(0,319,479,0, true)
G.rect(240,32,32,32,false,true)

local StringTests={"Hello\nWorld!","TREE-2","FANTASY CONSOLE"}
for i,str in pairs(StringTests) do
  G.print(str, math.random(0, 480), math.random(0, 100),true)
end
]]
local logo=[[

       %#
          %
   (%######%%(
&&%%#(###((##(((((,
@&&%&&%%#(#(#(((/(#
 (&@@@&%&%&&&&%%%%&
 .%&&&%#((((((%#/(
  #%%%##(//**,,,*
  ,%%%##((//**,*,
   /%%%%#((////
     %&&%####.
       .&&.
]]
--G.print(logo,0,0)
G.print("THIS\nIS\nA\nTest Print",0,0)
--G.print("HI\nEveryone",0,0)
--G.print("WOIFIWIOOIWOIDHWOIDHWIOHIWODIWODH",420,0,true)

--G.pset(479,318,true)