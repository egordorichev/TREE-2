--[[
Events:
- love:quit, Called when the user wants to close the program, if any registered function returns true then the quit operation will be cancelled.
- love:graphics, Called when it's time to render the screen (like love.draw), but you have to clear the screen and origin the transformations manually.
- love:*, Any love callback (ex: 'love:update', 'love:keypressed', etc...)

Special Events:
- Trigger love:restart to soft restart the program.

--==Contributers==--
- Rami Sabbagh (RamiLego4Game)
- Egor Dorichev (egordorichev)
]]

--Requirements--
io.stdout:setvbuf("no")

local events = require("Engine.events")

function love.run()
  if love.math then
    love.math.setRandomSeed(os.time()) --Set random seed
  end

  --An outer loop for soft restarting.
  while true do
    local restart = false --The soft restart flag

    events:registerEvent("love:restart",function()
      restart = true
    end)

    require("BootLoader") --Start the bootloader.

    -- We don't want the first frame's dt to include time taken by the bootloader.
    if love.timer then love.timer.step() end

    local dt = 0

    -- Main loop time.
    while true do
      -- Process events.
      if love.event then
        love.event.pump()
        for name, a,b,c,d,e,f in love.event.poll() do
          if name == "quit" then
            local responds, flag = events:triggerEvent("love:quit"), true
            for id,respond in ipairs(responds) do
              if respond[1] then --Cancel the quit operation.
                flag = false
              end
            end

            if flag then return a end --Quit.
          end
          events:triggerEvent("love:"..name,a,b,c,d,e,f) --Trigger the event.
        end
      end

      -- Update dt, as we'll be passing it to update
      if love.timer then
        love.timer.step()
        dt = love.timer.getDelta()
      end

      -- Call update and draw
      if love.update then love.update(dt) end -- Will pass 0 if love.timer is disabled

      --Is it possible to render the screen ?
      if love.graphics and love.graphics.isActive() then
        events:triggerEvent("love:graphics") --Tell everyone that it's time to render the screen.
        
        if love.timer then love.timer.sleep(0.001) end
      end

      --Check if we should soft restart
      if restart then break end --Escape from the main loop

    end

    --Reset everything
    if love.graphics then
      love.graphics.reset() --Reset the graphics
    end

    package.loaded = {bit = package.loaded["bit"]} --Reset the package system (should pass the bitop library)
    events = require("Engine.events") --Re-require the new events system.

  end

end
