local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local Dash = require(Packages.Dash)
local Scene = require(script.Parent.Parent.Scene)
local FishBloxComponents = FishBlox.Components

type Props = {
    MachineData:table
}

local Machine = function(props:Props)

    local machinePart: Part, setMachinePart: (Part) -> nil = React.useState(nil)

    local children = {}
    local machine = props.MachineData

    --Instantiation Hook
    React.useEffect(function()
        -- local folder = Scene.getMachinesFolder()

        local part = script.Parent.Parent.Assets.Machines["PlaceholderMachine"]:Clone()
        local worldPosition = Vector3.new(machine.worldPosition["X"], machine.worldPosition["Y"], machine.worldPosition["Z"])
        part:PivotTo(CFrame.new(worldPosition))
        part.Name = "("..machine["coordinates"]["X"]..","..machine["coordinates"]["Y"]..")"
        part.Parent = game.Workspace
        part.Color = Color3.new(0.1,0.1,0.1)
        part.Transparency = 0.1
        -- part.Parent = folder
        
        setMachinePart(part)
        
    end, {})

    return React.createElement(React.Fragment, {}, children)
end

return function(props:Props)
    return React.createElement(Machine, props)
end