if game:GetService("RunService"):IsRunMode() then return end
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

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
	

-- 	ChangeHistoryService:SetWaypoint("Did a thing")
-- end
local function initPlugin()
    if plugin:IsActivated() then
        plugin:Deactivate()
    else
        plugin:Activate(true)
    end
    print("Is plugin activated?", plugin:IsActivated())
end
button.Click:Connect(initPlugin)

plugin.Unloading:Connect(function() print("Plugin unloading") end)
plugin.Deactivation:Connect(function() print("Plugin deactivated") end)
print("Plugin loaded")
-- plugin.Ready:Connect(function() print("Plugin is ready") end) --only accessible from coreScripts

