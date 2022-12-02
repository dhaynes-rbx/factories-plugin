--!strict
local Packages = script.Parent.Parent.Parent
local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)
local BentoBlox = require(Packages.BentoBlox)
local Block = require(BentoBlox.Components.Block)
local Text = require(script.Parent.Text)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)
local Themes = require(script.Parent.Parent.ThemeProvider.Themes)

local BASE_SIZE = Themes.Default.Tokens.Sizes.Registered.Large.Value
local BASE_SIZE_WITH_STROKE = BASE_SIZE + Themes.Default.Tokens.StrokeWidth.Medium * 2
local CURRENT_SIZE_WITH_STROKE = BASE_SIZE_WITH_STROKE + Themes.Default.Tokens.StrokeWidth.Medium * 2

export type Style = {
    ATTENTION: "string",
    TUTORIAL: "string",
    DEFAULT: "string",
}

local STYLE: Style = {
    ATTENTION = "Attention",
    TUTORIAL = "Tutorial",
    DEFAULT = "Default",
}
--- Module

--[[--
    @tfield number? Step
    @tfield boolean? Current
    @tfield boolean? Interactive
    @tfield boolean? Focused
    @tfield Style? Style
    @tfield boolean? Disabled
    @tfield (nil) -> (nil))? OnActivated
    @tfield boolean?=false HasTutorialOffset
    @table ProgressTrackStepProps
]]
export type ProgressTrackStepProps = {
    Step: number?,
    Current: boolean?,
    Interactive: boolean?,
    Focused: boolean?,
    Style: Style?,
    Disabled: boolean?,
    OnActivated: (nil) -> (nil)?,
    ZIndex: number?,
    HasTutorialOffset: true,
}

function getLabelColor(props: ProgressTrackStepProps, theme: Themes.Theme)
    if not props.Disabled then
        if not props.Current then
            if props.Interactive then
                if props.Focused then
                    return theme.Tokens.Colors.AttentionText.Color
                end

                return theme.Tokens.Colors.InteractiveText.Color
            end
            return theme.Tokens.Colors.TextSubtle.Color
        end

        if props.Style == STYLE.ATTENTION then
            return theme.Tokens.Colors.ProgressTrack.StepStyle.Attention.Text.Color
        end

        if props.Style == STYLE.TUTORIAL then
            return theme.Tokens.Colors.ProgressTrack.StepStyle.Tutorial.Text.Color
        end

        return theme.Tokens.Colors.ProgressTrack.StepStyle.Default.Text.Color
    end

    return theme.Tokens.Colors.TextSubtle.Color
end

function getStrokeColor(props: ProgressTrackStepProps, theme: Themes.Theme)
    if not props.Disabled then
        if not props.Current then
            if props.Interactive then
                if props.Current then
                    return theme.Tokens.Colors.AttentionLine.Color
                end
                return theme.Tokens.Colors.InteractiveLine.Color
            end

            return theme.Tokens.Colors.DisabledLine.Color
        end

        return theme.Tokens.Colors.Surface.Color
    end

    return theme.Tokens.Colors.DisabledLine.Color
end

function getFillColor(props: ProgressTrackStepProps, hovered: boolean, theme: Themes.Theme)
    if not props.Disabled then
        if not props.Current then
            if props.Interactive then
                if not props.Focused then
                    if hovered then
                        return theme.Tokens.Colors.InteractiveSurfaceSubtle.Color
                    end

                    return theme.Tokens.Colors.Surface.Color
                end
                return theme.Tokens.Colors.Surface.Color
            end

            return theme.Tokens.Colors.Surface.Color
        end

        if props.Style == STYLE.ATTENTION then
            return theme.Tokens.Colors.ProgressTrack.StepStyle.Attention.Fill.Color
        end

        if props.Style == STYLE.TUTORIAL then
            return theme.Tokens.Colors.ProgressTrack.StepStyle.Tutorial.Fill.Color
        end

        return theme.Tokens.Colors.ProgressTrack.StepStyle.Default.Fill.Color
    end

    return theme.Tokens.Colors.Surface.Color
