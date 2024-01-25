local ServerStorage = game:GetService("ServerStorage")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

-- local Dataset = require(script.Parent.Dataset)
local Utilities = require(script.Parent.Packages.Utilities)
local MapData = require(script.Parent.MapData)
local Constants = require(script.Parent.Constants)
local getOrCreateFolder = require(script.Parent.Helpers.getOrCreateFolder)
local Types = require(script.Parent.Types)

local function registerDebugId(instance: Instance)
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
    local cf = CFrame.new(
        -128.214401,
        206.470215,
        -6.83965349,
        -4.37113883e-08,
        0.855725706,
        -0.51742965,
        0,
        0.51742965,
        0.855725706,
        1,
        3.74049591e-08,
        -2.26175683e-08
    )
    Camera.CFrame = cf
    Camera.CameraType = Enum.CameraType.Custom
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
    Lighting.Ambient = Color3.fromRGB(70, 70, 70)
    Lighting.Brightness = 5
    Lighting.EnvironmentDiffuseScale = 1
    Lighting.EnvironmentSpecularScale = 1
    Lighting.GlobalShadows = true
    Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
    Lighting.ShadowSoftness = 0.2
    -- Lighting.Technology = Enum.Technology.ShadowMap --Not scriptable
    Lighting.ClockTime = 14.5
    Lighting.GeographicLatitude = 0

    Scene.setCamera()

    ChangeHistoryService:SetWaypoint("Instantiated Scene Hierarchy")
end

function Scene.getMachinesFolder()
    return Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.Machines")
end

-- function Scene.getMachineAnchorFromCoordinates(x:number, y:number)
--     local machines = Scene.getMachineAnchors()
--     for _,v in machines do
--         local nameX, nameY = Dataset:getCoordinatesFromAnchorName(v.Name)
--         if nameX == x and nameY == y then
--             return v
--         end
--     end
--     return nil
-- end
function Scene.isMachineAnchor(obj)
    if not obj then
        return false
    end
    if obj.Parent.Name == "Machines" then
        return true
    end
    return false
end

function Scene.getMachineAnchors()
    local machinesFolder = Scene.getMachinesFolder()
    return (Scene.isLoaded() and machinesFolder) and machinesFolder:GetChildren() or {}
end
-- function Scene.getAnchorFromMachine(machine: table)
--     local result = nil
--     local machineAnchors = Scene.getMachineAnchors()
--     local machineAnchorId = machine["machineAnchor"]
--     for _, machineAnchor in machineAnchors do
--         local debugId = machineAnchor:GetAttribute("debugId")
--         if debugId == machineAnchorId then
--             result = machineAnchor
--         end
--     end
--     return result
-- end

function Scene.getAnchorFromMachine(machine: Types.Machine)
    local anchor = nil
    if machine["machineAnchor"] then
        for _, anchorInScene in Scene.getMachineAnchors() do
            local debugId = anchorInScene:GetAttribute("debugId")
            if debugId == machine["machineAnchor"] then
                anchor = anchorInScene
            end
        end
    end
    return anchor
end

function Scene.instantiateMachineAnchor(machine: table)
    local folder = Scene.getMachinesFolder()

    -- local assetPath = string.split(machine["asset"], ".")[3]
    local position = Vector3.new()
    if machine["worldPosition"] then
        position =
            Vector3.new(machine["worldPosition"]["X"], machine["worldPosition"]["Y"], machine["worldPosition"]["Z"])
    end
    -- local asset = script.Parent.Assets.Machines[assetPath]:Clone()
    --TODO: Figure out why mesh machines are not importing correctly
    local anchor = Scene.getAnchorFromMachine(machine)
    if not anchor then
        -- anchor = script.Parent.Assets.Machines["PlaceholderMachine"]:Clone()
        anchor = Instance.new("Part")
        anchor.Anchored = true
        anchor.Size = Vector3.new(8, 2, 12)
        anchor.Color = Color3.new(0.1, 0.1, 0.1)
        anchor.Transparency = 0.1
        local cframe = CFrame.new(position)
        anchor:PivotTo(cframe)
        anchor.Name = "(" .. machine["coordinates"]["X"] .. "," .. machine["coordinates"]["Y"] .. ")"
        anchor.Parent = folder
    end

    local debugId = anchor:GetDebugId()
    machine["machineAnchor"] = debugId
    registerDebugId(anchor)

    return anchor
end

