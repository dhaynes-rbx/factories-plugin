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

local SidePanel = require(script.Parent.SubComponents.SidePanel)

local Constants = require(script.Parent.Parent.Constants)
local Scene = require(script.Parent.Parent.Scene)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Parent.Helpers.add)
local Manifest = require(script.Parent.Parent.Manifest)
local Dataset = require(script.Parent.Parent.Dataset)
local LabelWithAdd = require(script.Parent.SubComponents.LabelWithAdd)
local Separator = require(script.Parent.SubComponents.Separator)
local ErrorText = require(script.Parent.SubComponents.ErrorText)
local Types = require(script.Parent.Parent.Types)
local Incrementer = require(script.Parent.Parent.Incrementer)
local InlineTextInput = require(script.Parent.SubComponents.InlineTextInput)
local FormatText = require(script.Parent.Parent.FormatText)
local TextItem = require(script.Parent.SubComponents.TextItem)
local InlineNumberInput = require(script.Parent.InlineNumberInput)
local LabeledAddButton = require(script.Parent.SubComponents.LabeledAddButton)
local MachineListItem = require(script.Parent.SubComponents.MachineListItem)
local ItemListItem = require(script.Parent.SubComponents.ItemListItem)

type Props = {
    AddMachineAnchor: any,
    CurrentMap: table,
    Dataset: table,
    Machine: Types.Machine,
    MachineAnchor: Instance,
    OnClosePanel: any,
    OnAddInputMachine: (Types.Machine) -> nil,
    OnClickEditItem: (Types.Item) -> nil,
    UpdateDataset: any,
}

