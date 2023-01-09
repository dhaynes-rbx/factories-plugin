local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Column = FishBloxComponents.Column
local TextInput = FishBloxComponents.TextInput
local Text = FishBloxComponents.Text
local Button = FishBloxComponents.Button
local Panel = FishBloxComponents.Panel
local Overlay = FishBloxComponents.Overlay
local Scene = require(script.Parent.Parent.Scene)

local add = require(script.Parent.Helpers.add)
local getCoordinatesFromAnchorName = require(script.Parent.Helpers.getCoordinatesFromAnchorName)

type Props = {
    CurrentMap:table,
}

local function boxGizmo(adornee, xOffset, zOffset)
    xOffset = xOffset or 0
    return React.createElement("BoxHandleAdornment", {
        AdornCullingMode = Enum.AdornCullingMode.Never,
        Adornee = adornee,
        AlwaysOnTop = true,
        Color3 = Color3.new(0, 1, 0),
        SizeRelativeOffset = Vector3.new(xOffset, 0, zOffset)
    })
end

local function lineGizmo(adornee, length, orientation, xOffset, zOffset)

end

local function ConnectionGizmos(props: Props)

    local gizmos = {}
    local boxes = {}
    local machines = props.CurrentMap["machines"]
    for _,machine in machines do
        local x = machine["coordinates"]["X"]
        local y = machine["coordinates"]["Y"]
        local machineAnchor = Scene.getMachineAnchor(x, y)

        if machine["outputs"] then
            local numOutputs = machine["outputs"]
            for i,output in machine["outputs"] do
                add(boxes, boxGizmo(machineAnchor, 0, 1))
            end
        end

        if machine["sources"] then
            local numSources = #machine["sources"]
            for i,source in machine["sources"] do
                add(boxes, boxGizmo(machineAnchor, 0, -1))
            end
        end
    end

    
    return React.createElement("Folder", {
        Name = "Connection Gizmos",
    }, boxes)
end

return function(props)
    return ConnectionGizmos(props)
end