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

-- local Dash = require(Packages.Dash)
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
        Size = UDim2.fromOffset(20, 20),
        Text = props.Text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        [Roact.Event.MouseButton1Click] = props.OnActivated
    }, {
        uICorner = React.createElement("UICorner"),
    })
end



return function(props)
    local modalEnabled, setModalEnabled = React.useState(false)
    local currentFieldKey, setCurrentFieldKey = React.useState(nil)
    local currentFieldValue, setCurrentFieldValue = React.useState(nil)
    local currentFieldCallback, setCurrentFieldCallback = React.useState(nil)

    local createSmallTextChangingButton = function(key, object)
        print(key, object)
        return smallButton(
            {
                Text = key..": "..tostring(object[key]),
                OnActivated = function()
                    --set modal enabled
                    setModalEnabled(true)
                    setCurrentFieldKey(key)
                    setCurrentFieldValue(object[key])
                    setCurrentFieldCallback(function()
                        return function(value)
                            print("Updating...", value)
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
            TextXAlignment = Enum.TextXAlignment.Center,
            LayoutOrder = 110,
            OnActivated = props.ImportDataset,
            Size = UDim2.new(1, 0, 0, 0)
        }),
    }

    if datasetIsLoaded then
        
        children.ExportJSONButton = Button({
            Label = "Export Dataset",
            LayoutOrder = 120,
            TextXAlignment = Enum.TextXAlignment.Center,
            Size = UDim2.new(1, 0, 0, 0),
            OnActivated = props.ExportDataset,
        })
        children.id = createSmallTextChangingButton("id", map)
        children.locName = createSmallTextChangingButton("locName", map)

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

    -- local factoryInfoElements = {}
    -- if datasetIsLoaded then
    --     for _, mapData in dataset["maps"] do
    --         if mapData.id ~= "mapA" then
    --             continue
    --         end

    --         table.insert(factoryInfoElements, smallButton({Text = map.id}))
    --         table.insert(factoryInfoElements, smallButton({Text = "Default Inventory Currency: "..mapData.defaultInventory.currency}))
    --         table.insert(factoryInfoElements, Gap({Size = 10}))
    --         table.insert(factoryInfoElements, smallLabel("Items:"))
    --         for _, item in map["items"] do
    --             table.insert(factoryInfoElements, smallButton({Text = item.id}))
    --         end
    --         table.insert(factoryInfoElements, Gap({Size = 10}))
    --         table.insert(factoryInfoElements, smallLabel("Machines:"))
    --         for _,machine in map["machines"] do
    --             table.insert(factoryInfoElements, smallButton({Text = machine.id}))
    --         end
    --     end
    -- end

    -- local FactoryInfoPanel = Panel({
    --     AnchorPoint = Vector2.new(1,0),
    --     Corners = 0,
    --     Size = UDim2.new(0, 300, 1, 0),
    --     Position = UDim2.fromScale(1, 0)
    -- }, {
    --     ScrollingFrame = React.createElement("ScrollingFrame", {
    --         Size = UDim2.fromScale(1, 1),
    --         BackgroundTransparency = 1,
    --         BorderSizePixel = 0,
    --         CanvasSize = UDim2.fromScale(1, 0),
    --         AutomaticCanvasSize = Enum.AutomaticSize.Y,
    --         ScrollingDirection = Enum.ScrollingDirection.Y,
    --     }, {
    --         Content = Column({ --This overrides the built-in panel Column
    --             AutomaticSize = Enum.AutomaticSize.Y,
    --             Gaps = 4,
    --             HorizontalAlignment = Enum.HorizontalAlignment.Left,
    --             PaddingHorizontal = 20,
    --             PaddingVertical = 20,
    --             Width = 300,
    --         }, factoryInfoElements)
    --     })
    -- })

    return React.createElement(React.Fragment, nil, {
        EditFactoryPanel = EditFactoryPanel,
        Modal = modalEnabled and Modal({
            Title = currentFieldKey,
            Value = currentFieldValue,
            OnConfirm = function(value)
                print(value)
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
        -- FactoryInfoPanel = datasetIsLoaded and FactoryInfoPanel
    })
end