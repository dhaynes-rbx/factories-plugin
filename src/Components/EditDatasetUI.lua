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
local Constants = require(script.Parent.Parent.Constants)

local add = require(script.Parent.Parent.Helpers.add)
local SmallButton = require(script.Parent.SubComponents.SmallButton)
local DatasetInstance = require(script.Parent.Parent.DatasetInstance)
type Props = {
    Dataset: table,
    CurrentMap: table,
    CurrentMapIndex: number,
    Error: string,
    Title: string,
    -- UpdateDatasetName: any,
    UpdateSceneName: any,
    ShowEditFactoryUI: any,
    -- ShowEditMachinesListUI:any,
    ShowEditItemsListUI: any,
    ExportDataset: any,
    ImportDataset: any,
}

local function EditDatasetUI(props: Props)
    local currentMapIndex, setCurrentMapIndex = React.useState(props.CurrentMapIndex)

    local index = 0
    local incrementLayoutOrder = function()
        index = index + 1
        return index
    end

    local datasetIsLoaded = props.Dataset ~= nil and props.Dataset ~= "NONE"
    local dataset = props.Dataset
    local map = props.CurrentMap

    local buttonSize = UDim2.new(1, 0, 0, 0)

    local children = {}
    local maps = dataset["maps"]

    if datasetIsLoaded then
        local radioButtons = {}
        for i, choiceKey in maps do
            table.insert(radioButtons, {
                -- Choice = props.Choices[choiceKey],
                Label = maps[i]["id"],
                Value = i,
            })
        end

        add(
            children,
            TextInput({
                Label = "Dataset ID",
                LayoutOrder = incrementLayoutOrder(),
                Size = UDim2.new(1, 0, 0, 50),
                Value = DatasetInstance.getDatasetInstanceName(),
                OnChanged = function(value)
                    DatasetInstance.updateDatasetInstanceName(value)
                end,
            })
        )
        add(
            children,
            TextInput({
                Label = "Scene Name",
                LayoutOrder = incrementLayoutOrder(),
                Size = UDim2.new(1, 0, 0, 50),
                Value = map["scene"],
                OnChanged = props.UpdateSceneName,
            })
        )

        --TODO: Implement more robust map switching functionality.
        -- add(
        --     children,
        --     Block({
        --         Size = UDim2.new(1, 0, 0, 80),
        --         LayoutOrder = incrementLayoutOrder(),
        --         Corner = UDim.new(0, 8),
        --         BackgroundColor = Color3.new(1, 1, 1),
        --         BackgroundTransparency = 0.95,
        --         ZIndex = 2,
        --     }, {
        --         RadioButtonGroup({
        --             AsRow = true,
        --             Choices = radioButtons,
        --             CurrentValue = currentMapIndex,
        --             OnChanged = function(num, val)
        --                 setCurrentMapIndex(val)
        --                 props.SetCurrentMap(val)
        --             end,
        --         }),
        --     })
        -- )

        add(
            children,
            Button({
                Label = "Edit Factory",
                LayoutOrder = incrementLayoutOrder(),
                OnActivated = props.ShowEditFactoryUI,
                Size = buttonSize,
                TextXAlignment = Enum.TextXAlignment.Center,
            })
        )
        -- add(children, Button({
        --     Label = "Edit Machine List",
        --     LayoutOrder = incrementLayoutOrder(),
        --     OnActivated = props.ShowEditMachinesListUI,
        --     Size = buttonSize,
        --     TextXAlignment = Enum.TextXAlignment.Center,
        -- }))
        -- add(children, Button({
        --     Label = "Edit Items List",
        --     LayoutOrder = incrementLayoutOrder(),
        --     OnActivated = props.ShowEditItemsListUI,
        --     Size = buttonSize,
        --     TextXAlignment = Enum.TextXAlignment.Center,
        -- }))
        -- add(children, Button({
        --     Label = "Edit Powerups List",
        --     OnActivated = props.ShowEditPowerupsListUI,
        --     Size = buttonSize,
        --     TextXAlignment = Enum.TextXAlignment.Center,
        -- }))
        if props.Error == Constants.Errors.None then
            add(
                children,
                Button({
                    -- Active = false,
                    Label = "Export Dataset",
                    LayoutOrder = incrementLayoutOrder(),
                    OnActivated = props.ExportDataset,
                    Size = buttonSize,
                    TextXAlignment = Enum.TextXAlignment.Center,
                })
            )
            add(
                children,
                Button({
                    -- Active = false,
                    Label = "Export MapData",
                    LayoutOrder = incrementLayoutOrder(),
                    OnActivated = props.ExportMapData,
                    Size = buttonSize,
                    TextXAlignment = Enum.TextXAlignment.Center,
                })
            )
        else
            add(
                children,
                Text({
                    LayoutOrder = incrementLayoutOrder(),
                    Text = props.Error .. "!",
                    Color = Color3.new(1, 0, 0),
                    Size = UDim2.new(1, 0, 0, 10),
                    TextXAlignment = Enum.TextXAlignment.Center,
                })
            )
            add(
                children,
                Text({
                    LayoutOrder = incrementLayoutOrder(),
                    Text = "You must fix this before exporting.",
                    Color = Color3.new(1, 0, 0),
                    Size = UDim2.new(1, 0, 0, 10),
                    TextXAlignment = Enum.TextXAlignment.Center,
                })
            )
        end
    end

    -- add(
    --     children,
    --     Button({
    --         Label = "Import Dataset",
    --         LayoutOrder = incrementLayoutOrder(),
    --         OnActivated = props.ImportDataset,
    --         Size = buttonSize,
    --         TextXAlignment = Enum.TextXAlignment.Center,
    --     })
    -- )

    if datasetIsLoaded then
        add(
            children,
            SmallButton({
                Label = "Print Dataset to Console",
                LayoutOrder = incrementLayoutOrder(),
                OnActivated = function()
                    print(Dash.pretty(dataset, { multiline = true, indent = "\t", depth = 10 }))
                end,
                Size = UDim2.new(0.925, 0, 0, 30),
                TextXAlignment = Enum.TextXAlignment.Center,
            })
        )
        add(
            children,
            SmallButton({
                Label = "Print Machines to Console",
                LayoutOrder = incrementLayoutOrder(),
                OnActivated = function()
                    print(Dash.pretty(map["machines"], { multiline = true, indent = "\t", depth = 10 }))
                end,
                Size = UDim2.new(0.925, 0, 0, 30),
                TextXAlignment = Enum.TextXAlignment.Center,
            })
        )
        add(
            children,
            SmallButton({
                Label = "Print Items to Console",
                LayoutOrder = incrementLayoutOrder(),
                OnActivated = function()
                    print(Dash.pretty(map["items"], { multiline = true, indent = "\t", depth = 10 }))
                end,
                Size = UDim2.new(0.925, 0, 0, 30),
                TextXAlignment = Enum.TextXAlignment.Center,
            })
        )
    end

    return SidePanel({
        ShowClose = false,
        Title = props.Title,
    }, children)
end

return function(props)
    return React.createElement(EditDatasetUI, props)
end
