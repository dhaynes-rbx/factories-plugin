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
    MachineData:Types.Machine,
    UpdateDataset:() -> nil,
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
            part = Scene.instantiateMachineAnchor(props.MachineData)
            props.UpdateDataset()
        end
               
        setMachinePart(part)

    end, {})

    return React.createElement(React.Fragment, {}, children)
end

return function(props:Props)
    return React.createElement(Machine, props)
end