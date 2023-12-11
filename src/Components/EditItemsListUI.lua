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
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

local TextInputModal = require(script.Parent.Modals.TextInputModal)
local SmallButtonWithLabel = require(script.Parent.SubComponents.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SubComponents.SmallLabel)
local SidePanel = require(script.Parent.SubComponents.SidePanel)
local ListItemButton = require(script.Parent.SubComponents.ListItemButton)

local Dataset = require(script.Parent.Parent.Dataset)
local Scene = require(script.Parent.Parent.Scene)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Parent.Helpers.add)
type Props = {
    CurrentMapIndex: number,
    Items: table,
    ShowEditItemPanel: (string) -> nil,
    OnClosePanel: () -> nil,
    UpdateDataset: (table) -> nil,
    OnItemDeleteClicked: (string) -> nil,
}

local function EditItemsListUI(props: Props)
    --use this to create a consistent layout order that plays nice with Roact
    local index = 0
    local incrementLayoutOrder = function()
        index = index + 1
        return index
    end

    local items = props.Items
    local children = {}

    add(
        children,
        Button({
            Label = "Add Item",
            TextXAlignment = Enum.TextXAlignment.Center,
            OnActivated = function()
                local newItem = Dataset:addItem()
                props.UpdateDataset()
                props.ShowEditItemPanel(newItem["id"])
            end,
            Size = UDim2.fromScale(1, 0),
        })
    )

    local itemIndex = 1
    local itemKeys = Dash.keys(Dataset:getValidItems(items))
    table.sort(itemKeys, function(a, b) --Do this to make sure buttons show in alphabetical order
        return a:lower() < b:lower()
    end)
    for i, key in itemKeys do
        add(
            children,
            ListItemButton({
                CanDelete = true,
                Index = itemIndex,
                Image = items[key]["thumb"],
                ObjectToEdit = items[key],
                Label = items[key]["id"],
                LayoutOrder = incrementLayoutOrder(),
                OnSwapButtonClicked = Dash.noop(),
                OnEditButtonClicked = function(val)
                    props.ShowEditItemPanel(val)
                end,
                OnDeleteButtonClicked = function()
                    props.OnItemDeleteClicked(key)
                end,
                CanSwap = false,
            })
        )
        itemIndex += 1
    end

    return React.createElement(React.Fragment, nil, {
        SidePanel({
            Title = "Edit Items List",
            ShowClose = true,
            OnClosePanel = props.OnClosePanel,
        }, children),
    })
end

return function(props)
    return React.createElement(EditItemsListUI, props)
end
