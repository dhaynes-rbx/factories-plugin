--!strict
local Packages = script.Parent.Parent.Parent
local React = require(Packages.React)
local BentoBlox = require(Packages.BentoBlox)
local Block = require(BentoBlox.Components.Block)
local Row = require(BentoBlox.Components.Row)
local ProgressTrackStep = require(script.Parent.ProgressTrackStep)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)
local Themes = require(script.Parent.Parent.ThemeProvider.Themes)

local BASE_SIZE = Themes.Default.Tokens.Sizes.Registered.Large.Value
local BASE_SIZE_WITH_STROKE = BASE_SIZE + Themes.Default.Tokens.StrokeWidth.Medium * 2
local CURRENT_SIZE_WITH_STROKE = BASE_SIZE_WITH_STROKE + Themes.Default.Tokens.StrokeWidth.Medium * 2
local GAPS = Themes.Default.Tokens.Sizes.Registered.Medium.Value

export type Alignment = {
    OFFSET_LEFT: "string",
    FLUSH_LEFT: "string",
}

local ALIGNMENT: Alignment = {
    OFFSET_LEFT = "OffsetLeft",
    FLUSH_LEFT = "FlushLeft",
}
--- Module

--[[--
    @tfield number? Steps
    @tfield number? CurrentStep
    @tfield string? CurrentStepStyle
    @tfield Alignment? Alignment
    @tfield boolean? Interactive
    @tfield (nil) -> (nil)? OnNavigate
    @tfield boolean?=false FirstStepIsTutorial
    @table ProgressTrackProps
]]
export type ProgressTrackProps = {
    Steps: number?,
    CurrentStep: number?,
    CurrentStepStyle: string?,
    Alignment: Alignment?,
    Interactive: boolean?,
    OnNavigate: (nil) -> (nil)?,
    Debounce: number?,
    ZIndex: number?,
    LayoutOrder: number?,
    FirstStepIsTutorial: boolean?,
}

function getCurrentXPosition(props: ProgressTrackProps)
    if props.CurrentStep == 1 then
        return BASE_SIZE_WITH_STROKE / 2
    else
        return (BASE_SIZE_WITH_STROKE / 2) + ((props.CurrentStep - 1) * (BASE_SIZE_WITH_STROKE + GAPS))
    end

    return 0
end

function getPaddingLeft(props: ProgressTrackProps)
    if props.Alignment == ALIGNMENT.FLUSH_LEFT then
        return 2
    end

    return 0
end

--- @lfunction ProgressTrack A progress tracker made up of ProgressTrackSteps
--- @tparam ProgressTrackProps props
function ProgressTrack(props: ProgressTrackProps)
    local focusedStep, setFocusedStep = React.useState(nil)
    local shouldDebounce, setShouldDebounce = React.useState(false)

    return withThemeContext(function(theme)
        local steps = {}

        -- Loop through steps and render them
        if props.Steps then
            for index = 1, props.Steps do
                local step = React.createElement(ProgressTrackStep, {
                    Step = index,
                    Interactive = props.Interactive and not shouldDebounce,
                    Focused = index == focusedStep,
                    Disabled = index == props.CurrentStep,
                    OnActivated = function(step)
                        if props.OnNavigate and not shouldDebounce then
                            if props.Debounce then
                                setShouldDebounce(true)
                                if props.Debounce >= 0 then
                                    task.delay(props.Debounce, function()
                                        setShouldDebounce(false)
                                    end)
                                end
                            end
                            setFocusedStep(step)
                            props.OnNavigate(index)
                        end
                    end,
                    ZIndex = props.ZIndex or 1,
                    HasTutorialOffset = props.FirstStepIsTutorial,
                })
                table.insert(steps, step)
            end
        end

        -- The current step is rendered separately and floats above the track
        local currentStep = React.createElement(ProgressTrackStep, {
            Step = props.CurrentStep,
            Current = true,
            Interactive = false,
            Focused = false,
            Style = props.CurrentStepStyle,
            ZIndex = props.ZIndex or 1,
            HasTutorialOffset = props.FirstStepIsTutorial,
        })

        local currentStepBlock = Block({
            AnchorPoint = Vector2.new(0.5, 0),
            Size = UDim2.fromOffset(CURRENT_SIZE_WITH_STROKE, CURRENT_SIZE_WITH_STROKE),
            Position = UDim2.fromOffset(getCurrentXPosition(props), 0),
            ZIndex = props.ZIndex or 1,
        }, { currentStep })

        local progressTrackRow = Row({
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromScale(0, 1),
            Position = UDim2.fromOffset(0, 0),
            Gaps = GAPS,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            ZIndex = props.ZIndex or 1,
        }, steps)

        local progressTrackBlock = Block({
            Size = UDim2.fromOffset(0, CURRENT_SIZE_WITH_STROKE),
            AutomaticSize = Enum.AutomaticSize.X,
            PaddingLeft = getPaddingLeft(props),
            ZIndex = props.ZIndex or 1,
            LayoutOrder = props.LayoutOrder or 1,
        }, {
            -- Background line
            Block({
                Size = UDim2.new(1, -25, 0, 2),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundColor = theme.Tokens.Colors.DisabledLine.Color,
                ZIndex = props.ZIndex or 1,
            }, {}),
            progressTrackRow,
            props.CurrentStep >= 1 and currentStepBlock or nil,
        })

        return progressTrackBlock
    end)
end

return ProgressTrack
