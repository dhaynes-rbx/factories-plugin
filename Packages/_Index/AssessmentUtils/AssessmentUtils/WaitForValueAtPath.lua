--!strict
local Packages = script.Parent.Parent
local getValueAtPath = require(script.Parent.GetValueAtPath)

--[[--
    getValueAtPath utility Returns the value at the given path found inside the given table|Instance
]]

--[[--
    @function waitForValueAtPath Waits for and returns the value at the given path found inside the given table|Instance
    @tparam table|Instance table - The container to search in
    @string path - The path to look at
    @number timeout - Time in seconds to timeout
    @treturn any - The value found or nil
]]
local function waitForValueAtPath(table: table | Instance, path: string, timeout: number): any
    timeout = timeout or 5.0
    local startTime = tick()
    local result = nil
    repeat
        result = getValueAtPath(table, path)
        if result == nil then
            local now = tick()
            local delta = now - startTime
            if delta >= timeout then
                return nil
            end
            wait()
        end
    until result ~= nil
    return result
end

return waitForValueAtPath
