--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(script.Parent.Parent.Roact)

local FishBlox = require(script.Parent.Parent.FishBlox)
local withThemeContext = FishBlox.WithThemeContext
local FishBloxComponents = FishBlox.Components
local Block = FishBloxComponents.Block
local Text = FishBloxComponents.Text
local Column = FishBloxComponents.Column

local Manifest = require(script.Parent.Manifest)

local ScreenSizeWarning = Roact.Component:extend("ScreenSizeWarning")

function ScreenSizeWarning:init()
    self:setState({
        screenSize = workspace.CurrentCamera.ViewportSize,
    })
end

function ScreenSizeWarning:render()
    return withThemeContext(function(theme)
        if
            self.state.screenSize.X < self.props.MinScreenSize.X
            or self.state.screenSize.Y < self.props.MinScreenSize.Y
        then
            return Block({
                Size = UDim2.fromScale(1, 1),
                Position = UDim2.fromOffset(0, 0),
                BackgroundTransparency = 0,
                BackgroundColor = Color3.new(),
                PaddingHorizontal = theme.Tokens.Sizes.Registered.Large.Value,
                ZIndex = self.props.ZIndex,
            }, {
                ClickBlocker = Roact.createElement("ImageButton", {
                    Size = UDim2.fromScale(1, 1),
                    Active = true,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ImageTransparency = 1,
                    ZIndex = self.props.ZIndex,
                }),
                Column({
                    Size = UDim2.fromScale(1, 1),
                    Gaps = theme.Tokens.Sizes.Registered.XMedium.Value,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    PaddingHorizontal = theme.Tokens.Sizes.Registered.Large.Value,
                    ZIndex = self.props.ZIndex,
                }, {
                    Roact.createElement("ImageLabel", {
                        Size = UDim2.fromOffset(156 * 0.5, 110 * 0.5),
                        BackgroundTransparency = 1,
                        Image = Manifest["icon-warn-small-screen"],
                        BorderSizePixel = 0,
                        SizeConstraint = Enum.SizeConstraint.RelativeXY,
                        ZIndex = self.props.ZIndex,
                    }),
                    Text({
                        Text = "Your Roblox window is too small.",
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Color = theme.Tokens.Typography.HeadlineLarge.Color,
                        Font = theme.Tokens.Typography.HeadlineLarge.Font,
                        FontSize = theme.Tokens.Typography.HeadlineLarge.FontSize,
                        ZIndex = self.props.ZIndex,
                    }),
                    Text({
                        Text = "Please expand the size of your window until this message disappears.",
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Color = theme.Tokens.Typography.HeadlineSmall.Color,
                        Font = theme.Tokens.Typography.HeadlineSmall.Font,
                        FontSize = theme.Tokens.Typography.HeadlineSmall.FontSize,
                        ZIndex = self.props.ZIndex,
                    }),
                }),
            })
        end
    end)
end

function ScreenSizeWarning:didMount()
    self.connection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        self:setState({
            screenSize = workspace.CurrentCamera.ViewportSize,
        })
    end)
end

function ScreenSizeWarning:willUnmount()
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
end

return function(props: { MinScreenSize: Vector2, ZIndex: number }): Roact.Element
    return Roact.createElement(ScreenSizeWarning, props)
end
