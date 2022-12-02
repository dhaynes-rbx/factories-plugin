--!strict
local Dash = require(script.Parent.Parent.Dash)
local class = Dash.class

--[[--
    @classmod Timer Simple timer class
]]

--[[--
    @function constructor instantiates new instances
]]
local Timer = class("Timer", function()
    local event = Instance.new("BindableEvent")
    local self = {
        _finishedEvent = event,
        finished = event.Event,
        _running = false,
        _startTime = nil,
        _duration = nil,
    }
    return self
end)

--[[--
    @function start and runs the timer for the given duration
    @number duration - time in seconds
]]
function Timer:start(duration: number)
    if not self._running then
        local timerThread = coroutine.wrap(function()
            self._running = true
            self._duration = duration
            self._startTime = os.time()
            while self._running and os.time() - self._startTime < duration do
                wait()
            end
            local completed = self._running
            self._running = false
            self._startTime = nil
            self._duration = nil
            self._finishedEvent:Fire(completed)
        end)
        timerThread()
    else
        warn("Warning: timer could not start again as it is already running.")
    end
end

--[[--
    @function getTimeRemaining returns the seconds remaining on the timer or zero
    @treturn number - seconds remaining on the timer
]]
function Timer:getTimeRemaining(): number
    if self._running then
        local now = os.time()
        local timeLeft = self._startTime + self._duration - now
        if timeLeft < 0 then
            timeLeft = 0
        end
        return timeLeft
    end
end

--[[--
    @function isRunning returns true if the timer is running
    @treturn boolean - true if the timer is running
]]
function Timer:isRunning(): boolean
    return self._running
end

--[[--
    @function stop stops the timer, will dispatch event
]]
function Timer:stop()
    self._running = false
end

return Timer
