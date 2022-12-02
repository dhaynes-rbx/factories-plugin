--!strict
local Packages = script.Parent.Parent
local Dash = require(Packages.Dash)

--[[--
    findDeltaPaths utility Deep compares two variables and returns a list of `.` separated paths where they differ.
]]

--[[--
    @function findDeltaPaths Deep compares two variables and returns a list of `.` separated paths where they differ.
    @tparam any left - First variable to be compared
    @tparam any right - Second variable to be compared
    @treturn { string } - A table of changed paths
]]
local function findDeltaPaths(left: any, right: any, path: string): { string }
    path = path or ""
    if typeof(left) ~= typeof(right) then
        return { path }
    end

    local changedPaths = {}

    if typeof(left) == "table" then
        local visitedKeys: table = {}

        for key, value in pairs(left) do
            visitedKeys[key] = true
            local childPath = path == "" and key or path .. "." .. key
            changedPaths = Dash.append(changedPaths, findDeltaPaths(value, right[key], childPath))
        end

        for key, value in pairs(right) do
            if not visitedKeys[key] then
                local childPath = path == "" and key or path .. "." .. key
                changedPaths = Dash.append(changedPaths, findDeltaPaths(value, left[key], childPath))
            end
        end

        return changedPaths
    end

    if left == right then
        return changedPaths
    end

    table.insert(changedPaths, path)
    return changedPaths
end

return findDeltaPaths
