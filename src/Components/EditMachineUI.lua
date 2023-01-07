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

type Props = {

}

local function getMachineFromCoordinates(x, y, map)
    local machine = nil
    for _,v in map["machines"] do
        if v["coordinates"]["X"] == x and v["coordinates"]["Y"] == y then
            machine = v
        end
    end
    return machine
end

local callbacks = {}
return function(props:Props)

    local modalEnabled, setModalEnabled = React.useState(false)
    local currentFieldKey, setCurrentFieldKey = React.useState(nil)
    local currentFieldValue, setCurrentFieldValue = React.useState(nil)
    local currentFieldCallback, setCurrentFieldCallback = React.useState(nil)
    local valueType, setValueType = React.useState(nil)

    local datasetIsLoaded = props.Dataset ~= nil and props.Dataset ~= "NONE"
    local dataset = props.Dataset
    local map = datasetIsLoaded and dataset.maps[2] or nil

    callbacks.OnModalConfirm = function(value)
        setModalEnabled(false)
        currentFieldCallback(value)
        props.UpdateDataset(dataset)
    end
    callbacks.OnClosePanel = function()
        setModalEnabled(false)
        setCurrentFieldKey(nil)
        setCurrentFieldValue(nil)
        setCurrentFieldCallback(nil)
    end

    local createTextChangingButton = function(key, object, isNumber)
        print(key, object)
        return SmallButtonWithLabel({
            ButtonLabel = tostring(object[key]),
            Label = key..": ",
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

    local buttonSize = UDim2.new(1,0,0,0)

    local name = props.MachineAnchor.Name
    local x, y = table.unpack(string.split(string.sub(name, 2, #name - 1), ","))
    x = tonumber(x)
    y = tonumber(y)
    local machine = getMachineFromCoordinates(x, y, map)
    local machineFields = {}

    local children = {}

    if datasetIsLoaded then
        add(children, createTextChangingButton("id", machine))
        add(children, createTextChangingButton("type", machine))
        add(children, createTextChangingButton("defaultProductionDelay", machine, true))
        add(children, createTextChangingButton("defaultMaxStorage", machine, true))
        add(children, createTextChangingButton("currentOutputIndex", machine, true))
        add(children, createTextChangingButton("currentOutputCount", machine, true))
        add(children, SmallLabel({Label = "outputRange"}))
        add(children, createTextChangingButton("min", machine["outputRange"], true))
        add(children, createTextChangingButton("max", machine["outputRange"], true))
        add(children, SmallLabel({Label = "outputs"}))
        add(children, SmallLabel({Label = "coordinates"}))
        add(children, createTextChangingButton("X", machine["coordinates"], true))
        add(children, createTextChangingButton("Y", machine["coordinates"], true))
        add(children, SmallLabel({Label = "supportsPowerups: "..tostring(machine["supportsPowerups"])}))
    end

    return React.createElement(React.Fragment, nil, {
        EditMachineUI = SidePanel({
        OnClosePanel = props.OnClosePanel,
        ShowClose = true,
        Title = "Edit Machine "..props.MachineAnchor.Name
        }, children),

        Modal = modalEnabled and Modal({
            IsNumber = valueType,
            Key = currentFieldKey,
            Value = currentFieldValue,
            OnConfirm = function(value)
                props.UpdateDataset(dataset)
                setModalEnabled(false)
                currentFieldCallback(value)
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