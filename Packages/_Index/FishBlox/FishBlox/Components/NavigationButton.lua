--!strict
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local Dash = require(Packages.Dash)
local Text = require(script.Parent.Text)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

type OffsetOrUDim = number | UDim
--- Module

--[[--
    @tfield boolean?=false IsBack Is it a back button?
    @tfield boolean?=true Active Is the button active?
    @tfield string?="Flat" Appearance "Raised" ,"Flat", "Outline"
    @tfield string?="Next" Label
    @tfield UDim2? Size
    @tfield OffsetOrUDim? Width
    @tfield number?=0 LayoutOrder
    @tfield (self: NavigationButton) -> nil? OnActivated Called when the button is clicked
    @table NavigationButtonProps
]]

type NavigationButtonProps = {
    IsBack: boolean?,
    Active: boolean?,
    Appearance: string?,
    Label: string?,
    Size: UDim2?,
    Width: OffsetOrUDim?,
    Corner: UDim?,
    LayoutOrder: number?,
    -- Callbacks
    OnActivated: ((nil) -> nil)?,
}

local NavigationButtonPropDefaults = {
    Active = true,
    Appearance = "Flat",
    Label = "Next",
    Corner = UDim.new(0, 8),
}

--- @lfunction NavigationButton Basic NavigationButton
--- @tparam NavigationButtonProps props
function NavigationButton(props: NavigationButtonProps)
    local automaticSize = Enum.AutomaticSize.XY
    local size = props.Size

    -- only use width if size is not defined
    if size == nil then
        local hasWidth = props.Width ~= nil
        if hasWidth then
            local widthIsNumber = type(props.Width) == "number"
            if widthIsNumber then
                size = UDim2.new(0, props.Width, 0, 0)
            else
                size = UDim2.new(props.Width.Scale, props.Width.Offset, 0, 0)
                if props.Width.Scale ~= 0 or props.Width.Offset ~= 0 then
                    automaticSize = Enum.AutomaticSize.Y
                end
            end
        end
    end

    if props.Active == nil then
        props.Active = NavigationButtonPropDefaults.Active
    end
    props.Appearance = props.Appearance ~= nil and props.Appearance or NavigationButtonPropDefaults.Appearance
    props.Corner = props.Corner ~= nil and props.Corner or NavigationButtonPropDefaults.Corner

    return withThemeContext(function(theme)
        local imagePath = "rbxassetid://6769889377"
        if props.IsBack then
            imagePath = "rbxassetid://6861694050"
        end

        local image = Roact.createElement("ImageLabel", {
            Size = UDim2.fromOffset(22, 22),
            Image = imagePath,
            ScaleType = Enum.ScaleType.Fit,
            BackgroundTransparency = 1,
            ZIndex = 2,
            LayoutOrder = props.IsBack and 0 or 1,
        })

        local labelText = props.Label
                and Text({
                AutomaticSize = Enum.AutomaticSize.XY,
                Text = props.Label,
                Color = props.Active and theme.Tokens.Colors.InteractiveSurfaceText.Color or theme.Tokens.Colors.DisabledSurfaceText.Color,
                Font = theme.Tokens.Typography.BodySmall.Font,
                FontSize = theme.Tokens.Typography.BodySmall.FontSize,
                TextXAlignment = Enum.TextXAlignment.Center,
                LayoutOrder = props.IsBack and 1 or 0,
            })
            or nil

        local buttonChildrenJoin = Dash.join({
            UIPadding = Roact.createElement("UIPadding", {
                PaddingLeft = props.Padding and UDim.new(0, props.Padding) or UDim.new(
                    0,
                    theme.Tokens.Sizes.Registered.Medium.Value
                ),
                PaddingTop = props.Padding and UDim.new(0, props.Padding) or UDim.new(
                    0,
                    theme.Tokens.Sizes.Registered.Small.Value
                ),
                PaddingRight = props.Padding and UDim.new(0, props.Padding) or UDim.new(
                    0,
                    theme.Tokens.Sizes.Registered.Medium.Value
                ),
                PaddingBottom = props.Padding and UDim.new(0, props.Padding) or UDim.new(
                    0,
                    theme.Tokens.Sizes.Registered.Small.Value
                ),
            }),
            UIListLayout = Roact.createElement("UIListLayout", {
                SortOrder = props.SortOrder or Enum.SortOrder.LayoutOrder,
                VerticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Center,
                HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Left,
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = props.Gaps and UDim.new(0, props.Gaps) or UDim.new(
                    0,
                    theme.Tokens.Sizes.Registered.Small.Value
                ), -- TODO: support offsetOrUdim
            }),
            UICorner = Roact.createElement("UICorner", {
                CornerRadius = props.Corner,
            }),
            UIStroke = props.HasStroke and Roact.createElement("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Thickness = props.StrokeThickness or 5,
                Color = props.StrokeColor or theme.Tokens.Colors.Surface.Color,
            }) or nil,
            Image = image,
            Label = labelText,
        })
        return Roact.createElement("TextButton", {
            Size = size or UDim2.new(props.Width, { 0, 0 }),
            AutomaticSize = props.AutomaticSize or automaticSize,
            Text = "",
            BackgroundColor3 = props.Active and theme.Tokens.Colors.InteractiveSurface.Color or theme.Tokens.Colors.DisabledSurface.Color,
            Active = props.Active,
            BorderSizePixel = props.BorderSize or 0,
            ZIndex = props.ZIndex or 1,
            LayoutOrder = props.LayoutOrder or 0,
            AutoButtonColor = props.Active,
            [Roact.Event.Activated] = props.Active and props.OnActivated or nil,
            [Roact.Event.MouseEnter] = props.Active and props.OnMouseEnter or nil,
            [Roact.Event.MouseLeave] = props.Active and props.OnMouseLeave or nil,
            [Roact.Event.MouseButton1Up] = props.Active and props.OnMouseButton1Up or nil,
        }, buttonChildrenJoin)
    end)
end

return NavigationButton
