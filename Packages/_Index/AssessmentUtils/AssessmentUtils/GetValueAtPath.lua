--!strict
local Packages = script.Parent.Parent
local Dash = require(Packages.Dash)

--[[--
    getValueAtPath utility Returns the value at the given path found inside the given table|Instance
]]

--[[--
    @function getValueAtPath Returns the value at the given path found inside the given table|Instance
    @tparam table|Instance table - The container to search in
    @string path - The path to look at
    @string delineator - How to delineate the path
    @treturn any - The value found or nil
]]
local function getValueAtPath(table: table | Instance, path: string, delineator: string): any
    delineator = delineator or "%."
    local keys: { [number]: string } = Dash.splitOn(path, delineator)
    local result: any = table
    local index: number = 1
    local count = #keys
    while index <= count and result ~= nil and (typeof(result) == "table" or typeof(result) == "Instance") do
        local success, child = pcall(function()
            return result[keys[index]] or result[tonumber(keys[index])]
        end)
        if success == true then
            result = child
        else
            result = nil
        end

        index = index + 1
    end
    -- If we haven't walked the entire path, the value isn't there
    if index < count then
        return nil
    end
    return result
end

return getValueAtPath
