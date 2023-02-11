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
local Icon = FishBloxComponents.Icon

local Scene = require(script.Parent.Parent.Scene)
local SmallLabel = require(script.Parent.SmallLabel)
local SmallButton = require(script.Parent.SmallButton)

local Manifest = require(script.Parent.Parent.Manifest)


type Props = {
    Image:string,
    Label:string,
    LayoutOrder:number,
    OnEditButtonClicked:any,
    OnDeleteButtonClicked:any,
}

function ListItemButton(props)
    local hover, setHover = React.useState(false)

    return React.createElement("Frame", {
        BackgroundTransparency = .95,
        LayoutOrder = props.LayoutOrder or 1,
        Size = UDim2.new(1, 0, 0, 45),
        [React.Event.MouseEnter] = function() 
            setHover(true)
        end,
        [React.Event.MouseLeave] = function() 
            setHover(false)
        end,
    }, {
        uiPadding = React.createElement("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 5),
        }),
        uiCorner = React.createElement("UICorner"),
        uiStroke = React.createElement("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 1,
            Transparency = 0.9,
        }),
        Row1 = Row({
            Gaps = 8,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            Size = UDim2.fromScale(1,1),
        }, {
            Index = props.Index and Text({
                AutomaticSize = Enum.AutomaticSize.X,
                Color = Color3.new(1,1,1),
                LayoutOrder = 0,
                
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                Text = props.Index
            }),
            Image = React.createElement("ImageLabel", {
                BackgroundTransparency = 1,
                Image = Manifest.images[props.Image] or "rbxassetid://7553285523", --Question mark icon
                LayoutOrder = 2,
                Size = UDim2.fromOffset(40,40),
            }),
            Text1 = Text({
                AutomaticSize = Enum.AutomaticSize.X,
                Color = Color3.new(1,1,1),
                LayoutOrder = 3,
                Size = UDim2.fromScale(1,1),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                Text = props.Label or "NONE"
            }),
        }),
        Row = Row({
            Gaps = 8,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Size = UDim2.fromScale(1, 1)
        }, {
            EditButton = hover and SmallButton({
                Label = "Edit",
                LayoutOrder = 10,
                OnActivated = function()
                    props.OnEditButtonClicked(props.ObjectToEdit["id"])
                end
            }),
            DeleteButton = hover and SmallButton({
                Label = "X",
                LayoutOrder = 11,
                OnActivated = function()
                    props.OnDeleteButtonClicked(props.ObjectToEdit["id"])
                end
            })
        })
    })
end

return function(props: Props)
    return React.createElement(ListItemButton, props)
end