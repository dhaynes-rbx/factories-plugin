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

    local factoryInfoElements = {
        SmallButtonWithLabel({
            Appearance = "Filled",
            Size = UDim2.fromScale(1, 0),
            ButtonLabel = "Print Dataset to Console",
            OnActivated = function()
                print("Dataset:")
                print(dataset)
            end
        }),
        Gap({Size = 10})
    }
    if datasetIsLoaded then
        for _, mapData in dataset["maps"] do
            if mapData.id ~= "mapA" then
                continue
            end

            table.insert(factoryInfoElements, SmallLabel({Label = "Factory:"}))
            table.insert(factoryInfoElements, SmallButtonWithLabel({ButtonLabel = "id: "..map.id}))
            table.insert(factoryInfoElements, SmallButtonWithLabel({ButtonLabel = "locName: "..mapData.locName}))
            table.insert(factoryInfoElements, SmallButtonWithLabel({ButtonLabel = "locDesc: "..mapData.locDesc}))
            table.insert(factoryInfoElements, SmallButtonWithLabel({ButtonLabel = "scene: "..mapData.scene}))
            table.insert(factoryInfoElements, SmallButtonWithLabel({ButtonLabel = "thumb: "..mapData.thumb}))
            table.insert(factoryInfoElements, SmallButtonWithLabel({ButtonLabel = "stepsPerRun: "..mapData.stepsPerRun}))
            table.insert(factoryInfoElements, SmallButtonWithLabel({ButtonLabel = "stepUnit (singular): "..mapData.stepUnit.singular}))
            table.insert(factoryInfoElements, SmallButtonWithLabel({ButtonLabel = "stepUnit (plural): "..mapData.stepUnit.plural}))
            table.insert(factoryInfoElements, SmallButtonWithLabel({ButtonLabel = "defaultInventory (currency): "..mapData.defaultInventory.currency}))

            table.insert(factoryInfoElements, Gap({Size = 10}))
            table.insert(factoryInfoElements, SmallLabel({Label = "Items:"}))
            for _, item in map["items"] do
                table.insert(factoryInfoElements, SmallButtonWithLabel({ButtonLabel = item.id}))
            end
            table.insert(factoryInfoElements, Gap({Size = 10}))
            table.insert(factoryInfoElements, SmallLabel({Label = "Machines:"}))
            for _,machine in map["machines"] do
                table.insert(factoryInfoElements, SmallButtonWithLabel({ButtonLabel = machine.id}))
            end
            table.insert(factoryInfoElements, Gap({Size = 10}))
            table.insert(factoryInfoElements, SmallLabel({Label = "Powerups:"}))
            for _,powerup in map["powerups"] do
                table.insert(factoryInfoElements, SmallButtonWithLabel({ButtonLabel = powerup.id}))
            end
        end
        
    end
    local FactoryInfoPanel = Panel({
        AnchorPoint = Vector2.new(1,0),
        Size = UDim2.new(0, 400, 1, 0),
        Position = UDim2.fromScale(1, 0)
    }, {
        ScrollingFrame = React.createElement("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromScale(1, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.XY,
            ScrollingDirection = Enum.ScrollingDirection.Y,
        }, {
            Content = Column({ --This overrides the built-in panel Column
                AutomaticSize = Enum.AutomaticSize.Y,
                -- Gaps = 4,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                PaddingHorizontal = 20,
                -- PaddingVertical = 10,
                Size = UDim2.fromScale(1, 1)
                -- Width = 300,
            }, factoryInfoElements)
        }),
    })

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
                -- props.ForceUpdate()
            end,
            OnClosePanel = function()
                setModalEnabled(false)
                setCurrentFieldKey(nil)
                setCurrentFieldValue(nil)
                setCurrentFieldCallback(nil)
            end
        }),
        FactoryInfoPanel = (datasetIsLoaded and showDatasetInfoPanel) and FactoryInfoPanel
    })
end