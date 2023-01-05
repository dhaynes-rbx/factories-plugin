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
local Gap = FishBloxComponents.Gap
local Panel = FishBloxComponents.Panel
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

return function(props)
    local filled = props.Appearance == "Filled"

    return React.createElement("TextButton", {
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Color3.fromRGB(32, 117, 233),
        BackgroundTransparency = filled and 0 or 0.85,
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
        LayoutOrder = props.LayoutOrder,
        RichText = true,
        Size = UDim2.fromOffset(20, 30),
        Text = props.Label,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        [Roact.Event.MouseButton1Click] = props.OnActivated
    }, {
        uiCorner = React.createElement("UICorner"),
        uiStroke = filled or React.createElement("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(79, 159, 243),
            Thickness = 1,
        }),
        uiPadding = Roact.createElement("UIPadding", {
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
        })
    })
end
