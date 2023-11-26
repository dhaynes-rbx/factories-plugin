local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
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
local FishBloxComponents = FishBlox.Components

type Props = {
    Machines:table,
}

local FactoryFloor = function(props:Props)
    local children = {}

    --Instantiation Hook
    React.useEffect(function()
        --Get the existing machine anchors.
    end, {})
    
    --Create machine components
    local machineComponents = {}
    local conveyorData = {}
    for _,machine in props.Machines do
        table.insert(machineComponents, Machine({
            MachineData = machine
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

                table.insert(conveyorData[machine.id], {
                    name = "Conveyor-"..machine.id.."-"..sourceId,
                    sourceId = sourceId,
                    startPosition = worldPositionToVector3(machine.worldPosition),
                    endPosition = worldPositionToVector3(sourceMachine.worldPosition)
                })

            end
        else
            
            -- local beltEntryPart = Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.BeltEntryAndExit.Entry")
            -- conveyorData[machine.id] = {
            --     Name = "Conveyor-"..machine.id,
            --     StartPosition = worldPositionToVector3(machine.worldPosition),
            --     EndPosition = beltEntryPart.Attachment1.WorldCFrame.Position
            -- }
            
        end

        
        if machineType == Constants.MachineTypes.makerSeller then
            print("")
            -- local beltExitPart = Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.BeltEntryAndExit.Exit")
            -- conveyorData[machine.id] = {
                --     Name = "Conveyor-"..machine.id,
                --     StartPosition = beltExitPart.Attachment1.WorldCFrame.Position,
                --     EndPosition = worldPositionToVector3(machine.worldPosition),
                -- }
        end
    end

    --Sort conveyors start and end positions. Offset them so they don't overlap.
    for _,machine in props.Machines do
        table.sort(conveyorData[machine.id], function(a,b) 
            return a.endPosition.X < b.endPosition.X
        end)
        
        for i,conveyor in conveyorData[machine.id] do
            local numBelts = #conveyorData[machine.id]
            local offsetAmt = 3
            local offset = (i - 1) * offsetAmt - (offsetAmt * (numBelts-1)) / 2
            local newStart = conveyor.startPosition + Vector3.new(offset, 0, -5)
            conveyor.startPosition = newStart
            
            local otherMachinesUsingSameSource = {}
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
            table.sort(otherMachinesUsingSameSource, function(a,b)
                return a.worldPosition.X < b.worldPosition.X
            end)
                        
            local numSourceBelts = #otherMachinesUsingSameSource
            for j,otherMachine in ipairs(otherMachinesUsingSameSource) do
                if otherMachine.id == machine.id then
                    local sourceOffsetAmt = 3
                    local sourceOffset = (j - 1) * sourceOffsetAmt - (sourceOffsetAmt * (numSourceBelts-1)) / 2
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