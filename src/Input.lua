local InputService = game:GetService("UserInputService")
local Selection = game:GetService("Selection")

local Root = script.Parent
local Packages = Root.Packages
local React = require(Packages.React)

local Scene = require(script.Parent.Scene)
local SceneConfig = require(script.Parent.SceneConfig)

local getCoordinatesFromAnchorName = require(script.Parent.Components.Helpers.getCoordinatesFromAnchorName)
local getMachineFromCoordinates = require(script.Parent.Components.Helpers.getMachineFromCoordinates)
local getMachineFromMachineAnchor = require(script.Parent.Components.Helpers.getMachineFromMachineAnchor)

local Input = {}

function Input.listenForMachineSelection(map:table, callback:any)
    return Selection.SelectionChanged:Connect(function()
        if #Selection:Get() >= 1 then
            local selectedObj = Selection:Get()[1]
            if SceneConfig.checkIfDatasetInstanceExists() and Scene.isMachineAnchor(selectedObj) then
                local machine = getMachineFromMachineAnchor(map, selectedObj)
                --If we set selectedMachine to nil, then it will not trigger a re-render for the machine prop.
                if not machine then 
                    machine = React.None
                end
                callback(machine, selectedObj)
            end
        end
    end)
end

function Input.listenForMachineDrag(map:table, callback:any)
    return InputService.InputEnded:Connect(function(input:InputObject)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
    
        local selection = Selection:Get()[1]
        if selection then
            if Scene.isMachineAnchor(selection) then
                --Register that the machine may have been moved.
                local position = selection.PrimaryPart.CFrame.Position
                local machine = getMachineFromMachineAnchor(map, selection)
                local worldPosition = Vector3.new(
                    machine["worldPosition"]["X"],
                    machine["worldPosition"]["Y"],
                    machine["worldPosition"]["Z"]
                )
                if position ~= worldPosition then
                    machine["worldPosition"]["X"] = position.X
                    machine["worldPosition"]["Y"] = position.Y
                    machine["worldPosition"]["Z"] = position.Z
                    callback()
                end
            end
        end
    end)
end

function Input.listenForMachineAnchorDeletion(map:table, callback:any)
    return Scene.getMachinesFolder().ChildRemoved:Connect(function(child) 
        print("Child was removed.", map["id"])
        callback()
    end)
end

return Input