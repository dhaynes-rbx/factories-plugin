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
local SidePanel = require(script.Parent.SubComponents.SidePanel)
local SmallButtonWithLabel = require(script.Parent.SubComponents.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SubComponents.SmallLabel)
local SmallButton = require(script.Parent.SubComponents.SmallButton)
local MachineListItem = require(script.Parent.SubComponents.MachineListItem)
local ListItemButton = require(script.Parent.SubComponents.ListItemButton)

local Constants = require(script.Parent.Parent.Constants)
local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Parent.Helpers.add)
local Manifest = require(script.Parent.Parent.Manifest)
local Dataset = require(script.Parent.Parent.Dataset)
local LabelWithAdd = require(script.Parent.SubComponents.LabelWithAdd)
local Separator = require(script.Parent.SubComponents.Separator)


type Props = {
    AddMachineAnchor:any,
    CurrentMap:table,
    Dataset:table,
    Machine:table,
    MachineAnchor:Instance,
    OnClosePanel:any,
    UpdateDataset:any,
}

return function(props:Props)
    Studio.setSelectionTool()
    
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
    
    --When the machineAnchor is changed, we need to make sure that all modals are closed and canceled out.
    React.useEffect(function()
        return function()
            setCurrentFieldCallback(nil)
            setModalEnabled(false)
            setListModalEnabled(false)
            setCurrentFieldKey(nil)
            setCurrentFieldValue(nil)
            Studio.setSelectionTool()
        end
    end, {props.MachineAnchor})

    --use this to create a consistent layout order that plays nice with Roact
    local index = 0
    local incrementLayoutOrder = function()
        index = index + 1
        return index
    end

    local createTextChangingButton = function(key:string | number, object:table, isNumber:boolean, filled:boolean)
        return SmallButtonWithLabel({
            Appearance = filled and "Filled",
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
                    return function(newValue)
                        local previousValue = object[key]
                        if previousValue == newValue then
                            return
                        end
                        
                        if key == "id" then
                            object[key] = Dataset:resolveDuplicateId(newValue, machines)
                            --if we're changing the ID, we must also change it wherever it appears as another machine's source
                            for i,machine in machines do
                                if machine["sources"] then
                                    for j,source in machine["sources"] do
                                        if source == previousValue then
                                            machines[i]["sources"][j] = newValue
                                        end
                                    end
                                end
                            end
                        elseif key == "X" or key == "Y" then
                            props.MachineAnchor.Name = "("..tostring(object["X"])..","..tostring(object["Y"])..")"
                            object[key] = newValue
                        else
                            object[key] = newValue
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
    local children = {}
    -- local coordinateName = machine and machine["coordinates"]["X"]..","..machine["coordinates"]["Y"] or props.MachineAnchor.Name
    local coordinateName = ""
    
    if datasetIsLoaded and machine then
        add(children, createTextChangingButton("id", machine))
        
        add(children, createListModalButton("type", machine, Constants.MachineTypes, function(assetKey) 
            machine["asset"] = Constants.MachineAssetPaths[assetKey]
        end))
        
        add(children, createTextChangingButton("locName", machine))
        add(children, SmallLabel({Label = "coordinates", LayoutOrder = incrementLayoutOrder()}))
        add(children, createTextChangingButton("X", machine["coordinates"], true))
        add(children, createTextChangingButton("Y", machine["coordinates"], true))
        
        add(children, Separator({LayoutOrder = incrementLayoutOrder()}))
        --Outputs : Item
        --Remove any outputs from the list that already exist as a machine's output. We don't want to allow duplicate outputs.
        local machineOutputChoices = table.clone(items)
        for _,outputItem in machine["outputs"] do
            machineOutputChoices[outputItem] = nil
        end
        --Label with add button
        add(children, LabelWithAdd({
           Label = "outputs",
           LayoutOrder = incrementLayoutOrder(),
           OnActivated = function()
                if not machine["outputs"] then
                    machine["outputs"] = {}
                end
                setListModalEnabled(true)
                setListChoices(Dataset:getValidItems(machineOutputChoices))
                setCurrentFieldKey(nil)
                setCurrentFieldValue(nil)
                setCurrentFieldCallback(function()
                    return function(newValue)
                        table.insert(machine["outputs"], newValue)
                        props.UpdateDataset(dataset)
                    end
                end)
            end,
        }))

        for i,outputItem in machine["outputs"] do
            add(children, ListItemButton({
                CanDelete = true,
                Image = items[outputItem]["thumb"],
                Index = i,
                LayoutOrder = incrementLayoutOrder(),
                Label = outputItem,
                ObjectToEdit = items[outputItem],
                OnSwapButtonClicked = function(itemKey)
                    setListModalEnabled(true)
                    setListChoices(Dataset:getValidItems(machineOutputChoices))
                    setCurrentFieldKey(i)
                    setCurrentFieldValue(itemKey)
                    setCurrentFieldCallback(function()
                        return function(newValue)
                            machine["outputs"][i] = newValue
                            props.UpdateDataset(props.Dataset)
                        end
                    end)
                end,
                OnEditButtonClicked = function()
                    props.OnOutputItemEditClicked(outputItem)
                end,
                OnDeleteButtonClicked = function()
                    props.OnDeleteButtonClicked(
                        "Remove "..machine["outputs"][i].." from "..machine["id"].."?",
                        function()
                            table.remove(machine["outputs"], i)
                            props.UpdateDataset(props.Dataset)
                        end
                    )
                end,
                ShowSwapButton = true,
            }))
        end
        add(children, Separator({LayoutOrder = incrementLayoutOrder()}))

        --Sources : Machine
        local machineSourceChoices = {}
        for _,machineObj in machines do
            machineSourceChoices[machineObj["id"]] = machineObj["id"]
        end

        --Label with add button
        add(children, LabelWithAdd({
            Label = "sources",
            LayoutOrder = incrementLayoutOrder(),
            OnActivated = function()
                if not machine["sources"] then
                    machine["sources"] = {}
                end
                setListModalEnabled(true)
                setListChoices(machineSourceChoices)
                setCurrentFieldKey(nil)
                setCurrentFieldValue(nil)
                setCurrentFieldCallback(function()
                    return function(newValue)
                        table.insert(machine["sources"], newValue)
                    end
                end)
            end,
        }))

        machineSourceChoices[machine["id"]] = nil --Remove this machine. A machine shouldn't be able to choose itself as a source.
        if machine["sources"] and #machine["sources"] > 0 then --Sometimes machine source tables don't exist, and sometimes they're empty.
            for _,sourceMachine in machine["sources"] do
                machineSourceChoices[sourceMachine] = nil
            end

            for i,source in machine["sources"] do
                local machineObj = Dataset:getMachineFromId(source)
                add(children, ListItemButton({
                    CanDelete = true,
                    -- Image = items[source]["thumb"],
                    HideIcon = true,
                    Index = i,
                    LayoutOrder = incrementLayoutOrder(),
                    Label = source,
                    ObjectToEdit = machineObj,
                    OnSwapButtonClicked = function(machineId)
                        setListModalEnabled(true)
                        setListChoices(machineSourceChoices)
                        setCurrentFieldKey(machineId)
                        setCurrentFieldValue(machineId)
                        setCurrentFieldCallback(function()
                            return function(newValue)
                                machine["sources"][i] = newValue
                            end
                        end)
                    end,
                    OnEditButtonClicked = function()
                        props.OnOutputItemEditClicked(source)
                    end,
                    OnDeleteButtonClicked = function()
                        props.OnDeleteButtonClicked(
                            "Remove "..machine["sources"][i].." from "..machine["id"].."?",
                            function()
                                table.remove(machine["sources"], i)
                                props.UpdateDataset(props.Dataset)
                            end
                        )
                    end,
                    ShowSwapButton = true,
                }))
            end
        end 
        add(children, Separator({LayoutOrder = incrementLayoutOrder()}))

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

        Modal = modalEnabled and TextInputModal({
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