--TODO: This should be handled by the components.
function Scene.updateAllMapAssets(map: table)
    local folder = Scene.getMachinesFolder()
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "Machines"
        folder.Parent = game.Workspace.Scene.FactoryLayout
    end
    folder:ClearAllChildren()

    for _, machine in map["machines"] do
        Scene.instantiateMachineAnchor(machine)
    end

    -- Scene.updateAllConveyorBelts(map)
end

-- function Scene.removeMachineAnchor(machine: Types.Machine)
--     local anchor = Scene.getAnchorFromMachine(machine)
--     if anchor then
--         anchor:Destroy()
--     end
-- end

function Scene.getBeltsFolder()
    return Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.Belts")
end

function Scene.getConveyorDataFolder(name: string)
    local beltDataFolder: Folder = Utilities.getValueAtPath(game.Workspace, "BeltData")
    if beltDataFolder then
        return beltDataFolder:FindFirstChild(name)
    end
    return nil
end

function Scene.getConveyorsConnectedToMachine(anchorName: string)
    local conveyors = {}
    local beltDataFolder: Folder = Utilities.getValueAtPath(game.Workspace, "BeltData")
    for _, child in beltDataFolder:GetChildren() do
        local splitName = child.Name:split("-")
        for _, name in splitName do
            if name == anchorName then
                table.insert(conveyors, child)
            end
        end
    end
    return conveyors
end

function Scene.getMidpointAdjustment(conveyorName: string): NumberValue
    local conveyorFolder: Folder = Utilities.getValueAtPath(game.Workspace, "BeltData." .. conveyorName)
    local midpointAdjustment: NumberValue = conveyorFolder:FindFirstChild("MidpointAdjustment")
    if midpointAdjustment then
        return midpointAdjustment
    else
        return nil
    end
end

function Scene.getConveyorBeltName(machine1, machine2)
    local machine1Anchor = Scene.getAnchorFromMachine(machine1)
    local machine2Anchor = machine2 and Scene.getAnchorFromMachine(machine2) or nil
    if machine1Anchor and machine2Anchor then
        return machine1Anchor.Name .. "-" .. machine2Anchor.Name
    elseif machine1Anchor then
        return machine1Anchor.Name
    else
        return nil
    end
end

function Scene.removeConveyors(machine: Types.Machine)
    local folder = Utilities.getValueAtPath(game.Workspace, "BeltData")
    local conveyorName = "(" .. machine["coordinates"]["X"] .. "," .. machine["coordinates"]["Y"] .. ")"
    for _, conveyor: Folder in folder:GetChildren() do
        local splitName = conveyor.Name:split("-")
        if splitName[1] == conveyorName then
            conveyor:Destroy()
        end
        if #splitName > 1 and splitName[2] == conveyorName then
            conveyor:Destroy()
        end
    end
end

-- function Scene.instantiateConveyorBelt(conveyorBelt:table)
-- local part = Instance.new("Part")
-- part.Anchored = true
-- part.CanCollide = false
-- part.Locked = true
-- local distance = (conveyorBelt.endPosition - conveyorBelt.startPosition).Magnitude
-- local size = Vector3.new(1, 1, distance)
-- part.Size = size
-- part.CFrame = CFrame.new(conveyorBelt.startPosition, conveyorBelt.endPosition)
-- part.CFrame = part.CFrame:ToWorldSpace(CFrame.new(0, 0, -distance/2))
-- part.Name = conveyorBelt.name
-- part.Parent = Scene.getBeltsFolder()

-- return part
-- end

