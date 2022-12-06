local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Block = FishBloxComponents.Block
local Button = FishBloxComponents.Button
local Column = FishBloxComponents.Column
local Gap = FishBloxComponents.Gap
local Panel = FishBloxComponents.Panel
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

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

local function smallButton(text)
    return React.createElement("TextButton", {
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Color3.fromRGB(32, 117, 233),
        BackgroundTransparency = 0.85,
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
        RichText = true,
        Size = UDim2.fromOffset(20, 20),
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
      }, {
        uICorner = React.createElement("UICorner"),
      })
end

return function(props)
    local datasetIsLoaded = props.DatasetInstance ~= "NONE"

    local EditFactoryPanel = Panel({
        Title = "Edit Factory",
        Size = UDim2.new(0, 300, 1, 0),
    }, {
        Content = Column({ --This overrides the built-in panel Column
            AutomaticSize = Enum.AutomaticSize.Y,
            Gaps = 8,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            PaddingHorizontal = 20,
            PaddingVertical = 20,
            Width = 300,
        }, {
            DatasetNameInput = datasetIsLoaded and TextInput({
                Label = "Dataset Name:",
                LayoutOrder = 1,
                Placeholder = "Enter dataset name here",
                Value = SceneConfig.getDatasetName() or "",
                OnChanged = function(val)
                    local str = "dataset_"..val
                    SceneConfig.setDatasetName(str)
                end
            }),
            Spacer = Block({
                Height = 10
            }),
            ImportJSONButton = Button({
                Label = "Import Dataset",
                TextXAlignment = Enum.TextXAlignment.Center,
                LayoutOrder = 100,
                OnActivated = props.ImportDataset,
                Size = UDim2.new(1, 0, 0, 0)
            }),
            ExportJSONButton = datasetIsLoaded and Button({
                Label = "Export Dataset",
                LayoutOrder = 110,
                TextXAlignment = Enum.TextXAlignment.Center,
                Size = UDim2.new(1, 0, 0, 0),
                OnActivated = function()
                    -- local dataset = HttpService:JSON/
                end
            }),
        })
    })

    local textElements = {}
    local FactoryInfoPanel = nil
    if datasetIsLoaded then
        local datasetString = require(props.DatasetInstance)
        local dataset = HttpService:JSONDecode(datasetString)
        for _, map in dataset["maps"] do
            if map.id ~= "mapA" then
                continue
            end

            table.insert(textElements, smallButton(map.id))
            table.insert(textElements, Gap({Size = 10}))
            table.insert(textElements, smallLabel("Items:"))
            for _, item in map["items"] do
                table.insert(textElements, smallButton(item.id))
            end
            table.insert(textElements, Gap({Size = 10}))
            table.insert(textElements, smallLabel("Machines:"))
            for _,machine in map["machines"] do
                table.insert(textElements, smallButton(machine.id))
            end
        end
        
        FactoryInfoPanel = Panel({
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
                }, textElements)
            })
        })
    end
    

    return React.createElement(React.Fragment, nil, {
        EditFactoryPanel = EditFactoryPanel,
        FactoryInfoPanel = FactoryInfoPanel
    })
end