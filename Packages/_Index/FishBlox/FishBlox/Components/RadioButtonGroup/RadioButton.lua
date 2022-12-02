--!strict
local Packages = script.Parent.Parent.Parent.Parent
local React = require(Packages.React)
local Manifest = require(script.Parent.Parent.Parent.Assets.Manifest)
local BentoBlox = require(Packages.BentoBlox)
local Block = require(BentoBlox.Components.Block)
local Column = require(BentoBlox.Components.Column)
local Row = require(BentoBlox.Components.Row)
local Text = require(script.Parent.Parent.Text)
local withThemeContext = require(script.Parent.Parent.Parent.ThemeProvider.WithThemeContext)

type OffsetOrUDim = number | UDim
--- Module

--[[--
    @tfield string?="" Label
    @tfield string?="" Value
    @tfield boolean?=true Active
    @tfield boolean?=false Hovered
    @tfield boolean?=false Checked
    @tfield boolean?=false Selected
    @tfield boolean?=false AsColumn
    @tfield number?=0 LayoutOrder
    @tfield (self: RadioButton) -> nil? OnChanged called when radio button is selected
    @table RadioButtonProps
]]

export type RadioButtonProps = {
    Label: string?,
    Value: string?,
    Active: boolean?,
    Hovered: boolean?,
    Checked: boolean?,
    Selected: boolean?,
    AsColumn: boolean?,
    LayoutOrder: number?,
    OnChanged: ((nil) -> nil)?,
    OnMouseEnter: ((nil) -> nil)?,
    OnMouseLeave: ((nil) -> nil)?,
    ZIndex: number?,
}

local RadioButtonPropDefaults = {
    Label = "Label",
    Active = true,
    Hovered = false,
    Checked = false,
    Selected = false,
    AsColumn = false,
    LayoutOrder = 0,
    ZIndex = 1,
}

local RadioButton = React.Component:extend("RadioButton")

function RadioButton:getBaseColor(theme)
    if not self.props.Active then
        return theme.Tokens.Colors.DisabledLine.Color
    end

    if self.props.Selected then
        return theme.Tokens.Colors.AttentionLine.Color
    end

    return theme.Tokens.Colors.InteractiveLine.Color
end

function RadioButton:didUpdate(prevProps, prevState)
    if prevState and prevProps.Hovered ~= self.props.Hovered then
        self:setState({
            isHovered = self.props.Hovered,
        })
    end
end

function RadioButton:init()
    self:setState({
        isHovered = false,
    })
end

--- @lfunction RadioButton A basic radio button
--- @tparam RadioButtonProps props
function RadioButton:render()
    return withThemeContext(function(theme)
        self.props.Label = self.props.Label ~= nil and self.props.Label or RadioButtonPropDefaults.Label
        if self.props.Checked == nil then
            self.props.Checked = RadioButtonPropDefaults.Checked
        end
        if self.props.Selected == nil then
            self.props.Selected = RadioButtonPropDefaults.Selected
        end
        self.props.AsColumn = self.props.AsColumn ~= nil and self.props.AsColumn or RadioButtonPropDefaults.AsColumn
        self.props.LayoutOrder = self.props.LayoutOrder ~= nil and self.props.LayoutOrder
        self.props.ZIndex = self.props.ZIndex ~= nil and self.props.ZIndex or RadioButtonPropDefaults.ZIndex
        if self.props.Active == nil then
            self.props.Active = RadioButtonPropDefaults.Active
        end

        local radioButton = Block({
            ZIndex = self.props.ZIndex,
            Size = UDim2.fromOffset(
                theme.Tokens.Sizes.Registered.MediumPlus.Value,
                theme.Tokens.Sizes.Registered.MediumPlus.Value
            ),
            OnMouseEnter = function()
                self:setState({
                    isHovered = true,
                })
            end,
            OnMouseLeave = function()
                self:setState({
                    isHovered = false,
                })
            end,
            OnClick = function()
                if self.props.Active then
                    if self.props.OnChanged then
                        self.props.OnChanged(self.props.LayoutOrder, self.props.Value)
                    end
                end
            end,
        }, {
            Base = React.createElement("ImageLabel", {
                Size = UDim2.fromScale(1, 1),
                Image = Manifest["radio-button-base"],
                ImageColor3 = self:getBaseColor(theme),
                BackgroundTransparency = 1,
                ZIndex = self.props.ZIndex,
            }, {
                Hover = Block({
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor = theme.Tokens.Colors.InteractiveSurface.Color,
                    Corner = UDim.new(0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    BackgroundTransparency = self.props.Active
                            and not self.props.Selected
                            and not self.props.Checked
                            and self.state.isHovered
                            and 0.7
                        or 1,
                    ZIndex = self.props.ZIndex + 1,
                }, {}),
                Selected = Block({
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor = theme.Tokens.Colors.AttentionFill.Color,
                    Corner = UDim.new(0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    BackgroundTransparency = not self.props.Checked and self.props.Selected and 0.7 or 1,
                    ZIndex = self.props.ZIndex + 2,
                }, {}),
                Checked = Block({
                    Size = UDim2.fromOffset(10, 10),
                    BackgroundColor = self.props.Active and theme.Tokens.Colors.Text.Color
                        or theme.Tokens.Colors.DisabledLine.Color,
                    Corner = UDim.new(0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    BackgroundTransparency = self.props.Checked and 0 or 1,
                    ZIndex = self.props.ZIndex + 3,
                }, {}),
            }),
        })

        local label = self.props.Label
            and #self.props.Label > 0
            and Block({
                Size = UDim2.fromScale(0, 0),
                AutomaticSize = Enum.AutomaticSize.XY,
                ZIndex = self.props.ZIndex,
                OnClick = function()
                    if self.props.Active then
                        if self.props.OnChanged then
                            self.props.OnChanged(self.props.LayoutOrder, self.props.Value)
                        end
                    end
                end,
            }, {
                LabelText = Text({
                    Text = self.props.Label,
                    Font = theme.Tokens.Typography.BodyMedium.Font,
                    FontSize = theme.Tokens.Typography.BodyMedium.FontSize,
                    Color = self.props.Active and theme.Tokens.Typography.BodyMedium.Color
                        or theme.Tokens.Colors.DisabledSurfaceText.Color,
                    LayoutOrder = 1,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    ZIndex = self.props.ZIndex,
                }),
            })

        local radioButtonAndLabel = {}
        if not self.props.AsColumn then
            radioButtonAndLabel = Row({
                Size = UDim2.fromScale(1, 0),
                Gaps = theme.Tokens.Sizes.Registered.Small.Value,
                LayoutOrder = self.props.LayoutOrder,
                AutomaticSize = Enum.AutomaticSize.Y,
                PaddingTop = 1,
                ZIndex = self.props.ZIndex,
            }, {
                Button = radioButton,
                Label = label or nil,
            })
        else
            radioButtonAndLabel = Column({
                Size = UDim2.fromScale(1 / self.props.NumChoices, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Gaps = theme.Tokens.Sizes.Registered.SmallPlus.Value,
                LayoutOrder = self.props.LayoutOrder,
                ZIndex = self.props.ZIndex,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            }, {
                Button = radioButton,
                Label = label or nil,
            })
        end

        return radioButtonAndLabel
    end)
end

return function(props)
    return React.createElement(RadioButton, props)
end
