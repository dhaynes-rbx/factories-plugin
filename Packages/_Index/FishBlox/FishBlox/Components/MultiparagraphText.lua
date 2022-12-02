--!strict
local Packages = script.Parent.Parent.Parent
local BentoBlox = require(Packages.BentoBlox)
local Column = require(BentoBlox.Components.Column)
local Text = require(script.Parent.Text)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

--- Module

--[[--
    @tfield table? Component
    @tfield number?=16 Gaps
    @table MultiparagraphTextProps
]]

type MultiparagraphTextProps = {
    Component: table?,
    Gaps: number?,
}

local MultiparagraphTextPropDefaults = {
    Gaps = 16,
}

local createTextChildren = function(textProps, theme)
    local textChildren = {}
    local textStrings = textProps.Text:split("\n")

    for index, value in ipairs(textStrings) do
        table.insert(
            textChildren,
            Text({
                LayoutOrder = index,
                Text = value,
                RichText = textProps.RichText,
                Font = textProps.Font,
                FontSize = textProps.TextSize,
                Width = textProps.Width,
                Visible = textProps.Visible,
                LineHeight = textProps.LineHeight,
                TextXAlignment = textProps.TextXAlignment,
                TextYAlignment = textProps.TextYAlignment,
                Size = textProps.Size,
                Color = textProps.TextColor3,
                TextTransparency = textProps.TextTransparency,
                AutomaticSize = textProps.AutomaticSize,
                ZIndex = textProps.ZIndex,
            })
        )
    end

    return textChildren
end

--- @lfunction MultiparagraphText
--- @tparam MultiparagraphTextProps props
function MultiparagraphText(props)
    return withThemeContext(function(theme)
        -- set defaults
        props.Gaps = props.Gaps ~= nil and props.Gaps or MultiparagraphTextPropDefaults.Gaps

        local ParagraphContainer = Column({ Gaps = props.Gaps }, createTextChildren(props.Component.props, theme))
        return ParagraphContainer
    end)
end

return MultiparagraphText
