local Packages = script.Parent.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local ReactRoblox = require(Packages.ReactRoblox)
local FishBloxComponents = FishBlox.Components

type Props = {
    Label: string,
    LayoutOrder: number,
    OnActivated: () -> number,
}

local function LabeledAddButton(props: Props)
    return React.createElement("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        LayoutOrder = props.LayoutOrder,
    }, {
        label = React.createElement("TextLabel", {
            FontFace = Font.new(
                "rbxasset://fonts/families/GothamSSm.json",
                Enum.FontWeight.Bold,
                Enum.FontStyle.Normal
            ),
            Text = props.Label,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0.6, 1),
        }),

        button = React.createElement("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.new(0, 40, 1, 0),
        }, {
            uIStroke = React.createElement("UIStroke", {
                Color = Color3.fromRGB(79, 159, 243),
                Thickness = 2,
            }),

            uICorner = React.createElement("UICorner", {
                CornerRadius = UDim.new(0, 6),
            }),

            textButton = React.createElement("TextButton", {
                FontFace = Font.new(
                    "rbxasset://fonts/families/GothamSSm.json",
                    Enum.FontWeight.Medium,
                    Enum.FontStyle.Normal
                ),
                Text = "+",
                TextColor3 = Color3.fromRGB(79, 159, 243),
                TextSize = 24,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                [ReactRoblox.Event.Activated] = function()
                    props.OnActivated()
                end,
            }),
        }),
    })
end
return function(props: Props)
    return React.createElement(LabeledAddButton, props)
end
