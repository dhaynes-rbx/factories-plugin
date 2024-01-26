local Packages = script.Parent.Parent.Parent.Packages
local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components

type Props = {
    Label: string,
    SubLabel: string,
    LayoutOrder: number,
    Value: string,
    OnReset: () -> nil,
    OnChanged: () -> number,
    OnHover: () -> number,
}

local function InlineNumberInput(props: Props)
    local hovered, setHovered = React.useState(false)

    return React.createElement("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = props.LayoutOrder,
        Size = UDim2.new(1, 0, 0, 50),
    }, {
        textInput = React.createElement("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.new(0, 100, 1, 0),
        }, {
            input = FishBloxComponents.TextInput({
                Value = props.Value,
                Size = UDim2.new(1, 0, 0, 50),
                HideLabel = true,
                MultiLine = false,
                OnChanged = function(value)
                    props.OnChanged(value)
                end,
            }),
        }),

        labels = React.createElement("Frame", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            [ReactRoblox.Event.MouseEnter] = function()
                if props.OnHover then
                    props.OnHover(true)
                    setHovered(true)
                end
            end,
            [ReactRoblox.Event.MouseLeave] = function()
                if props.OnHover then
                    props.OnHover(false)
                    setHovered(false)
                end
            end,
        }, {
            uIListLayout = React.createElement("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),

            subLabel = props.SubLabel and React.createElement("TextLabel", {
                FontFace = Font.new(
                    "rbxasset://fonts/families/GothamSSm.json",
                    Enum.FontWeight.Regular,
                    Enum.FontStyle.Italic
                ),
                Text = props.SubLabel,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 12,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                LayoutOrder = 10,
            }),

            label = React.createElement("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(0.6, 0),
            }, {
                label1 = React.createElement("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                    Text = props.Label,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 16,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(0, 0),
                }),

                imageButton = React.createElement("ImageButton", {
                    Image = "rbxassetid://15626193282",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromOffset(15, 15),
                    [ReactRoblox.Event.Activated] = function()
                        props.OnReset()
                    end,
                }),

                uIListLayout = React.createElement("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                }),
            }),
        }),
    })
end

return function(props: Props)
    return React.createElement(InlineNumberInput, props)
end
