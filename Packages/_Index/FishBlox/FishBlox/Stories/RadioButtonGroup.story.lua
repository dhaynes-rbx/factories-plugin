--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RadioButtonGroup = require(ReplicatedStorage.Packages.FishBlox.Components.RadioButtonGroup)

return {
    name = "RadioButtonGroup",
    summary = "A basic group of radio buttons to select from a list of options.",
    controls = { CurrentValue = "One" },
    story = function(props)
        return RadioButtonGroup({
            Gaps = 12,
            Choices = {
                {
                    Label = "One",
                    Order = 1,
                    Value = "One",
                },
                { Label = "Two", Order = 2, Value = "Two" },
                { Label = "Three", Order = 3, Value = "Three" },
            },
            CurrentValue = props.controls.CurrentValue,
            OnChanged = function(num, value)
                props.setControls({
                    CurrentValue = value,
                })
            end,
        })
    end,
}
