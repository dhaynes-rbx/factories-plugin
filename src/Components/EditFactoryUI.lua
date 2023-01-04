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

local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)

local function smallLabel(text)
    return Text({
        Bold = true,
        Color = Color3.new(1,1,1),
        FontSize = 24,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        RichText = true,
        Text = text or "EMPTY",
    })
end

local function smallButton(props)
    return React.createElement("TextButton", {
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Color3.fromRGB(32, 117, 233),
        BackgroundTransparency = 0.85,
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
        RichText = true,
        Size = UDim2.fromOffset(20, 30),
        Text = props.Label,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        [Roact.Event.MouseButton1Click] = props.OnActivated
    }, {
        uiCorner = React.createElement("UICorner"),
        uiStroke = React.createElement("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(79, 159, 243),
            Thickness = 1,
        }),
        uiPadding = Roact.createElement("UIPadding", {
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
          })
    })
end

return function(props)
    local modalEnabled, setModalEnabled = React.useState(false)
    local currentFieldKey, setCurrentFieldKey = React.useState(nil)
    local currentFieldValue, setCurrentFieldValue = React.useState(nil)
    local currentFieldCallback, setCurrentFieldCallback = React.useState(nil)

    local showDatasetInfoPanel, setShowDatasetInfoPanel = React.useState(false)

    local createTextChangingButton = function(key, object)
        return smallButton(
            {
                Label = key..": "..tostring(object[key]),
                OnActivated = function()
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
            }
        )
    end


    local datasetIsLoaded = props.Dataset ~= nil and props.Dataset ~= "NONE"
    local dataset = props.Dataset
    local map = datasetIsLoaded and dataset.maps[2] or nil

    local children = {
        Spacer = Block({
            Height = 10,
            LayoutOrder = 100,
        }),
        ImportJSONButton = Button({
            Label = "Import Dataset",
            LayoutOrder = 110,
            OnActivated = props.ImportDataset,
            Size = UDim2.new(1, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
        }),
    }

    if datasetIsLoaded then
        children["ExportJSONButton"] = Button({
            Label = "Export Dataset",
            LayoutOrder = 120,
            OnActivated = props.ExportDataset,
            Size = UDim2.new(1, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
        })
        children["ShowOrHideDatasetButton"] = Button({
            Label = showDatasetInfoPanel and "Hide Dataset View" or "Show Dataset View",
            LayoutOrder = 130,
            OnActivated = function()
                setShowDatasetInfoPanel(not showDatasetInfoPanel)
            end,
            Size = UDim2.new(1, 0, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Center,
        })

        children.locName = createTextChangingButton("locName", map)
    end

    local EditFactoryPanel = Panel({
        Title = "Edit Factory",
        Size = UDim2.new(0, 300, 1, 0),
    }, {
        Content = Column({ --This overrides the built-in panel Column
            AutomaticSize = Enum.AutomaticSize.Y,
            Gaps = 8,
            PaddingHorizontal = 20,
            PaddingVertical = 20,
            Width = 300,
        }, children
    )})

    local factoryInfoElements = {
        smallButton({
            Size = UDim2.fromScale(1, 0),
            Label = "Print Dataset to Console",
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

            table.insert(factoryInfoElements, smallButton({Label = "id: "..map.id}))
            table.insert(factoryInfoElements, smallButton({Label = "locName: "..mapData.locName}))
            table.insert(factoryInfoElements, smallButton({Label = "locDesc: "..mapData.locDesc}))
            table.insert(factoryInfoElements, smallButton({Label = "scene: "..mapData.scene}))
            table.insert(factoryInfoElements, smallButton({Label = "thumb: "..mapData.thumb}))
            table.insert(factoryInfoElements, smallButton({Label = "stepsPerRun: "..mapData.stepsPerRun}))
            table.insert(factoryInfoElements, smallButton({Label = "stepUnit (singular): "..mapData.stepUnit.singular}))
            table.insert(factoryInfoElements, smallButton({Label = "stepUnit (plural): "..mapData.stepUnit.plural}))
            table.insert(factoryInfoElements, smallButton({Label = "defaultInventory (currency): "..mapData.defaultInventory.currency}))

            table.insert(factoryInfoElements, Gap({Size = 10}))
            table.insert(factoryInfoElements, smallLabel("Items:"))
            for _, item in map["items"] do
                table.insert(factoryInfoElements, smallButton({Label = item.id}))
            end
            table.insert(factoryInfoElements, Gap({Size = 10}))
            table.insert(factoryInfoElements, smallLabel("Machines:"))
            for _,machine in map["machines"] do
                table.insert(factoryInfoElements, smallButton({Label = machine.id}))
            end
            table.insert(factoryInfoElements, Gap({Size = 10}))
            table.insert(factoryInfoElements, smallLabel("Powerups:"))
            for _,powerup in map["powerups"] do
                table.insert(factoryInfoElements, smallButton({Label = powerup.id}))
            end
        end
        
    end

    local FactoryInfoPanel = Panel({
        AnchorPoint = Vector2.new(1,0),
        Corners = 0,
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.fromScale(1, 0)
    }, {
        ScrollingFrame = React.createElement("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromScale(1, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
        }, {
            Content = Column({ --This overrides the built-in panel Column
                AutomaticSize = Enum.AutomaticSize.Y,
                Gaps = 4,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                PaddingHorizontal = 20,
                PaddingVertical = 20,
                Width = 300,
            }, factoryInfoElements)
        }),
        
    })

    return React.createElement(React.Fragment, nil, {
        EditFactoryPanel = EditFactoryPanel,
        Modal = modalEnabled and Modal({
            Key = currentFieldKey,
            Value = currentFieldValue,
            OnConfirm = function(value)
                setModalEnabled(false)
                currentFieldCallback(value)
                props.ForceUpdate()
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