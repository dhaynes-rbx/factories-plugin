--!strict

--[[--
    deepCompare utility Deep compares two variables
]]

--[[--
    @function deepCompare Deep compares two variables
    @tparam any left - First variable to be compared
    @tparam any right - Second variable to be compared
    @treturn boolean - true if the two are equivalent
    @treturn string? - Message about the first non-equivalent values found
]]
local function deepCompare(left: any, right: any): (boolean, string | boolean)
    if typeof(left) ~= typeof(right) then
        local message: string = ("{1} is of type %s, but {2} is of type %s"):format(typeof(left), typeof(right))
        return false, message
    end

    if typeof(left) == "table" then
        local visitedKeys: table = {}

        for key, value in pairs(left) do
            visitedKeys[key] = true
            local success: boolean, innerMessage: string = deepCompare(value, right[key])
            if not success then
                local message: string = innerMessage:gsub("{1}", ("{1}[%s]"):format(tostring(key))):gsub("{2}", ("{2}[%s]"):format(tostring(key)))
                return false, message
            end
        end

        for key, value in pairs(right) do
            if not visitedKeys[key] then
                local success: boolean, innerMessage: string = deepCompare(value, left[key])
                if not success then
                    local message: string = innerMessage:gsub("{1}", ("{1}[%s]"):format(tostring(key))):gsub("{2}", ("{2}[%s]"):format(tostring(key)))
                    return false, message
                end
            end
        end

        return true
    end

    if left == right then
        return true
    end

    local message: string = "{1} ~= {2}"
    return false, message
end

return deepCompare
