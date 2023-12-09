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
    Machines: { Types.Machine },
    OnMachineSelect: (Types.Machine, Instance) -> nil,
    OnClearSelection: () -> nil,
    UpdateDataset: () -> nil,
}

local FactoryFloor = function(props: Props)
    local children = {}

    --Instantiation Hook
    React.useEffect(function()
        local folder = getOrCreateFolder("Belts", game.Workspace.Scene.FactoryLayout)
    end, {})

    --Connections Hook.
    --Listen for machine selection and machine drag.
    React.useEffect(function()
        local connections: { RBXScriptConnection } = {}

        connections["ClearSelection"] = Selection.SelectionChanged:Connect(function()
            if #Selection:Get() == 0 then
                props.OnClearSelection()
            end
        end)

        connections["Selection"] = Selection.SelectionChanged:Connect(function()
            local selection = Selection:Get()
            if #selection >= 1 then
                local selectedObj = selection[1]
                if Scene.isMachineAnchor(selectedObj) then
                    local machine = Dataset:getMachineFromMachineAnchor(selectedObj)
                    props.OnMachineSelect(machine, selectedObj)
                end
            end
        end)

        connections["DragMachine"] = InputService.InputEnded:Connect(function(input: InputObject)
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
                if machine then
                    props.DeleteMachine(machine, child)
                end
            end)
        end)

        return function()
            for _, connection in connections do
                connection:Disconnect()
            end
        end
    end, { props.OnClearSelection })

    --Create machine and conveyor components
    local machineComponents = {}
    local conveyorData = {}
    -- for _, machine in props.Machines do
    -- machineComponents[machine.id] = Machine({
    --     Id = machine.id,
    --     OnHover = function(hoveredMachine, selectedObj)
    --         props.OnMachineSelect(hoveredMachine, selectedObj)
    --     end,
    --     MachineData = machine,
    --     UpdateDataset = function()
    --         props.UpdateDataset()
    --     end,
    -- })

    -- conveyorData[machine.id] = {}
    -- local machineType = machine["type"]
    -- if machine["sources"] then
    --     for _, sourceId in machine["sources"] do
    --         local sourceMachine = nil
    --         for _, machineToCheck in props.Machines do
    --             if sourceId == machineToCheck.id then
    --                 sourceMachine = machineToCheck
    --             end
    --         end

    --         local conveyorName = Scene.getConveyorBeltName(sourceMachine, machine)
    --         if conveyorName then
    --             table.insert(conveyorData[machine.id], {
    --                 name = conveyorName,
    --                 sourceId = sourceId,
    --                 startPosition = worldPositionToVector3(machine.worldPosition),
    --                 endPosition = worldPositionToVector3(sourceMachine.worldPosition),
    --             })
    --         else
    --             print("No conveyor name! Likely related to an error in the machine data.")
    --         end
    --     end
    -- else
    --     if machine["type"] ~= Constants.MachineTypes.invalid then
    --         --This is a purchaser, which means it doesn't have a source machine. Its conveyor comes in from offscreen.
    --         local conveyorName = "(" .. machine["coordinates"]["X"] .. "," .. machine["coordinates"]["Y"] .. ")"
    --         local beltEntryPart =
    --             Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.BeltEntryAndExit.Entry")
    --         table.insert(conveyorData[machine.id], {
    --             sourceId = "enter",
    --             name = conveyorName,
    --             startPosition = worldPositionToVector3(machine.worldPosition),
    --             endPosition = beltEntryPart.Attachment1.WorldCFrame.Position,
    --         })
    --     end
    -- end

    -- if machineType == Constants.MachineTypes.makerSeller then
    --     local conveyorName = "(" .. machine["coordinates"]["X"] .. "," .. machine["coordinates"]["Y"] .. ")"
    --     local beltExitPart = Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.BeltEntryAndExit.Exit")
    --     table.insert(conveyorData[machine.id], {
    --         sourceId = "exit",
    --         name = conveyorName,
    --         startPosition = beltExitPart.Attachment1.WorldCFrame.Position,
    --         endPosition = worldPositionToVector3(machine.worldPosition),
    --     })
    -- end
    -- end

    --Sort conveyors start and end positions. Offset them so they don't overlap.
    -- for _, machine in props.Machines do
    -- table.sort(conveyorData[machine.id], function(a, b)
    --     return a.endPosition.X < b.endPosition.X
    -- end)

    -- for i, conveyor in conveyorData[machine.id] do
    --     local numBelts = #conveyorData[machine.id]
    --     local offsetAmt = 3
    --     local offset = (i - 1) * offsetAmt - (offsetAmt * (numBelts - 1)) / 2
    --     local startPos = conveyor.startPosition + Vector3.new(offset, 0, -5)
    --     conveyor.startPosition = startPos

    --     local otherMachinesUsingSameSource = {}
    --     local makerSellerMachines = {}
    --     if conveyor.sourceId == "enter" then
    --         for _, otherMachine in props.Machines do
    --             if otherMachine.type == Constants.MachineTypes.purchaser then
    --                 table.insert(otherMachinesUsingSameSource, otherMachine)
    --             end
    --         end
    --     elseif conveyor.sourceId == "exit" then
    --         for _, otherMachine in props.Machines do
    --             if otherMachine.type == Constants.MachineTypes.makerSeller then
    --                 table.insert(makerSellerMachines, otherMachine)
    --             end
    --         end
    --     else
    --         local machineSource = Dataset:getMachineFromId(conveyor.sourceId)
    --         if machineSource then
    --             --Check to see if other machines consider this machine a source
    --             for _, otherMachine in props.Machines do
    --                 if otherMachine.sources then
    --                     for _, otherMachineSource in otherMachine.sources do
    --                         if otherMachineSource == machineSource.id then
    --                             table.insert(otherMachinesUsingSameSource, otherMachine)
    --                         end
    --                     end
    --                 end
    --             end
    --         end
    --     end
    --     table.sort(otherMachinesUsingSameSource, function(a, b)
    --         return a.worldPosition.X < b.worldPosition.X
    --     end)
    --     table.sort(makerSellerMachines, function(a, b)
    --         return a.worldPosition.X < b.worldPosition.X
    --     end)

    --     local conveyorXOffsetAmount = 3
    --     local numSourceBelts = #otherMachinesUsingSameSource
    --     for j, otherMachine in ipairs(otherMachinesUsingSameSource) do
    --         if otherMachine.id == machine.id then
    --             local sourceOffset = (j - 1) * conveyorXOffsetAmount
    --                 - (conveyorXOffsetAmount * (numSourceBelts - 1)) / 2

    --             -- print(conveyor.sourceId, machine.id, j, sourceOffset)
    --             local newEnd = conveyor.endPosition + Vector3.new(sourceOffset, 0, 5)
    --             conveyor.endPosition = newEnd
    --         end
    --     end

    --     local numExitBelts = #makerSellerMachines
    --     for j, makerSeller in ipairs(makerSellerMachines) do
    --         local sourceOffset = (j - 1) * conveyorXOffsetAmount - (conveyorXOffsetAmount * (numExitBelts - 1)) / 2
    --         -- print(conveyor.sourceId, machine.id, j, sourceOffset)
    --         local newStart = conveyor.startPosition + Vector3.new(sourceOffset, 0, 1)
    --         conveyor.startPosition = newStart
    --     end
    -- end
    -- end

    local machineConveyorMap = {}
    local entryPoints = {}
    local exitPoints = {}
    for _, machine: Types.Machine in props.Machines do
        local machinePosition = worldPositionToVector3(machine.worldPosition)
        --For each machine, get information on the conveyors that enter, and the conveyors that exit.
        machineConveyorMap[machine.id] = {}
        machineConveyorMap[machine.id]["beltsIn"] = {}
        local beltsIn = machineConveyorMap[machine.id]["beltsIn"]
        machineConveyorMap[machine.id]["beltsOut"] = {}
        local beltsOut = machineConveyorMap[machine.id]["beltsOut"]
        --Find the other in belts.
        --"Sources" should never be empty and always nil if there are no sources. But checking just in case.
        --TODO: Throw an error if #sources is 0 rather than nil.
        if machine.sources and #machine.sources > 0 then
            for _, sourceId in machine.sources do
                for _, sourceMachine in props.Machines do
                    if sourceId == sourceMachine.id then
                        --This machine is a source. Its belt will be coming in.
                        local conveyorName = Scene.getConveyorBeltName(sourceMachine, machine)
                        if conveyorName then
                            table.insert(beltsIn, {
                                name = conveyorName,
                                sourceId = sourceId,
                                sortingPosition = worldPositionToVector3(sourceMachine.worldPosition), --This is just for sorting.
                            })
                        end
                    end
                end
            end
        else
            --If there's no sources, then it's a purchaser.
            local conveyorName = Scene.getConveyorBeltName(machine)
            table.insert(beltsIn, {
                name = conveyorName,
                sourceId = "enter",
                sortingPosition = machinePosition,
            })
            table.insert(entryPoints, {
                name = conveyorName,
                destinationId = machine.id,
                sortingPosition = machinePosition,
            })
        end

        table.sort(beltsIn, function(a, b)
            return a.sortingPosition.X < b.sortingPosition.X
        end)
        for i, belt in ipairs(beltsIn) do
            belt.inPosition = machinePosition + Vector3.new((i - 1) * 3 - ((#beltsIn - 1) * 3 / 2), 0, -5)
        end

        --Find the out belts.
        for _, potentialDestinationMachine in props.Machines do
            --"Sources" should never be empty and always nil if there are no sources. But checking just in case.
            if potentialDestinationMachine.sources and #potentialDestinationMachine.sources > 0 then
                for _, sourceId in potentialDestinationMachine.sources do
                    if sourceId == machine.id then
                        --This machine is a destination. Its belt will be going out to the right.
                        local conveyorName = Scene.getConveyorBeltName(machine, potentialDestinationMachine)
                        if conveyorName then
                            table.insert(beltsOut, {
                                name = conveyorName,
                                destinationId = potentialDestinationMachine.id,
                                destinationPosition = worldPositionToVector3(potentialDestinationMachine.worldPosition), --This is just for sorting.
                            })
                        end
                    end
                end
            end
        end
        table.sort(beltsOut, function(a, b)
            return a.destinationPosition.X < b.destinationPosition.X
        end)
        for i, belt in ipairs(beltsOut) do
            belt.outPosition = machinePosition + Vector3.new((i - 1) * 3 - ((#beltsOut - 1) * 3 / 2), 0, 5)
        end
    end

    table.sort(entryPoints, function(a, b)
        return a.sortingPosition.X < b.sortingPosition.X
    end)
    local beltEntryPart = Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.BeltEntryAndExit.Entry")
    for i, point in ipairs(entryPoints) do
        point.position = beltEntryPart.Attachment1.WorldCFrame.Position
            + Vector3.new((i - 1) * 3 - ((#entryPoints - 1) * 3 / 2), 0, -5)
    end

    local conveyorComponents = {}
    for id, conveyorMap in machineConveyorMap do
        if conveyorComponents[id] ~= nil then
            print("Skipping...")
            continue
        end
        for i, beltComingIn in conveyorMap.beltsIn do
            if beltComingIn.sourceId == "enter" then
                for _, point in entryPoints do
                    if beltComingIn.name == point.name then
                        conveyorComponents[beltComingIn.name] = Conveyor({
                            Name = beltComingIn.name,
                            StartPosition = beltComingIn.inPosition,
                            EndPosition = point.position,
                        })
                    end
                end
                --this belt is coming from the left, offscreen.
            else
                --Check the other machines
                for _, sourceMachine in machineConveyorMap do
                    for _, beltLeavingSource in sourceMachine.beltsOut do
                        if beltLeavingSource.name == beltComingIn.name then
                            conveyorComponents[beltComingIn.name] = Conveyor({
                                Name = beltComingIn.name,
                                StartPosition = beltComingIn.inPosition,
                                EndPosition = beltLeavingSource.outPosition,
                            })
                        end
                    end
                end
            end
        end
    end

    for _, machineConveyorsArray in conveyorData do
        for _, conveyor in machineConveyorsArray do
            conveyorComponents[conveyor.name] = Conveyor({
                Name = conveyor.name,
                StartPosition = conveyor.startPosition,
                EndPosition = conveyor.endPosition,
            })
        end
    end

    children = Dash.join(children, machineComponents, conveyorComponents)
    -- children = Dash.join(children, machineComponents)

    return React.createElement(React.Fragment, {}, children)
end

return function(props: Props)
    return React.createElement(FactoryFloor, props)
end
