[1mdiff --git a/Chips/Graphics.lua b/Chips/Graphics.lua[m
[1mindex a6435f1..d841034 100644[m
[1m--- a/Chips/Graphics.lua[m
[1m+++ b/Chips/Graphics.lua[m
[36m@@ -5,7 +5,7 @@[m
 ]][m
 [m
 --The Graphics CHIP[m
[31m-[m
[32m+[m[32mlocal utf8 = require("utf8")[m
 local bit = require("bit")[m
 local lshift,rshift,band,bor,bxor = bit.lshift, bit.rshift, bit.band, bit.bor, bit.bxor[m
 [m
[36m@@ -494,7 +494,7 @@[m [mreturn function(Config)[m
     [m
     for char = 1, #s do[m
       local code = string.byte(s, char)[m
[31m-[m
[32m+[m[32m      if string.char(code) == "e" then line = line + 1 end[m
       for x1 = 0, 5 do[m
         for y1 = 0, 7 do[m
           if code <32 or code > 126 then break end[m
