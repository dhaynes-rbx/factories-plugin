--!strict
local HttpService = game:GetService("HttpService")
local forEachDescendent = require(script.Parent.ForEachDescendent)

--[[--
    hideInstance utility Sets all parts to transparent and saves the state inside the instance to be used by showInstance
]]

--[[--
    @function hideInstance Sets all parts to transparent and saves the state inside the instance to be used by showInstance
    @tparam Instance instance - The instance
]]
local function hideInstance(instance: Instance)
    local stringValue: StringValue = instance:FindFirstChild("HideInstanceState") or Instance.new("StringValue")

    local previousState = {}
    forEachDescendent(instance, function(descendant: Instance, path: string)
        if descendant:IsA("BasePart") then
            previousState[path] = descendant.Transparency
            descendant.Transparency = 1
        end
    end)

    stringValue.Name = "HideInstanceState"
    stringValue.Parent = instance
    stringValue.Value = HttpService:JSONEncode(previousState)
end

return hideInstance
