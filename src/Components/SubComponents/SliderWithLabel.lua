local React = require(script.Parent.Parent.Parent.Packages.React)
local ReactRoblox = require(script.Parent.Parent.Parent.Packages.ReactRoblox)
local Packages = script.Parent.Parent.Parent.Packages
local Dash = require(Packages.Dash)
local Incrementer = require(script.Parent.Parent.Parent.Incrementer)

type Props = {
    LayoutOrder: number,
}

local function SliderWithLabel(props: Props)
    return React.createElement("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
    }, {
        slider = React.createElement("Frame", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            LayoutOrder = 2,
            Size = UDim2.new(1, 0, 0, 40),
        }, {
            sliderBG = React.createElement("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(79, 159, 243),
                BackgroundTransparency = 0.75,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 6),
            }, {
                uICorner = React.createElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),
            }),

            sliderButton = React.createElement("ImageButton", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
            }),

            sliderKnob = React.createElement("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(79, 159, 243),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(20, 20),
            }, {
                uICorner1 = React.createElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),

                knobButton = React.createElement("ImageButton", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 1),
                }),
            }),
        }),

        uIListLayout = React.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),

        label = React.createElement("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Text = "Conveyor Adjustment",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
        }),
    })
end

return function(props: Props)
    return React.createElement(SliderWithLabel, props)
end
