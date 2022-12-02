--!strict
local Packages = script.Parent.Parent
local Dash = require(Packages.Dash)

--[[--
    getDescendantsByNameAndClass utility Returns the value(s) with the given name of the given type found inside the given Instance
]]

--[[--
    @function getDescendantsByNameAndClass Returns the value(s) with the given name of the given type found inside the given Instance
    @tparam Instance instance - The container to search in
    @string name - The name to look for
    @string className - The classname
    @treturn any - The value found or nil
]]
local function getDescendantsByNameAndClass(instance: Instance, name: string, className: string): { any }
    local results = {}
    for _, child in ipairs(instance:GetChildren()) do
        if child.name == name and child.className == className then
            table.insert(results, child)
        end
        results = Dash.append(results, getDescendantsByNameAndClass(child, name, className))
    end
    return results
end

return getDescendantsByNameAndClass
