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
local SmallButtonWithLabel = require(script.Parent.SubComponents.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SubComponents.SmallLabel)
local SidePanel = require(script.Parent.SubComponents.SidePanel)

local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Constants = require(script.Parent.Parent.Constants)

local add = require(script.Parent.Parent.Helpers.add)
local SmallButton = require(script.Parent.SubComponents.SmallButton)
type Props = {
    Dataset:table,
    CurrentMap:table,
    CurrentMapIndex:number,
    Error:string,
    ShowError:(string),
    Title:string,
}

local function EditDatasetUI(props:Props)
    local currentMapIndex, setCurrentMapIndex = React.useState(props.CurrentMapIndex)

    local index = 0
    local incrementLayoutOrder = function()
        index = index + 1
        return index
    end

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
            LayoutOrder = incrementLayoutOrder(),
            OnActivated = props.ShowEditFactoryPanel,
            Size = buttonSize,
            TextXAlignment = Enum.TextXAlignment.Center,
        }))
        add(children, Button({
            Label = "Edit Machine List",
            LayoutOrder = incrementLayoutOrder(),
            OnActivated = props.ShowEditMachinesListUI,
            Size = buttonSize,
            TextXAlignment = Enum.TextXAlignment.Center,
        }))
        add(children, Button({
            Label = "Edit Items List",
            LayoutOrder = incrementLayoutOrder(),
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
            LayoutOrder = incrementLayoutOrder(),
            Size = UDim2.fromOffset(0, 40)
        }))

        if props.Error == Constants.Errors.None then
            add(children, Button({
                Label = "Export Dataset",
                LayoutOrder = incrementLayoutOrder(),
                OnActivated = props.ExportDataset,
                Size = buttonSize,
                TextXAlignment = Enum.TextXAlignment.Center,
            }))
        else
            add(children, Text({
                LayoutOrder = incrementLayoutOrder(),
                Text = props.Error.."!",
                Color = Color3.new(1,0,0),
                Size = UDim2.new(1, 0, 0, 10),
                TextXAlignment = Enum.TextXAlignment.Center,
            }))
            add(children, Text({
                LayoutOrder = incrementLayoutOrder(),
                Text = "You must fix this before exporting.",
                Color = Color3.new(1,0,0),
                Size = UDim2.new(1, 0, 0, 10),
                TextXAlignment = Enum.TextXAlignment.Center,
            }))
        end
    end
    
    add(children, Button({
        Label = "Import Dataset",
        LayoutOrder = incrementLayoutOrder(),
        OnActivated = props.ImportDataset,
        Size = buttonSize,
        TextXAlignment = Enum.TextXAlignment.Center,
    }))
    
    if datasetIsLoaded then

        add(children, SmallButton({
            Label = "Print Dataset to Console",
            LayoutOrder = incrementLayoutOrder(),
            OnActivated = function()
                print(Dash.pretty(dataset, {multiline = true, indent = "\t"}))
            end,
            Size = UDim2.new(.925,0,0,30),
            TextXAlignment = Enum.TextXAlignment.Center,
        }))
        add(children, SmallButton({
            Label = "Print Machines to Console",
            LayoutOrder = incrementLayoutOrder(),
            OnActivated = function()
                print(Dash.pretty(map["machines"], {multiline = true, indent = "\t"}))
            end,
            Size = UDim2.new(.925,0,0,30),
            TextXAlignment = Enum.TextXAlignment.Center,
        }))
        add(children, SmallButton({
            Label = "Print Items to Console",
            LayoutOrder = incrementLayoutOrder(),
            OnActivated = function()
                print(Dash.pretty(map["items"], {multiline = true, indent = "\t"}))
            end,
            Size = UDim2.new(.925,0,0,30),
            TextXAlignment = Enum.TextXAlignment.Center,
        }))
    end

    return SidePanel({
        ShowClose = false,
        Title = props.Title
        }, children
    )
end

return function(props)
    return React.createElement(EditDatasetUI, props)
end