end

function getCurrentStrokeColor(props: ProgressTrackStepProps, theme: Themes.Theme)
    if props.Style == STYLE.ATTENTION then
        return theme.Tokens.Colors.ProgressTrack.StepStyle.Attention.Stroke.Color
    end

    if props.Style == STYLE.TUTORIAL then
        return theme.Tokens.Colors.ProgressTrack.StepStyle.Tutorial.Stroke.Color
    end

    return theme.Tokens.Colors.ProgressTrack.StepStyle.Default.Stroke.Color
end

function getStepLabel(props: ProgressTrackStepProps)
    if props.HasTutorialOffset then
        if props.Step == 1 then
            return "T"
        else
            return string.format("%d", props.Step - 1)
        end
    end

    return string.format("%d", props.Step)
end

--- @lfunction ProgressTrackStep The individual step of a ProgressStepTracker
--- @tparam ProgressTrackStepProps props
function ProgressTrackStep(props: ProgressTrackStepProps)
    local hovered, setHovered = React.useState(false)

    React.useEffect(function()
        setHovered(false)
    end, { props.Current, props.Focused })

    return withThemeContext(function(theme)
        local label = Text({
            Text = getStepLabel(props),
            Font = Enum.Font.GothamBold,
            FontSize = theme.Tokens.Typography.BodyMedium.FontSize,
            Color = getLabelColor(props, theme),
            AutomaticSize = Enum.AutomaticSize.XY,
            ZIndex = props.ZIndex or 1,
        })

        local labelBlock = Block({
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            AutomaticSize = Enum.AutomaticSize.XY,
            ZIndex = props.ZIndex or 1,
        }, { Label = label })

        local stepFrameBase = React.createElement("Frame", {
            Size = UDim2.fromOffset(BASE_SIZE, BASE_SIZE),
            BackgroundColor3 = getFillColor(props, hovered, theme),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            ZIndex = props.ZIndex or 1,
        }, {
            UICorner = React.createElement("UICorner", { CornerRadius = UDim.new(50, 0) }),
            LabelBlock = labelBlock,
        })

        local stepFrameStroke = React.createElement("Frame", {
            Size = UDim2.fromOffset(BASE_SIZE_WITH_STROKE, BASE_SIZE_WITH_STROKE),
            BackgroundColor3 = getStrokeColor(props, theme),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            ZIndex = props.ZIndex or 1,
            [ReactRoblox.Event.InputEnded] = function(element, input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if not props.Disabled and not props.Current and props.Interactive then
                        -- TODO: focus should only show on mouse down
                        props.OnActivated(props.Step)
                    end
                end
            end,
            [ReactRoblox.Event.MouseEnter] = function(element, input)
                if not props.Disabled and not props.Current and props.Interactive then
                    setHovered(true)
                end
            end,
            [ReactRoblox.Event.MouseLeave] = function(element, input)
                if not props.Disabled and not props.Current and props.Interactive then
                    setHovered(false)
                end
            end,
        }, {
            UICorner = React.createElement("UICorner", { CornerRadius = UDim.new(50, 0) }),
            Inner = stepFrameBase,
        })

        local stepFrameCurrentStroke = React.createElement("Frame", {
            Size = UDim2.fromOffset(CURRENT_SIZE_WITH_STROKE, CURRENT_SIZE_WITH_STROKE),
            BackgroundColor3 = getCurrentStrokeColor(props, theme),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            ZIndex = props.ZIndex or 1,
        }, {
            UICorner = React.createElement("UICorner", { CornerRadius = UDim.new(50, 0) }),
            Inner = stepFrameStroke,
        })

        return props.Current and stepFrameCurrentStroke or stepFrameStroke
    end)
end

return ProgressTrackStep
