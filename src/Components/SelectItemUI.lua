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
    OnHover: (Model) -> nil,
    UpdateDataset: () -> nil,
}

local function SelectItemUI(props: Props)
    --use this to create a consistent layout order that plays nice with Roact
    local layoutOrder = Incrementer.new()

    local scrollingFrameChildren = {
        uIPadding = React.createElement("UIPadding", {
            PaddingBottom = UDim.new(0, #Dash.keys(props.Items) * 10),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 8),
        }),

        uIListLayout = React.createElement("UIListLayout", {
            Padding = UDim.new(0, 12),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    }

    local itemChoices = {}
    local sortedItemKeys = Dash.keys(props.Items)
    table.sort(sortedItemKeys, function(a, b)
        return props.Items[a].locName:lower() < props.Items[b].locName:lower()
    end)
    --Check the unused items. Change the visual appearance based on whether or not the item is available to be used.
    local availableItemKeys = Dash.keys(Dataset:getValidItems(true))
    local unavailableItemKeys = {}
    for i, itemKey in sortedItemKeys do
        local item = props.Items[itemKey]
        local unavailable = true
        for _, availableItem in availableItemKeys do
            if availableItem.id == item.id then
                unavailable = false
            end
        end
        if unavailable then
            table.insert(unavailableItemKeys, item.id)
        end
    end
    for _, key in availableItemKeys do
        local item = props.Items[key]
        if key == "currency" or key == "none" then
            continue
        end

        table.insert(
            itemChoices,
            ItemListItem({
                HideArrows = true,
                ShowTrashButton = true,
                Item = item,
                Label = item.locName,
                LayoutOrder = layoutOrder:Increment(),
                Thumbnail = item.thumb,
                -- Unavailable = false,

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
    for _, key in unavailableItemKeys do
        local item = props.Items[key]
        local skip = false
        for _, itemKey in availableItemKeys do
            if itemKey == key then
                skip = true
            end
        end
        if not skip then
            table.insert(
                itemChoices,
                ItemListItem({
                    HideArrows = true,

                    Item = item,
                    Label = item.locName,
                    LayoutOrder = layoutOrder:Increment(),
                    Thumbnail = item.thumb,
                    Unavailable = true,

                    OnClickEdit = function() end,
                    OnClickRemove = function() end,
                    OnActivated = function() end,
                    OnHover = function(anchor)
                        props.OnHover(anchor)
                    end,
                })
            )
        end
    end

    -- table.insert(
    --     itemChoices,
    --     ItemListItem({
    --         HideArrows = true,
    --         Item = item,
    --         Label = item.locName,
    --         LayoutOrder = layoutOrder:Increment(),
    --         Thumbnail = item.thumb,
    --         Unavailable = unavailable,

    --         OnClickEdit = not unavailable and function(itemToEdit: Types.Item)
    --             props.OnClickEditItem(itemToEdit)
    --         end,
    --         OnClickRemove = not unavailable and function(itemToRemove)
    --             Dataset:removeItem(itemToRemove.id)
    --             props.UpdateDataset()
    --         end,
    --         OnActivated = not unavailable and function(itemChosen: Types.Item)
    --             Dataset:addOutputToMachine(props.SelectedMachine, itemChosen)
    --             props.UpdateDataset()
    --             props.OnClosePanel()
    --         end,
    --     })
    -- )

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
