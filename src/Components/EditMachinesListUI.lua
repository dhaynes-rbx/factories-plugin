local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Packages
local Dash = require(Packages.Dash)
local React = require(Packages.React)
local Roact = require(Packages.Roact)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Block = FishBloxComponents.Block
local Button = FishBloxComponents.Button
local Column = FishBloxComponents.Column
local Gap = FishBloxComponents.Gap
local Panel = FishBloxComponents.Panel
local Row = FishBloxComponents.Row
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

local Modal = require(script.Parent.Modal)
local SmallButtonWithLabel = require(script.Parent.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SmallLabel)
local SidePanel = require(script.Parent.SidePanel)
local ListItemRow = require(script.Parent.ListItemRow)

local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Helpers.add)
local getMachineFromCoordinates = require(script.Parent.Helpers.getMachineFromCoordinates)

type Props = {}

local function EditMachinesListUI(props: Props)
	local datasetIsLoaded = props.Dataset ~= nil and props.Dataset ~= "NONE"
	local dataset = props.Dataset
	local map = datasetIsLoaded and dataset.maps[2] or nil

	local children = {}
	add(
		children,
		Button({
			Label = "Add Machine",
			TextXAlignment = Enum.TextXAlignment.Center,
			OnActivated = function()
				print("Add Machine")
			end,
			Size = UDim2.fromScale(1, 0),
		})
	)
	for i, v in map["machines"] do
        local x = tonumber(v["coordinates"]["X"])
        local y = tonumber(v["coordinates"]["Y"])
        assert((x or y), "Machine coordinate error in data!")
        local machineAnchor = Scene.getMachineAnchor(x,y)
        local showError: boolean = not Scene.isMachine(machineAnchor)
        local errorText: string = showError and "Cannot find corresponding Machine Anchor ("..x..","..y..")!"

		add(children, ListItemRow({
			ButtonLabel = "Edit",
			ErrorText = errorText,
			Label = v.id,
			Machine = v,
			MachineAnchor = machineAnchor,
			OnMachineEditClicked = props.OnMachineEditClicked
		}))

		local outputStr = "outputs: "
		for j,output in v["outputs"] do
			local separator = j > 1 and ", " or ""
			outputStr = outputStr..separator..output
		end
		add(children, SmallLabel({
			Bold = false,
			FontSize = 16,
			Label = outputStr
		}))	
		add(children, SmallLabel({
			Label = "destination machines: "
		}))
		
	end

	return SidePanel({
		Title = "Edit Machines List",
		ShowClose = true,
		OnClosePanel = props.OnClosePanel,
	}, children)
end

return function(props)
	return React.createElement(EditMachinesListUI, props)
end
