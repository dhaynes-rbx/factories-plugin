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

local SmallButtonWithLabel = require(script.Parent.SubComponents.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SubComponents.SmallLabel)
local SidePanel = require(script.Parent.SubComponents.SidePanel)

local Scene = require(script.Parent.Parent.Scene)
local Studio = require(script.Parent.Parent.Studio)

type Props = {

}

local function EditPowerupsListUI(props: Props)
    
    return SidePanel({
            Title = "Edit Powerups List",
            ShowClose = true,
            OnClosePanel = props.OnClosePanel,
        }, {

        }
    )
end

return function(props)
    return React.createElement(EditPowerupsListUI, props)
end