local Packages = script.Parent.Parent.Parent.Packages
local Dash = require(Packages.Dash)
local React = require(Packages.React)

type Props = {
    LayoutOrder:number,
}

return function(props:Props)
    return React.createElement("Frame", {
        Size = UDim2.new(1, 0 - 2, 0, 1),
        BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        LayoutOrder = props.LayoutOrder
    })
end