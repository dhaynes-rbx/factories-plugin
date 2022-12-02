--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProgressTrackStep = require(ReplicatedStorage.Packages.FishBlox.Components.ProgressTrackStep)

return {
    name = "ProgressTrackStep",
    summary = "A component representing an individual step of the ProgressTrack",
    controls = {
        Step = 2,
        Current = false,
        Interactive = true,
        Focused = false,
        Style = "Default",
        Disabled = false,
    },
    story = function(props)
        return ProgressTrackStep({
            Step = props.controls.Step,
            Current = props.controls.Current,
            Interactive = props.controls.Interactive,
            Focused = props.controls.Focused,
            Style = props.controls.Style,
            OnActivated = function()
                print("activated")
            end,
            Disabled = props.controls.Disabled,
        })
    end,
}
