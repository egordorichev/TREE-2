--[[
--==Contributers==--
- Egor Dorichev (egordorichev)
]]

local editors = {
  sfx = dofile("/rom/Editors/Sfx.lua")
}

local current = editors.sfx

while true do
  Graphics.clear()

  current._update()
  current._draw()

  Graphics.flip()
end