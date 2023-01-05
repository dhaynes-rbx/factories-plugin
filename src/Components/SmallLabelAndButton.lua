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

local SmallLabel = require(script.Parent.SmallLabel)
local SmallButton = require(script.Parent.SmallButton)

type Props = {
    Appearance : string,
    Label : string,
    ButtonLabel : string,
    LayoutOrder : number,
    OnActivated : any,
}

return function(props: Props)
    return Row({
            AutomaticSize = Enum.AutomaticSize.Y,
            Gaps = 10,
            PaddingTop = -15,
            Size = UDim2.new(1, 0, 0, 0),
        }, {
            Label = SmallLabel({
                Bold = true,
                Label = props.Label,
                LayoutOrder = 1,
            }),
            Button = not props.Inactive and SmallButton({
                Label = props.ButtonLabel,
                LayoutOrder = 3,
                OnActivated = props.OnActivated
            })
        })
    
end