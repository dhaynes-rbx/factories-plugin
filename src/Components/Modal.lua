local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Column = FishBloxComponents.Column
local TextInput = FishBloxComponents.TextInput
local Button = FishBloxComponents.Button
local Panel = FishBloxComponents.Panel
local Overlay = FishBloxComponents.Overlay
local Scene = require(script.Parent.Parent.Scene)

return function(props)

    print("Modal")

    return Overlay({
        Size = UDim2.new(1, 40,1, 40),
        Position = UDim2.new(0, -20, 0, -20)
        -- PaddingLeft = -20,
        -- PaddingRight = -20,
        -- PaddingTop = -20,
        -- PaddingBottom = -20,
    }, {
        Panel({
            AnchorPoint = Vector2.new(0.5, 0.5),
            Title = props.Title,
            Size = UDim2.new(0, 500, 0, 0),
            ShowClose = true,
            Position = UDim2.fromScale(0.5, 0.5),
            AutomaticSize = Enum.AutomaticSize.Y,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
        }, {
            Content = Column({ --This overrides the built-in panel Column
                AutomaticSize = Enum.AutomaticSize.Y,
                Gaps = 8,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                PaddingHorizontal = 20,
                PaddingVertical = 20,
            }, {
                Button1 = Button({
                    Label = "Initialize Scene",
                    OnActivated = function()
                        Scene.loadScene()
                        props.ShowEditFactoryPanel()
                    end,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Width = UDim.new(1, 0),
                }),
            })
        }),
    })
end