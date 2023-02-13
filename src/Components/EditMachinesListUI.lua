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
local SmallButton = require(script.Parent.SubComponents.SmallButton)
local SmallButtonWithLabel = require(script.Parent.SubComponents.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SubComponents.SmallLabel)
local SidePanel = require(script.Parent.SubComponents.SidePanel)
local MachineListItem = require(script.Parent.SubComponents.MachineListItem)

local Dataset = require(script.Parent.Parent.Dataset)
local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Parent.Helpers.add)
local getTemplateMachine = require(script.Parent.Parent.Helpers.getTemplateMachine)
local ListItemButton = require(script.Parent.SubComponents.ListItemButton)

type Props = {
	OnMachineDeleteClicked:any
}

local function EditMachinesListUI(props: Props)
	--use this to create a consistent layout order that plays nice with Roact
    local index = 0
    local incrementLayoutOrder = function()
        index = index + 1
        return index
    end

	local dataset = props.Dataset
	local map = props.CurrentMap

	local children = {}
	add(
		children,
		Button({
			Label = "Add Machine",
			TextXAlignment = Enum.TextXAlignment.Center,
			OnActivated = function()
				local newMachine = Dataset:addMachine()
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
		
		add(children, ListItemButton({
			CanDelete = true,
            CanEdit = true,
			CanSwap = false,
			HideIcon = true,
			Index = i,
			Label = machine["id"],
			LayoutOrder = incrementLayoutOrder(),
			ObjectToEdit = machine,
			OnDeleteButtonClicked = function(machineId)
				props.OnMachineDeleteClicked(machineId)
			end,
			OnEditButtonClicked = function(machineId)
				local machineObj = Dataset:getMachineFromId(machineId)
				local machineAnchor = Scene.getAnchorFromMachine(machineObj)
				props.OnMachineEditClicked(machineObj, machineAnchor)
			end,
			OnHover = function(machineObj:table)
				props.HighlightMachineAnchor(machineObj)
			end
		}))

		--There might be a case where a machine exists but the machine anchor is missing.
		local missingMachineAnchor = false
		if missingMachineAnchor then 
			add(children, SmallButton({
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = Color3.fromRGB(32, 117, 233),
				LayoutOrder = incrementLayoutOrder(),
				Size = UDim2.new(0, 30, 0, 30),
				Text = "Fix Missing Machine Anchor",
				TextXAlignment = Enum.TextXAlignment.Center,

				OnActivated = function()
					local anchor = Scene.instantiateMachineAnchor(machine)
					props.UpdateDataset(dataset)
					Selection:Set({anchor})
				end,
			}))
		end
		
		-- add(children, MachineListItem({
		-- 	ButtonLabel = "Edit",
		-- 	Label = i..": "..machine["id"],
		-- 	Machine = machine,

		-- 	FixMissingMachineAnchor = function(machineObj)
		-- 		local anchor = Scene.instantiateMachineAnchor(machineObj)
		-- 		props.UpdateDataset(dataset)
        --         Selection:Set({anchor})
		-- 	end,
		-- 	OnDeleteMachineClicked = function(machineObj)
		-- 		Dataset:removeMachine(machineObj["id"])
		-- 		Scene.removeMachineAnchor(machineObj)
		-- 		props.UpdateDataset(dataset)
		-- 	end,
		-- 	OnMachineEditClicked = function(machineObj, machineAnchor)
		-- 		props.OnMachineEditClicked(machineObj, machineAnchor)
		-- 	end
		-- }))
		
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
