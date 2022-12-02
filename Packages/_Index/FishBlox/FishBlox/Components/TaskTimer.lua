--!strict
local Manifest = require(script.Parent.Parent.Assets.Manifest)
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local BentoBlox = require(Packages.BentoBlox)
local Row = require(BentoBlox.Components.Row)
local Block = require(BentoBlox.Components.Block)

local Text = require(script.Parent.Text)

local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

local pingPongTween = require(script.Parent.Parent.Utilities.PingPongTween)

-- WARN: Components should only use Tokens, here we are exposing a ColorScale directly but better is to map a semantic name to the color, such as ProgressFill
local ColorScales = require(script.Parent.Parent.Tokens.ColorScales)

type OffsetOrUDim = number | UDim

local WARN_AT_TIME_REMAINING = (2 * 60) + 29 -- Warn at 2 minutes and 29 seconds (because at that point the text will say "2 minutes remaining" due to the rounding)

type TaskTimerProps = {
    TimerState: {
        started: number,
        elapsed: number,
        duration: number,
        expired: boolean,
        segments: { number },
    },
    GetTime: (() -> number),
    InTutorial: boolean,
    -- Pass in a section number to allow distinguishing between Time Up in previous section and Time Paused in new section
    SectionNumber: number,
}

type TimerState = {
    totalElapsed: number,
    totalDuration: number,
    segmentElapsed: number,
    segmentDuration: number,
    segmentRemaining: number,
    totalSegments: number,
}

local TIMELINE_WIDTH = 300

local TaskTimer = Roact.Component:extend("TaskTimer")

function TaskTimer:init()
    self.timerBackgroundRef = Roact.createRef()
    self.timerTimeRemainingRef = Roact.createRef()
    -- set these before we call getDerivedState because they are referenced inside it
    self.warningAnimationStarted = false
    self.warningAnimationFinished, self.updateWarningAnimationFinished = Roact.createBinding(false)
    -- TODO: Should we be calling self:getDerivedState from init, seems wrong
    self.timerState, self.updateTimerState = Roact.createBinding(self:getDerivedState())
    self.timerActive = true

    coroutine.wrap(function()
        while self.timerActive do
            self.updateTimerState(self:getDerivedState())
            wait(1)
        end
    end)()
end

function TaskTimer:getDerivedState(): TimerState
    local timer = self.props.TimerState
    local totalSegments = #timer.segments
    local segmentBegin = 0
    local totalElapsed = timer.started == -1 and timer.elapsed or timer.elapsed + (self.props.GetTime() - timer.started)
    local isPaused = timer.started == -1

    -- sum previous sections into segmentBegin
    for sectionNumber = 1, self.props.SectionNumber - 1 do
        segmentBegin = segmentBegin + timer.segments[sectionNumber]
    end

    local segmentElapsed = totalElapsed - segmentBegin
    local segmentDuration = timer.segments[self.props.SectionNumber]
    local segmentRemaining = segmentDuration and math.floor(segmentDuration - segmentElapsed) or 0

    -- trigger tween or cleanup tween
    local pastWarningTime = segmentRemaining ~= 0 and segmentRemaining <= WARN_AT_TIME_REMAINING
    if self.props.TimerState.started ~= -1 and not isPaused and pastWarningTime then
        if not self.warningAnimationStarted then
            local timerBackgroundEl = self.timerBackgroundRef:getValue()
            local timeRemainingTextEl = self.timerTimeRemainingRef:getValue()
            local mountedStateExists = self.theme and timerBackgroundEl and timeRemainingTextEl
            if mountedStateExists then
                self.warningAnimationStarted = true
                -- blink the container white
                pingPongTween(
                    timerBackgroundEl,
                    { BackgroundTransparency = 1 },
                    { BackgroundTransparency = 0.4 },
                    0.5, -- half a second
                    6, -- go to pong 3 times, return to ping 3 times
                    -- when done, blink the text yellow
                    function()
                        pingPongTween(
                            timeRemainingTextEl,
                            { TextColor3 = self.theme.Tokens.Colors.TextSubtle.Color },
                            { TextColor3 = self.theme.Tokens.Colors.WarningText.Color },
                            0.5,
                            5, -- go to yellow 4 times, return to grey 3 times, end yellow
                            function()
                                -- and we tell Roact we are done via a binding so it knows we messed with its render tree
                                self.updateWarningAnimationFinished(true)
                            end
                        )
                    end
                )
            end
        end
    end
    if self.props.TimerState.started == -1 or not pastWarningTime then
        -- We reset these variables to set correct state and allow triggering warnging again
        self.warningAnimationStarted = false
        self.updateWarningAnimationFinished(false) -- this binding set prompts react to rerender the finished text in the correct color
    end

    return {
        totalElapsed = totalElapsed,
        totalDuration = timer.duration,
        segmentElapsed = segmentElapsed,
        segmentDuration = segmentDuration,
        segmentRemaining = segmentRemaining,
        totalSegments = totalSegments,
    }
end

