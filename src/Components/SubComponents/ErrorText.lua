local Packages = script.Parent.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Block = FishBloxComponents.Block

type Props = {
    Text:string,
}

function ErrorText(props:Props)
    -- return React.createElement(React.Fragment, {}, {})
    return Block({
        AutomaticSize = Enum.AutomaticSize.X,
        HasStroke = true,
        StrokeThickness = 1,
        Padding = 4,
        LayoutOrder = props.LayoutOrder,
    }, {
        Text = FishBloxComponents.Text({
            Bold = true,
            Text = props.Text,
            Color = Color3.new(1,0,0),
        })
    })
end

return function(props: Props)
    return React.createElement(ErrorText, props)
end