local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Packages
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

type Props = {
    Appearance : string,
    ButtonLabel : string,
    IndentAmount : number,
    Label : string,
    LayoutOrder : number,
    OnActivated : any,
}

return function(props: Props)
    local hasLabel = typeof(props.Label) == "string"
    local filled = (props.Appearance == "Filled")
    local showError = props.ErrorText or false

    local buttonStyle = {
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
    }

    return Column({
    }, {
        Row = Row({
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 0.5,
            Gaps = 8,
            Size = UDim2.new(1, 0, 0, 0),
            LayoutOrder = props.LayoutOrder
        }, {
            Label = hasLabel and SmallLabel({
                FontSize = 18,
                Label = props.Label,
                LayoutOrder = 1,
            }),
            EditButton = React.createElement("TextButton", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = Color3.fromRGB(32, 117, 233),
                BackgroundTransparency = filled and 0 or 0.85,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                LayoutOrder = 2,
                RichText = true,
                Size = UDim2.new(0, 30, 0, 30),
                Text = "Edit",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 20,
                TextXAlignment = Enum.TextXAlignment.Center,
                [Roact.Event.MouseButton1Click] = function()
                    props.OnMachineEditClicked(props.MachineAnchor)
                end,
            }, buttonStyle),
            DeleteButton = React.createElement("TextButton", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = Color3.fromRGB(32, 117, 233),
                BackgroundTransparency = filled and 0 or 0.85,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                LayoutOrder = 3,
                RichText = true,
                Size = UDim2.new(0, 30, 0, 30),
                Text = "Del",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 20,
                TextXAlignment = Enum.TextXAlignment.Center,
                [Roact.Event.MouseButton1Click] = function() print("Delete Clicked") end,
            }, buttonStyle),
            
        }),
        Error = showError and Text({
            Text = props.ErrorText,
            Color = Color3.new(1, 0, 0),
        }),
    })
end