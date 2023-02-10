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
local RadioButtonGroup = FishBloxComponents.RadioButtonGroup
local Row = FishBloxComponents.Row
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

local TextInputModal = require(script.Parent.Modals.TextInputModal)
local SmallButtonWithLabel = require(script.Parent.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SmallLabel)
local SidePanel = require(script.Parent.SidePanel)

local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)

local add = require(script.Parent.Helpers.add)

type Props = {

}

local function EditDatasetUI(props:Props)
    local currentMapIndex, setCurrentMapIndex = React.useState(props.CurrentMapIndex)

    local datasetIsLoaded = props.Dataset ~= nil and props.Dataset ~= "NONE"
    local dataset = props.Dataset
    local map = props.CurrentMap

    local buttonSize = UDim2.new(1,0,0,0)

    local children = {}
    local maps = dataset["maps"]
    local radioButtons = {}
    if datasetIsLoaded then
        for i,choiceKey in maps do
            table.insert(radioButtons, {
                -- Choice = props.Choices[choiceKey],
                Label = maps[i]["id"],
                Value = i,
            })
        end
    end

    if datasetIsLoaded then
        add(children, RadioButtonGroup({
            AsRow = true,
            Choices = radioButtons,
            CurrentValue = currentMapIndex,
            OnChanged = function(num, val)
                setCurrentMapIndex(val)
                props.SetCurrentMap(val)
            end
        }))
        add(children, Button({
            Label = "Edit Factory",
            OnActivated = props.ShowEditFactoryPanel,
            Size = buttonSize,
            TextXAlignment = Enum.TextXAlignment.Center,
        }))
        add(children, Button({
            Label = "Edit Machine List",
            OnActivated = props.ShowEditMachinesListUI,
            Size = buttonSize,
            TextXAlignment = Enum.TextXAlignment.Center,
        }))
        add(children, Button({
            Label = "Edit Items List",
            OnActivated = props.ShowEditItemsListUI,
            Size = buttonSize,
            TextXAlignment = Enum.TextXAlignment.Center,
        }))
        -- add(children, Button({
        --     Label = "Edit Powerups List",
        --     OnActivated = props.ShowEditPowerupsListUI,
        --     Size = buttonSize,
        --     TextXAlignment = Enum.TextXAlignment.Center,
        -- }))
        
        add(children, Block({
            Size = UDim2.fromOffset(0, 40)
        }))

        add(children, Button({
            Label = "Export Dataset",
            OnActivated = props.ExportDataset,
            Size = buttonSize,
            TextXAlignment = Enum.TextXAlignment.Center,
        }))
        add(children, Button({
            Label = "Print Dataset to Console",
            OnActivated = function()
                print(Dash.pretty(dataset, {multiline = true, indent = "\t"}))
            end,
            Size = buttonSize,
            TextXAlignment = Enum.TextXAlignment.Center,
        }))
        add(children, Button({
            Label = "Print Machines to Console",
            OnActivated = function()
                print(Dash.pretty(map["machines"], {multiline = true, indent = "\t"}))
            end,
            Size = buttonSize,
            TextXAlignment = Enum.TextXAlignment.Center,
        }))
        add(children, Button({
            Label = "Print Items to Console",
            OnActivated = function()
                print(Dash.pretty(map["items"], {multiline = true, indent = "\t"}))
            end,
            Size = buttonSize,
            TextXAlignment = Enum.TextXAlignment.Center,
        }))
        
    end

    add(children, Button({
        Label = "Import Dataset",
        OnActivated = props.ImportDataset,
        Size = buttonSize,
        TextXAlignment = Enum.TextXAlignment.Center,
    }))

    return SidePanel({
        ShowClose = false,
        Title = props.Title
        }, children
    )
end

return function(props)
    return React.createElement(EditDatasetUI, props)
end
