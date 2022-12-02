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
            Gaps = 8,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            AutomaticSize = Enum.AutomaticSize.Y,
            Width = 300,
            PaddingVertical = 20,
            PaddingHorizontal = 20
        }, {
            Button1 = Button({
                Label = "Initialize Scene",
                OnActivated = function()
                    Scene.loadScene()
                    props.callback()
                end,
                TextXAlignment = Enum.TextXAlignment.Center,
                Width = UDim.new(1, 0)
            }),
        })
    })
end