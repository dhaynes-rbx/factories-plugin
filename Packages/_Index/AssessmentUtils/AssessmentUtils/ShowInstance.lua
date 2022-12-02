--!strict
local HttpService = game:GetService("HttpService")
local forEachDescendent = require(script.Parent.ForEachDescendent)

--[[--
    showInstance utility Sets all parts to visible or to the previous state if the state has been defined by hideInstance
]]

--[[--
    @function showInstance Sets all parts to visible or to the previous state if the state has been defined by hideInstance
    @tparam Instance instance - The instance
]]
local function showInstance(instance: Instance)
    local stringValue: StringValue = instance:FindFirstChild("HideInstanceState")
    local previousState = nil
    if stringValue ~= nil then
        previousState = HttpService:JSONDecode(stringValue.Value)
    end
    forEachDescendent(instance, function(descendant: Instance, path: string)
        if descendant:IsA("BasePart") then
            descendant.Transparency = previousState ~= nil and previousState[path] or 0
        end
    end)
    if stringValue ~= nil then
        stringValue:Destroy()
    end
end

return showInstance
