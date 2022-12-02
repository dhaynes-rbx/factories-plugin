--!strict
local Packages = script.Parent.Parent.Parent
local React = require(Packages.React)
local BentoBlox = require(Packages.BentoBlox)
local Block = require(BentoBlox.Components.Block)
local Row = require(BentoBlox.Components.Row)
local Text = require(script.Parent.Text)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

type OffsetOrUDim = number | UDim
--- Module

--[[--
    @tfield boolean?=false Checked
    @tfield boolean?=true Active
    @tfield OffsetOrUDim? Height
    @tfield string?="Label" Label
    @tfield OffsetOrUDim? Width
    @tfield (self: Checkbox) -> nil? OnChanged called when checkbox is checked or unchecked
    @table CheckboxProps
]]

type CheckboxProps = {
    Checked: boolean?,
    Active: boolean?,
    Height: OffsetOrUDim?,
    Width: OffsetOrUDim?,
    -- Callbacks
    OnChanged: ((proposedCheckedValueAfterActivation: boolean) -> {})?,
}

local CheckboxPropDefaults = {
    Checked = false,
    Active = true,
    Label = "Label",
}

local onClick = function(props: CheckboxProps)
    if props.Active then
        props.OnChanged(not props.Checked)
    end
end

--- @lfunction Checkbox A basic checkbox
--- @tparam CheckboxProps props
function Checkbox(props)
    return withThemeContext(function(theme)
        -- TODO: Will need a Focus state for accessibility
        if props.Active == nil then
            props.Active = CheckboxPropDefaults.Active
        end
        if props.Checked == nil then
            props.Checked = CheckboxPropDefaults.Checked
        end
        props.Label = props.Label ~= nil and props.Label or CheckboxPropDefaults.Label

        local checkboxBlock = Block({
            Height = theme.Tokens.Sizes.Registered.XMedium.Value,
            Width = theme.Tokens.Sizes.Registered.XMedium.Value,
            BackgroundColor = theme.Tokens.Colors.Surface.Color,
            BorderColor = props.Active and theme.Tokens.Colors.InteractiveLine.Color
                or theme.Tokens.Colors.DisabledLine.Color,
            BorderSizePixel = 3,
            LayoutOrder = 0,
            OnClick = function()
                onClick(props)
            end,
        }, {
            CheckedImage = React.createElement("ImageLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                Image = "rbxassetid://6804034542",
                ImageColor3 = theme.Tokens.Colors.InteractiveLine.Color,
                BackgroundTransparency = 1,
                Visible = props.Checked,
            }, {}),
        })
        local checkboxLabelBlock = Block({
            AutomaticSize = Enum.AutomaticSize.XY,
            OnClick = function()
                onClick(props)
            end,
        }, {
            CheckboxLabel = Text({
                Width = UDim.new(
                    1,
                    -theme.Tokens.Sizes.Registered.ControlHeight.Value - theme.Tokens.Sizes.Registered.Small.Value
                ),
                Text = props.Label or "",
                Font = theme.Tokens.Typography.BodyLarge.Font,
                FontSize = theme.Tokens.Typography.BodyLarge.FontSize,
                Color = theme.Tokens.Typography.BodyLarge.Color,
                Visible = props.Label ~= nil,
                LayoutOrder = 1,
            }, {}),
        })

        local checkboxRow = Row({
            Height = theme.Tokens.Sizes.Registered.XMedium.Value,
            Gaps = theme.Tokens.Sizes.Registered.MediumPlus.Value,
            LayoutOrder = props.LayoutOrder or 0,
        }, {
            CheckboxBlock = checkboxBlock,
            CheckboxLabelBlock = checkboxLabelBlock,
        })

        return Block({
            AutomaticSize = Enum.AutomaticSize.XY,
        }, checkboxRow)
    end)
end

return Checkbox
