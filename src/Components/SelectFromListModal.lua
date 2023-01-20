local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local Dash = require(Packages.Dash)

local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Column = FishBloxComponents.Column
local TextInput = FishBloxComponents.TextInput
local Text = FishBloxComponents.Text
local Button = FishBloxComponents.Button
local RadioButtonGroup = FishBloxComponents.RadioButtonGroup
local Panel = FishBloxComponents.Panel
local Overlay = FishBloxComponents.Overlay
local Scene = require(script.Parent.Parent.Scene)

type Props = {
    Choices: table,
    OnClosePanel: any,
    OnConfirm: any,
    Value: string | number,
    ValueType: string,
}

local function SelectFromListModal(props: Props)
    
    local value, setValue = React.useState(props.Value)
    local showError, setShowError = React.useState(false)
    
    local choiceKeys = Dash.keys(props.Choices)
    table.sort(choiceKeys, function(a,b)  --Do this to make sure buttons show in alphabetical order
        return a:lower() < b:lower()
    end)
    local radioButtons = {}
    for _,choiceKey in choiceKeys do
        table.insert(radioButtons, {
            Choice = props.Choices[choiceKey],
            Label = props.Choices[choiceKey]["id"],
            Value = choiceKey,
        })
        
    end

    return Panel({
        AnchorPoint = Vector2.new(0.5, 0.5),
        Title = "Choose Item",
        Size = UDim2.new(0, 500, 0, 500),
        ShowClose = true,
        Position = UDim2.fromScale(0.5, 0.5),
        
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        OnClosePanel = props.OnClosePanel,
        -- ZIndex = 100
    }, {
        ScrollingFrame = React.createElement("ScrollingFrame", {
        -- AutomaticSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 5, 0),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        }, {
            Content = Column({
                -- AutomaticSize = Enum.AutomaticSize.Y,
                Gaps = 8,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                PaddingHorizontal = 20,
                PaddingVertical = 20,
                -- ZIndex = 200,
            }, {
                RadioButtonGroup = RadioButtonGroup({
                    Choices = radioButtons,
                    CurrentValue = value,
                    OnChanged = function(num, val) 
                        setValue(val)
                    end
                }),
                
                Error = showError and Text({
                    Text = "Error! Only numbers allowed.",
                    Color = Color3.new(1, 0, 0),
                })
            })
        }),
        Button1 = Button({
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Label = "Confirm",
            LayoutOrder = 100,
            OnActivated = function() 
                props.OnConfirm(value)
            end,
            TextXAlignment = Enum.TextXAlignment.Center,
            Width = UDim.new(1, 0),
            -- ZIndex = 300,
        }),
    })
end

return function(props)
    return React.createElement(SelectFromListModal, props)
end