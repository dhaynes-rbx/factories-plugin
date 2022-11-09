if game:GetService("RunService"):IsRunMode() then return end
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local CoreGui = game:GetService("CoreGui")
local Maid = require(script.Parent.Maid).new()

-- Create a new toolbar section titled "Custom Script Tools"
local toolbar = plugin:CreateToolbar("AT-Factories")

-- Add a toolbar button named "Create Empty Script"
local button = toolbar:CreateButton("Factories", "Start", "rbxassetid://4458901886")

-- Make button clickable even if 3D viewport is hidden
button.ClickableWhenViewportHidden = true

-- local active = false
-- local mouse = nil

-- local factoryLayoutFolder = game.Workspace.Scene.FactoryLayout
-- local machinesFolder = factoryLayoutFolder.Machines
-- local beltsFolder = factoryLayoutFolder.Belts

-- local function createGuiFolder()
-- 	local coreGui = game:GetService("CoreGui")
	
-- 	if coreGui:FindFirstChild("ConveyorBeltPlugin") then
-- 		coreGui:FindFirstChild("ConveyorBeltPlugin"):Destroy()
-- 	end
	
-- 	local folder = Instance.new("Folder")
-- 	folder.Name = "ConveyorBeltPlugin"
-- 	folder.Parent = coreGui
-- 	return folder
-- end


-- local guiFolder = nil
-- local startingAdornment = nil
-- local endingAdornment = nil
-- local connectingAdornment = nil
-- local mousePart = nil

-- local function onDrawBeltButtonClicked()
-- 	print("Plugin clicked.")
-- 	active = not active
-- 	if active then
-- 		print("Plugin activated")
-- 		plugin:Activate(true)
				
-- 		--Deselect everything
-- 		Selection:Set({})
		
-- 		local guiFolder = createGuiFolder()
		
-- 		startingAdornment = nil
-- 		endingAdornment = nil
-- 		connectingAdornment = nil
-- 		mousePart = nil
		
-- 		mouse = plugin:GetMouse()
-- 		local mouseMoveConnection = nil
-- 		local startingTarget = nil
-- 		local endingTarget = nil
		
-- 		mouse.Button1Down:Connect(function()
-- 			print("Mouse down!", mouse.Target)
-- 			startingTarget = mouse.Target
			
-- 			startingAdornment = Instance.new("BoxHandleAdornment")
-- 			startingAdornment.AlwaysOnTop = true
-- 			startingAdornment.AdornCullingMode = Enum.AdornCullingMode.Never
-- 			startingAdornment.Adornee = startingTarget
-- 			startingAdornment.Parent = guiFolder
			
-- 			endingTarget = nil
-- 			mouseMoveConnection = mouse.Move:Connect(function()
-- 				if mouse.Target ~= startingTarget then
-- 					if not mousePart then
-- 						mousePart = Instance.new("Part")
-- 						mousePart.Transparency = 0.8
-- 						mousePart.CanCollide = false
-- 						mousePart.CanTouch = false
-- 						mousePart.CanQuery = false
-- 						mousePart.Anchored = true
-- 						mousePart.Size = Vector3.new(1,1,1)
-- 						mousePart.Parent = guiFolder
-- 						connectingAdornment = Instance.new("LineHandleAdornment")
-- 						connectingAdornment.AlwaysOnTop = true
-- 						connectingAdornment.AdornCullingMode = Enum.AdornCullingMode.Never
-- 						connectingAdornment.Visible = true
-- 						connectingAdornment.Thickness = 10
-- 						connectingAdornment.Parent = guiFolder
-- 					end
-- 					endingTarget = mouse.Target
-- 					connectingAdornment.Adornee = mousePart
-- 					if not endingAdornment then
-- 						endingAdornment = Instance.new("BoxHandleAdornment")
-- 						endingAdornment.AlwaysOnTop = true
-- 						endingAdornment.AdornCullingMode = Enum.AdornCullingMode.Never
-- 						endingAdornment.Parent = guiFolder
-- 					end
-- 					endingAdornment.Adornee = endingTarget
-- 				end
-- 				if mousePart and connectingAdornment then
-- 					local cframe = CFrame.lookAt(mouse.Hit.Position, startingTarget.Position)
-- 					mousePart:PivotTo(cframe)
-- 					--print(mousePart.Position)
-- 					local magnitude = math.abs((startingTarget.Position - mousePart.Position).Magnitude)
-- 					connectingAdornment.Length = magnitude 
-- 				end
-- 			end)
-- 		end)
		
-- 		mouse.Button1Up:Connect(function()
-- 			print("Mouse up!", mouse.Target)
-- 			if mouseMoveConnection then mouseMoveConnection:Disconnect() end
-- 		end)
-- 	else
-- 		print("Plugin deactivated")
-- 		startingAdornment = nil
-- 		endingAdornment = nil
-- 		connectingAdornment = nil
-- 		mousePart = nil
-- 		guiFolder:Destroy()
-- 	end

local function instantiateFactoriesSceneHierarchy()
    print("Instantiating new Factory scene")

    local function createScene()
        local scene = script.Parent.Assets.SceneHierarchy.Scene:Clone()
        scene.Parent = game.Workspace
        
        game.Workspace:SetAttribute("Factories", true)
        
        ChangeHistoryService:SetWaypoint("Instantiated Scene Hierarchy")
    end

    if game.Workspace:GetAttribute("Factories") ~= true then
        if not game.Workspace:FindFirstChild("Scene") then
            createScene()
        else
            warn("Folder named Scene already exists!")
        end
    elseif game.Workspace:GetAttribute("Factories") == true then
        if not game.Workspace:FindFirstChild("Scene") then
            createScene()
        end
        game.Workspace:SetAttribute("Factories", true)
    end
end


local function showPluginGui()
    local screenGui
    local folder = CoreGui:FindFirstChild("FactoriesPluginScreenGui")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "FactoriesPluginScreenGui"
        
        screenGui = script.Parent.Assets.ScreenGui:Clone()
        screenGui.Parent = folder
        
        folder.Parent = CoreGui
    else
        screenGui = folder.ScreenGui
    end
    screenGui.Enabled = true
    Maid:GiveTask(folder)
    
    local screenGuiButton:TextButton = screenGui.TextButton
    local connection = screenGuiButton.MouseButton1Click:Connect(instantiateFactoriesSceneHierarchy)
    Maid:GiveTask(connection)
end

local function cleanup()
    Maid:DoCleaning()
end

-- 	ChangeHistoryService:SetWaypoint("Did a thing")
-- end
local function initPlugin()
    if plugin:IsActivated() then
        plugin:Deactivate()
        cleanup()
        print("Plugin deactivated")
    else
        plugin:Activate(true)
        showPluginGui()
        print("Plugin activated")
    end
end
button.Click:Connect(initPlugin)

plugin.Unloading:Connect(function() 
    cleanup()
    print("Unloading Plugin")
end)
-- plugin.Deactivation:Connect(function() print("Plugin deactivated") end)
-- print("Plugin loaded")

