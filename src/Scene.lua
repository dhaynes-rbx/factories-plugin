local ServerStorage = game:GetService("ServerStorage")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Utilities = require(script.Parent.Packages.Utilities)
local getCoordinatesFromAnchorName = require(script.Parent.Components.Helpers.getCoordinatesFromAnchorName)

local Scene = {}

local function createScene()
    local scene = script.Parent.Assets.SceneHierarchy.Scene:Clone()
    scene.Parent = game.Workspace

    -- for _,v in scene:GetDescendants() do
    --     if v:IsA("BasePart") and v.Parent.Name ~= "Machines" then
    --         v.Locked = true
    --     end
    -- end
    
    game.Workspace:SetAttribute("Factories", true)
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

function Scene.getMachineAnchor(x:number, y:number)
    local machines = Scene.getMachineAnchors()
    for _,v in machines do
        local nameX, nameY = getCoordinatesFromAnchorName(v.Name)
        if nameX == x and nameY == y then
            return v
        end
    end
    return nil
end

-- function Scene.createMachine()
--     if Scene.isLoaded() then
--         local machine = script.Parent.Assets.Machines.Maker:Clone()
--         machine.Parent = Scene.machinesFolder
--     end
-- end

function Scene.loadScene()
    if Scene.isLoaded() then
        print("Scene is already loaded!")
        return 
    end

    if not game.Workspace:FindFirstChild("Scene") then
        createScene()
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

function Scene.isMachine(obj)
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

function Scene.loadMachines(dataset:table)
    Scene.getMachineStorageFolder():Destroy()

    for _,map in dataset["maps"] do
        local mapFolder = Scene.getOrCreateFolder(map["id"], Scene.getMachineStorageFolder())
        for _,machine in map["machines"] do
            local assetPath = string.split(machine["asset"], ".")[3]
            local position = Vector3.new()
            if machine["worldPosition"] then
                position = Vector3.new(
                    machine["worldPosition"]["X"],
                    machine["worldPosition"]["Y"],
                    machine["worldPosition"]["Z"]
                )
            end
            local asset = script.Parent.Assets.Machines[assetPath]:Clone()
            local cframe = CFrame.new(position)
            asset:PivotTo(cframe)
            asset.Name = "("..machine["coordinates"]["X"]..","..machine["coordinates"]["Y"]..")"
            asset.Parent = mapFolder
        end
    end
end

function Scene.populateMapWithMachines(dataset:table, mapIndex:number)
    Scene.getMachinesFolder():Destroy()

    local map = dataset["maps"][mapIndex]
    local folder = Scene.getOrCreateFolder(map["id"], Scene.getMachineStorageFolder())
    local parent = Scene.getMachinesFolder().Parent
    Scene.getMachinesFolder():Destroy()
    folder.Name = "Machines"
    folder.Parent = parent
end

return Scene