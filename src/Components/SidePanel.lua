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
local Gap = FishBloxComponents.Gap
local Panel = FishBloxComponents.Panel
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

local Modal = require(script.Parent.Modal)
local SmallButtonWithLabel = require(script.Parent.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SmallLabel)

local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)

return function(props, children)
    children = children or {}
    local showClose = props.ShowClose
    if props.ShowClose == nil then
        showClose = true
    end

    return Panel({
        OnClosePanel = props.OnClosePanel,
        Title = props.Title,
        ShowClose = showClose,
        Size = UDim2.new(0, 400, 1, 0),
    },{
        ScrollingFrame = React.createElement("ScrollingFrame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.fromScale(1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollingDirection = Enum.ScrollingDirection.Y,
        },{
            Content = Column({ --This overrides the built-in panel Column
            AutomaticSize = Enum.AutomaticSize.Y,
            Gaps = 8,
            PaddingHorizontal = 20,
            PaddingTop = 5,
            }, children)
        })
    })
end