function TaskTimer:render()
    return withThemeContext(function(theme)
        -- Store theme for use within derivedState
        -- TODO: this feels a bit hacky. Is there a better way to do this?
        self.theme = theme
        local pausedIcon = nil

        if self.props.TimerState.started == -1 then
            if self.props.InTutorial then
                pausedIcon = Roact.createElement("ImageLabel", {
                    Image = Manifest["icon-tutorial-timer-paused"],
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.new(
                        0,
                        theme.Tokens.Sizes.Registered.Large.Value,
                        0,
                        theme.Tokens.Sizes.Registered.Large.Value
                    ),
                    BackgroundTransparency = 1,
                    ZIndex = 100,
                }, nil)
            else
                pausedIcon = Roact.createElement("ImageLabel", {
                    Image = Manifest["icon-timer-paused"],
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.new(
                        0,
                        theme.Tokens.Sizes.Registered.Large.Value,
                        0,
                        theme.Tokens.Sizes.Registered.Large.Value
                    ),
                    BackgroundTransparency = 1,
                    ZIndex = 100,
                }, nil)
            end
        end

        -- this is the blok we want to colorize on time warning
        return Block({
            Position = UDim2.fromScale(0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0),
            Size = UDim2.fromScale(0, 1),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor = theme.Tokens.Colors.SurfaceInverted.Color,
            BackgroundTransparency = 1,
            [Roact.Ref] = self.timerBackgroundRef,
        }, {
            -- UICorner will only be visible when animating the time warning
            Roact.createElement("UICorner", {
                CornerRadius = UDim.new(0, theme.Tokens.CornerRadius.SmallOutside),
            }),
            Row({
                Gaps = 10,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Size = UDim2.fromScale(1, 1),
            }, {
                Left = Text({
                    Text = self.props.InTutorial and "Tutorial" or self.timerState:map(function(timerState: TimerState)
                        return "Section " .. self.props.SectionNumber .. " of " .. timerState.totalSegments
                    end),
                    Color = theme.Tokens.Colors.Text.Color,
                    Font = theme.Tokens.Typography.BodyMediumSemiBold.Font,
                    FontSize = theme.Tokens.Typography.BodyMediumSemiBold.FontSize,
                    LayoutOrder = 0,
                    RichText = true,
                    Size = UDim2.new(0, 200, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextYAlignment = Enum.TextYAlignment.Center,
                }),
                Progress = Block({
                    LayoutOrder = 1,
                    Size = UDim2.new(0, TIMELINE_WIDTH, 0, theme.Tokens.Sizes.Registered.Small.Value),
                    BackgroundTransparency = 0,
                    -- TODO: avoid color scales in component, we should create semantic names
                    BackgroundColor = self.props.InTutorial and ColorScales.Purple["500"]
                        or ColorScales.GreyBlue["300"],
                    Corner = UDim.new(0, theme.Tokens.Sizes.Registered.SmallPlus.Value),
                }, {
                    Fill = Block({
                        LayoutOrder = 1,
                        Size = self.timerState:map(function(timerState: TimerState)
                            local scalePercent = timerState.segmentDuration
                                    and timerState.segmentElapsed / timerState.segmentDuration
                                or 0
                            -- limit to 0..1
                            scalePercent = math.max(math.min(scalePercent, 1), 0)
                            return UDim2.fromScale(scalePercent, 1)
                        end),
                        BackgroundColor = ColorScales.Green["400"],
                        BackgroundTransparency = 0,
                        Corner = UDim.new(0, theme.Tokens.Sizes.Registered.SmallPlus.Value),
                    }, {}),
                    Icon = pausedIcon,
                }),
                Right = Text({
                    Text = self.timerState:map(function(timerState: TimerState)
                        -- in the Time Up state we set self.props.TimerState.started to true
                        -- so we need to condition on segmentRemaining = 0 first or we get Time Paused
                        if self.props.TimerState.started ~= -1 and timerState.segmentRemaining <= 1 then
                            return "Time is Up"
                            -- Checking against 1 instead of 0 seconds remaining
                            -- because when checking against 0 we see a brief flicker
                            -- of "Time Paused" before seeing "Time Is Up"
                            -- liekly because it doesn't update until the getDerivedState loop on a 1 second tick
                        elseif self.props.TimerState.started == -1 then
                            return "Time Paused"
                        else
                            local minutesRemaining = (timerState.segmentRemaining / 60)
                            if minutesRemaining > 1 then
                                return math.round(minutesRemaining) .. " Minutes Left"
                            else
                                return timerState.segmentRemaining .. " Seconds Left"
                            end
                        end
                    end),
                    Color = self.warningAnimationFinished:map(function(warningAnimationFinished)
                        return warningAnimationFinished and self.theme.Tokens.Colors.WarningText.Color
                            or self.theme.Tokens.Colors.Text.Color
                    end),
                    Font = theme.Tokens.Typography.BodyMediumSemiBold.Font,
                    FontSize = theme.Tokens.Typography.BodyMediumSemiBold.FontSize,
                    LayoutOrder = 2,
                    RichText = true,
                    Size = UDim2.new(0, 200, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    [Roact.Ref] = self.timerTimeRemainingRef,
                }),
            }),
        })
    end)
end

function TaskTimer:willUnmount()
    self.timerActive = false
end

return function(props)
    return Roact.createElement(TaskTimer, props)
end
