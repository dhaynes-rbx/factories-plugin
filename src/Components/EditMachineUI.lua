local Selection = game:GetService("Selection")

local Packages = script.Parent.Parent.Packages
local Types = require(script.Parent.Parent.Types)
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components

local Block = FishBloxComponents.Block
local Button = FishBloxComponents.Button
local Column = FishBloxComponents.Column
local Panel = FishBloxComponents.Panel
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

local function selectedObjectIsMachine()
    if #Selection:Get() >= 1 and Selection:Get()[1].Parent.Name == "Machines" then
       return true
    end
    return false
end

return function(props)
    local machine : Types.Machine = {
        
        id = props.SelectedMachine.Name,
        type = "Maker",
        outputs = {

        },
        defaultMaxStorage = 10,
        defaultProductionDelay = 10,
        defaultOutputCount = 10,
        sources = {

        },
        destinations = {

        },
        coordinates = {

        },
        outputRange = {
            min = 10,
            max = 100
        },
        powerup = "None",
        supportsPowerup = true,
    }

    local contents = {
        MachineNameText = Text({
            Text = "Id: "..machine.id,
            Color = Color3.new(1,1,1),
            RichText = true,
            FontSize = 24,
        }),
        TypeText = Text({
            Text = "Type: "..machine.type,
            Color = Color3.new(1,1,1),
            RichText = true,
            FontSize = 24,
        }),
    }

    return Panel({
        Size = UDim2.new(0, 300, 1, 0),
        ShowClose = true,
        OnClosePanel = props.OnClosePanel,
        Title = "Edit Machine",
    }, {
        Content = Column({ --This overrides the built-in panel Column
            AutomaticSize = Enum.AutomaticSize.Y,
            Gaps = 8,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            PaddingHorizontal = 20,
            PaddingVertical = 20,
            Width = 300,
        }, selectedObjectIsMachine() and contents)
    })
end

