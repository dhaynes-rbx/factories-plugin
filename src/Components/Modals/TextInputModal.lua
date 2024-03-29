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
    Key: string,
    OnClosePanel: any,
    OnConfirm: any,
    Value: string | number,
    ValueType: string,
}

local function TextInputModal(props: Props)
    
    local value, setValue = React.useState(props.Value)
    local showError, setShowError = React.useState(false)
    local isNumber = props.ValueType == "number"
    
    return Overlay({
        Size = UDim2.new(1, 40,1, 40),
        Position = UDim2.new(0, -20, 0, -20),
    }, { 
        Panel({
            AnchorPoint = Vector2.new(0.5, 0.5),
            Title = "Edit Field",
            Size = UDim2.new(0, 500, 0, 0),
            ShowClose = true,
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
            }, {
                TextInput = TextInput({
                    Label = props.Key,
                    OnChanged = function(newValue)
                        if isNumber then
                            if tonumber(newValue) then
                                setShowError(false)
                                setValue(tonumber(newValue))
                            else
                                setShowError(true)
                            end
                        else
                            setShowError(false)
                            setValue(newValue)
                        end
                    end,
                    Placeholder = "",
                    Value = value,
                    Size = UDim2.new(1, 0, 0, 100),
                    ZIndex = 2,
                }),
                Error = showError and Text({
                    Text = "Error! Only numbers allowed.",
                    Color = Color3.new(1, 0, 0),
                    ZIndex = 2,
                }),
                Button1 = Button({
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Label = "Confirm",
                    LayoutOrder = 100,
                    OnActivated = function() 
                        if isNumber and tonumber(value) then
                            props.OnConfirm(tonumber(value))
                        else
                            props.OnConfirm(value)
                        end
                    end,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Width = UDim.new(1, 0),
                    ZIndex = 2,
                }),
            })
        })
    })
end

return function(props)
    return React.createElement(TextInputModal, props)
end