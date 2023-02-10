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
local SelectFromListModal = require(script.Parent.Modals.SelectFromListModal)
local SmallButtonWithLabel = require(script.Parent.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SmallLabel)
local SidePanel = require(script.Parent.SidePanel)
local SmallButton = require(script.Parent.SmallButton)

local Dataset = require(script.Parent.Parent.Dataset)
local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Helpers.add)
local getMachineFromCoordinates = require(script.Parent.Helpers.getMachineFromCoordinates)

type Props = {

}

local function EditItemUI(props: Props)
    local modalEnabled, setModalEnabled = React.useState(false)
    local listModalEnabled, setListModalEnabled = React.useState(false)
    local listChoices, setListChoices = React.useState({})
    local currentFieldKey, setCurrentFieldKey = React.useState(nil)
    local currentFieldValue, setCurrentFieldValue = React.useState(nil)
    local currentFieldCallback, setCurrentFieldCallback = React.useState(nil)
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

    local createListModalButton = function(key:string | number, list:table, choices:table, callback:any)

        return SmallButtonWithLabel({
            Appearance = "Filled",
            ButtonLabel = tostring(list[key]),
            Label = key..": ",
            LayoutOrder = incrementLayoutOrder(),

            OnActivated = function()
                setListModalEnabled(true)
                setListChoices(choices)
                setCurrentFieldKey(key)
                setCurrentFieldValue(list[key])
                setCurrentFieldCallback(function()
                    return function(newValue)
                        list[key] = newValue

                        --Callback for additional special case functionality
                        if callback then
                            callback(newValue)
                        end
                    end
                end)
            end
        })
    end

    local children = {}
    local item = props.Item
    add(children, createTextChangingButton("id", item))
    add(children, createTextChangingButton("locName", item))
    add(children, createTextChangingButton("thumb", item))

    --REQUIREMENTS
    --Create a list of requirements to choose from, but omit items that are already used, or is the current item.
    local itemRequirementChoices = table.clone(items)
    for _,outputItem in item["requirements"] do
        local id = outputItem["itemId"]
        itemRequirementChoices[id] = nil
    end
    itemRequirementChoices[item["id"]] = nil

    add(children, SmallLabel({Label = "requirements:", LayoutOrder = incrementLayoutOrder()}))
    if item["requirements"] then
        for i,requirement in item["requirements"] do
            add(children, createListModalButton("itemId", requirement, items, Dash.noop))
            add(children, createTextChangingButton("count", requirement, true))
            add(children, SmallButton({
                Label = "Delete",
                LayoutOrder = incrementLayoutOrder(),
                OnActivated = function()
                    table.remove(item["requirements"], i)
                    props.UpdateDataset(dataset)
                end
            }))
        end
    end
    add(children, SmallButton({
        Appearance = "Filled",
        Label = "Add New Requirement Item",
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
        end
    }))

    add(children, SmallLabel({Label = "value:", LayoutOrder = incrementLayoutOrder()}))
    if item["value"] and item["value"]["itemId"] then
        add(children, createTextChangingButton("itemId", item["value"]))
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
            Title = props.Item["id"],
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