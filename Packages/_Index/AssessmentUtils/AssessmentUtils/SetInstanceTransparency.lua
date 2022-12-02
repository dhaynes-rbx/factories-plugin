--!strict
local forEachDescendent = require(script.Parent.ForEachDescendent)

--[[--
    setInstanceTransparency utility Sets all transparency
]]

--[[--
    @function setInstanceTransparency Sets all parts to the passed in transparency
    @tparam Instance instance - The instance
    @tparam number transparency
]]
local function setInstanceTransparency(instance: Instance, transparency: number)
    forEachDescendent(instance, function(descendant: Instance, path: string)
        if descendant:IsA("BasePart") then
            descendant.Transparency = transparency
        end
    end)
end

return setInstanceTransparency
