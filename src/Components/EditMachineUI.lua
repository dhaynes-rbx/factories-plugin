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
local getCoordinatesFromAnchorName = require(script.Parent.Helpers.getCoordinatesFromAnchorName)

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
    local map = props.CurrentMap

    --use this to create a consistent layout order that plays nice with Roact
    local index = 0
    local incrementLayoutOrder = function()
        index = index + 1
        return index
    end

    local createTextChangingButton = function(key:string | number, object:table, isNumber:boolean)
        return SmallButtonWithLabel({
            ButtonLabel = tostring(object[key]),
            Label = key..": ",
            LayoutOrder = incrementLayoutOrder(),
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
                        local previousValue = object[key]
                        object[key] = value
                        
                        --if the value being changed is a Machine's coordinates, then we need to update the MachineAnchor's name as well.
                        --This is because when you select a MachineAnchor, it uses the Name to query which Machine the anchor refers to.
                        if key == "X" or key == "Y" then
                            local prevX = object["X"]
                            local prevY = object["Y"]
                            if key == "X" and object["X"] ~= previousValue then
                                prevX = previousValue
                            elseif key == "Y" and object["Y"] ~= previousValue then
                                prevY = previousValue
                            end
                            
                            --Get the anchor based on the previous coordinates
                            local machineAnchor = Scene.getMachineAnchor(prevX, prevY)
                            machineAnchor.Name = "("..tostring(object["X"])..","..tostring(object["Y"])..")"
                        end

                        setModalEnabled(false)
                        Studio.setSelectionTool()
                    end
                end)
            end,
        })
    end

    local machine = props.Machine
    local coordinateName = machine["coordinates"]["X"]..","..machine["coordinates"]["Y"]

    local children = {}

    if datasetIsLoaded and machine then
        add(children, createTextChangingButton("id", machine))
        add(children, createTextChangingButton("type", machine))
        add(children, createTextChangingButton("locName", machine))
        add(children, SmallLabel({Label = "coordinates", LayoutOrder = incrementLayoutOrder()}))
        add(children, createTextChangingButton("X", machine["coordinates"], true))
        add(children, createTextChangingButton("Y", machine["coordinates"], true))

        add(children, SmallLabel({Label = "outputs", LayoutOrder = incrementLayoutOrder()}))
        for i,_ in machine["outputs"] do
            add(children, createTextChangingButton(i, machine["outputs"]))
        end

        if machine["sources"] then
            add(children, SmallLabel({Label = "sources", LayoutOrder = incrementLayoutOrder()}))
            for i,_ in machine["sources"] do
                add(children, createTextChangingButton(i, machine["sources"]))
            end    
        end
        add(children, Block({LayoutOrder = incrementLayoutOrder(), Size = UDim2.new(1, 0, 0, 50)}))
        add(children, createTextChangingButton("defaultProductionDelay", machine, true))
        add(children, createTextChangingButton("defaultMaxStorage", machine, true))
        add(children, createTextChangingButton("currentOutputCount", machine, true))
        add(children, SmallLabel({Label = "outputRange", LayoutOrder = incrementLayoutOrder()}))
        add(children, createTextChangingButton("min", machine["outputRange"], true))
        add(children, createTextChangingButton("max", machine["outputRange"], true))
        add(children, SmallLabel({Label = "supportsPowerups: "..tostring(machine["supportsPowerup"]), LayoutOrder = incrementLayoutOrder()}))
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
            Title = "Edit Machine "..coordinateName
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