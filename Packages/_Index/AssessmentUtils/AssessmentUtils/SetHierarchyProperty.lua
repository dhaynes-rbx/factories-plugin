--!strict
local forEachDescendent = require(script.Parent.ForEachDescendent)

--[[--
    setHierarchyProperty utility Sets the given property on instance and all descendants
]]

--[[--
    @function setHierarchyProperty Sets all parts to transparent and saves the state inside the instance to be used by showInstance
    @tparam Instance instance - The instance
    @tparam string propertyName - name of property to set
    @tparam Instance instance - The instance
]]
function setHierarchyProperty(instance: Instance, propertyName: string, propertyValue: any, types: { string })
    forEachDescendent(instance, function(descendant: Instance, _: string)
        for _, typeName in ipairs(types) do
            if descendant:IsA(typeName) then
                descendant[propertyName] = propertyValue
                break
            end
        end
    end)
end

return setHierarchyProperty
