local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Dash = require(Packages.Dash)
local Block = FishBloxComponents.Block
local Row = FishBloxComponents.Row
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
local Manifest = require(script.Parent.Parent.Manifest)
local Types = require(script.Parent.Parent.Types)
local MachineListItem = require(script.Parent.SubComponents.MachineListItem)
local Incrementer = require(script.Parent.Parent.Incrementer)
local LabeledAddButton = require(script.Parent.SubComponents.LabeledAddButton)
local ItemListItem = require(script.Parent.SubComponents.ItemListItem)

local layoutOrder = Incrementer.new()
type Props = {
    Items: any,
    OnClosePanel: () -> nil,
    OnChooseItem: (Types.Item) -> nil,
    OnClickEdit: (Types.Item) -> nil,
    UpdateDataset: () -> nil,
}

local function SelectItemUI(props: Props)
    --use this to create a consistent layout order that plays nice with Roact
    local layoutOrder = Incrementer.new()

    local scrollingFrameChildren = {
        uIPadding = React.createElement("UIPadding", {
            PaddingBottom = UDim.new(0, 80),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            PaddingTop = UDim.new(0, 8),
        }),

        uIListLayout = React.createElement("UIListLayout", {
            Padding = UDim.new(0, 12),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    }

    local itemChoices = {}
    for itemKey, item in props.Items do
        table.insert(
            itemChoices,
            ItemListItem({
                HideArrows = true,
                Item = item,
                Label = item.locName,
                LayoutOrder = layoutOrder:Increment(),
                Thumbnail = item.thumb,

                OnClickEdit = function(itemToEdit: Types.Item)
                    props.OnClickEditItem(itemToEdit)
                end,
                OnClickRemove = function(itemToRemove)
                    Dataset:removeItem(itemToRemove.id)
                    props.UpdateDataset()
                end,
                OnActivated = function(itemChosen: Types.Item)
                    Dataset:addOutputToMachine(props.SelectedMachine, itemChosen)
                    props.UpdateDataset()
                    props.OnClosePanel()
                end,
            })
        )
    end

    scrollingFrameChildren = Dash.join(scrollingFrameChildren, itemChoices)

    local children = {
        AddItem = LabeledAddButton({
            LayoutOrder = layoutOrder:Increment(),
            Label = "Create New Item",

            OnActivated = function()
                Dataset:addItem()
                props.UpdateDataset()
            end,
        }),
        ScrollingList = React.createElement("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(),
            ScrollBarImageTransparency = 1,
            ScrollBarThickness = 4,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            VerticalScrollBarInset = Enum.ScrollBarInset.Always,
            Active = true,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            LayoutOrder = layoutOrder:Increment(),
        }, {
            frame = React.createElement("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 0),
            }, scrollingFrameChildren),
        }),
    }

    return React.createElement(React.Fragment, nil, {
        SidePanel({
            Gaps = 12,
            Title = "Select Item",
            ShowClose = true,
            OnClosePanel = props.OnClosePanel,
        }, children),
    })
end

return function(props: Props)
    return React.createElement(SelectItemUI, props)
end
