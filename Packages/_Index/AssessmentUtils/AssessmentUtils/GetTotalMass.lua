--!strict

--[[--
    getTotalMass utility Calculates the total mass of a roblox instance including all descendants
]]

--[[--
    @function getTotalMass Calculates the total mass of a roblox instance including all descendants
    @tparam Instance instance - The container to search in
    @treturn number - The total mass calculated
]]
local function getTotalMass(instance: Instance): number
    local mass = 0
    for _, child in pairs(instance:GetChildren()) do
        if child:IsA("BasePart") then
            mass = mass + child:GetMass()
        end
        mass = mass + getTotalMass(child)
    end
    return mass
end

return getTotalMass
