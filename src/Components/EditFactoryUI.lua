local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Column = FishBloxComponents.Column
local TextInput = FishBloxComponents.TextInput
local Button = FishBloxComponents.Button
local Panel = FishBloxComponents.Panel

local Scene = require(script.Parent.Parent.Scene)

-- local Dash = require(Packages.Dash)

return function(props)

    local panel = Panel({
        Title = "Edit Factory",
        Size = UDim2.new(0, 300, 1, 0),
    }, {
        Content = Column({ --This overrides the built-in panel Column
            Gaps = 8,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            AutomaticSize = Enum.AutomaticSize.Y,
            Width = 300,
        }, {
            DatasetNameInput = TextInput({
                Label = "Dataset Name",
                LayoutOrder = 0,
            }),
            

            
        })
    })

    

    return panel
end