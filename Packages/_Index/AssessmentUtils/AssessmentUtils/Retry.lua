--[[--
    retry utility Will retry the given action up to maxRetries applying a backoff up to maxBackoff
]]

--[[--
    retry utility retries the given action and returns the results
    @tparam ()->any action - The action to retry
    @tparam number maxRetries - The number of times to retry
    @tparam number maxBackoff - The maximum backoff time
]]
return function(action: () -> any, maxRetries: number, maxBackoff: number)
    local attempts: number = 0
    local result: { any }
    repeat
        attempts = attempts + 1
        result = { pcall(action) }
        -- Failure to retrieve
        if not result[1] then
            local delay = math.min(maxBackoff, 2 ^ attempts + math.random())
            task.wait(delay)
        end
    until attempts >= maxRetries or result[1]
    return table.unpack(result)
end
