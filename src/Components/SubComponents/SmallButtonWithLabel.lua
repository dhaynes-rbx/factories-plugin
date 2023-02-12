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
local Row = FishBloxComponents.Row
local Gap = FishBloxComponents.Gap
local Panel = FishBloxComponents.Panel
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

local SmallLabel = require(script.Parent.SmallLabel)
local SmallButton = require(script.Parent.SmallButton)

type Props = {
    Appearance : string,
    ButtonLabel : string,
    IndentAmount : number,
    Label : string,
    LayoutOrder : number,
    OnActivated : any,
    OnDeleteButtonPressed : any,
}

return function(props: Props)
    local hasLabel = typeof(props.Label) == "string"
    local filled = (props.Appearance == "Filled")
    local indentAmount = props.IndentAmount or 0

    return Block({
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 0),
        LayoutOrder = props.LayoutOrder
    }, {
        Block = Block({
            LayoutOrder = 0,
            Size = UDim2.fromOffset(indentAmount, 0)
        }),
        Label = hasLabel and SmallLabel({
            Bold = false,
            Label = props.Label,
            LayoutOrder = 1,
        }),
        Gap = hasLabel and Block({
            LayoutOrder = 2,
            Size = UDim2.new(0, 10, 0, 0),
        }),
        Button = React.createElement("TextButton", {
            AutomaticSize = Enum.AutomaticSize.X,
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(32, 117, 233),
            BackgroundTransparency = filled and 0 or 0.85,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
            LayoutOrder = 3,
            Position = UDim2.new(1, 0, 0, 0),
            RichText = true,
            Size = UDim2.new(0, 100, 0, 30),
            Text = props.ButtonLabel,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Right,
            [Roact.Event.MouseButton1Click] = props.OnActivated
        }, {
            uiCorner = React.createElement("UICorner"),
            uiStroke = filled or React.createElement("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Color3.fromRGB(79, 159, 243),
                Thickness = 1,
            }),
            uiPadding = Roact.createElement("UIPadding", {
                PaddingBottom = UDim.new(0, 5),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 5),
            })
        }),
    })
end