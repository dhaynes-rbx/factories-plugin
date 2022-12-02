--!strict
local Packages = script.Parent.Parent.Parent

local Roact = require(Packages.Roact)

local Utilities = require(Packages.Utilities)

local Manifest = require(script.Parent.Parent.Assets.Manifest)

local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)
local BentoBlox = require(Packages.BentoBlox)
local Block = require(BentoBlox.Components.Block)
local Row = require(BentoBlox.Components.Row)
local Text = require(script.Parent.Text)

local LoadingScreen = Roact.Component:extend("LoadingScreen")

local FADE_IN_DURATION = 0.25
local LABEL_FADE_IN_DURATION = 0.5
local FADE_OUT_DURATION = 0.25
local ROTATIONS_PER_SECOND = 1

function LoadingScreen:init()
    self.backgroundTransparency, self.setBackgroundTransparency = Roact.createBinding(1)
    self.overlayTransparency, self.setOverlayTransparency = Roact.createBinding(1)
    self.spinnerRotation, self.setSpinnerRotation = Roact.createBinding(0)
    self.topOffset = task.spawn(function()
        local start = tick()
        while true do
            local delta = tick() - start
            local rotation = (delta * 360 * ROTATIONS_PER_SECOND) % 360
            self.setSpinnerRotation(rotation)
            task.wait()
        end
    end)
    self.showOverlayTimeout = nil
    self.interpolateOverlay = false
end

function LoadingScreen:render()
    local result = withThemeContext(function(theme)
        return Block({
            BackgroundColor = theme.Tokens.Colors.TextInverted.Color,
            BackgroundTransparency = self.backgroundTransparency,
            Size = UDim2.new(1, 0, 1, -self.props.VerticalOffset or 0),
            Position = UDim2.fromOffset(0, self.props.VerticalOffset or 0),
            ZIndex = self.props.ZIndex or 1,
        }, {
            ClickBlocker = self.props.Show and Roact.createElement("ImageButton", {
                Size = UDim2.fromScale(1, 1),
                Active = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ImageTransparency = 1,
                ZIndex = self.props.ZIndex or 1,
            }),
            Container = Block({
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                ZIndex = self.props.ZIndex or 1,
                Padding = theme.Tokens.Sizes.Registered.XLarge.Value,
            }, {
                Content = Row({
                    Size = UDim2.fromScale(1, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Gaps = theme.Tokens.Sizes.Registered.Small.Value,
                    Position = UDim2.fromScale(0, 0.5),
                }, {
                    IconContainer = Block({
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(21, 21),
                        ZIndex = self.props.ZIndex or 1,
                    }, {
                        Icon = Roact.createElement("ImageLabel", {
                            Image = Manifest["icon-spinner"],
                            Size = UDim2.fromOffset(21, 21),
                            BackgroundTransparency = 1,
                            ZIndex = self.props.ZIndex or 1,
                            ImageTransparency = self.overlayTransparency,
                            Rotation = self.spinnerRotation,
                        }),
                    }),
                    Label = Text({
                        Text = "Loading...",
                        Font = theme.Tokens.Typography.BodyLarge.Font,
                        FontSize = theme.Tokens.Typography.BodyLarge.FontSize,
                        Color = theme.Tokens.Typography.BodyLarge.Color,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        LayoutOrder = 0,
                        ZIndex = self.props.ZIndex or 1,
                        TextTransparency = self.overlayTransparency,
                    }),
                }),
            }),
        })
    end)
    return result
end

function interpolate(time: number, callback: (number))
    task.spawn(function()
        local start = tick()
        local t = math.clamp((tick() - start) / time, 0, 1)
        while t < 1 do
            callback(t)
            task.wait()
            t = math.clamp((tick() - start) / time, 0, 1)
        end
        callback(1)
    end)
end

function LoadingScreen:show()
    self:clearTimeout()
    if self.props.FadeIn then
        interpolate(FADE_IN_DURATION, function(t)
            self.setBackgroundTransparency(1 - t)
            if t == 1 and self.props.OnCovered then
                self.props.OnCovered()
            end
        end)
        self.showOverlayTimeout = Utilities.Timeout.set(3, 0, function()
            self.showOverlayTimeout = nil
            self.interpolateOverlay = true
            interpolate(LABEL_FADE_IN_DURATION, function(t)
                if self.interpolateOverlay then
                    self.setOverlayTransparency(1 - t)
                end
            end)
        end)
    else
        self.setBackgroundTransparency(0)
        self.setOverlayTransparency(0)
        if self.props.OnCovered then
            self.props.OnCovered()
        end
    end
end

function LoadingScreen:hide()
    self:clearTimeout()
    interpolate(FADE_OUT_DURATION, function(t)
        self.setBackgroundTransparency(t)
        self.setOverlayTransparency(math.max(t, self.overlayTransparency:getValue()))
        if t == 1 and self.props.OnUncovered then
            self.props.OnUncovered()
        end
    end)
end

function LoadingScreen:clearTimeout()
    if self.showOverlayTimeout then
        Utilities.Timeout.clear(self.showOverlayTimeout)
        self.showOverlayTimeout = nil
    end
    if self.interpolateOverlay then
        self.interpolateOverlay = false
    end
end

function LoadingScreen:willUpdate(nextProps)
    if self.props.Show ~= nextProps.Show then
        if nextProps.Show then
            self:show()
        else
            self:hide()
        end
    end
end

function LoadingScreen:didMount()
    if self.props.Show then
        self:show()
    end
end

return function(props)
    return Roact.createElement(LoadingScreen, props)
end
