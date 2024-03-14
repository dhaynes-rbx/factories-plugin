local React = require(script.Parent.Parent.Parent.Packages.React)
local ReactRoblox = require(script.Parent.Parent.Parent.Packages.ReactRoblox)

type Props = {
    Text: string,
    TextSize: number,
    LayoutOrder: number,
    OnActivate: () -> any,
}

local function TextItem(props: Props)
    return React.createElement("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = props.LayoutOrder,
        Size = UDim2.new(1, 0, 0, 30),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, {
        label = React.createElement("TextButton", {
            Active = props.OnActivate and true or false,
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Text = props.Text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = props.TextSize or 16,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0, 1),

            [ReactRoblox.Event.Activated] = props.OnActivate and function()
                props.OnActivate()
            end,
        }),
    })
end

return function(props: Props)
    return React.createElement(TextItem, props)
end
