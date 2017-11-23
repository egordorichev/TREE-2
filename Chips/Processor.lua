--[[
--==Contributers==--
- Rami Sabbagh (RamiLego4Game)
]]

local events = require("Engine.events")

local onOS = love.system.getOS()
local onMobile = (onOS == "Android" or onOS == "iOS")

--The Processor CHIP
return function(config)
  local Machine --The machine state.
  
  events:registerEvent("Chip:PreInitalize", function(APIS, DevKits, M)
    Machine = M
  end)
  
  local devkit = {} --The processor devkit
  local api = {} --The processor API
  
  local eventStack = {} --Stores all the events.
  local pullEvent --The machine is yielded and waiting for any event.
  
  function devkit.triggerEvent(...)
    
    if pullEvent and Machine then
      
      pullEvent = false --Reset the pull flag.
      
      Machine.Resume(...) --Directly pass the event.
      
    else
      
      eventStack[#eventStack + 1] = {...} --Store the event in the stack.
      
    end
    
  end
  
  function api.pullEvent()
    
    if #eventStack > 0 then
      
      local event = eventStack[1]
      
      for i=2, #eventStack do
        eventStack[i-1] = eventStack[i]
      end
      
      eventStack[#eventStack] = nil
      
      return unpack(event)
      
    else
      
      pullEvent = true --We are pulling new events.
      
      return Machine.Yield() --Yield
      
    end
    
  end
  
  function api.triggerEvent(...)
    
    devkit.triggerEvent(...)
    
  end
  
  function api.getOS()
    
    return onOS
    
  end
  
  function api.isMobile()
    
    return onMobile
    
  end
  
  api.log = print --Console print.
  
  return api, {"Processor"}, devkit
end