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
local SidePanel = require(script.Parent.SidePanel)
local SmallButtonWithLabel = require(script.Parent.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SmallLabel)

local Constants = require(script.Parent.Parent.Constants)
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
    local listModalEnabled, setListModalEnabled = React.useState(false)
    local listChoices, setListChoices = React.useState({})
    local currentFieldKey, setCurrentFieldKey = React.useState(nil)
    local currentFieldValue, setCurrentFieldValue = React.useState(nil)
    local currentFieldCallback, setCurrentFieldCallback = React.useState(nil)
    local valueType, setValueType = React.useState(nil)

    local datasetIsLoaded = props.Dataset ~= nil and props.Dataset ~= "NONE"
    local dataset = props.Dataset
    local map = props.CurrentMap
    local machines = map["machines"]
    local items = map["items"]

    --use this to create a consistent layout order that plays nice with Roact
    local index = 0
    local incrementLayoutOrder = function()
        index = index + 1
        return index
    end

    local createTextChangingButton = function(key:string | number, machineObject:table, isNumber:boolean, filled:boolean)

        return SmallButtonWithLabel({
            Appearance = filled and "Filled",
            ButtonLabel = tostring(machineObject[key]),
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
                setCurrentFieldValue(machineObject[key])
                setCurrentFieldCallback(function()
                    return function(newValue)
                        local previousValue = machineObject[key]
                        machineObject[key] = newValue
                        
                        --if the value being changed is a Machine's coordinates, then we need to update the MachineAnchor's name as well.
                        --This is because when you select a MachineAnchor, it uses the Name to query which Machine the anchor refers to.
                        if key == "X" or key == "Y" then
                            local prevX = machineObject["X"]
                            local prevY = machineObject["Y"]
                            if key == "X" and machineObject["X"] ~= previousValue then
                                prevX = previousValue
                            elseif key == "Y" and machineObject["Y"] ~= previousValue then
                                prevY = previousValue
                            end
                            
                            --Get the anchor based on the previous coordinates
                            local machineAnchor = Scene.getMachineAnchor(prevX, prevY)
                            machineAnchor.Name = "("..tostring(machineObject["X"])..","..tostring(machineObject["Y"])..")"
                        elseif key == "id" then
                            --if we're changing the ID, we must also change it wherever it appears as a machine's source
                            for i,machine in machines do
                                if machine["sources"] then
                                    for j,source in machine["sources"] do
                                        if source == previousValue then
                                            machines[i]["sources"][j] = newValue
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
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

    local machine = props.Machine
    local coordinateName = machine and machine["coordinates"]["X"]..","..machine["coordinates"]["Y"] or props.MachineAnchor.Name
    local children = {}

    print(props.MachineAnchor, machine)
    
    if datasetIsLoaded and machine then
        local machineIds = {}
        for _,machineObj in machines do
            machineIds[machineObj["id"]] = machineObj["id"]
        end
        add(children, createTextChangingButton("id", machine))

        add(children, createListModalButton("type", machine, Constants.MachineTypes, function(assetKey) 
            machine["asset"] = Constants.MachineAssetPaths[assetKey]
        end)) --

        add(children, createTextChangingButton("locName", machine))
        add(children, SmallLabel({Label = "coordinates", LayoutOrder = incrementLayoutOrder()}))
        add(children, createTextChangingButton("X", machine["coordinates"], true))
        add(children, createTextChangingButton("Y", machine["coordinates"], true))

        add(children, SmallLabel({Label = "outputs", LayoutOrder = incrementLayoutOrder()}))
        for i,_ in machine["outputs"] do
            add(children, createListModalButton(i, machine["outputs"], items, Dash.noop)) --
        end

        if machine["sources"] then
            add(children, SmallLabel({Label = "sources", LayoutOrder = incrementLayoutOrder()}))
            for i,_ in machine["sources"] do
                -- add(children, createTextChangingButton(i, machine["sources"], false, true))
                add(children, createListModalButton(i, machine["sources"], machineIds, function(machineId)
                    print("Callback: ", machineId)
                end))
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
            Value = currentFieldValue,
            ValueType = valueType,

            OnConfirm = function(value)
                currentFieldCallback(value)
                setModalEnabled(false)
                setCurrentFieldKey(nil)
                setCurrentFieldValue(nil)
                Studio.setSelectionTool()
                props.UpdateDataset(dataset)
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