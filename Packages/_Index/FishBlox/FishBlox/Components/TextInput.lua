--!strict
local TextService = game:GetService("TextService")
local Manifest = require(script.Parent.Parent.Assets.Manifest)
local Packages = script.Parent.Parent.Parent
local React = require(Packages.React)
local Roact = require(Packages.Roact)
local ReactRoblox = require(Packages.ReactRoblox)
local BentoBlox = require(Packages.BentoBlox)
local Block = require(BentoBlox.Components.Block)
local Column = require(BentoBlox.Components.Column)
local Row = require(BentoBlox.Components.Row)
local Text = require(script.Parent.Text)
local sizedByShorthand = require(BentoBlox.Utilities.SizedByShorthand)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)
--- Module

--[[--
    @tfield string? Value
    @tfield string? Placeholder
    @tfield boolean? Disabled
    @tfield UDim2? Size
    @tfield boolean? Wrap
    @tfield string? Label
    @tfield boolean? LabelInline
    @tfield boolean? HideLabel
    @tfield (nil) -> nil? OnChanged
    @table TextInputProps
]]
type TextInputProps = {
    Value: string?,
    Placeholder: string?,
    Disabled: boolean?,
    Size: UDim2?,
    Wrap: boolean?,
    Label: string?,
    LabelInline: boolean?,
    HideLabel: boolean?,
    OnChanged: ((nil) -> nil)?,
}

local function getLineHeight(theme, wrap)
    local lineHeight = 1

    if wrap then
        lineHeight = theme.Tokens.Typography.BodyMedium.LineHeight
    else
        local targetControlHeight = theme.Tokens.Sizes.Registered.ControlHeight.Value -- add as size token
        local padding = (2 * theme.Tokens.Sizes.Registered.Medium.Value)
        local singleLineheight = (targetControlHeight - padding) / theme.Tokens.Typography.BodyMedium.FontSize

        lineHeight = singleLineheight
    end

    return lineHeight
end

local function getBorderImage(theme, props, focused)
    if props.Disabled then
        return Manifest["text-input-border-disabled"]
    end

    if focused then
        if theme.ThemeKey == "Dark" then
            return Manifest["text-input-border-selected-dark"]
        end
        return Manifest["text-input-border-selected-light"]
    end
    return Manifest["text-input-border"]
end

local function getTextColor(props, theme)
    if props.Disabled then
        return theme.Tokens.Colors.DisabledSurfaceText.Color
    end
    return theme.Tokens.Colors.Text.Color
end

local function getTextWrap(props, theme)
    if props.Wrap then
        return true
    end

    if props.Size and props.Size.Y and props.Size.Y.Offset then
        return props.Size.Y.Offset > theme.Tokens.Sizes.Registered.ControlHeight.Value
    end

    return false
end

local function adjustTextPosition(textBoxRef, textWrapperRef, theme)
    local reveal = textWrapperRef.current.AbsoluteSize.X

    if textBoxRef.current.TextBounds.X <= reveal then
        -- we fit so be normal
        textBoxRef.current.Position = UDim2.fromOffset(0, 0)
    else
        -- we don't fit, so adjust position
        local cursor = textBoxRef.current.CursorPosition
        if cursor ~= -1 then
            -- calculate pixel width of text from start to cursor
            local subtext = string.sub(textBoxRef.current.Text, 1, cursor - 1)
            local width = TextService:GetTextSize(
                subtext,
                textBoxRef.current.TextSize,
                textBoxRef.current.Font,
                Vector2.new(math.huge, math.huge)
            ).X

            -- check if we're inside the box with the cursor
            local currentCursorPos = textBoxRef.current.Position.X.Offset + width

            -- adjust if necessary
            if currentCursorPos < 0 then
                textBoxRef.current.Position = UDim2.fromOffset(-width, 0)
            elseif currentCursorPos > reveal - 1 then
                textBoxRef.current.Position = UDim2.fromOffset(reveal - width - 1, 0)
            end
        end
    end
end

