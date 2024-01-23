local React = require(script.Parent.Parent.Parent.Packages.React)
local ReactRoblox = require(script.Parent.Parent.Parent.Packages.ReactRoblox)
local Packages = script.Parent.Parent.Parent.Packages
local Dash = require(Packages.Dash)
local Incrementer = require(script.Parent.Parent.Parent.Incrementer)

type Props = {
    LayoutOrder: number,
    ToggleIndex: number,
}

type RadioButtonProps = {
    LayoutOrder: number,
    Toggled: boolean,
}

local function RadioButton(props: Props)
    return React.createElement("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        LayoutOrder = props.LayoutOrder,
        Size = UDim2.fromScale(0.333, 1),
    }, {
        button = React.createElement("Frame", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.fromOffset(20, 20),
        }, {
            uIStroke = React.createElement("UIStroke", {
                Color = Color3.fromRGB(79, 159, 243),
                Thickness = 2,
            }),

            uICorner = React.createElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
            }),

            imageButton = React.createElement("ImageButton", {
                ImageTransparency = 1,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                [ReactRoblox.Event.Activated] = function()
                    props.OnActivated()
                end,
            }),

            toggle = props.Toggled and React.createElement("Frame", {
                BackgroundColor3 = Color3.fromRGB(79, 159, 243),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
            }, {
                uICorner1 = React.createElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),
            }),

            uIPadding = React.createElement("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 4),
                PaddingRight = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
            }),
        }),

        uIListLayout = React.createElement("UIListLayout", {
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),

        label = React.createElement("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Text = props.Label,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(0, 30),
        }),
    })
end

local function RadioButtonGroup(props: Props)
    local layoutOrder = Incrementer.new()

    local ephemerals = {
        uIListLayout = React.createElement("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),

        uIPadding = React.createElement("UIPadding", {
            PaddingTop = UDim.new(0, 12),
        }),
    }

    local children = {
        Purchaser = RadioButton({
            Label = "Purchaser",
            Toggled = props.ToggleIndex == 1,
            LayoutOrder = layoutOrder:Increment(),
            OnActivated = function()
                props.OnRadioButtonToggled(1)
            end,
        }),
        Maker = RadioButton({
            Label = "Maker",
            Toggled = props.ToggleIndex == 2,
            LayoutOrder = layoutOrder:Increment(),
            OnActivated = function()
                props.OnRadioButtonToggled(2)
            end,
        }),
        MakerSeller = RadioButton({
            Label = "MakerSeller",
            Toggled = props.ToggleIndex == 3,
            LayoutOrder = layoutOrder:Increment(),
            OnActivated = function()
                props.OnRadioButtonToggled(3)
            end,
        }),
    }

    children = Dash.join(ephemerals, children)

    return React.createElement("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = props.LayoutOrder,
        Size = UDim2.new(1, 0, 0, 60),
    }, children)
end

return function(props: Props)
    return React.createElement(RadioButtonGroup, props)
end
