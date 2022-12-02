--!strict
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local BentoBlox = require(Packages.BentoBlox)
local sizedByShorthand = require(BentoBlox.Utilities.SizedByShorthand)

local baseFontSize = 16
local visible = true

--- Module

--[[--
    @tfield string?="Text" Text
    @table TextProps
]]
type OffsetOrUDim = number | UDim
export type TextProps = {
    AutomaticSize: Enum.AutomaticSize?,
    BackgroundTransparency: number?,
    Bold: boolean?,
    FontSize: number?,
    Height: OffsetOrUDim?,
    Italic: boolean?,
    LayoutOrder: number?,
    LineHeight: number?,
    RichText: boolean?,
    [Roact.Ref]: Roact.Ref?,
    Size: UDim2?,
    Text: string?,
    TextColor3: Color3?,
    TextTransparency: number?,
    TextWrapped: boolean?,
    TextXAlignment: Enum.TextXAlignment?,
    TextYAlignment: Enum.TextYAlignment?,
    Visible: boolean?,
    Width: OffsetOrUDim?,
    ZIndex: number?,
}

local TextPropDefaults = {
    Text = "Text",
}

local getTextStyle = function(props: TextProps)
    local str = props.Text
    local strPrefix = ""
    local strSuffix = ""

    if props.RichText then
        if props.Bold then
            strPrefix = strPrefix .. "<b>"
            strSuffix = strSuffix .. "</b>"
        end
        if props.Italic then
            strPrefix = strPrefix .. "<i>"
            if strSuffix ~= "" then
                strSuffix = "</i>" .. strSuffix
            else
                strSuffix = strSuffix .. "</i>"
            end
        end
    end

    return strPrefix .. str .. strSuffix
end

--- @lfunction Text Basic text
--- @tparam TextProps props
function Text(props: TextProps)
    props.Text = props.Text ~= nil and props.Text or TextPropDefaults.Text
    local fontSize = props.FontSize or baseFontSize
    props.Width = props.Width or UDim.new(1, 0) -- default to 1 (should sizedByShorthand handle this?)
    local sized = sizedByShorthand(props)
    if props.Visible == nil then
        props.Visible = visible
    end

    return Roact.createElement("TextLabel", {
        RichText = props.RichText,
        Text = typeof(props.Text) == "string" and props.Text ~= "" and getTextStyle(props) or props.Text,
        Font = props.Font or Enum.Font.SourceSans,
        TextSize = fontSize,
        LineHeight = props.LineHeight,
        TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
        TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Top,

        TextColor3 = props.Color,

        Size = props.Size or UDim2.fromOffset(0, 0),
        AutomaticSize = props.AutomaticSize or Enum.AutomaticSize.XY,

        TextWrapped = props.TextWrapped == nil and true or props.TextWrapped,

        BackgroundTransparency = 1,
        TextTransparency = props.TextTransparency ~= nil and props.TextTransparency or 0,
        LayoutOrder = props.LayoutOrder or 0,
        Visible = props.Visible,
        ZIndex = props.ZIndex or 1,
        [Roact.Ref] = props[Roact.Ref],
    })
end

return Text