--- @lfunction TextInput A basic text input
--- @tparam TextInputProps props
local function TextInput(props: TextInputProps, children)
    local sized = sizedByShorthand(props)

    -- Hooks
    local focused, setFocused = React.useState(false)
    local textBoxRef = React.useRef(nil)
    local textBlockRef = React.useRef(nil)

    return withThemeContext(function(theme)
        local label = Text({
            Text = props.Label or "Label",
            Font = theme.Tokens.Typography.HeadlineSmall.Font,
            FontSize = theme.Tokens.Typography.HeadlineSmall.FontSize,
            Color = theme.Tokens.Typography.HeadlineSmall.Color,
            AutomaticSize = Enum.AutomaticSize.XY,
            LayoutOrder = 1,
        })

        local textBox = React.createElement("TextBox", {
            -- TODO: change the large version to a prop "MaxChars"?
            Size = getTextWrap(props, theme) and UDim2.fromScale(1, 1) or UDim2.fromScale(5, 1),
            Position = UDim2.fromOffset(0, 0),
            AutomaticSize = Enum.AutomaticSize.XY,
            PlaceholderText = props.Placeholder,
            Text = props.Value,
            TextXAlignment = Enum.TextXAlignment.Left,
            LineHeight = getLineHeight(theme, getTextWrap(props, theme)),
            ClipsDescendants = true,
            BackgroundTransparency = 1,
            PlaceholderColor3 = theme.Tokens.Colors.TextSubtle.Color,
            TextColor3 = getTextColor(props, theme),
            Font = theme.Tokens.Typography.BodyMedium.Font,
            TextSize = theme.Tokens.Typography.BodyMedium.FontSize,
            RichText = true,
            ClearTextOnFocus = false,
            TextWrapped = getTextWrap(props, theme),
            TextEditable = not props.Disabled,
            ref = textBoxRef,
            [ReactRoblox.Event.Focused] = function()
                if props.Disabled then
                    textBoxRef.current:ReleaseFocus()
                end
                setFocused(true)
            end,
            [ReactRoblox.Event.FocusLost] = function()
                setFocused(false)

                if not getTextWrap(props, theme) then
                    textBoxRef.current.Position = UDim2.fromOffset(0, 0)
                end
            end,
            [ReactRoblox.Change.Text] = function(rbx)
                if not getTextWrap(props, theme) then
                    adjustTextPosition(textBoxRef, textBlockRef, theme)
                end

                if props.OnChanged then
                    props.OnChanged(rbx.Text)
                end
            end,
            [ReactRoblox.Change.CursorPosition] = function()
                if not getTextWrap(props, theme) then
                    adjustTextPosition(textBoxRef, textBlockRef, theme)
                end
            end,
        })

        local textInputWrapper = React.createElement("ImageLabel", {
            Size = sized.Size or UDim2.fromScale(1, 0),
            AutomaticSize = sized.AutomaticSize or Enum.AutomaticSize.Y,
            Image = getBorderImage(theme, props, focused),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(8, 8, 24, 24),
            SliceScale = 1,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = 2,
        }, {
            UIPadding = Roact.createElement("UIPadding", {
                PaddingTop = UDim.new(0, theme.Tokens.Sizes.Registered.Medium.Value),
                PaddingRight = UDim.new(0, theme.Tokens.Sizes.Registered.Medium.Value),
                PaddingBottom = UDim.new(0, theme.Tokens.Sizes.Registered.Medium.Value),
                PaddingLeft = UDim.new(0, theme.Tokens.Sizes.Registered.Medium.Value),
            }),
            Block = Block({
                Size = UDim2.fromScale(1, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                [Roact.Ref] = textBlockRef,
            }, {
                TextBox = textBox,
            }),
        })

        local textColumn = Column(
            { Gaps = theme.Tokens.Sizes.Registered.Small.Value },
            { LabelSlot = not props.HideLabel and (children["Label"] or label) or nil, Wrapper = textInputWrapper }
        )
        local textRow = Row(
            { Gaps = theme.Tokens.Sizes.Registered.Medium.Value },
            { LabelSlot = not props.HideLabel and (children["Label"] or label) or nil, Wrapper = textInputWrapper }
        )

        -- Returns a column with a label and text wrapper unless LabelInline is true, in which
        -- case a row is returned instead.
        if props.LabelInline then
            return textRow
        end
        return textColumn
    end)
end

return function(props: TextInputProps)
    return React.createElement(TextInput, props)
end
