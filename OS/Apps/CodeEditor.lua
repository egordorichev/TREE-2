--[[
--==Contributers==--
- Egor Dorichev (egordorichev)
]]

-- Code editor app

local Object = require("Libs.classic")
local Code = Object:extend()

function Code:new()
  self.name = "code editor"
end

function Code:draw()

end

return Code