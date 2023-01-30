local ServerStorage = game:GetService("ServerStorage")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Utilities = require(script.Parent.Packages.Utilities)
local getCoordinatesFromAnchorName = require(script.Parent.Components.Helpers.getCoordinatesFromAnchorName)
local getMachineFromCoordinates = require(script.Parent.Components.Helpers.getMachineFromCoordinates)

local function registerDebugId(instance:Instance)
    instance:SetAttribute("debugId", instance:GetDebugId())
end

local Scene = {}

local function instantiateEnvironmentArt()
    local scene = script.Parent.Assets.SceneHierarchy.Scene:Clone()
    scene.Parent = game.Workspace
end

function Scene.isLoaded()
    return game.Workspace:FindFirstChild("Scene") ~= nil
end

function Scene.setCamera()
    local Camera = game.Workspace.Camera
    Camera.FieldOfView = 25.676
    Camera.CameraType = Enum.CameraType.Scriptable
    local cf = CFrame.new(-128.214401, 206.470215, -6.83965349, -4.37113883e-08, 0.855725706, -0.51742965, 0, 0.51742965, 0.855725706, 1, 3.74049591e-08, -2.26175683e-08)
    Camera.CFrame = cf
    Camera.CameraType = Enum.CameraType.Custom
end

function Scene.getOrCreateFolder(name, parent)
    local folder:Folder = parent:FindFirstChild(name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = parent
    end
    return folder
end

function Scene.getMachinesFolder()
    return Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.Machines")
end

function Scene.getMachineAnchors()
    local machinesFolder = Scene.getMachinesFolder()
    return (Scene.isLoaded() and machinesFolder) and machinesFolder:GetChildren() or {}
end

function Scene.getMachineAnchorFromCoordinates(x:number, y:number)
    local machines = Scene.getMachineAnchors()
    for _,v in machines do
        local nameX, nameY = getCoordinatesFromAnchorName(v.Name)
        if nameX == x and nameY == y then
            return v
        end
    end
    return nil
end

function Scene.getMachineAnchor(machine:table)
    local result = nil
    local machineAnchors = Scene.getMachineAnchors()
    local machineAnchorId = machine["machineAnchor"]
    for _,machineAnchor in machineAnchors do
        local debugId = machineAnchor:GetAttribute("debugId")
        if debugId == machineAnchorId then
            result = machineAnchor
        end
    end
    print("id:", machineAnchorId)
    return result
end

function Scene.loadScene()
    if Scene.isLoaded() then
        print("Scene is already loaded!")
        return
    end

    if not game.Workspace:FindFirstChild("Scene") then
        instantiateEnvironmentArt()
    end

    if game.Workspace:FindFirstChild("Baseplate") then
        game.Workspace.Baseplate:Destroy()
    end
    if game.Workspace:FindFirstChild("SpawnLocation") then
        game.Workspace.SpawnLocation:Destroy()
    end

    --Update the lighting and camera
    local Lighting = game:GetService("Lighting")
    Lighting.Ambient = Color3.fromRGB(70,70,70)
    Lighting.Brightness = 5
    Lighting.EnvironmentDiffuseScale = 1
    Lighting.EnvironmentSpecularScale = 1
    Lighting.GlobalShadows = true
    Lighting.OutdoorAmbient = Color3.fromRGB(70,70,70)
    Lighting.ShadowSoftness = 0.2
    -- Lighting.Technology = Enum.Technology.ShadowMap --Not scriptable
    Lighting.ClockTime = 14.5
    Lighting.GeographicLatitude = 0

    Scene.setCamera()

    ChangeHistoryService:SetWaypoint("Instantiated Scene Hierarchy")
end

function Scene.isMachineAnchor(obj)
    if not obj then
        return false
    end
    if obj.Parent.Name == "Machines" then
        return true
    end
    return false
end

function Scene.getMachineStorageFolder()
    return Scene.getOrCreateFolder("FactoriesPlugin-Machines", ServerStorage)
end

function Scene.getAnchorFromMachine(machine:table)
    local anchor = nil
    if machine["machineAnchor"] then
        for _,anchorInScene in Scene.getMachineAnchors() do
            local debugId = anchorInScene:GetAttribute("debugId")
            if debugId == machine["machineAnchor"] then
                anchor = anchorInScene
            end
        end
    end
    return anchor
end

function Scene.instantiateMachineAnchor(machine:table)
    local folder = Scene.getMachinesFolder()

    local assetPath = string.split(machine["asset"], ".")[3]
    local position = Vector3.new()
    if machine["worldPosition"] then
        position = Vector3.new(
            machine["worldPosition"]["X"],
            machine["worldPosition"]["Y"],
            machine["worldPosition"]["Z"]
        )
    end
    -- local asset = script.Parent.Assets.Machines[assetPath]:Clone()
    --TODO: Figure out why mesh machines are not importing correctly
    local anchor = Scene.getAnchorFromMachine(machine)
    if not anchor then 
        anchor = script.Parent.Assets.Machines["PlaceholderMachine"]:Clone()
        anchor.PrimaryPart.Color = Color3.new(0.1,0.1,0.1)
        anchor.PrimaryPart.Transparency = 0.1
        local cframe = CFrame.new(position)
        anchor:PivotTo(cframe)
        anchor.Name = "("..machine["coordinates"]["X"]..","..machine["coordinates"]["Y"]..")"
        anchor.Parent = folder
    end

    local debugId = anchor:GetDebugId()
    machine["machineAnchor"] = debugId
    registerDebugId(anchor)

    return anchor
end

function Scene.instantiateMapMachineAnchors(map:table)
    local folder = Scene.getMachinesFolder()
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "Machines"
        -- folder.ChildRemoved:Connect(function(child:Instance)
            
        -- end)
        -- folder.ChildAdded:Connect(function(child:Instance)
        --     registerDebugId(child)
        -- end)
        folder.Parent = game.Workspace.Scene.FactoryLayout
    end
    folder:ClearAllChildren()

    for _,machine in map["machines"] do
        Scene.instantiateMachineAnchor(machine)
    end
end

function Scene.removeMachineAnchor(machine:table)
    local anchor = Scene.getMachineAnchor(machine["coordinates"]["X"], machine["coordinates"]["Y"])
    if anchor then
        anchor:Destroy()
    end
end


return Scene