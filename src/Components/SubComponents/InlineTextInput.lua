local React = require(script.Parent.Parent.Parent.Packages.React)
local Incrementer = require(script.Parent.Parent.Parent.Incrementer)

type Props = {
    Text: string,
}

local function InlineTextInput(props: Props)
    local layoutOrder = Incrementer.new()
    return React.createElement("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
    }, {
        label = React.createElement("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Text = "ID",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0.4, 1),
            LayoutOrder = layoutOrder:Increment(),
        }),

        uIListLayout = React.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),

        frame = React.createElement("Frame", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(0.6, 1),
            LayoutOrder = layoutOrder:Increment(),
        }, {
            input = React.createElement("TextBox", {
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                PlaceholderText = "templateMachine",
                Text = props.Text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
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
    return React.createElement(InlineTextInput, props)
end
