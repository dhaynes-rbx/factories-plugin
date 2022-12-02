--!strict

--[[--
    forEachDescendent utility Iterates all descendants and calls `operation` function (includes root)
]]

--[[--
    @function forEachDescendent Iterates all descendants and calls `operation` function (includes root)
    @tparam Instance instance - The instance
    @tparam (Instance, string) -> () operation - The function called
]]
local function forEachDescendent(instance: Instance, operation: (Instance, string) -> (), path: string)
    path = path or ""
    operation(instance, path)
    for _, child in ipairs(instance:GetChildren()) do
        local childPath = path == "" and child.Name or path .. "." .. child.Name
        forEachDescendent(child, operation, childPath)
    end
end

return forEachDescendent
