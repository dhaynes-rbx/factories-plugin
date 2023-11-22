local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local Dash = require(Packages.Dash)
local Machine = require(script.Parent.Machine)
local Constants = require(script.Parent.Parent.Constants)
local Conveyor = require(script.Parent.Conveyor.Conveyor)
local FishBloxComponents = FishBlox.Components

type Props = {
    Machines:table,
}

local FactoryFloor = function(props:Props)
    print("Factory Floor", props.Machines)
    local children = {}

    --Instantiation Hook
    React.useEffect(function()
        --Get the existing machine anchors.
    end, {})

    --Create machine components
    local machineComponents = {}
    local conveyorComponents = {}
    for _,machine in props.Machines do
        table.insert(machineComponents, Machine({
            MachineData = machine
        }))

        if machine["sources"] then
            for _,sourceId in machine["sources"] do
                -- local conveyorData = {}
                -- local startPosition = Vector3.new(machine.worldPosition["X"], machine.worldPosition["Y"], machine.worldPosition["Z"]) :: Vector3
                -- local endPosition = Vector3.new()
                local sourceMachine = nil
                for _,machineToCheck in props.Machines do
                    if sourceId == machineToCheck.id then
                        sourceMachine = machineToCheck
                    end
                end
                -- if sourceMachine then
                --     endPosition = Vector3.new(sourceMachine.worldPosition["X"], sourceMachine.worldPosition["Y"], sourceMachine.worldPosition["Z"])
                -- end

                table.insert(conveyorComponents, Conveyor({
                    Name = "Conveyor-"..machine.id.."-"..sourceId,
                    Machine = machine,
                    SourceMachine = sourceMachine
                }))
                
                -- -- conveyorBelt.name = Scene.getAnchorFromMachine(machine).Name.."-"..Scene.getAnchorFromMachine(sourceMachine).Name
                -- conveyorBelt.name = Scene.getAnchorFromMachine(sourceMachine).Name.."-"..Scene.getAnchorFromMachine(machine).Name
                -- conveyorBelt.startPosition = startPosition
                -- conveyorBelt.endPosition = endPosition

                -- Scene.instantiateConveyorBelt(conveyorBelt)
                -- table.insert(conveyorBelts, conveyorBelt)
            end
        end

        local machineType = machine["type"]
        if machineType == Constants.MachineTypes.purchaser then
            print("Do that")
            -- for _,beltEntryPoint in beltEntryPoints do
                
            --     if beltEntryPoint.inUse then
            --         continue
            --     end
                
            --     local conveyorBelt = {}
            --     local startPosition = Vector3.new(machine.worldPosition["X"], machine.worldPosition["Y"], machine.worldPosition["Z"]) :: Vector3
            --     local endPosition = beltEntryPoint.attachment.WorldCFrame.Position
            --     beltEntryPoint.inUse = true
            --     conveyorBelt.name = Scene.getAnchorFromMachine(machine).Name
            --     conveyorBelt.startPosition = startPosition
            --     conveyorBelt.endPosition = endPosition

            --     Scene.instantiateConveyorBelt(conveyorBelt)
            --     table.insert(conveyorBelts, conveyorBelt)
            --     break
            -- end
        elseif machineType == Constants.MachineTypes.makerSeller then
            print("Then that")
            -- for _,beltExitPoint in beltExitPoints do
            --     if beltExitPoint.inUse then
            --         continue
            --     end
                
            --     local conveyorBelt = {}
            --     local startPosition = beltExitPoint.attachment.WorldCFrame.Position
            --     local endPosition = Vector3.new(machine.worldPosition["X"], machine.worldPosition["Y"], machine.worldPosition["Z"]) :: Vector3
            --     beltExitPoint.inUse = true
            --     conveyorBelt.name = Scene.getAnchorFromMachine(machine).Name
            --     conveyorBelt.startPosition = startPosition
            --     conveyorBelt.endPosition = endPosition

            --     Scene.instantiateConveyorBelt(conveyorBelt)
            --     table.insert(conveyorBelts, conveyorBelt)
            --     break
            -- end
        end
    end


    children = Dash.join(children, machineComponents, conveyorComponents)

    return React.createElement(React.Fragment, {}, children)
end

return function(props:Props)
    return React.createElement(FactoryFloor, props)
end