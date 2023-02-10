local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")
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

local TextInputModal = require(script.Parent.Modals.TextInputModal)
local SmallButtonWithLabel = require(script.Parent.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SmallLabel)
local SidePanel = require(script.Parent.SidePanel)
local MachineListItem = require(script.Parent.MachineListItem)

local Dataset = require(script.Parent.Parent.Dataset)
local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Helpers.add)
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
				--check for duplicate id and coordinates
				table.insert(map["machines"], newMachine)
				
				local anchor = Scene.instantiateMachineAnchor(newMachine)
				props.OnMachineEditClicked(newMachine, anchor)
				props.UpdateDataset(dataset)
			end,
			Size = UDim2.fromScale(1, 0),
		})
	)

	local machines = map["machines"]
	table.sort(machines, function(a,b)  --Do this to make sure buttons show in alphabetical order
        return a["id"]:lower() < b["id"]:lower()
    end)

	for i, machine in machines do
		
		add(children, MachineListItem({
			ButtonLabel = "Edit",
			Label = i..": "..machine["id"],
			Machine = machine,

			FixMissingMachineAnchor = function(machineObj)
				local anchor = Scene.instantiateMachineAnchor(machineObj)
				props.UpdateDataset(dataset)
                Selection:Set({anchor})
			end,
			OnDeleteMachineClicked = function(machineObj)
				Dataset:removeMachine(machineObj["id"])
				Scene.removeMachineAnchor(machineObj)
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
