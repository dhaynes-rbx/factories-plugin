--!strict
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local BentoBlox = require(Packages.BentoBlox)
local Dash = require(Packages.Dash)
local Column = require(BentoBlox.Components.Column)
local Row = require(BentoBlox.Components.Row)
local Text = require(script.Parent.Text)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

type OffsetOrUDim = number | UDim
--- Module

--[[--
    @tfield string?="Content" Content
    @tfield boolean?=false HideArrow
    @tfield boolean?=false ShowAdvance
    @tfield number?=0 Steps
    @tfield number?=0 Step
    @tfield OffsetOrUDim?="UDim.new(1,0)" Width
    @table TooltipProps
]]

type TooltipProps = {
    Content: string?,
    HideArrow: boolean?,
    ShowAdvance: boolean?,
    Steps: number?,
    Step: number?,
    Width: OffsetOrUDim?,
    Height: OffsetOrUDim?,
}

local TooltipPropDefaults = {
    Content = "",
    HideArrow = false,
    ShowAdvance = false,
    Steps = 0,
    Step = 0,
    Width = UDim.new(0, 244),
    Height = UDim.new(0, 0),
}

--- @lfunction Tooltip A basic tooltip
--- @tparam TooltipProps props
--[[
    WARNING: This component is deprecated and will not be updated.
    You should instead use a PointerBlock composed with a Panel.
]]
local function Tooltip(props: TooltipProps, children)
    props.Width = props.Width ~= nil and props.Width or TooltipPropDefaults.Width
    props.Height = props.Height ~= nil and props.Height or TooltipPropDefaults.Height
    props.ShowAdvance = props.ShowAdvance ~= nil and props.ShowAdvance or TooltipPropDefaults.ShowAdvance
    props.Steps = props.Steps ~= nil and props.Steps or TooltipPropDefaults.Steps

    return withThemeContext(function(theme)
        children = children or {}
        -- TODO: Add props/method to position arrow (only on left side currently)
        local arrow = Roact.createElement("ImageLabel", {
            Image = "rbxassetid://6846205553",
            Size = UDim2.new(0, 31, 0, 46),
            BackgroundTransparency = 1,
            ImageColor3 = theme.Tokens.Colors.Surface.Color,
        }, nil)
        local arrowColumn = Column({
            Size = UDim2.new(0, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.XY,
            LayoutOrder = 0,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }, {
            Arrow = arrow,
        })

        local hasContentProp = props.Content ~= nil and props.Content ~= ""

        local bodyColumn = Column(
            {
                LayoutOrder = 2,
                Padding = props.Padding and props.Padding or theme.Tokens.Sizes.Registered.XMedium.Value,
                Color = theme.Tokens.Colors.Surface.Color,
                Gaps = theme.Tokens.Sizes.Registered.Medium.Value,
                CornerRadius = theme.Tokens.Sizes.Registered.SmallPlus.Value,
            },
            Dash.assign(children, hasContentProp and {
                Content = Text({
                    Text = props.Content,
                    Color = theme.Tokens.Colors.Text.Color,
                    Font = theme.Tokens.Typography.BodySmall.Font,
                    FontSize = theme.Tokens.Typography.BodySmall.FontSize,
                    LineHeight = theme.Tokens.Typography.BodySmall.LineHeight,
                    LayoutOrder = 0,
                    Width = props.ShowAdvance and UDim.new(0.7, 0) or UDim.new(1, 0),
                    RichText = true,
                }),
            } or {})
        )
        local tooltipRow = Row({
            Width = props.Width,
            Height = props.Height,
            AutomaticSize = props.AutomaticSize ~= nil and props.AutomaticSize or Enum.AutomaticSize.Y,
            -- TODO: Q: shouldn't Row sizedByShorthand be handling this?
            -- e.g. if no height shouldn't it default into auto Y.
        }, {
            ArrowColumn = arrowColumn,
            BodyColumn = bodyColumn,
        })

        return tooltipRow
    end)
end

return Tooltip
