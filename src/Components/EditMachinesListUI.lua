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
local MachineListItem = require(script.Parent.MachineListItem)

local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Helpers.add)
local getMachineFromCoordinates = require(script.Parent.Helpers.getMachineFromCoordinates)
local getTemplateMachine = require(script.Parent.Helpers.getTemplateMachine)

type Props = {}

local function EditMachinesListUI(props: Props)
	-- local datasetIsLoaded = props.Dataset ~= nil and props.Dataset ~= "NONE"
	local dataset = props.Dataset
	local map = props.CurrentMap

	local children = {}
	add(
		children,
		Button({
			Label = "Add Machine",
			TextXAlignment = Enum.TextXAlignment.Center,
			OnActivated = function()
				local newMachine = getTemplateMachine()
				table.insert(map["machines"], newMachine)
				props.UpdateDataset(dataset)
				props.AddMissingMachineAnchor(newMachine)
			end,
			Size = UDim2.fromScale(1, 0),
		})
	)
	for i, machine in map["machines"] do

		add(children, MachineListItem({
			ButtonLabel = "Edit",
			Label = machine["id"],
			Machine = machine,

			AddMissingMachineAnchor = function(machineObj)
				props.AddMissingMachineAnchor(machineObj)
			end,
			OnDeleteMachineClicked = function(machineObj)
				Scene.removeMachineAnchor(machineObj)
				table.remove(map["machines"], i)
				props.UpdateDataset(dataset)
			end,
			OnMachineEditClicked = function(machineObj, machineAnchor)
				props.OnMachineEditClicked(machineObj, machineAnchor)
			end
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
