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

local Scene = require(script.Parent.Parent.Scene)
local SmallLabel = require(script.Parent.SmallLabel)

local add = require(script.Parent.Helpers.add)

type Props = {
    Appearance : string,
    LabelColor : Color3,
    Label : string,
    LayoutOrder : number,
    Item : table,
    OnEditButtonClicked : any,
    OnDeleteButtonClicked : any,
}

return function(props: Props)
    local children = {}
    
    local hasLabel = typeof(props.Label) == "string"
    local filled = (props.Appearance == "Filled")

    --check to make sure item is used
    local showError = (props.Error ~= nil)

    -- local errorText: string = showError and "Cannot find corresponding Machine Anchor: "..debugId.."!"

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
                Color = props.LabelColor,
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
                    props.OnEditButtonClicked(props.Item["id"])
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
                [Roact.Event.MouseButton1Click] = function() 
                    props.OnDeleteButtonClicked(props.Item["id"])
                end,
            }, buttonStyle),
            
        }),
        Error = showError and Text({
            Text = props.Error,
            Color = Color3.new(1, 0, 0),
            LayoutOrder = 100,
        }),
    })
end