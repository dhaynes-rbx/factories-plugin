--!strict
local getTableSize = require(script.Parent.GetTableSize)

--[[--
    @classmod TimerUtils
]]

type Timeout = {
    handle: number,
    callback: Function,
    start: number,
    duration: number,
    repeats: number,
    params: any,
}

local currentHandle: number = 0
local timeouts: { [number]: Timeout } = {}
local running = false

function run()
    while running do
        local now = tick()
        for handle, timeout in pairs(timeouts) do
            if now - timeout.start >= timeout.duration then
                timeout.callback(table.unpack(timeout.params))
                if timeout.repeats == -1 then
                    timeout.start = now
                elseif timeout.repeats > 0 then
                    timeout.repeats = timeout.repeats - 1
                    timeout.start = now
                else
                    timeouts[handle] = nil
                end
            end
        end
        if getTableSize(timeouts) == 0 then
            running = false
        end
        wait()
    end
end

--[[--
    @function setTimeout - Sets a timeout to call a callback function
    @number duration - Seconds until calling callback
    @number repeats - How many times this will repeat (-1 == forever, 0 == none, n)
    @tparam Function callback - The callback to call
    @tparam any args - arbitrary arguments to pass to callback when called
    @treturn number - Handle for clearing timeout
]]
function setTimeout(duration: number, repeats: number, callback: Function, ...): number
    local handle = currentHandle
    currentHandle = currentHandle + 1

    timeouts[handle] = {
        handle = handle,
        callback = callback,
        start = tick(),
        duration = duration,
        repeats = repeats,
        params = { ... },
    }

    if running == false then
        running = true
        coroutine.wrap(run)()
    end

    return handle
end

--[[--
    @function clearTimeout - Sets a timeout to call a callback function
    @number - Handle for clearing timeout
]]
function clearTimeout(handle: number): nil
    if timeouts[handle] then
        timeouts[handle] = nil
    end
end

return {
    set = setTimeout,
    clear = clearTimeout,
}
