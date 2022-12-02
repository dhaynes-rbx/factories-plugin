--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Roact = require(Packages.Roact)

return function(props: { TopOffset: number, ZIndex: number }): Roact.Element
    return Roact.createElement("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 1, -props.TopOffset),
        Position = UDim2.fromOffset(0, props.TopOffset),
        ZIndex = props.ZIndex,
    }, {
        ClickBlocker = Roact.createElement("ImageButton", {
            Size = UDim2.fromScale(1, 1),
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ImageTransparency = 1,
            ZIndex = props.ZIndex,
        }),
    })
end
