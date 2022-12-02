--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProgressTrack = require(ReplicatedStorage.Packages.FishBlox.Components.ProgressTrack)

return {
    name = "ProgressTrack",
    summary = "A component representing progress in a task.",
    controls = {
        Steps = 4,
        CurrentStep = 2,
        CurrentStepStyle = "Default",
        Alignment = "OffsetLeft",
    },
    story = function(props)
        return ProgressTrack({
            Steps = props.controls.Steps,
            CurrentStep = props.controls.CurrentStep,
            CurrentStepStyle = props.controls.CurrentStepStyle,
            Alignment = props.controls.Alignment,
        })
    end,
}
