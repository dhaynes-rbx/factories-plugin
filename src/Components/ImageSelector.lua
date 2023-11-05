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

}

local function ImageButton(image)
    return React.createElement("Frame", {
        BackgroundTransparency = .95,
        LayoutOrder = incrementLayoutOrder(),
        Size = UDim2.new(0, 90, 0, 90),
        [React.Event.MouseEnter] = function() 
            -- setHover(true)
            -- if props.OnHover and props.ObjectToEdit["machineAnchor"] then
            --     props.OnHover(props.ObjectToEdit)
            -- end
        end,
        [React.Event.MouseLeave] = function() 
            -- setHover(false)
            -- if props.OnHover and props.ObjectToEdit["machineAnchor"] then
            --     props.OnHover(nil)
            -- end
        end,
    }, {
        Image = React.createElement("ImageLabel", {
            BackgroundTransparency = 1,
            Image = image, --Question mark icon
            LayoutOrder = 2,
            Size = UDim2.fromScale(1,1)
        })
    })
end

local function ImageButtonRow(images:{string})
    local rowButtons = {}
    for _,v in images do
        table.insert(rowButtons, ImageButton(v))
    end
    return Row({Gaps = 8}, rowButtons)
end

local function ImageSelector(props:Props)
    local children = {}
    
    local thumbnails = {}
    for k,v in Manifest.images do
        if k:split("-")[1] == "icon" then
            table.insert(thumbnails, v)
        end
    end
    table.sort(thumbnails, function(a,b)  --Do this to make sure buttons show in alphabetical order
        return a:lower() < b:lower()
    end)

    local count = 0
    local imagesToShow = {}
    for k,v in thumbnails do    
        count = count + 1
        if count%3 == 0 then
            table.insert(imagesToShow, v)
            table.insert(children, ImageButtonRow(imagesToShow))
            table.clear(imagesToShow)
        else
            table.insert(imagesToShow, v)
        end
    end

    return React.createElement(React.Fragment, nil, {
        SidePanel({
            Title = "Select Image",
            ShowClose = true,
            OnClosePanel = props.OnClosePanel,
        }, children),
    })
end

return function(props:Props)
    return React.createElement(ImageSelector, props)
end