--[[
--==Contributers==--
- Rami Sabbagh (RamiLego4Game)
- Egor Dorichev (egordorichev)
]]

--The Audio CHIP

local events = require("Engine.events")
local QueueableSource = require("Libs.QueueableSource")

return function(config)
  local devkit = {} -- The audio devkit
  local api = {} -- The audio API

  local sampleRate = config.SampleRate

  -- Converts note to frequency
  local function noteToHZ(note)
  	return 440 * math.pow(2, (note - 33) / 12)
  end

  local channels = {} -- The audio channels

  for i = 0, 3 do
    channels[i] = QueueableSource:new(8)
    channels[i]:play()
  end

  local waves = {} -- Wave functions

  -- Triangle wave
  waves[0] = function(x)
    return (math.abs((x % 1) * 2 - 1) * 2 - 1) * 0.7
  end

  -- Uneven triangle wave
  waves[1] = function(x)
    local t = x%1
    return (((t < 0.875) and (t * 16 / 7) or ((1 - t) * 16)) -1) * 0.7
  end

  -- Sawtooth wave
  waves[2] = function(x)
    return (x % 1 - 0.5) * 0.9
  end

  -- Square wave
  waves[3] = function(x)
    return (x % 1 < 0.5 and 1 or -1) * 1 / 3
  end

  -- Pulse wave
  waves[4] = function(x)
    return (x % 1 < 0.3125 and 1 or -1) * 1 / 3
  end

  -- Half triangle function
  waves[5] = function(x)
    x = x * 4
    return (abs((x%2)-1)-0.5 + (abs(((x*0.5)%2)-1)-0.5)/2-0.1) * 0.7
  end

  -- Noise
  waves[6] = function(x)
    local lastX = 0
		local sample = 0
		local lastSample = 0
		local tScale = noteToHZ(63) / sampleRate

		return function(x)
			local scale = (x - lastX) / tScale
			lastSample = sample
			sample = (lastSample + scale * (math.random() * 2 - 1)) / (1 + scale)
			lastX = x

			return math.min(math.max((lastSample + sample) * 4 / 3 * (1.75 - scale), -1), 1) * 0.7
		end
  end

  -- Detuned triangle wave
  waves[7] = function(x)
    x = x * 2
		return (math.abs((x % 2) - 1) - 0.5 + (math.abs(((x * 127 / 128) % 2) - 1) - 0.5) / 2) - 1 / 4
  end

  -- Used for arppregiator
  waves["saw_lfo"] = function(x)
    return x % 1
  end

  local sfxChannels = {}

  for i = 0, 3 do
    sfxChannels[i] = {
      position = 0,
      noise = waves[6]()
    }
  end

  -- Updates audio
  events:registerEvent("love:update", function(delta)
    local samples = math.floor(delta * sampleRate)

    for i = 0, samples - 1 do
      -- TODO: update audio
      -- (requires ram)
    end
  end)

  return api, {"Audio"}, devkit
end