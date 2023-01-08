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
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Helpers.add)
local getMachineFromCoordinates = require(script.Parent.Helpers.getMachineFromCoordinates)
local getCoordinatesFromName = require(script.Parent.Helpers.getCoordinatesFromName)

type Props = {

}

return function(props:Props)

    local modalEnabled, setModalEnabled = React.useState(false)
    local currentFieldKey, setCurrentFieldKey = React.useState(nil)
    local currentFieldValue, setCurrentFieldValue = React.useState(nil)
    local currentFieldCallback, setCurrentFieldCallback = React.useState(nil)
    local valueType, setValueType = React.useState(nil)

    local datasetIsLoaded = props.Dataset ~= nil and props.Dataset ~= "NONE"
    local dataset = props.Dataset
    local map = datasetIsLoaded and dataset.maps[2] or nil

    local createTextChangingButton = function(key, object, isNumber)
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
                        
                        --if the value being changed is a Machine's coordinates, then we need to update the MachineAnchor's name as well.
                        --This is because when you select a MachineAnchor, it uses the Name to query which Machine the anchor refers to.
                        if props.MachineAnchor and (key == "X" or key == "Y") then
                            props.MachineAnchor.Name = "("..tostring(object["X"])..","..tostring(object["Y"])..")"
                        end

                        setModalEnabled(false)
                        Studio.setSelectionTool()
                    end
                end)
            end,
        })
    end

    local name = props.MachineAnchor.Name
    local x, y = getCoordinatesFromName(name)
    local machine = getMachineFromCoordinates(x, y, map)

    local children = {}

    -- print("Machine", machine)
    -- print("Map", map)

    if datasetIsLoaded and machine then
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

    if not machine then
        add(children, Text({
            Color = Color3.new(1, 0, 0),
            FontSize = 24,
            Text = "Error: Machine Anchor "..props.MachineAnchor.Name.." does not have corresponding machine data in this dataset!",
        }))
    end


    return React.createElement(React.Fragment, nil, {
        EditMachineUI = SidePanel({
            OnClosePanel = props.OnClosePanel,
            ShowClose = true,
            Title = "Edit Machine "..props.MachineAnchor.Name
        }, children),

        Modal = modalEnabled and Modal({
            Key = currentFieldKey,
            OnConfirm = function(value)
                currentFieldCallback(value)
                --Make sure to change the name of the machine.

                props.UpdateDataset(dataset)
            end,
            OnClosePanel = function()
                setModalEnabled(false)
                setCurrentFieldKey(nil)
                setCurrentFieldValue(nil)
                setCurrentFieldCallback(nil)
            end,
            Value = currentFieldValue,
            ValueType = valueType,
        }),
    })
end