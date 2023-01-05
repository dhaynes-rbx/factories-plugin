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

local function Modal(props)
    
    local value, setValue = React.useState(props.Value)

    -- return Overlay({
    --     Size = UDim2.new(1, 40,1, 40),
    --     Position = UDim2.new(0, -20, 0, -20),
    -- }, {
    return Panel({
            AnchorPoint = Vector2.new(0.5, 0.5),
            Title = "Edit Field",
            Size = UDim2.new(0, 500, 0, 0),
            ShowClose = true,
            Position = UDim2.fromScale(0.5, 0.5),
            AutomaticSize = Enum.AutomaticSize.Y,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            OnClosePanel = props.OnClosePanel,
            -- ZIndex = 100
        }, {
            Content = Column({ --This overrides the built-in panel Column
                AutomaticSize = Enum.AutomaticSize.Y,
                Gaps = 8,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                PaddingHorizontal = 20,
                PaddingVertical = 20,
                -- ZIndex = 200,
            }, {
                TextInput = TextInput({
                    Label = props.Key,
                    OnChanged = function(newValue)
                        setValue(newValue)
                    end,
                    Placeholder = "",
                    Value = props.Value,
                    Size = UDim2.new(1, 0, 0, 100),
                    -- ZIndex = 300,
                }),
                Button1 = Button({
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Label = "Confirm",
                    LayoutOrder = 100,
                    OnActivated = function() props.OnConfirm(value) end,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Width = UDim.new(1, 0),
                    -- ZIndex = 300,
                }),
            })
        })
end

return function(props)
    return React.createElement(Modal, props)
end