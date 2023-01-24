local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Packages
local Dash = require(Packages.Dash)
local React = require(Packages.React)
local Roact = require(Packages.Roact)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Block = FishBloxComponents.Block
local Button = FishBloxComponents.Button
local Column = FishBloxComponents.Column
local Row = FishBloxComponents.Row
local Gap = FishBloxComponents.Gap
local Panel = FishBloxComponents.Panel
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

local Scene = require(script.Parent.Parent.Scene)
local SmallLabel = require(script.Parent.SmallLabel)

local add = require(script.Parent.Helpers.add)

type Props = {
    Appearance : string,
    ButtonLabel : string,
    IndentAmount : number,
    Label : string,
    LayoutOrder : number,
    Machine : table,
    OnActivated : any,
}

return function(props: Props)
    local children = {}
    
    local hasLabel = typeof(props.Label) == "string"
    local filled = (props.Appearance == "Filled")

    local machine = props.Machine
    local x = tonumber(machine["coordinates"]["X"])
    local y = tonumber(machine["coordinates"]["Y"])
    assert((x or y), "Machine coordinate error in data!")
    local machineAnchor = Scene.getMachineAnchor(x,y)
    local showError: boolean = not Scene.isMachineAnchor(machineAnchor)
    local errorText: string = showError and "Cannot find corresponding Machine Anchor ("..x..","..y..")!"

    local buttonStyle = {
        uiCorner = React.createElement("UICorner"),
        uiStroke = filled or React.createElement("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(79, 159, 243),
            Thickness = 1,
        }),
        uiPadding = Roact.createElement("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 5),
        })
    }

    local outputStr = "outputs: "
    for j,output in machine["outputs"] do
        local separator = j > 1 and ", " or ""
        outputStr = outputStr..separator..output
    end

    add(children, SmallLabel({
        Bold = false,
        FontSize = 16,
        Label = outputStr
    }))

    return Column({
    }, {
        Row = Row({
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 0.5,
            Gaps = 8,
            Size = UDim2.new(1, 0, 0, 0),
            LayoutOrder = props.LayoutOrder
        }, {
            Label = hasLabel and SmallLabel({
                FontSize = 18,
                Label = props.Label,
                LayoutOrder = 1,
            }),
            EditButton = React.createElement("TextButton", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = Color3.fromRGB(32, 117, 233),
                BackgroundTransparency = filled and 0 or 0.85,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                LayoutOrder = 2,
                RichText = true,
                Size = UDim2.new(0, 30, 0, 30),
                Text = "Edit",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 20,
                TextXAlignment = Enum.TextXAlignment.Center,
                [Roact.Event.MouseButton1Click] = function()
                    props.OnMachineEditClicked(machine, machineAnchor)
                end,
            }, buttonStyle),
            DeleteButton = React.createElement("TextButton", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = Color3.fromRGB(32, 117, 233),
                BackgroundTransparency = filled and 0 or 0.85,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                LayoutOrder = 3,
                RichText = true,
                Size = UDim2.new(0, 30, 0, 30),
                Text = "Del",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 20,
                TextXAlignment = Enum.TextXAlignment.Center,
                [Roact.Event.MouseButton1Click] = function() print("Delete Clicked") end,
            }, buttonStyle),
            
        }),
        Error = showError and Text({
            Text = errorText,
            Color = Color3.new(1, 0, 0),
        }),
        FixButton = showError and React.createElement("TextButton",{
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Color3.fromRGB(32, 117, 233),
            BackgroundTransparency = filled and 0 or 0.85,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
            LayoutOrder = 3,
            RichText = true,
            Size = UDim2.new(0, 30, 0, 30),
            Text = "Fix",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Center,
            [Roact.Event.MouseButton1Click] = function()
                props.FixMissingMachineAnchor(machine)
            end,
        })
    })
end