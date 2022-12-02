local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Block = FishBloxComponents.Block
local Column = FishBloxComponents.Column
local Row = FishBloxComponents.Row
local TextInput = FishBloxComponents.TextInput
local Button = FishBloxComponents.Button
local Panel = FishBloxComponents.Panel

local Scene = require(script.Parent.Parent.Scene)

return function(props)
    local buttons = {}
    for i=1, 4 do
        buttons["Button"..i] = Button({
            Label = tostring(i),
            OnActivated = function() props.Callback(i) end,
            LayoutOrder = i
        })
    end
    
    return Block({
        Position = UDim2.new(0.5, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        AnchorPoint = Vector2.new(0.5, 1),
    }, {
        Row = Row({
            Gaps = 4
        }, buttons)
    })
end