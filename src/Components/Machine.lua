local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Selection = game:GetService("Selection")
local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local Dash = require(Packages.Dash)
local Scene = require(script.Parent.Parent.Scene)
local Dataset = require(script.Parent.Parent.Dataset)
local DatasetInstance = require(script.Parent.Parent.DatasetInstance)
local FishBloxComponents = FishBlox.Components
local Types = script.Parent.Parent.Types

type Props = {
    Id:string,
    OnHover:(Types.Machine, Instance) -> nil,
    OnClearSelection:() -> nil,
}

local Machine = function(props:Props)

    local machinePart: Part, setMachinePart: (Part) -> nil = React.useState(nil)

    local children = {}
    local machine = Dataset:getMachineFromId(props.Id)

    --Instantiation Hook
    React.useEffect(function()
        local folder = Scene.getMachinesFolder()
        local part = nil
        for _,child in folder:GetChildren() do
            local machineToCheck = Dataset:getMachineFromMachineAnchor(child)
            if machineToCheck and machineToCheck.id == machine.id then
                part = child
                setMachinePart(child)
            end
        end

        if not part then
            part = script.Parent.Parent.Assets.Machines["PlaceholderMachine"]:Clone()
            local worldPosition = Vector3.new(machine.worldPosition["X"], machine.worldPosition["Y"], machine.worldPosition["Z"])
            part:PivotTo(CFrame.new(worldPosition))
            part.Name = "("..machine["coordinates"]["X"]..","..machine["coordinates"]["Y"]..")"
            part.Parent = folder
            part.Color = Color3.new(0.1,0.1,0.1)
            part.Transparency = 0.1
        end
               
        setMachinePart(part)
        
        -- return function()
        --     if part then
        --         part:Destroy()
        --     end
        -- end
    end, {})

    React.useEffect(function()
        local connections: { RBXScriptConnection } = {}

        -- connections["Selection"] =  Selection.SelectionChanged:Connect(function()
        --     if #Selection:Get() >= 1 then
        --         if Selection:Get()[1] == machinePart then
        --             props.OnHover(machine, machinePart)
        --         end
        --     end
        -- end)

        return function()
            for _,connection in connections do
                connection:Disconnect()
            end
            table.clear(connections)
        end

    end, { machinePart, props.OnHover })

    return React.createElement(React.Fragment, {}, children)
end

return function(props:Props)
    return React.createElement(Machine, props)
end