local function EditMachineUI(props: Props)
    --use this to create a consistent layout order that plays nice with Roact
    local layoutOrder = Incrementer.new()

    local id, setMachineId = React.useState("")
    local currentOutputCount, setCurrentOutputCount = React.useState(props.Machine.currentOutputCount)
    local machine = props.Machine

    local machineInputs = {}
    if machine.sources then
        for i, sourceMachineId in machine.sources do
            local sourceMachine: Types.Machine = Dataset:getMachineFromId(sourceMachineId)
            table.insert(
                machineInputs,
                MachineListItem({
                    Machine = sourceMachine,
                    Label = sourceMachine.locName,
                    LayoutOrder = i,
                    OnActivated = function() end,
                    OnClickUp = function()
                        --
                    end,
                    OnClickDown = function()
                        --
                    end,
                    OnClickEdit = function()
                        --
                    end,
                    OnClickRemove = function(sourceToRemove)
                        Dataset:removeSourceFromMachine(machine, sourceToRemove)
                        props.UpdateDataset()
                    end,
                    OnHover = function(hoveredMachine: Types.Machine)
                        local anchor = hoveredMachine and Scene.getAnchorFromMachine(hoveredMachine)
                        props.OnHover(anchor)
                    end,

                    HideEditButton = true,
                })
            )
        end
    end

    local machineOutputs = {}
    if machine.outputs then
        for i, outputItem in machine.outputs do
            local item: Types.Item = props.Dataset.maps[props.CurrentMapIndex].items[outputItem]
            table.insert(
                machineOutputs,
                ItemListItem({
                    Item = item,
                    Label = item.locName,
                    LayoutOrder = i,
                    OnClickUp = function()
                        --
                    end,
                    OnClickDown = function()
                        --
                    end,
                    OnClickEdit = function(itemToEdit: Types.Item)
                        props.OnClickEditItem(itemToEdit)
                    end,
                    OnClickRemove = function(itemToRemove: Types.Item)
                        Dataset:removeOutputFromMachine(props.Machine, itemToRemove)
                        props.UpdateDataset()
                    end,
                    OnActivated = function()
                        Dash.noop()
                    end,
                })
            )
        end
    end

    local children = {

        ID = TextItem({
            Text = "ID: " .. props.Machine.id,
            LayoutOrder = layoutOrder:Increment(),
            OnActivate = function(input)
                print(Dash.pretty(props.Machine, { multiline = true, indent = "\t", depth = 10 }))
            end,
        }),

        LocName = FishBloxComponents.TextInput({
            HideLabel = true,
            LayoutOrder = layoutOrder:Increment(),
            Placeholder = "Enter Localized Name",
            Size = UDim2.new(1, 0, 0, 50),
            Value = props.Machine.locName,
            --Events
            OnChanged = function(text)
                local newText = text
                --prevent the id from being empty
                if #text < 1 then
                    return
                end
                --Check for invalid characters
                --Auto update ID based on LocName
                local updated = Dataset:updateMachineId(props.Machine, FormatText.convertToIdText(newText))
                if updated then
                    props.Machine.locName = newText
                    setMachineId(props.Machine.id)
                    props.UpdateDataset()
                end
            end,
        }),

        AddInputMachines = LabeledAddButton({
            LayoutOrder = layoutOrder:Increment(),
            Label = "Input Machines",

            OnActivated = function()
                props.OnAddInputMachine()
            end,
        }),

        InputMachines = Column({
            Gaps = 8,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            LayoutOrder = layoutOrder:Increment(),
        }, machineInputs),

        AddOutputs = LabeledAddButton({
            LayoutOrder = layoutOrder:Increment(),
            Label = "Outputs (Making)",

            OnActivated = function()
                props.OnAddOutput(machine)
            end,
        }),

        OutputItems = Column({
            Gaps = 8,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            LayoutOrder = layoutOrder:Increment(),
        }, machineOutputs),

        StartingOutput = InlineNumberInput({
            Value = props.Machine.currentOutputCount,
            LayoutOrder = layoutOrder:Increment(),
            Label = "Starting Output",
            OnReset = function()
                Dataset:updateMachineProperty(
                    props.Machine,
                    "currentOutputCount",
                    Constants.Defaults.MachineDefaultOutput
                )
                props.UpdateDataset()
            end,
            OnChanged = function(value)
                if not tonumber(value) then
                    return
                end
                value = tonumber(value)
                -- local min = props.Machine.outputRange.min
                -- local max = props.Machine.outputRange.max
                -- if value < min then
                --     value = min
                -- elseif value > max then
                --     value = max
                -- end
                setCurrentOutputCount(value)
                Dataset:updateMachineProperty(props.Machine, "currentOutputCount", value)
                props.UpdateDataset()
            end,
        }),

        MinOutput = InlineNumberInput({
            Value = props.Machine.outputRange.min,
            LayoutOrder = layoutOrder:Increment(),
            Label = "Min",
            OnReset = function()
                local defaultOutputRange = {
                    min = Constants.Defaults.MachineDefaultOutputRange.min,
                    max = props.Machine.outputRange.max,
                }
                Dataset:updateMachineProperty(props.Machine, "outputRange", defaultOutputRange)
                props.UpdateDataset()
            end,
            OnChanged = function(value)
                if not tonumber(value) then
                    return
                end
                value = tonumber(value)
                local max = props.Machine.outputRange.max
                -- if value > max then
                --     value = max
                -- end
                local newOutputRange = {
                    min = value,
                    max = max,
                }
                Dataset:updateMachineProperty(props.Machine, "outputRange", newOutputRange)
                -- if currentOutputCount < value then
                --     Dataset:updateMachineProperty(props.Machine, "currentStartingOutput", value)
                --     setCurrentOutputCount(value)
                -- end
                props.UpdateDataset()
            end,
        }),

        MaxOutput = InlineNumberInput({
            Value = props.Machine.outputRange.max,
            LayoutOrder = layoutOrder:Increment(),
            Label = "Max",
            OnReset = function()
                local defaultOutputRange = {
                    min = props.Machine.outputRange.min,
                    max = Constants.Defaults.MachineDefaultOutputRange.max,
                }
                Dataset:updateMachineProperty(props.Machine, "outputRange", defaultOutputRange)
                props.UpdateDataset()
            end,
            OnChanged = function(value)
                if not tonumber(value) then
                    return
                end
                value = tonumber(value)
                local min = props.Machine.outputRange.min
                -- if value < min then
                --     value = min
                -- end
                local newOutputRange = {
                    min = min,
                    max = value,
                }
                Dataset:updateMachineProperty(props.Machine, "outputRange", newOutputRange)
                -- if currentOutputCount > value then
                --     Dataset:updateMachineProperty(props.Machine, "currentStartingOutput", value)
                --     setCurrentOutputCount(value)
                -- end
                props.UpdateDataset()
            end,
        }),
    }

    return React.createElement(React.Fragment, {}, {
        EditMachineUI = SidePanel({
            OnClosePanel = props.OnClosePanel,
            ShowClose = true,
            Title = "Editing Machine",
        }, children),
    })
