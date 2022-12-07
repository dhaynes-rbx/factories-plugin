local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")

local Packages = script.Parent.Parent.Packages
local Dash = require(Packages.Dash)
local Types = require(script.Parent.Parent.Types)
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components

local Block = FishBloxComponents.Block
local Button = FishBloxComponents.Button
local Column = FishBloxComponents.Column
local Panel = FishBloxComponents.Panel
local Row = FishBloxComponents.Row
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

return function(props)
    local machineAnchor = props.MachineAnchor
    
    local dataset = HttpService:JSONDecode(require(props.DatasetInstance))
    -- print(dataset["maps"][2]["machines"][1].coordinates)
    --Find the machine anchor's corresponding machine entry in the dataset
    local machineData = nil
    local coordString = string.sub(machineAnchor.Name, 2, #machineAnchor.Name - 1):split(",")
    local map = dataset["maps"][2]
    local machines = map["machines"]
    for _, machine in machines do
        if coordString[1] == tostring(machine.coordinates.X) then
            if coordString[2] == tostring(machine.coordinates.Y) then
                machineData = machine
                break
            end
        end
    end
    local temp = Dash.pretty(machineData)
    print(temp)

    -- {
        -- id = machineData.id,
        -- type = machineData["type"],
        -- outputs = machineData.outputs,
        -- defaultMaxStorage = 10,
        -- defaultProductionDelay = 10,
        -- defaultOutputCount = 10,
        -- sources = {

        -- },
        -- destinations = {

        -- },
        -- coordinates = {
        --     X = coordString[1],
        --     Y = coordString[2],
        -- },
        -- outputRange = {
        --     min = 10,
        --     max = 100
        -- },
        -- powerup = "None",
        -- supportsPowerup = true,
    -- }
    --plugin-only properties
    -- machineInfo.anchor = machineAnchor:GetFullName()


    local contents = {
        -- MachineNameText = Text({
        --     Color = Color3.new(1,1,1),
        --     FontSize = 24,
        --     RichText = true,
        --     Text = "Id: ",
        -- }),
        -- TypeText = Text({
        --     Color = Color3.new(1,1,1),
        --     FontSize = 24,
        --     RichText = true,
        --     Text = "Type: ",
        -- }),
        Coordinates = Column({}, {
            Label = Text({
                Bold = true,
                Color = Color3.new(1,1,1),
                FontSize = 24,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                RichText = true,
                Text = "Coordinates:",
                LayoutOrder = 1,
            }),
            CoordinateRow = Row({
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.fromScale(1, 0),
                LayoutOrder = 2
            }, {
                Y = TextInput({
                    Label = "Y",
                    Placeholder = "Y",
                    Value = machineData.coordinates.Y,
                    Size = UDim2.fromScale(0.5, 0),
                    LayoutOrder = 2
                }),
                X = TextInput({
                    Label = "X",
                    Placeholder = "X",
                    Value = machineData.coordinates.X,
                    Size = UDim2.fromScale(0.5, 0),
                    LayoutOrder = 1
                }),
            })
        })
    }

    return Panel({
        OnClosePanel = props.OnClosePanel,
        ShowClose = true,
        Size = UDim2.new(0, 300, 1, 0),
        Title = "Edit Machine",
    }, {
        Content = Column({ --This overrides the built-in panel Column
            AutomaticSize = Enum.AutomaticSize.Y,
            Gaps = 8,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            PaddingHorizontal = 20,
            PaddingVertical = 20,
            Width = 300,
        }, contents)
    })
end

