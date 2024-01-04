local React = require(script.Parent.Parent.Parent.Packages.React)
local ReactRoblox = require(script.Parent.Parent.Parent.Packages.ReactRoblox)

type Props = {
    Text: string,
    OnChanged: (string) -> any,
}

local function TextInput(props: Props)
    return React.createElement("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
    }, {
        frame = React.createElement("Frame", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
        }, {
            input = React.createElement("TextBox", {
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                PlaceholderText = "Enter Localized Name",
                Text = props.Text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),

                [ReactRoblox.Change.Text] = function(text)
                    props.OnChanged(text)
                end,
            }, {
                uICorner = React.createElement("UICorner"),
            }),

            uIStroke = React.createElement("UIStroke", {
                Color = Color3.fromRGB(79, 159, 243),
                Thickness = 2,
            }),

            uICorner1 = React.createElement("UICorner", {
                CornerRadius = UDim.new(0, 6),
            }),

            uIPadding = React.createElement("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
            }),
        }),
    })
end

return function(props: Props)
    return React.createElement(TextInput, props)
end