end

return function(props: Props)
    return React.createElement(EditMachineUI, props)
    -- return React.createElement(React.Fragment, {}, {})
end

-- return function(props: Props)
-- Studio.setSelectionTool()

-- local modalEnabled, setModalEnabled = React.useState(false)
-- local listModalEnabled, setListModalEnabled = React.useState(false)
-- local listChoices, setListChoices = React.useState({})
-- local currentFieldKey, setCurrentFieldKey = React.useState(nil)
-- local currentFieldValue, setCurrentFieldValue = React.useState(nil)
-- local currentFieldCallback, setCurrentFieldCallback = React.useState(nil)
-- local valueType, setValueType = React.useState(nil)

-- local datasetIsLoaded = props.Dataset ~= nil and props.Dataset ~= "NONE"
-- local dataset = props.Dataset
-- local map = props.CurrentMap
-- local machines = map["machines"]
-- local items = map["items"]

-- --When the machineAnchor is changed, we need to make sure that all modals are closed and canceled out.
-- React.useEffect(function()
--     return function()
--         setCurrentFieldCallback(nil)
--         setModalEnabled(false)
--         setListModalEnabled(false)
--         setCurrentFieldKey(nil)
--         setCurrentFieldValue(nil)
--         Studio.setSelectionTool()
--     end
-- end, { props.MachineAnchor })

-- --use this to create a consistent layout order that plays nice with Roact
-- local index = 0
-- local incrementLayoutOrder = function()
--     index = index + 1
--     return index
-- end

-- local createTextChangingButton = function(key: string | number, object: table, isNumber: boolean, filled: boolean)
--     return SmallButtonWithLabel({
--         Appearance = filled and "Filled",
--         ButtonLabel = tostring(object[key]),
--         Label = key .. ": ",
--         LayoutOrder = incrementLayoutOrder(),

--         OnActivated = function()
--             if isNumber then
--                 setValueType("number")
--             else
--                 setValueType("string")
--             end
--             --set modal enabled
--             setModalEnabled(true)
--             setCurrentFieldKey(key)
--             setCurrentFieldValue(object[key])
--             setCurrentFieldCallback(function()
--                 return function(newValue)
--                     if valueType == "string" then
--                         newValue = newValue:gsub("%s", "")
--                     end

--                     local previousValue = object[key]
--                     if previousValue == newValue then
--                         return
--                     end

--                     if key == "id" then
--                         object[key] = Dataset:resolveDuplicateId(newValue, machines)
--                         --if we're changing the ID, we must also change it wherever it appears as another machine's source
--                         for i, machine in machines do
--                             if machine["sources"] then
--                                 for j, source in machine["sources"] do
--                                     if source == previousValue then
--                                         machines[i]["sources"][j] = newValue
--                                     end
--                                 end
--                             end
--                         end
--                     elseif key == "X" or key == "Y" then
--                         props.MachineAnchor.Name = "("
--                             .. tostring(object["X"])
--                             .. ","
--                             .. tostring(object["Y"])
--                             .. ")"
--                         object[key] = newValue
--                     else
--                         object[key] = newValue
--                     end
--                 end
--             end)
--         end,
--     })
-- end

-- local createListModalButton = function(key: string | number, list: table, choices: table, callback: any)
--     return SmallButtonWithLabel({
--         Appearance = "Filled",
--         ButtonLabel = tostring(list[key]),
--         Label = key .. ": ",
--         LayoutOrder = incrementLayoutOrder(),

--         OnActivated = function()
--             setListModalEnabled(true)
--             setListChoices(choices)
--             setCurrentFieldKey(key)
--             setCurrentFieldValue(list[key])
--             setCurrentFieldCallback(function()
--                 return function(newValue)
--                     list[key] = newValue

--                     --Callback for additional special case functionality
--                     if callback then
--                         callback(newValue)
--                     end
--                 end
--             end)
--         end,
--     })
-- end

-- local machine = props.Machine
-- local children = {}
-- -- local coordinateName = machine and machine["coordinates"]["X"]..","..machine["coordinates"]["Y"] or props.MachineAnchor.Name
-- local coordinateName = ""

-- if datasetIsLoaded and machine then
--     add(children, ErrorText({ Text = "Error!", LayoutOrder = incrementLayoutOrder() }))

