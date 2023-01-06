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

local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)

local add = require(script.Parent.Helpers.add)

local indentAmount = 40

return function(props)
    local modalEnabled, setModalEnabled = React.useState(false)
    local currentFieldKey, setCurrentFieldKey = React.useState(nil)
    local currentFieldValue, setCurrentFieldValue = React.useState(nil)
    local currentFieldCallback, setCurrentFieldCallback = React.useState(nil)
    local valueType, setValueType = React.useState(nil)

    local showDatasetInfoPanel, setShowDatasetInfoPanel = React.useState(false)

    local createTextChangingButton = function(key, object, layoutOrder, indent, isNumber)
        return SmallButtonWithLabel({
            ButtonLabel = tostring(object[key]),
            IndentAmount = indent,
            Label = key..": ",
            LayoutOrder = layoutOrder or 1,
            OnActivated = function()
                if isNumber then
                    setValueType("number")
                else
                    setValueType("string")
                end
                --set modal enabled
                setModalEnabled(true)
                setCurrentFieldKey(key)
                setCurrentFieldValue(object[key])
                setCurrentFieldCallback(function()
                    return function(value)
                        object[key] = value
                    end
                end)
            end,
        })
    end

    local datasetIsLoaded = props.Dataset ~= nil and props.Dataset ~= "NONE"
    local dataset = props.Dataset
    local map = datasetIsLoaded and dataset.maps[2] or nil

    local children = {

    }

    if datasetIsLoaded then

        children["scene"] = createTextChangingButton("scene", map, 0)
        children["id"] = createTextChangingButton("id", map, 1)
        children["locName"] = createTextChangingButton("locName", map, 2)
        -- children["locDesc"] = createTextChangingButton("locDesc", map, 3)
        -- children["thumb"] = createTextChangingButton("thumb", map, 4)
        children["stepsPerRun"] = createTextChangingButton("stepsPerRun", map, 5, 0, true)
        children["stepUnit"] = SmallLabel({Label = "stepUnit", LayoutOrder = 6})
        children["singular"] = createTextChangingButton("singular", map["stepUnit"], 7, indentAmount)
        children["plural"] = createTextChangingButton("plural", map["stepUnit"], 8, indentAmount)
        children["defaultInventory"] = SmallLabel({Label = "defaultInventory", LayoutOrder = 9})
        children["currency"] = createTextChangingButton("currency", map["defaultInventory"], 10, indentAmount, true)
        
    end

    local EditFactoryPanel = SidePanel({
        OnClosePanel = props.OnClosePanel,
        Title = "Edit Factory",
        ShowClose = true,
    }, children)

    return React.createElement(React.Fragment, nil, {
        EditFactoryPanel = EditFactoryPanel,
        Modal = modalEnabled and Modal({
            IsNumber = valueType,
            Key = currentFieldKey,
            Value = currentFieldValue,
            OnConfirm = function(value)
                setModalEnabled(false)
                currentFieldCallback(value)
                props.UpdateDataset(dataset)
            end,
            OnClosePanel = function()
                setModalEnabled(false)
                setCurrentFieldKey(nil)
                setCurrentFieldValue(nil)
                setCurrentFieldCallback(nil)
            end
        }),
    })
end