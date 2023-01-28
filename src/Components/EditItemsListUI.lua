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

local Modal = require(script.Parent.Modal)
local SmallButtonWithLabel = require(script.Parent.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SmallLabel)
local SidePanel = require(script.Parent.SidePanel)
local ItemListItem = require(script.Parent.ItemListItem)

local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Helpers.add)
local getMachineFromCoordinates = require(script.Parent.Helpers.getMachineFromCoordinates)
local getTemplateItem = require(script.Parent.Helpers.getTemplateItem)

type Props = {

}

local function EditItemsListUI(props: Props)
    --use this to create a consistent layout order that plays nice with Roact
    local index = 0
    local getLayoutOrderIndex = function()
        index = index + 1
        return index
    end

    local dataset = props.Dataset
    local map = props.CurrentMap
    local children = {}

    add(children, Button({
        Label = "Add Item",
			TextXAlignment = Enum.TextXAlignment.Center,
			OnActivated = function()
                local items = map["items"]
				local newItem = getTemplateItem()
                local newItemId = newItem["id"]
                local duplicateIdCount = 0
                for _,item in items do
                    if item["id"] == newItemId then
                        duplicateIdCount += 1
                    end
                end
                newItemId = newItemId..tostring(duplicateIdCount)
                items[newItemId] = newItem
				props.UpdateDataset(dataset)
				props.ShowEditItemPanel(newItem["id"])
			end,
			Size = UDim2.fromScale(1, 0),
    }))

    local items = map["items"]
    local itemKeys = Dash.keys(items)
    table.sort(itemKeys, function(a,b)  --Do this to make sure buttons show in alphabetical order
        return a:lower() < b:lower()
    end)
    for i,itemKey in itemKeys do
        add(children, ItemListItem({
            Label = i..": "..itemKey,
            LayoutOrder = getLayoutOrderIndex(),
            
            OnEditButtonClicked = function()
                props.ShowEditItemPanel(itemKey)
            end,
            OnDeleteButtonClicked = function()
                print("Delete")
            end,
        }))
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