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
local getMachineFromId = require(script.Parent.Helpers.getMachineFromId)

type Props = {
    CurrentMap:table,
}

type MachineConnection = {
    anchor: Instance,
    outputs: {
        cframe: CFrame,
        id: string,
        worldCFrame: CFrame,
    },
    sources: {
        cframe: CFrame,
        machineId: string,
        worldCFrame: CFrame,
    }

}

local function boxGizmo(adornee, cframe)
    xOffset = xOffset or 0
    return React.createElement("BoxHandleAdornment", {
        AdornCullingMode = Enum.AdornCullingMode.Never,
        Adornee = adornee,
        AlwaysOnTop = true,
        Color3 = Color3.new(0, 1, 0),
        CFrame = cframe
    })
end

local function lineGizmo(adornee, length, thickness, cframe)
    return React.createElement("LineHandleAdornment", {
        AdornCullingMode = Enum.AdornCullingMode.Never,
        Adornee = adornee,
        AlwaysOnTop = true,
        Color3 = Color3.new(0, 1, 0),
        CFrame = cframe,
        Length = -length,
        Thickness = thickness,
    })
end

local function ConnectionGizmos(props: Props)

    local connectionInfo = {}
    local boxes = {}
    local machines = props.CurrentMap["machines"]
    for _,machine in machines do
        local x = machine["coordinates"]["X"]
        local y = machine["coordinates"]["Y"]
        local machineAnchor = Scene.getMachineAnchor(x, y)

        local zOffset = 2.5
        local xSpacing = 3

        connectionInfo[machine] = {} :: MachineConnection
        connectionInfo[machine].anchor = machineAnchor
        connectionInfo[machine].outputs = {}
        connectionInfo[machine].sources = {}

        if machine["outputs"] then

            local numOutputs = #machine["outputs"]
            
            for i,output in machine["outputs"] do
                local index = i - 1
                local xOffset = (xSpacing * index) - (((numOutputs - 1) * xSpacing) / 2)
                local cframe = CFrame.new(Vector3.new(xOffset, 0, zOffset))
                add(boxes, boxGizmo(machineAnchor, cframe))

                local worldCFrame = machineAnchor:GetPivot() + cframe.Position
                
                connectionInfo[machine].outputs[i] = {}
                connectionInfo[machine].outputs[i].cframe = cframe
                connectionInfo[machine].outputs[i].id = output
                connectionInfo[machine].outputs[i].worldCFrame = worldCFrame
            end
        end

        if machine["sources"] then

            local numSources = #machine["sources"]

            for i,source in machine["sources"] do
                local index = i - 1
                local xOffset = (xSpacing * index) - (((numSources - 1) * xSpacing) / 2)
                local cframe = CFrame.new(Vector3.new(xOffset, 0, -zOffset))
                add(boxes, boxGizmo(machineAnchor, cframe))

                local worldCFrame = machineAnchor:GetPivot() + cframe.Position
                
                connectionInfo[machine].sources[i] = {}
                connectionInfo[machine].sources[i].cframe = cframe
                connectionInfo[machine].sources[i].machineId = source
                connectionInfo[machine].sources[i].worldCFrame = worldCFrame
            end
        end
    end

    --Loop through again and draw connections between the machines.
    for _,machine in machines do
        print("Machine: "..machine["id"], machine)
        if machine["sources"] then
            local x = machine["coordinates"]["X"]
            local y = machine["coordinates"]["Y"]
            local machineAnchor = Scene.getMachineAnchor(x, y)

            local info = connectionInfo[machine]

            for i,source in machine["sources"] do
                local lineTarget = getMachineFromId(source, props.CurrentMap)
                local cframe1 = connectionInfo[machine].sources[i].cframe
                local lookAt = connectionInfo[machine].anchor:GetPivot():VectorToObjectSpace()
                local magnitude = (cframe1:VectorToWorldSpace() - connectionInfo[machine].anchor:GetPivot().Position).Magnitude
                add(boxes, lineGizmo(machineAnchor, magnitude, 10, CFrame.new(cframe1.Position, lookAt)))
                -- add(boxes, lineGizmo(machineAnchor, 25, 10, CFrame.new(cframe1.Position)))
                
                
                -- print("Source: "..source)
                -- print("Machine ID: "..machine["id"], connectionInfo[lineTarget].outputs[i])
                -- print(" ")
                -- local cframe2 = connectionInfo[lineTarget].outputs[i].worldCFrame
                -- print(connectionInfo[lineTarget].outputs, i)
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