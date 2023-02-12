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
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Parent.Helpers.add)
local Separator = require(script.Parent.SubComponents.Separator)
local LabelWithAdd = require(script.Parent.SubComponents.LabelWithAdd)
type Props = {
    CurrentMap:table,
    Dataset:table,
    Item:table,
    OnClosePanel:any,
    UpdateDataset:any,
    UpdateItem:any,
}

local function EditItemUI(props: Props)
    local currentFieldKey, setCurrentFieldKey = React.useState(nil)
    local currentFieldValue, setCurrentFieldValue = React.useState(nil)
    local currentFieldCallback, setCurrentFieldCallback = React.useState(nil)
    local listModalEnabled, setListModalEnabled = React.useState(false)
    local listChoices, setListChoices = React.useState({})
    local modalEnabled, setModalEnabled = React.useState(false)
    local showThumbnails, setShowThumbnails = React.useState(false)
    local valueType, setValueType = React.useState(nil)
    
    local dataset = props.Dataset
    local map = props.CurrentMap
    local machines = props.CurrentMap["machines"]
    local items = map["items"]

    --use this to create a consistent layout order that plays nice with Roact
    local index = 0
    local incrementLayoutOrder = function()
        index = index + 1
        return index
    end

    local createTextChangingButton = function(key:string, itemObject:table, isNumber:boolean)
        return SmallButtonWithLabel({
            ButtonLabel = tostring(itemObject[key]),
            Label = key,
            LayoutOrder = incrementLayoutOrder(),

            OnActivated = function()
                if isNumber then
                    setValueType("number")
                else
                    setValueType("string")
                end
                setModalEnabled(true)
                setCurrentFieldKey(key)
                setCurrentFieldValue(itemObject[key])
                setCurrentFieldCallback(function()
                    return function(newValue)
                        local previousValue = itemObject[key]
                        if newValue ~= previousValue then
                            itemObject[key] = newValue
                            --The "items" table is a dictionary. So the key needs to be replaced, as well as the contents.
                            if key == "id" then
                                Dataset:changeItemId(previousValue, newValue)
                                props.UpdateDataset(dataset)
                            end
                        end
                    end
                end)
            end,
        })
    end

    local createListModalButton = function(key:string | number, list:table, choices:table, showThumbnailImages:boolean)

        return SmallButtonWithLabel({
            Appearance = "Filled",
            ButtonLabel = tostring(list[key]),
            Label = key..": ",
            LayoutOrder = incrementLayoutOrder(),

            OnActivated = function()
                setListModalEnabled(true)
                setShowThumbnails(showThumbnailImages)
                setListChoices(choices)
                setCurrentFieldKey(key)
                setCurrentFieldValue(list[key])
                setCurrentFieldCallback(function()
                    return function(newValue)
                        list[key] = newValue
                    end
                end)
            end
        })
    end

    local children = {}
    local item = props.Item

    add(children, createTextChangingButton("id", item))
    add(children, createTextChangingButton("locName", item))
    local imageKeys = Dash.keys(Manifest.images)
    add(children, createListModalButton("thumb", item, imageKeys, false))
    add(children, Row({
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        LayoutOrder = incrementLayoutOrder(),
        Size = UDim2.new(1, 0, 0, 75)
    }, {
        Icon = React.createElement("ImageLabel", {
            AnchorPoint = Vector2.new(0.5,0.5),
            BackgroundTransparency = 1,
            Image = Manifest.images[props.Item["thumb"]],
            Size = UDim2.fromScale(1,1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
        })
    }))
    
    --REQUIREMENTS
    --Create a list of requirements to choose from, but omit items that are already used, or is the current item.
    local itemRequirementChoices = table.clone(items)
    if item["requirements"] then
        for _,outputItem in item["requirements"] do
            local id = outputItem["itemId"]
            itemRequirementChoices[id] = nil
        end
        itemRequirementChoices[item["id"]] = nil
    end

    add(children, Separator({LayoutOrder = incrementLayoutOrder()}))
    add(children, LabelWithAdd({
        Label = "requirements:",
        LayoutOrder = incrementLayoutOrder(),
        OnActivated = function()
            if not item["requirements"] then
                item["requirements"] = {}
            end
            setListModalEnabled(true)
            setListChoices(itemRequirementChoices)
            setCurrentFieldKey(nil)
            setCurrentFieldValue(nil)
            setCurrentFieldCallback(function()
                return function(newValue)
                    local newRequirementItem = {itemId = newValue, count = 0.2}
                    table.insert(item["requirements"], newRequirementItem)
                    props.UpdateDataset(dataset)
                end
            end)
        end,
    }))
    if item["requirements"] then
        for i,requirement in item["requirements"] do
            -- add(children, createListModalButton("itemId", requirement, items, false))
            add(children, ListItemButton({
                CanDelete = true,
                Image = items[requirement["itemId"]]["thumb"],
                Index = i,
                Label = requirement["itemId"],
                LayoutOrder = incrementLayoutOrder(),
                ObjectToEdit = items[requirement["itemId"]],
                OnDeleteButtonClicked = function(itemKey) 
                    props.OnDeleteRequirementClicked(
                        "Do you want to delete "..itemKey.." as a requirement for "..props.Item["id"].."?",
                        function()
                            table.remove(item["requirements"], i)
                        end
                    )
                end,
                OnEditButtonClicked = function(itemKey) 
                    props.ShowEditItemPanel(itemKey)
                end,
                OnSwapButtonClicked = function(itemKey) 
                    setListModalEnabled(true)
                    setListChoices(itemRequirementChoices)
                    setCurrentFieldKey(i)
                    setCurrentFieldValue(itemKey)
                    setCurrentFieldCallback(function()
                        return function(newValue)
                            item["requirements"][i] = {
                                itemId = newValue,
                                count = 0.2
                            }
                            props.UpdateDataset(props.Dataset)
                        end
                    end)
                end,
            }))
            add(children, createTextChangingButton("count", requirement, true))
        end
    end

    add(children, Separator({LayoutOrder = incrementLayoutOrder()}))
    add(children, SmallLabel({Label = "value:", LayoutOrder = incrementLayoutOrder()}))
    if item["value"] and item["value"]["itemId"] then
        -- add(children, createTextChangingButton("itemId", item["value"]))
        add(children, createTextChangingButton("count", item["value"]))
        add(children, SmallButton({
            Appearance = "Filled",
            Label = "Remove Value",
            LayoutOrder = incrementLayoutOrder(),
            OnActivated = function()
                item["value"] = nil
                props.UpdateDataset(dataset)
            end
        }))
    else
        add(children, Text({Text = "None", Color = Color3.new(1,1,1), LayoutOrder = incrementLayoutOrder()}))
        add(children, SmallButton({
            Appearance = "Filled",
            Label = "Add Value",
            LayoutOrder = incrementLayoutOrder(),
            OnActivated = function()
                item["value"] = {itemId = "currency", count = 0.2}
                props.UpdateDataset(dataset)
            end
        }))
    end

    return React.createElement(React.Fragment, nil, {
        SidePanel({
            Title = "Edit Item: "..props.Item["id"],
            ShowClose = true,
            OnClosePanel = props.OnClosePanel,
        }, children),
        Modal = modalEnabled and TextInputModal({
            Key = currentFieldKey,
            Value = currentFieldValue,
            ValueType = valueType,

            OnConfirm = function(value)
                currentFieldCallback(value)
                setModalEnabled(false)
                setCurrentFieldKey(nil)
                setCurrentFieldValue(nil)
                props.UpdateItem(value)
                props.UpdateDataset(dataset)
                Studio.setSelectionTool()
            end,
            OnClosePanel = function()
                setCurrentFieldCallback(nil)
                setModalEnabled(false)
                setCurrentFieldKey(nil)
                setCurrentFieldValue(nil)
                Studio.setSelectionTool()
            end,
        }),
        SelectFromListModal = listModalEnabled and SelectFromListModal({
            Choices = listChoices,
            Key = currentFieldKey,
            Value = currentFieldValue,
            ShowThumbnails = showThumbnails,

            OnConfirm = function(value)
                currentFieldCallback(value)
                setListModalEnabled(false)
                setCurrentFieldKey(nil)
                setCurrentFieldValue(nil)
                Studio.setSelectionTool()
                props.UpdateDataset(dataset)
            end,
            OnClosePanel = function()
                setCurrentFieldCallback(nil)
                setListModalEnabled(false)
                setCurrentFieldKey(nil)
                setCurrentFieldValue(nil)
                Studio.setSelectionTool()
            end,
        })
    })
end

return function(props)
    return React.createElement(EditItemUI, props)
end