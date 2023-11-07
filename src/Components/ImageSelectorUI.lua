local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Dash = require(Packages.Dash)
local Block = FishBloxComponents.Block
local Row = FishBloxComponents.Row
local Button = FishBloxComponents.Button
local Column = FishBloxComponents.Column
local Gap = FishBloxComponents.Gap
local Panel = FishBloxComponents.Panel
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

local TextInputModal = require(script.Parent.Modals.TextInputModal)
local SmallButtonWithLabel = require(script.Parent.SubComponents.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SubComponents.SmallLabel)
local SidePanel = require(script.Parent.SubComponents.SidePanel)
local ListItemButton = require(script.Parent.SubComponents.ListItemButton)

local Dataset = require(script.Parent.Parent.Dataset)
local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Studio = require(script.Parent.Parent.Studio)
local Manifest = require(script.Parent.Parent.Manifest)

--use this to create a consistent layout order that plays nice with Roact
local index = 0
local incrementLayoutOrder = function()
    index = index + 1
    return index
end
type Props = {
    OnClick:(any)
}

local function ImageButton(imageKey, onClick)
    local hover, setHover = React.useState(false)

    local prefix = imageKey:split("-")[1]
    local imageLabel = imageKey:gsub(prefix, ""):sub(2)
    return Block({
        BackgroundTransparency = hover and .85 or 0.9,
        Corner = UDim.new(0,8),
        HasStroke = true,
        StrokeThickness = 2,
        StrokeColor = Color3.new(1,1,1),
        StrokeTransparency = hover and 0.7 or 0.8,
        LayoutOrder = incrementLayoutOrder(),
        Size = UDim2.new(0, 90, 0, 120),
        OnClick = function()
            onClick(imageKey)
        end,
        OnMouseEnter = function()
            setHover(true)

        end,
        OnMouseLeave = function() 
            setHover(false)

        end,
    }, {
        Column = Column({
            Padding = UDim.new(0,8),
            Gaps = 8,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
        },{
            Image = React.createElement("ImageLabel", {
                BackgroundTransparency = 1,
                Image = Manifest.images[imageKey],
                LayoutOrder = 1,
                Size = UDim2.fromScale(0.9,0.9),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
            }),
            Text = Text({
                Color = Color3.new(1,1,1),
                TextXAlignment = Enum.TextXAlignment.Center,
                LayoutOrder = 2,
                Text = imageLabel,
            })
        })
    })
end

local function ImageButtonRow(imageNames:{string}, onClick)
    local rowButtons = {}
    for _,v in imageNames do
        table.insert(rowButtons, ImageButton(v, onClick))
    end
    return Row({Gaps = 12}, rowButtons)
end

local function ImageSelectorUI(props:Props)
    local children = {}
    
    local thumbnails = {}
    for imageKey,_ in Manifest.images do
        if imageKey:split("-")[1] == "icon" then
            table.insert(thumbnails, imageKey)
        end
    end
    table.sort(thumbnails, function(a,b)  --Do this to make sure buttons show in alphabetical order
        return a:lower() < b:lower()
    end)

    local count = 0
    local imagesToShow = {}
    for _,imageKey in thumbnails do    
        count = count + 1
        if count%3 == 0 then
            table.insert(imagesToShow, imageKey)
            table.insert(children, ImageButtonRow(imagesToShow, props.OnClick))
            table.clear(imagesToShow)
        else
            table.insert(imagesToShow, imageKey)
        end
    end

    return React.createElement(React.Fragment, nil, {
        SidePanel({
            Gaps = 12,
            Title = "Choose a thumbnail",
            ShowClose = true,
            OnClosePanel = props.OnClosePanel,
        }, children),
    })
end

return function(props:Props)
    return React.createElement(ImageSelectorUI, props)
end