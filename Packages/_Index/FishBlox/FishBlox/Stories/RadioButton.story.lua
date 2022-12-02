--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RadioButton = require(ReplicatedStorage.Packages.FishBlox.Components.RadioButtonGroup.RadioButton)

return {
    name = "RadioButton",
    summary = "A basic radio button to select from a list of options.",
    controls = {
        Label = "My label",
        Value = "My value",
        Active = true,
        Hovered = false,
        Checked = false,
        Selected = false,
        AsColumn = false,
        LayoutOrder = 0,
    },
    story = function(props)
        return RadioButton({
            Label = props.controls.Label,
            Value = props.controls.Value,
            Active = props.controls.Active,
            Hovered = props.controls.Hovered,
            Checked = props.controls.Checked,
            Selected = props.controls.Selected,
            AsColumn = props.controls.AsColumn,
            Layout = props.controls.LayoutOrder,
        })
    end,
}