--     add(
--         children,
--         Text({
--             Text = "type: " .. machine["type"],
--             Color = Color3.new(1, 1, 1),
--             LayoutOrder = incrementLayoutOrder(),
--         })
--     )

--     add(children, createTextChangingButton("id", machine))

--     add(children, createTextChangingButton("locName", machine))
--     add(children, SmallLabel({ Label = "coordinates", LayoutOrder = incrementLayoutOrder() }))
--     add(children, createTextChangingButton("X", machine["coordinates"], true))
--     add(children, createTextChangingButton("Y", machine["coordinates"], true))

--     add(children, Separator({ LayoutOrder = incrementLayoutOrder() }))
--     --Outputs : Item
--     --Remove any outputs from the list that already exist as a machine's output. We don't want to allow duplicate outputs.
--     local machineOutputChoices = table.clone(items)
--     for _, outputItem in machine["outputs"] do
--         machineOutputChoices[outputItem] = nil
--     end
--     --Label with add button
--     add(
--         children,
--         LabelWithAdd({
--             Label = "outputs",
--             LayoutOrder = incrementLayoutOrder(),
--             OnActivated = function()
--                 if not machine["outputs"] then
--                     machine["outputs"] = {}
--                 end
--                 setListModalEnabled(true)
--                 setListChoices(Dataset:getValidItems(machineOutputChoices))
--                 setCurrentFieldKey(nil)
--                 setCurrentFieldValue(nil)
--                 setCurrentFieldCallback(function()
--                     return function(newValue)
--                         table.insert(machine["outputs"], newValue)
--                         props.UpdateDataset(dataset)
--                     end
--                 end)
--             end,
--         })
--     )

--     for i, outputItem in machine["outputs"] do
--         add(
--             children,
--             ListItemButton({
--                 CanDelete = true,
--                 Image = items[outputItem]["thumb"],
--                 Index = i,
--                 LayoutOrder = incrementLayoutOrder(),
--                 Label = outputItem,
--                 ObjectToEdit = items[outputItem],
--                 OnSwapButtonClicked = function(itemKey)
--                     setListModalEnabled(true)
--                     setListChoices(Dataset:getValidItems(machineOutputChoices))
--                     setCurrentFieldKey(i)
--                     setCurrentFieldValue(itemKey)
--                     setCurrentFieldCallback(function()
--                         return function(newValue)
--                             machine["outputs"][i] = newValue
--                             props.UpdateDataset(props.Dataset)
--                         end
--                     end)
--                 end,
--                 OnEditButtonClicked = function()
--                     props.OnOutputItemEditClicked(outputItem)
--                 end,
--                 OnDeleteButtonClicked = function()
--                     props.OnDeleteButtonClicked(
--                         "Remove " .. machine["outputs"][i] .. " from " .. machine["id"] .. "?",
--                         function()
--                             table.remove(machine["outputs"], i)
--                             props.UpdateDataset(props.Dataset)
--                         end
--                     )
--                 end,
--                 ShowSwapButton = true,
--             })
--         )
--     end
--     add(children, Separator({ LayoutOrder = incrementLayoutOrder() }))

--     --Sources : Machine
--     local machineSourceChoices = {}
--     for _, machineObj in machines do
--         machineSourceChoices[machineObj["id"]] = machineObj["id"]
--     end

--     --Label with add button
--     add(
--         children,
--         LabelWithAdd({
--             Label = "sources",
--             LayoutOrder = incrementLayoutOrder(),
--             OnActivated = function()
--                 if not machine["sources"] then
--                     machine["sources"] = {}
--                 end
--                 setListModalEnabled(true)
--                 setListChoices(machineSourceChoices)
--                 setCurrentFieldKey(nil)
--                 setCurrentFieldValue(nil)
--                 setCurrentFieldCallback(function()
--                     return function(newValue)
--                         table.insert(machine["sources"], newValue)
--                     end
--                 end)
--             end,
--         })
--     )

--     machineSourceChoices[machine["id"]] = nil --Remove this machine. A machine shouldn't be able to choose itself as a source.
--     --machine sources should NEVER be empty.
--     --TODO: Remove the check for empty source array.
--     if machine["sources"] and #machine["sources"] > 0 then
--         for _, sourceMachine in machine["sources"] do
--             machineSourceChoices[sourceMachine] = nil
--         end

