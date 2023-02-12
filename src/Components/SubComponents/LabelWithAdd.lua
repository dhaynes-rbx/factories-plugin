local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Parent.Packages
local Dash = require(Packages.Dash)
local React = require(Packages.React)
local Roact = require(Packages.Roact)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Block = FishBloxComponents.Block
local Button = FishBloxComponents.Button
local Column = FishBloxComponents.Column
local Gap = FishBloxComponents.Gap
local Row = FishBloxComponents.Row
local Panel = FishBloxComponents.Panel
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

local SmallLabel = require(script.Parent.SmallLabel)
local SmallButton = require(script.Parent.SmallButton)

type Props = {
    Label : string,
    LayoutOrder : number,
    OnActivated : any,
}

function LabelWithAddButton(props)
    local hover, setHover = React.useState(false)

    return React.createElement("Frame", {
        BackgroundTransparency = 1,
        LayoutOrder = props.LayoutOrder or 1,
        Size = UDim2.new(1, 0, 0, 45),
        [React.Event.MouseEnter] = function() 
            setHover(true)
        end,
        [React.Event.MouseLeave] = function() 
            setHover(false)
        end,
    },{
        Row1 = Row({
            Gaps = 8,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            Size = UDim2.fromScale(1,1),
        }, {
            Label = SmallLabel({
                Bold = true,
                Color = Color3.new(1,1,1),
                Label = props.Label,
                LayoutOrder = 5,
            }),
            AddButton = hover and SmallButton({
                Appearance = "Filled",
                AutomaticSize = Enum.AutomaticSize.X,
                Label = "Add",
                LayoutOrder = 10,
                Size = UDim2.fromOffset(25,25),
                OnActivated = props.OnActivated
            })
        })
    })
end

return function(props: Props)
    -- local isBold = (props.Bold == nil) and true or props.Bold
    -- return Text({
    --     Bold = isBold,
    --     Color = props.Color or Color3.new(1,1,1),
    --     FontSize = props.FontSize or 24,
    --     HorizontalAlignment = Enum.HorizontalAlignment.Left,
    --     LayoutOrder = props.LayoutOrder,
    --     RichText = true,
    --     Text = props.Label or "EMPTY",
    -- })
    return React.createElement(LabelWithAddButton, props)
end