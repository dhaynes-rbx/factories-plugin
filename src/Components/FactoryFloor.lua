local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Selection = game:GetService("Selection")
local InputService = game:GetService("UserInputService")
local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local Dash = require(Packages.Dash)
local Machine = require(script.Parent.Machine)
local Constants = require(script.Parent.Parent.Constants)
local Conveyor = require(script.Parent.Conveyor.Conveyor)
local worldPositionToVector3 = require(script.Parent.Parent.Helpers.worldPositionToVector3)
local Utilities = require(script.Parent.Parent.Packages.Utilities)
local Types = require(script.Parent.Parent.Types)
local Dataset = require(script.Parent.Parent.Dataset)
local Scene = require(script.Parent.Parent.Scene)
local getOrCreateFolder = require(script.Parent.Parent.Helpers.getOrCreateFolder)
local FishBloxComponents = FishBlox.Components

type Props = {
    Machines:table,
    OnMachineSelect:(Types.Machine, Instance) -> nil,
    OnClearSelection:() -> nil,
    UpdateDataset:() -> nil,
}

local FactoryFloor = function(props:Props)
    local children = {}

    --Instantiation Hook
    React.useEffect(function()
        local folder = getOrCreateFolder("Belts", game.Workspace.Scene.FactoryLayout)
    end, {})

    --Connections Hook.
    --Listen for machine selection and machine drag.
    React.useEffect(function()
        local connections:{ RBXScriptConnection } = {}
        
        connections["ClearSelection"] =  Selection.SelectionChanged:Connect(function()
            if #Selection:Get() == 0 then
                props.OnClearSelection()
            end
        end)

        connections["Selection"] =  Selection.SelectionChanged:Connect(function()
            local selection = Selection:Get()
            if #selection >= 1 then
                local selectedObj = selection[1]
                if Scene.isMachineAnchor(selectedObj) then
                    local machine = Dataset:getMachineFromMachineAnchor(selectedObj)
                    props.OnMachineSelect(machine, selectedObj)
                end
            end
        end)

        connections["DragMachine"] = InputService.InputEnded:Connect(function(input:InputObject)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end
        
            local selectedObj = Selection:Get()[1]
            if selectedObj then
                if Scene.isMachineAnchor(selectedObj) then
                    --Register that the machine may have been moved.
                    local position = selectedObj.CFrame.Position
    
                    local machine = Dataset:getMachineFromMachineAnchor(selectedObj)
                    local worldPosition = Vector3.new()
                    if machine and machine["worldPosition"] then
                        worldPosition = Vector3.new(
                            machine["worldPosition"]["X"],
                            machine["worldPosition"]["Y"],
                            machine["worldPosition"]["Z"]
                        )

                        if position ~= worldPosition then
                            machine["worldPosition"]["X"] = position.X
                            machine["worldPosition"]["Y"] = position.Y
                            machine["worldPosition"]["Z"] = position.Z
                            props.UpdateDataset()
                        end
                    end
                end
            end

            connections["DeleteMachine"] = Scene.getMachinesFolder().ChildRemoved:Connect(function(child)
                local machine = Dataset:getMachineFromMachineAnchor(child)
                print("Machine deletion:", machine)
                if machine then
                    props.DeleteMachine(machine, child)
                end
            end)
        end)

        return function()
            for _,connection in connections do
                connection:Disconnect()
            end
        end
    end, { props.OnClearSelection })
    
    --Create machine and conveyor components
    local machineComponents = {}
    local conveyorData = {}
    for _,machine in props.Machines do
        table.insert(machineComponents, Machine({
            Id = machine.id,
            OnHover = function(hoveredMachine, selectedObj)
                props.OnMachineSelect(hoveredMachine, selectedObj)
            end,
            MachineData = machine,
            UpdateDataset = function()
                props.UpdateDataset()
            end
        }))

        conveyorData[machine.id] = {}
        local machineType = machine["type"]
        if machine["sources"] then
            for _,sourceId in machine["sources"] do

                local sourceMachine = nil
                for _,machineToCheck in props.Machines do
                    if sourceId == machineToCheck.id then
                        sourceMachine = machineToCheck
                    end
                end

                local conveyorName = Scene.getConveyorBeltName(sourceMachine, machine)
                if conveyorName then
                    table.insert(conveyorData[machine.id], {
                        name = conveyorName,
                        sourceId = sourceId,
                        startPosition = worldPositionToVector3(machine.worldPosition),
                        endPosition = worldPositionToVector3(sourceMachine.worldPosition),
                    })
                else
                    print("No conveyor name! Likely related to an error in the machine data.")
                end

            end
        else
            if machine["type"] ~= Constants.MachineTypes.invalid then
                --This is a purchaser, which means it doesn't have a source machine. Its conveyor comes in from offscreen.
                local beltEntryPart = Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.BeltEntryAndExit.Entry")
                table.insert(conveyorData[machine.id], {
                    sourceId = "enter",
                    name = "Conveyor-"..machine.id,
                    startPosition = worldPositionToVector3(machine.worldPosition),
                    endPosition = beltEntryPart.Attachment1.WorldCFrame.Position,
                })
            end
        end

        
        if machineType == Constants.MachineTypes.makerSeller then
            local beltExitPart = Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.BeltEntryAndExit.Exit")
            table.insert(conveyorData[machine.id], {
                sourceId = "exit",
                name = "Conveyor-"..machine.id,
                startPosition = beltExitPart.Attachment1.WorldCFrame.Position,
                endPosition = worldPositionToVector3(machine.worldPosition),
            })
        end

        print(machine.id, conveyorData[machine.id])
    end
    
    --Sort conveyors start and end positions. Offset them so they don't overlap.
    for _,machine in props.Machines do
        table.sort(conveyorData[machine.id], function(a,b)
            return a.endPosition.X < b.endPosition.X
        end)
        
        local conveyorXOffsetAmount = 3
        for i,conveyor in conveyorData[machine.id] do
            local numBelts = #conveyorData[machine.id]
            local offsetAmt = 3
            local offset = (i - 1) * offsetAmt - (offsetAmt * (numBelts-1)) / 2
            local newStart = conveyor.startPosition + Vector3.new(offset, 0, -5)
            conveyor.startPosition = newStart
            
            local otherMachinesUsingSameSource = {}
            if conveyor.sourceId == "enter" then
                conveyorXOffsetAmount = 6
                for _,otherMachine in props.Machines do
                    if otherMachine.type == Constants.MachineTypes.purchaser then
                        table.insert(otherMachinesUsingSameSource, otherMachine)
                    end
                end
            elseif conveyor.sourceId == "exit" then
                conveyorXOffsetAmount = 6
                for _,otherMachine in props.Machines do
                    if otherMachine.type == Constants.MachineTypes.makerSeller then
                        table.insert(otherMachinesUsingSameSource, otherMachine)
                    end
                end
            else
                local machineSource = Dataset:getMachineFromId(conveyor.sourceId)
                if machineSource then
                    --Check to see if other machines consider this machine a source
                    for _,otherMachine in props.Machines do
                        if otherMachine.sources then
                            for _,otherMachineSource in otherMachine.sources do
                                if otherMachineSource == machineSource.id then
                                    table.insert(otherMachinesUsingSameSource, otherMachine)
                                end
                            end
                        end
                    end
                end
            end
            table.sort(otherMachinesUsingSameSource, function(a,b)
                return a.worldPosition.X < b.worldPosition.X
            end)
                        
            local numSourceBelts = #otherMachinesUsingSameSource
            for j,otherMachine in ipairs(otherMachinesUsingSameSource) do
                if otherMachine.id == machine.id then
                    local sourceOffset = (j - 1) * conveyorXOffsetAmount - (conveyorXOffsetAmount * (numSourceBelts-1)) / 2
                    local newEnd = conveyor.endPosition + Vector3.new(sourceOffset, 0, 5)
                    conveyor.endPosition = newEnd
                end
            end
        end
    end
        
    
    local conveyorComponents = {}
    for _,machineConveyorsArray in conveyorData do
        for _,conveyor in machineConveyorsArray do
            table.insert(conveyorComponents, Conveyor({
                Name = conveyor.name,
                StartPosition = conveyor.startPosition,
                EndPosition = conveyor.endPosition,
            }))
        end
    end


    children = Dash.append(children, machineComponents, conveyorComponents)

    return React.createElement(React.Fragment, {}, children)
end

return function(props:Props)
    return React.createElement(FactoryFloor, props)
end