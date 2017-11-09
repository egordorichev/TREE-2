--TREE-2 Events System

local reg = {} --The list of registered events

local e = {} --The events system

--- Register a new function to be called at a specific event.
--P <name> (String): The name of the event.
--P <func> (Function): The function to register.
function e:registerEvent(name,func)
  --Arguments type verification.
  if type(name) ~= "string" then return error("Event name must be a string, provided: "..type(name)) end
  if type(func) ~= "function" then return error("Event function must be a string, provided: "..type(func)) end
  if not reg[name] then reg[name] = {} end --Create a new table for this event name.
  table.insert(reg[name],func) --Add the function.
end

--- Trigger the functions register for a specific event.
--P <name> (String): The name of the event.
--P [...]: Any arguments to pass to the functions.
--
--R reponds (Table): The return values of the functions.
function e:triggerEvent(name,...)
  --Argument type verification.
  if type(name) ~= "string" then return error("Event name must be a string, provided: "..type(name)) end
  if not reg[name] then return {} end --No functions are registered for this event.
  local responds = {}
  for id,func in ipairs(reg[name]) do
    local respond = {func(name,...)} --Call each function, in the order they are registered with.
    table.insert(responds,respond) --Add the repond to the responds list.
  end
  return responds --Return the responds list.
end

return e