function Scene.updateAllConveyorBelts(map: table)
    -- local machines = map["machines"]
    -- local folder = Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.Belts")
    -- folder:ClearAllChildren()

    -- local conveyorBelts = {}

    -- local beltEntryPart = Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.BeltEntryAndExit.Entry")
    -- local beltEntryPoints = {}
    -- for _,child in beltEntryPart:GetChildren() do
    --     local index = tonumber(child.Name:match("%d"))
    --     local t = {}
    --     t["attachment"] = child
    --     t["inUse"] = false
    --     beltEntryPoints[index] = t
    -- end
    -- local beltExitPart = Utilities.getValueAtPath(game.Workspace, "Scene.FactoryLayout.BeltEntryAndExit.Exit")
    -- local beltExitPoints = {}
    -- for _,child in beltExitPart:GetChildren() do
    --     local index = tonumber(child.Name:match("%d"))
    --     local t = {}
    --     t["attachment"] = child
    --     t["inUse"] = false
    --     beltExitPoints[index] = t
    -- end

    -- for _,machine in machines do
    --     if machine["sources"] then
    --         for _,sourceId in machine["sources"] do
    --             local conveyorBelt = {}
    --             local startPosition = Vector3.new(machine.worldPosition["X"], machine.worldPosition["Y"], machine.worldPosition["Z"]) :: Vector3
    --             local endPosition = Vector3.new()
    --             local sourceMachine = nil
    --             for _,machineToCheck in machines do
    --                 if sourceId == machineToCheck.id then
    --                     sourceMachine = machineToCheck
    --                 end
    --             end
    --             if sourceMachine then
    --                 endPosition = Vector3.new(sourceMachine.worldPosition["X"], sourceMachine.worldPosition["Y"], sourceMachine.worldPosition["Z"])
    --             end
    --             -- conveyorBelt.name = Scene.getAnchorFromMachine(machine).Name.."-"..Scene.getAnchorFromMachine(sourceMachine).Name
    --             conveyorBelt.name = Scene.getAnchorFromMachine(sourceMachine).Name.."-"..Scene.getAnchorFromMachine(machine).Name
    --             conveyorBelt.startPosition = startPosition
    --             conveyorBelt.endPosition = endPosition

    --             Scene.instantiateConveyorBelt(conveyorBelt)
    --             table.insert(conveyorBelts, conveyorBelt)
    --         end
    --     end

    --     local machineType = machine["type"]
    --     if machineType == Constants.MachineTypes.purchaser then
    --         for _,beltEntryPoint in beltEntryPoints do

    --             if beltEntryPoint.inUse then
    --                 continue
    --             end

    --             local conveyorBelt = {}
    --             local startPosition = Vector3.new(machine.worldPosition["X"], machine.worldPosition["Y"], machine.worldPosition["Z"]) :: Vector3
    --             local endPosition = beltEntryPoint.attachment.WorldCFrame.Position
    --             beltEntryPoint.inUse = true
    --             conveyorBelt.name = Scene.getAnchorFromMachine(machine).Name
    --             conveyorBelt.startPosition = startPosition
    --             conveyorBelt.endPosition = endPosition

    --             Scene.instantiateConveyorBelt(conveyorBelt)
    --             table.insert(conveyorBelts, conveyorBelt)
    --             break
    --         end
    --     elseif machineType == Constants.MachineTypes.makerSeller then
    --         for _,beltExitPoint in beltExitPoints do
    --             if beltExitPoint.inUse then
    --                 continue
    --             end

    --             local conveyorBelt = {}
    --             local startPosition = beltExitPoint.attachment.WorldCFrame.Position
    --             local endPosition = Vector3.new(machine.worldPosition["X"], machine.worldPosition["Y"], machine.worldPosition["Z"]) :: Vector3
    --             beltExitPoint.inUse = true
    --             conveyorBelt.name = Scene.getAnchorFromMachine(machine).Name
    --             conveyorBelt.startPosition = startPosition
    --             conveyorBelt.endPosition = endPosition

    --             Scene.instantiateConveyorBelt(conveyorBelt)
    --             table.insert(conveyorBelts, conveyorBelt)
    --             break
    --         end
    --     end
    -- end

    -- local conveyorBeltData = {}
    -- -- local folder = getOrCreateFolder("Debug", game.Workspace)
    -- -- folder:ClearAllChildren()
    -- for _,belt in conveyorBelts do
    --     local distance = (belt.endPosition - belt.startPosition).Magnitude
    --     local numPoints = distance * 3 --3 points per stud

    --     -- local beltFolder = getOrCreateFolder(belt.name, folder)
    --     -- beltFolder:ClearAllChildren()

    --     local points = {}
    --     for i = 1, numPoints, 1 do
    --         local lerpedPosition = belt.endPosition:Lerp(belt.startPosition, i/numPoints)
    --         local point = {}
    --         point.position = {}
    --         --Match the orientation of the original blender plugin
    --         point.position.x = -lerpedPosition.x
    --         point.position.y = lerpedPosition.z
    --         point.position.z = lerpedPosition.y
    --         point.index = i - 1 --Original MapData json files are 0-indexed
    --         table.insert(points, point)

    --         -- local part = Instance.new("Part")
    --         -- part.Size = Vector3.new(0.25, 0.25, 0.25)
    --         -- part.Color = Color3.new(1,0,0)
    --         -- part.Anchored = true
    --         -- part.CFrame = CFrame.new(lerpedPosition + Vector3.new(0,0.5,0))
    --         -- part.Parent = beltFolder
    --     end
    --     local beltKey = ('["%s"]'):format(belt.name) --Format this so when we write to MapData Source the keys show up with quotes around them
    --     conveyorBeltData[beltKey] = points
    -- end

    -- MapData.write(conveyorBeltData, map.scene)
end

return Scene
