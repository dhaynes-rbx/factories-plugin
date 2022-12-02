--!strict
local Packages = script.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local Manifest = require(script.Parent.Parent.Parent.Assets.Manifest)
local BentoBlox = require(Packages.BentoBlox)
local Block = require(BentoBlox.Components.Block)
local Column = require(BentoBlox.Components.Column)
local Row = require(BentoBlox.Components.Row)
local Text = require(script.Parent.Parent.Text)
local withThemeContext = require(script.Parent.Parent.Parent.ThemeProvider.WithThemeContext)

local BASE_SIZE_CURRENT = 36
local BASE_SIZE = 30

type OffsetOrUDim = number | UDim
--- Module

--[[--
    @tfield number? NumQuestion
    @tfield string?="" Value
    @tfield boolean?=false IsCurrent
    @tfield boolean?=false Completed
    @tfield boolean?=false Hovered
    @tfield boolean?=false Selected
    @tfield (self: QuestionIndicator) -> nil? OnActivated
    @table QuestionIndicatorProps
]]

type QuestionIndicatorProps = {
    NumQuestion: number?,
    Value: string?,
    IsCurrent: boolean?,
    Completed: boolean?,
    Hovered: boolean?,
    Selected: boolean?,
    OnActivated: ((nil) -> nil)?,
    OnMouseEnter: ((nil) -> nil)?,
    OnMouseLeave: ((nil) -> nil)?,
}

--- @lfunction QuestionIndicator
--- @tparam QuestionIndicatorProps props
function QuestionIndicator(props)
    return withThemeContext(function(theme)
        local getBaseColor = function()
            if props.Completed then
                return Color3.fromRGB(16, 150, 97)
            end

            if props.Selected then
                return Color3.fromRGB(246, 202, 86)
            end

            return theme.Tokens.Colors.InteractiveLine.Color
        end

        local getFillColor = function()
            if props.Completed then
                return Color3.fromRGB(16, 150, 97)
            end

            if props.Selected then
                return Color3.fromRGB(246, 202, 86)
            end

            return theme.Tokens.Colors.InteractiveSurface.Color
        end

        local getTextColor = function()
            if props.Completed then
                return Color3.fromRGB(16, 150, 97)
            end

            if props.Selected then
                return Color3.fromRGB(246, 202, 86)
            end

            return theme.Tokens.Colors.InteractiveText.Color
        end

        local QuestionIndicator = Block({
            Size = UDim2.fromOffset(BASE_SIZE_CURRENT, BASE_SIZE_CURRENT),
            OnMouseEnter = function()
                if props.OnMouseEnter then
                    props.OnMouseEnter(props.NumQuestion)
                end
            end,
            OnMouseLeave = function()
                if props.OnMouseLeave then
                    props.OnMouseLeave(props.NumQuestion)
                end
            end,
            OnClick = function()
                if props.OnActivated then
                    props.OnActivated(props.NumQuestion)
                end
            end,
            -- TODO: Handle a "selected ('active' in JS)" state
        }, {
            Base = Roact.createElement("ImageLabel", {
                Size = props.IsCurrent and UDim2.fromScale(1, 1) or UDim2.fromOffset(BASE_SIZE, BASE_SIZE),
                Image = props.IsCurrent and Manifest["question-tracker-item-base-current"]
                    or Manifest["question-tracker-item-base"],
                ImageColor3 = getBaseColor(),
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
            }, {
                SurfaceFill = Block({
                    Size = UDim2.new(1, -6, 1, -6),
                    BackgroundColor = theme.Tokens.Colors.Surface.Color,
                    Corner = UDim.new(0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    BackgroundTransparency = 0,
                    ZIndex = 1,
                }, {}),
                HoverBlock = Block({
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor = getFillColor(),
                    Corner = UDim.new(0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    BackgroundTransparency = (props.Hovered or props.Selected) and 0.9 or 1,
                    ZIndex = 2,
                }, {}),
                LabelBlock = Block({
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    ZIndex = 3,
                }, {
                    LabelRow = Row({
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    }, {
                        Label = props.Completed and Roact.createElement("ImageLabel", {
                            Size = UDim2.fromOffset(16, 16),
                            Image = Manifest["checkmark"],
                            ImageColor3 = Color3.fromRGB(16, 150, 97),
                            BackgroundTransparency = 1,
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                        }, {}) or Text({
                            Text = tostring(props.NumQuestion),
                            TextXAlignment = Enum.TextXAlignment.Center,
                            TextYAlignment = Enum.TextYAlignment.Center,
                            Font = theme.Tokens.Typography.HeadlineSmall.Font,
                            FontSize = theme.Tokens.Typography.HeadlineSmall.FontSize,
                            Color = getTextColor(),
                            LayoutOrder = 1,
                            AutomaticSize = Enum.AutomaticSize.XY,
                        }),
                    }),
                }),
            }),
        })

        return QuestionIndicator
    end)
end

return QuestionIndicator
