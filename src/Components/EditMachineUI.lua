local Selection = game:GetService("Selection")

local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Column = FishBloxComponents.Column
local TextInput = FishBloxComponents.TextInput
local Button = FishBloxComponents.Button
local Panel = FishBloxComponents.Panel

local function selectedObjectIsMachine()
    if #Selection:Get() >= 1 and Selection:Get()[1].Parent.Name == "Machines" then
       print("Machine is selected")
    end
end

return function(props)
    local contents = {
        Button1 = selectedObjectIsMachine() and Button()
    }
    return Panel({
        Title = "Edit Machine",
        Size = UDim2.new(0, 300, 1, 0),
    }, {
        Content = Column({ --This overrides the built-in panel Column
            Gaps = 8,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            AutomaticSize = Enum.AutomaticSize.Y,
            Width = 300,
        }, contents)
    })
end