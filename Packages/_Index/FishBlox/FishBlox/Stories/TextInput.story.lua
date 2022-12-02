--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = script.Parent.Parent.Parent
local BentoBlox = require(Packages.BentoBlox)
local Text = require(ReplicatedStorage.Packages.FishBlox.Components.Text)
local TextInput = require(ReplicatedStorage.Packages.FishBlox.Components.TextInput)

return {
    name = "TextInput",
    summary = "A component to capture user text input.",
    controls = { Value = "", Placeholder = "Enter some text", Wrap = false, Disabled = false, LabelInline = false },
    story = function(props)
        return TextInput({
            Size = UDim2.fromOffset(350, 50),
            AutomaticSize = Enum.AutomaticSize.Y,
            Value = props.controls.Value,
            Placeholder = props.controls.Placeholder,
            Wrap = props.controls.Wrap,
            Disabled = props.controls.Disabled,
            LabelInline = props.controls.LabelInline,
        }, {
            -- Uncomment the next line to see label slot replacement
            -- Label = Text({ Text = "Hello this is slot content", AutomaticSize = Enum.AutomaticSize.XY }),
        })
    end,
}
