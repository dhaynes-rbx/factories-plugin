local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")

local Packages = script.Parent.Parent.Packages
local React = Packages.React
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

local Vector2Row = require(script.Parent.Vector2Row)

return function(props)
    
    -- local showModal, setShowModal = React.useState({enabled = true, machineProperty = "locName"))

    local dataset = props.Dataset
    local machineAnchor = props.MachineAnchor
    -- print(dataset["maps"][2]["machines"][1].coordinates)
    --Find the machine anchor's corresponding machine entry in the dataset
    local machine : Types.Machine = nil
    local coordString = string.sub(machineAnchor.Name, 2, #machineAnchor.Name - 1):split(",")
    local map = dataset["maps"][2] --Only worried about non-tutorial maps for now
    local machines = map["machines"]
    for _, val in machines do
        if coordString[1] == tostring(val.coordinates.X) then
            if coordString[2] == tostring(val.coordinates.Y) then
                machine = val
                break
            end
        end
    end

    -- "id": "rubberPurchaser",
    -- "type": "purchaser",
    -- "locName": "Rubber Purchaser",
    -- "thumb": "",
    -- "asset": "Assets.Machines.Purchaser",
    -- "defaultProductionDelay": 0,
    -- "defaultMaxStorage": 2000,
    -- "state": "ready",
    -- "currentOutputIndex": 1,
    -- "currentOutputCount": 125,
    -- "outputRange": {
    --     "min": 0,
    --     "max": 1000
    -- },
    -- "outputs": [
    --     "rubber"
    -- ],
    -- "storage": {},
    -- "coordinates": {
    --     "X": -2,
    --     "Y": 1
    -- },
    -- "supportsPowerup": false

    local contents = {
        MachineNameText = Text({
            Bold = true,
            Color = Color3.new(1,1,1),
            FontSize = 24,
            LayoutOrder = 1,
            RichText = true,
            Text = machine.locName,
        }),
        Coordinates = Vector2Row({
            Label = "Coordinates",
            LayoutOrder = 2,
            X = machine.coordinates.X, 
            Y = machine.coordinates.Y
        }),

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

