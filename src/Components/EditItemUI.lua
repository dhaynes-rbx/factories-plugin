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
local SelectFromListModal = require(script.Parent.SelectFromListModal)
local SmallButtonWithLabel = require(script.Parent.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SmallLabel)
local SidePanel = require(script.Parent.SidePanel)

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
                        print(Dash.pretty(itemObject, {multiline = true, indent = "\t"}))
                        print("Key: ", key)
                        local previousValue = itemObject[key]
                        print("Prev value: ", previousValue)
                        if newValue ~= previousValue then
                            itemObject[key] = newValue
                            --The "items" table is a dictionary. So the key needs to be replaced, as well as the contents.
                            if key == "id" then
                                items[newValue] = table.clone(items[previousValue])
                                items[newValue]["id"] = newValue
                                items[previousValue] = nil
    
                                for i,machine in machines do
                                    if machine["outputs"] then
                                        for j,output in machine["outputs"] do
                                            if output == previousValue then
                                                machines[i]["outputs"][j] = newValue
                                            end
                                        end
                                    end
                                end
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
    add(children, SmallLabel({Label = "requirements:", LayoutOrder = incrementLayoutOrder()}))
    if item["requirements"] then
        for i,requirement in item["requirements"] do
            add(children, createListModalButton("itemId", requirement, items, Dash.noop))
            add(children, createTextChangingButton("count", requirement, true))
        end
    end
    if item["value"] then
        add(children, SmallLabel({Label = "value:", LayoutOrder = incrementLayoutOrder()}))
        add(children, createTextChangingButton("itemId", item["value"]))
        add(children, createTextChangingButton("count", item["value"]))
    end


    return React.createElement(React.Fragment, nil, {
        SidePanel({
            Title = props.Item["id"],
            ShowClose = true,
            OnClosePanel = props.OnClosePanel,
        }, children),
        Modal = modalEnabled and Modal({
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