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
        CFrame = cframe,
        Name = adornee.Name
    })
end

local function lineGizmo(adornee, length, thickness, cframe, showError)
    return React.createElement("LineHandleAdornment", {
        AdornCullingMode = Enum.AdornCullingMode.Never,
        Adornee = adornee,
        AlwaysOnTop = true,
        Color3 = showError and Color3.new(1,0,0) or Color3.new(0, 1, 0),
        CFrame = cframe,
        Length = length,
        Thickness = thickness,
    })
end

local function ConnectionGizmos(props: Props)

    local missingAnchor = false

    local connectionInfo = {}
    local gizmos = {}
    local machines = props.CurrentMap["machines"]
    for _,machine in machines do
        local x = machine["coordinates"]["X"]
        local y = machine["coordinates"]["Y"]
        local machineAnchor = Scene.getMachineAnchor(machine)
        if not machineAnchor then
            print("No machine anchor found for ("..x..","..y..")")
            return
        end

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
                -- local xOffset = (xSpacing * index) - (((numOutputs - 1) * xSpacing) / 2)
                local xOffset = 0
                local cframe = CFrame.new(Vector3.new(xOffset, 0, zOffset))
                add(gizmos, boxGizmo(machineAnchor, cframe))

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
                -- local xOffset = (xSpacing * index) - (((numSources - 1) * xSpacing) / 2)
                local xOffset = 0
                local cframe = CFrame.new(Vector3.new(xOffset, 0, -zOffset))
                add(gizmos, boxGizmo(machineAnchor, cframe))

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
        if machine["sources"] then
            local machineAnchor = Scene.getMachineAnchor(machine)

            for i,source in machine["sources"] do
                local showError = false

                local lineTarget = getMachineFromId(source, props.CurrentMap)
                if not lineTarget then
                    print("No machine that matches ID: "..source)
                    continue
                end
                local sourceCFrameRelativeToAnchor = connectionInfo[machine].sources[i].cframe
                local outputWorldCFrame = Scene.getAnchorFromMachine(lineTarget):GetPivot()
                if #connectionInfo[lineTarget]["outputs"] > 0 then
                    --This machine has no source!
                    outputWorldCFrame = connectionInfo[lineTarget]["outputs"][1].worldCFrame
                else
                    showError = true
                end
                local outputCFrameRelativeToSource = CFrame.new(outputWorldCFrame.Position - machineAnchor:GetPivot().Position)
                local magnitude = (sourceCFrameRelativeToAnchor.Position - outputCFrameRelativeToSource.Position).Magnitude
                add(gizmos, lineGizmo(machineAnchor, magnitude, 5, CFrame.new(sourceCFrameRelativeToAnchor.Position, outputCFrameRelativeToSource.Position), showError))

            end
        end
    end

    
    return React.createElement("Folder", {
        Name = "Connection Gizmos",
    }, gizmos)
end

return function(props)
    return ConnectionGizmos(props)
end