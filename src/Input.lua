local Debris = game:GetService("Debris")
local InputService = game:GetService("UserInputService")
local Selection = game:GetService("Selection")

local Root = script.Parent
local Packages = Root.Packages
local React = require(Packages.React)

local Dataset = require(script.Parent.Dataset)
local Scene = require(script.Parent.Scene)
local SceneConfig = require(script.Parent.SceneConfig)

local Input = {}

function Input.listenForMachineSelection(map:table, callback:any)
    return Selection.SelectionChanged:Connect(function()
        if #Selection:Get() >= 1 then
            local selectedObj = Selection:Get()[1]
            if SceneConfig.checkIfDatasetInstanceExists() and Scene.isMachineAnchor(selectedObj) then
                local machine = Dataset:getMachineFromMachineAnchor(selectedObj)
                --If we set selectedMachine to nil, then it will not trigger a re-render for the machine prop.
                if not machine then 
                    machine = React.None
                end
                callback(machine, selectedObj)
            end
        else
            callback(nil, nil)
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
                local machine = Dataset:getMachineFromMachineAnchor(selection)
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

function Input.listenForMachineAnchorDeletion(callback:any)
    return Scene.getMachinesFolder().ChildRemoved:Connect(function(child) 
        if not child:GetAttribute("debugId") then
            return
        end
        local machine = Dataset:getMachineFromMachineAnchor(child)
        if machine then
            callback()
        end
    end)
end

function Input.listenForMachineDuplication(callback:any)
    return Scene.getMachinesFolder().ChildAdded:Connect(function(child) 
        if not child:GetAttribute("debugId") then
            return
        end
        local machine = Dataset:getMachineFromMachineAnchor(child)
        child:SetAttribute("debugId", nil)
        Debris:AddItem(child, 0.1)
        local machineAnchor = Scene.getAnchorFromMachine(machine)
        callback(machine, machineAnchor)
    end)
end

return Input