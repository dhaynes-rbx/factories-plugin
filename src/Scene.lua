local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Scene = {}

Scene.machinesFolder = nil

local function createScene()
    local scene = script.Parent.Assets.SceneHierarchy.Scene:Clone()
    scene.Parent = game.Workspace

    for _,v in scene:GetDescendants() do
        if v:IsA("BasePart") and v.Parent.Name ~= "Machines" then
            v.Locked = true
        end
    end
    
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

function Scene.getMachines()
    return (Scene.isLoaded() and Scene.machinesFolder) and Scene.machinesFolder:GetChildren() or {}
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

    Scene.machinesFolder = game.Workspace.Scene.FactoryLayout.Machines

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

function Scene.updateSceneConfig(key, value)
    --TODO: Setup the config stuff or check to make sure it exists
    --TODO: Validate the incoming string and transform it if necessary. Example: No spaces or special characters in dataset names
end

function Scene.isMachine(obj)
    if obj.Parent.Name == "Machines" then
        return true
    end
    return false
end

return Scene