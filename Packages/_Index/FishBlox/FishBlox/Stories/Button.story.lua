--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = script.Parent.Parent.Parent
local Roact = require(ReplicatedStorage.Packages.Roact)
local BentoBlox = require(Packages.BentoBlox)
local Block = require(BentoBlox.Components.Block)
local Text = require(ReplicatedStorage.Packages.FishBlox.Components.Text)
local Button = require(ReplicatedStorage.Packages.FishBlox.Components.Button)

--- Module

--[[--

]]

return {
    name = "Button",
    summary = "A basic button.",
    controls = {
        Appearance = { "Filled", "Outline", "Borderless", "Roblox" },
        Label = "Button Label",
        IsNavigation = true,
        NavDirection = { "forward", "back" },
    },
    story = function(props)
        return Button({
            Appearance = props.controls.Appearance,
            Label = props.controls.Label,
            IsNavigation = props.controls.IsNavigation,
            NavDirection = props.controls.NavDirection,
        })
    end,
}