--         for i, source in machine["sources"] do
--             local machineObj = Dataset:getMachineFromId(source)
--             add(
--                 children,
--                 ListItemButton({
--                     CanDelete = true,
--                     -- Image = items[source]["thumb"],
--                     HideIcon = true,
--                     Index = i,
--                     LayoutOrder = incrementLayoutOrder(),
--                     Label = source,
--                     ObjectToEdit = machineObj,
--                     OnSwapButtonClicked = function(machineId)
--                         setListModalEnabled(true)
--                         setListChoices(machineSourceChoices)
--                         setCurrentFieldKey(machineId)
--                         setCurrentFieldValue(machineId)
--                         setCurrentFieldCallback(function()
--                             return function(newValue)
--                                 machine["sources"][i] = newValue
--                             end
--                         end)
--                     end,
--                     OnEditButtonClicked = function()
--                         props.OnOutputItemEditClicked(source)
--                     end,
--                     OnDeleteButtonClicked = function()
--                         props.OnDeleteButtonClicked(
--                             "Remove " .. machine["sources"][i] .. " from " .. machine["id"] .. "?",
--                             function()
--                                 table.remove(machine["sources"], i)
--                                 props.UpdateDataset(props.Dataset)
--                             end
--                         )
--                     end,
--                     ShowSwapButton = true,
--                 })
--             )
--         end
--     end
--     add(children, Separator({ LayoutOrder = incrementLayoutOrder() }))

--     add(children, Block({ LayoutOrder = incrementLayoutOrder(), Size = UDim2.new(1, 0, 0, 50) }))
--     add(children, createTextChangingButton("defaultProductionDelay", machine, true))
--     add(children, createTextChangingButton("defaultMaxStorage", machine, true))
--     add(children, createTextChangingButton("currentOutputCount", machine, true))
--     add(children, SmallLabel({ Label = "outputRange", LayoutOrder = incrementLayoutOrder() }))
--     add(children, createTextChangingButton("min", machine["outputRange"], true))
--     add(children, createTextChangingButton("max", machine["outputRange"], true))
--     add(
--         children,
--         SmallLabel({
--             Label = "supportsPowerups: " .. tostring(machine["supportsPowerup"]),
--             LayoutOrder = incrementLayoutOrder(),
--         })
--     )
-- end

-- if not machine then
--     add(
--         children,
--         Text({
--             Color = Color3.new(1, 0, 0),
--             FontSize = 24,
--             Text = "Error: Machine Anchor "
--                 .. props.MachineAnchor.Name
--                 .. " does not have corresponding machine data in this dataset!",
--         })
--     )
-- end

-- return React.createElement(React.Fragment, nil, {
--     EditMachineUI = SidePanel({
--         OnClosePanel = props.OnClosePanel,
--         ShowClose = true,
--         Title = "Edit Machine " .. coordinateName,
--     }, children),

--     Modal = modalEnabled and TextInputModal({
--         Key = currentFieldKey,
--         Value = currentFieldValue,
--         ValueType = valueType,

--         OnConfirm = function(value)
--             currentFieldCallback(value)
--             setModalEnabled(false)
--             setCurrentFieldKey(nil)
--             setCurrentFieldValue(nil)
--             Studio.setSelectionTool()
--             props.UpdateDataset(dataset)
--         end,
--         OnClosePanel = function()
--             setCurrentFieldCallback(nil)
--             setModalEnabled(false)
--             setCurrentFieldKey(nil)
--             setCurrentFieldValue(nil)
--             Studio.setSelectionTool()
--         end,
--     }),

--     SelectFromListModal = listModalEnabled and SelectFromListModal({
--         Choices = listChoices,
--         Key = currentFieldKey,
--         Value = currentFieldValue,

--         OnConfirm = function(value)
--             currentFieldCallback(value)
--             setListModalEnabled(false)
--             setCurrentFieldKey(nil)
--             setCurrentFieldValue(nil)
--             Studio.setSelectionTool()
--             props.UpdateDataset(dataset)
--         end,
--         OnClosePanel = function()
--             setCurrentFieldCallback(nil)
--             setListModalEnabled(false)
--             setCurrentFieldKey(nil)
--             setCurrentFieldValue(nil)
--             Studio.setSelectionTool()
--         end,
--     }),
-- })
-- end
