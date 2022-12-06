local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Column = FishBloxComponents.Column
local TextInput = FishBloxComponents.TextInput
local Button = FishBloxComponents.Button
local Panel = FishBloxComponents.Panel
local Block = FishBloxComponents.Block
local Text = FishBloxComponents.Text

local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)

-- local Dash = require(Packages.Dash)

return function(props)

    local datasetName, setDatasetName = React.useState(SceneConfig.getDatasetName())

    local panel = Panel({
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
            DatasetNameInput = TextInput({
                Label = "Dataset Name:",
                LayoutOrder = 1,
                Placeholder = "Enter dataset name here",
                Value = SceneConfig.getDatasetName() or "",
                OnChanged = function(val)
                    local str = "dataset_"..val
                    SceneConfig.getDataset().Name = str
                    setDatasetName(str)
                end
            }),
            Spacer = Block({
                Height = 10
            }),
            ImportJSONButton = Button({
                Label = "Import Dataset",
                TextXAlignment = Enum.TextXAlignment.Center,
                LayoutOrder = 100,
                OnActivated = function()
                    local file = StudioService:PromptImportFile()
                    local fileScript = Instance.new("ModuleScript")
                    fileScript.Source = "return [[\n"..file:GetBinaryContents().."\n]]"
                    fileScript.Name = file.Name:split(".")[1]
                    fileScript.Parent = game.Workspace
                    SceneConfig.replaceDataset(fileScript)
                end,
                Size = UDim2.new(1, 0, 0, 0)
            }),
            ExportJSONButton = Button({
                Label = "Export Dataset",
                LayoutOrder = 110,
                TextXAlignment = Enum.TextXAlignment.Center,
                Size = UDim2.new(1, 0, 0, 0)
            }),
        })
    })



    local function smallText(text)
        return Text({
            Text = text or "EMPTY",
            Color = Color3.new(1,1,1),
            RichText = true,
            FontSize = 20,
        })
    end
    
    local textElements = {}
    
    local datasetString = require(SceneConfig.getDataset())
    local dataset = HttpService:JSONDecode(datasetString)
    for _, map in dataset["maps"] do
        table.insert(textElements, smallText(map.id))
        for _, item in map["items"] do
            table.insert(textElements, smallText(item.id))
        end
    end
    
    
    local debugPanel = Panel({
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.fromOffset(500, 0)
    }, {
        Content = Column({ --This overrides the built-in panel Column
            AutomaticSize = Enum.AutomaticSize.Y,
            Gaps = 8,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            PaddingHorizontal = 20,
            PaddingVertical = 20,
            Width = 300,
        }, textElements)
    })

    

    return React.createElement(React.Fragment, nil, {
        Panel = panel,
        DebugPanel = debugPanel
    })
end