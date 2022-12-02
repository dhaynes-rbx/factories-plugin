--!strict
local Packages = script.Parent.Parent.Parent
local React = require(Packages.React)
local BentoBlox = require(Packages.BentoBlox)
local Column = require(BentoBlox.Components.Column)
local Row = require(BentoBlox.Components.Row)
local RadioButton = require(script.RadioButton)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

type OffsetOrUDim = number | UDim
--- Module

--[[--
    @tfield number? Id
    @tfield table?={} Choices
    @tfield string?="" CurrentValue
    @tfield boolean?=false AsRow
    @tfield boolean?=true Active
    @tfield number?=10 Gaps
    @tfield number?=16 RowPadding
    @tfield number?=16 ColumnPadding
    @tfield (self: RadioButtonGroup) -> nil? OnChanged called when radio button in a group is clicked
    @table RadioButtonGroupProps
]]

export type RadioButtonGroupProps = {
    Id: number?,
    Choices: table?,
    CurrentValue: string?,
    Active: boolean?,
    Gaps: number?,
    AsRow: boolean?,
    OnChanged: ((nil) -> nil)?,
    ZIndex: number?,
}

local RadioButtonGroupPropDefaults = {
    Choices = {},
    Active = true,
    Gaps = 12,
    AsRow = false,
    ZIndex = 1,
}

local RadioButtonGroup = React.Component:extend("RadioButtonGroup")

function RadioButtonGroup:init() end

--- @lfunction RadioButtonGroup A group for holding radio buttons in a vertical or horizonal orientation
--- @tparam RadioButtonGroupProps props
function RadioButtonGroup:render()
    return withThemeContext(function(theme)
        self.props.Choices = self.props.Choices ~= nil and self.props.Choices or RadioButtonGroupPropDefaults.Choices
        self.props.Gaps = self.props.Gaps ~= nil and self.props.Gaps or RadioButtonGroupPropDefaults.Gaps
        self.props.AsRow = self.props.AsRow ~= nil and self.props.AsRow or RadioButtonGroupPropDefaults.AsRow
        self.props.ZIndex = self.props.ZIndex ~= nil and self.props.ZIndex or RadioButtonGroupPropDefaults.ZIndex
        if self.props.Active == nil then
            self.props.Active = RadioButtonGroupPropDefaults.Active
        end

        local radioButtons = {}

        for _, value in pairs(self.props.Choices) do
            local radioButton = RadioButton({
                Label = value.Label,
                LayoutOrder = value.Order,
                Value = value.Value,
                AsColumn = self.props.AsRow,
                Checked = value.Value == self.props.CurrentValue,
                Selected = value.Selected,
                Active = value.Active,
                ZIndex = self.props.ZIndex,
                NumChoices = #self.props.Choices,
                OnChanged = function(num, val)
                    if val ~= self.props.CurrentValue then
                        self:onChanged(num, val, self.props.Id)
                    end
                end,
                OnSelected = function() end,
                OnMouseEnter = function() end,
                OnMouseLeave = function() end,
            })
            table.insert(radioButtons, radioButton)
        end

        local radioGroup = {}
        if not self.props.AsRow then
            radioGroup = Column({
                Padding = self.props.ColumnPadding or theme.Tokens.Sizes.Registered.Medium.Value,
                Gaps = self.props.Gaps,
                Color = theme.Tokens.Colors.Surface.Color,
                BackgroundTransparency = 0,
                AutomaticSize = Enum.AutomaticSize.XY,
                ZIndex = self.props.ZIndex,
            }, radioButtons)
        else
            radioGroup = Row({
                Padding = self.props.RowPadding or theme.Tokens.Sizes.Registered.Medium.Value,
                Gaps = self.props.Gaps,
                Color = theme.Tokens.Colors.Surface.Color,
                BackgroundTransparency = 0,
                AutomaticSize = Enum.AutomaticSize.XY,
                ZIndex = self.props.ZIndex,
            }, radioButtons)
        end
        return radioGroup
    end)
end

function RadioButtonGroup:onChanged(num, val, id)
    if self.props.OnChanged then
        self.props.OnChanged(num, val, id)
    end
end

return function(props)
    return React.createElement(RadioButtonGroup, props)
end
