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
local Row = FishBloxComponents.Row
local Gap = FishBloxComponents.Gap
local Panel = FishBloxComponents.Panel
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

local TextInputModal = require(script.Parent.Modals.TextInputModal)
local SelectFromListModal = require(script.Parent.Modals.SelectFromListModal)
local SmallButtonWithLabel = require(script.Parent.SubComponents.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SubComponents.SmallLabel)
local SidePanel = require(script.Parent.SubComponents.SidePanel)
local SmallButton = require(script.Parent.SubComponents.SmallButton)
local ListItemButton = require(script.Parent.SubComponents.ListItemButton)

local Dataset = require(script.Parent.Parent.Dataset)
local Manifest = require(script.Parent.Parent.Manifest)
local Scene = require(script.Parent.Parent.Scene)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Parent.Helpers.add)
local Separator = require(script.Parent.SubComponents.Separator)
local LabelWithAdd = require(script.Parent.SubComponents.LabelWithAdd)
local FormatText = require(script.Parent.Parent.FormatText)
local TextItem = require(script.Parent.SubComponents.TextItem)
local Incrementer = require(script.Parent.Parent.Incrementer)
local InlineThumbnailSelect = require(script.Parent.SubComponents.InlineThumbnailSelect)
local Types = require(script.Parent.Parent.Types)
local InlineNumberInput = require(script.Parent.SubComponents.InlineNumberInput)
type Props = {
    CurrentMapIndex: number,
    Dataset: table,
    Item: Types.Item,
    OnClosePanel: any,
    OnDeleteRequirementClicked: any,
    ShowEditItemPanel: () -> nil,
    OnClickThumbnail: () -> nil,
    UpdateDataset: () -> nil,
}

local function EditItemUI(props: Props)
    local itemId, setItemId = React.useState(props.Item.id)

    local item: Types.Item = props.Dataset.maps[props.CurrentMapIndex].items[itemId]

    local layoutOrder = Incrementer.new()
    local children = {
        ID = TextItem({
            Text = "ID: " .. item.id,
            LayoutOrder = layoutOrder:Increment(),
            OnActivate = function(input)
                print(Dash.pretty(item, { multiline = true, indent = "\t", depth = 10 }))
            end,
        }),

        LocName = FishBloxComponents.TextInput({
            HideLabel = true,
            LayoutOrder = layoutOrder:Increment(),
            Placeholder = "Enter Localized Name",
            Size = UDim2.new(1, 0, 0, 50),
            Value = item.locName,
            --Events
            OnChanged = function(text)
                local newText = text
                --prevent the id from being empty
                if #text < 1 then
                    return
                end
                --Check for invalid characters
                --Auto update ID based on LocName
                local updated, newItem = Dataset:updateItemId(item, FormatText.convertToIdText(newText))
                if updated then
                    newItem.locName = newText
                    setItemId(newItem.id)
                    props.UpdateSelectedItem(newItem)
                    props.UpdateDataset()
                end
            end,
        }),

        ThumbnailSelect = InlineThumbnailSelect({
            Label = "Thumbnail",
            Thumbnail = item.thumb,
            OnActivated = function()
                props.OnClickThumbnail()
            end,
        }),

        MinOutput = InlineNumberInput({
            LayoutOrder = layoutOrder:Increment(),
            Label = "Sale Price",
            OnReset = function() end,
            OnChanged = function() end,
            Value = item.value,
        }),
    }

    return React.createElement(React.Fragment, {}, {
        EditMachineUI = SidePanel({
            OnClosePanel = props.OnClosePanel,
            ShowClose = true,
            Title = "Editing Machine",
        }, children),
    })
end

return function(props)
    return React.createElement(EditItemUI, props)
end
