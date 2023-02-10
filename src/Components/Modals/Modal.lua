local Packages = script.Parent.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Column = FishBloxComponents.Column
local TextInput = FishBloxComponents.TextInput
local Text = FishBloxComponents.Text
local Button = FishBloxComponents.Button
local Panel = FishBloxComponents.Panel
local Overlay = FishBloxComponents.Overlay
local Scene = require(script.Parent.Parent.Parent.Scene)

type Props = {
    ModalElements:table,
    OnClosePanel: any,
}

local function Modal(props: Props)
    
    return Overlay({
        Size = UDim2.new(1, 40,1, 40),
        Position = UDim2.new(0, -20, 0, -20),
    }, { 
        Panel({
            AnchorPoint = Vector2.new(0.5, 0.5),
            Title = props.Title,
            Size = UDim2.new(0, 500, 0, 0),
            ShowClose = props.ShowClose,
            Position = UDim2.fromScale(0.5, 0.5),
            AutomaticSize = Enum.AutomaticSize.Y,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            OnClosePanel = props.OnClosePanel,
            ZIndex = 2,
        }, {
            Content = Column({ --This overrides the built-in panel Column
                AutomaticSize = Enum.AutomaticSize.Y,
                Gaps = 8,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                PaddingHorizontal = 20,
                PaddingVertical = 20,
                ZIndex = 2,
            }, props.ModalElements)
        })
    })
end

return function(props)
    return React.createElement(Modal, props)
end