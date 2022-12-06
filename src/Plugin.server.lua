if game:GetService("RunService"):IsRunMode() then return end

local CoreGui = game:GetService("CoreGui")
local Selection = game:GetService("Selection")

local Maid = require(script.Parent.Maid).new()
local Packages = script.Parent.Packages
local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)

--Components
local PluginRoot = require(script.Parent.Components.PluginRoot)

local root = nil
local guiFolder = nil
local pluginIsInitialized = false

local function cleanup()
    if root then
        root:unmount()
    end

    Maid:DoCleaning()
end

local function initPlugin()
    if not pluginIsInitialized then
        plugin:Activate(false)
        
        guiFolder = CoreGui:FindFirstChild("FactoriesPluginScreenGui")
        if not guiFolder then
            guiFolder = Instance.new("Folder")
            guiFolder.Name = "FactoriesPluginScreenGui"
            guiFolder.Parent = CoreGui
        end
        Maid:GiveTask(guiFolder)
        
        root = ReactRoblox.createRoot(guiFolder)
        root:render(React.createElement(PluginRoot, {}))
        
        plugin:SelectRibbonTool(Enum.RibbonTool.Select, UDim2.new())

        pluginIsInitialized = true
        print("Factories Plugin activated")
    else
        cleanup()
        plugin:Deactivate()
        
        pluginIsInitialized = false
        print("Factories Plugin deactivated.")
    end
end

--Create plugin toolbar and button
local toolbar = plugin:CreateToolbar("AT-Factories")
local button = toolbar:CreateButton("Factories", "Start", "rbxassetid://4458901886")
button.ClickableWhenViewportHidden = true
button.Click:Connect(initPlugin)

plugin.Unloading:Connect(function() 
    cleanup()
    print("Unloading Plugin")
end)



-- local machines = {}
-- local function createMachine()
--     --Create a machine
--     local machineInfo:Types.Machine = {
--         model = nil,
--         type = "maker",
--     }

--     machineInfo.model = script.Parent.Assets.Machines.Maker:Clone()
--     machineInfo.model.Name = "New Machine"
--     machineInfo.model.CFrame = CFrame.new()
--     machineInfo.model.Parent = game.Workspace.Scene.FactoryLayout.
    

--     table.insert(machines, machineInfo)
-- end


-- local function cleanupConnections(connections)
--     for _, connection in connections do
--         if connection then
--             connection:Disconnect()
--             connection = nil
--         end
--     end
-- end

-- local function isMachine(obj)
--     return obj.Parent == game.Workspace.Scene.FactoryLayout.Machines
-- end

-- local prevTarget:BasePart = nil
-- local currentlySelectedPart:BasePart = nil
-- local function initPluginGui()
--     local screenGui
--     local folder = CoreGui:FindFirstChild("FactoriesPluginScreenGui")
--     if not folder then
--         folder = Instance.new("Folder")
--         folder.Name = "FactoriesPluginScreenGui"
        
--         screenGui = script.Parent.Assets.ScreenGui:Clone()
--         screenGui.Parent = folder
        
--         folder.Parent = CoreGui
--     else
--         screenGui = folder.ScreenGui
--     end
--     screenGui.Enabled = true
--     Maid:GiveTask(folder)
    
--     local initializeSceneButton:TextButton = screenGui.TextButton
--     Maid:GiveTask(initializeSceneButton.MouseButton1Click:Connect(instantiateFactoriesSceneHierarchy))

--     local addMachineButton:TextButton = screenGui.TextButton2
--     addMachineButton.Text = "Add Machine"
--     addMachineButton.MouseButton1Click:Connect(createMachine)
    
--     local selectMachineButton:TextButton = screenGui.TextButton3
--     selectMachineButton.Text = "Select Machine"
--     local mouseConnections = {}
--     Maid:GiveTask(selectMachineButton.MouseButton1Click:Connect(
--         function()
--             cleanupConnections(mouseConnections)

--             prevTarget = nil
--             local mouse = plugin:GetMouse()
--             plugin:Activate(true)
--             table.insert(mouseConnections, mouse.Button1Down:Connect(
--                 function() 
--                     if isMachine(mouse.Target) then
--                         print(mouse.Target.Name)
--                     end
--                 end
--             ))


--             table.insert(mouseConnections, mouse.Move:Connect(
--                 function()
--                     if isMachine(mouse.Target) then
--                         if mouse.Target ~= prevTarget then
--                             print("Machine hover: "..mouse.Target.Name)
--                             prevTarget = mouse.Target

--                             Selection:Set({mouse.Target})
--                         end
--                     end
--                 end
--             ))
--         end)
--     )
-- end





-- plugin.Deactivation:Connect(function() print("Plugin deactivated") end)
-- print("Plugin loaded")

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