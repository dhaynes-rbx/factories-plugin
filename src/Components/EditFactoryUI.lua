local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Column = FishBloxComponents.Column
local TextInput = FishBloxComponents.TextInput
local Button = FishBloxComponents.Button
local Panel = FishBloxComponents.Panel

local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)

-- local Dash = require(Packages.Dash)

return function(props)


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
                Label = "Dataset Name",
                LayoutOrder = 1,
                Placeholder = "Enter dataset name here",
                Value = ""
                --OnActivated = TODO: When the this name changes, update the scene config accordingly
            }),
            
            ImportJSONButton = Button({
                Label = "Import Dataset",
                LayoutOrder = 100,
                OnActivated = function()
                    local file = StudioService:PromptImportFile()
                    local fileScript = Instance.new("ModuleScript")
                    fileScript.Source = "return [[\n"..file:GetBinaryContents().."\n]]"
                    fileScript.Name = file.Name:split(".")[1]
                    fileScript.Parent = game.Workspace
                    SceneConfig.updateConfig(fileScript)
                end
            }),
            ExportJSONButton = Button({
                Label = "Export Dataset",
                LayoutOrder = 110
            }),
            

            
        })
    })

    

    return panel
end