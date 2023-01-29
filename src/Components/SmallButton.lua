local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)

type Props = {
    Appearance : string,
    Label : string,
    LayoutOrder : number,
    OnActivated : any,
    Size : UDim2,
}

return function(props : Props)
    local filled = (props.Appearance == "Filled")
    local buttonStyle = {
        uiCorner = React.createElement("UICorner"),
        uiStroke = filled or React.createElement("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(79, 159, 243),
            Thickness = 1,
        }),
        uiPadding = React.createElement("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 5),
        })
    }

    return React.createElement("TextButton", {
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Color3.fromRGB(32, 117, 233),
        BackgroundTransparency = filled and 0 or 0.85,
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
        LayoutOrder = props.LayoutOrder,
        RichText = true,
        Size = props.Size or UDim2.new(0, 30, 0, 30),
        Text = props.Label,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Center,
        [React.Event.MouseButton1Click] = props.OnActivated,
    }, buttonStyle)
end