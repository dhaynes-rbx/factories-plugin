local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Column = FishBloxComponents.Column
local TextInput = FishBloxComponents.TextInput
local Button = FishBloxComponents.Button
local Panel = FishBloxComponents.Panel
local Scene = require(script.Parent.Parent.Scene)

return function(props)

    return Panel({
        Size = UDim2.new(0, 300, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    }, {
        Content = Column({ --This overrides the built-in panel Column
            AutomaticSize = Enum.AutomaticSize.Y,
            Gaps = 8,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            PaddingHorizontal = 20,
            PaddingVertical = 20,
            Width = 300,
        }, {
            Button1 = Button({
                Label = "Initialize Scene",
                OnActivated = function()
                    Scene.loadScene()
                    props.ShowEditFactoryPanel()
                end,
                TextXAlignment = Enum.TextXAlignment.Center,
                Width = UDim.new(1, 0)
            }),
        })
    })
end