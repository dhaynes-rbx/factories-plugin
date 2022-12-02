--!strict
local Manifest = require(script.Parent.Parent.Assets.Manifest)
local Packages = script.Parent.Parent.Parent
local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)
local Dash = require(Packages.Dash)
local Utilities = require(Packages.Utilities)
local BentoBlox = require(Packages.BentoBlox)
local Row = require(BentoBlox.Components.Row)
local Text = require(script.Parent.Text)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

type OffsetOrUDim = number | UDim
--- Module

--[[--
    @tfield boolean?=true Active Is the button active or disabled
    @tfield string?="Filled" Appearance "Filled" ,"Outline", "Borderless", "Roblox"
    @tfield number?=0 Time to wait until button is clickable again. If < 0 then it is never clickable beyond the first click
    @tfield boolean?=false Large Large button mode
    @tfield string?="" Label
    @tfield UDim2? Size
    @tfield OffsetOrUDim? Width
    @tfield boolean?=false FullyRoundedCorners
    @tfield boolean?=false HasStroke The button has a UIStroke
    @tfield boolean?=false IsNavigation
    @tfield string?="" NavDirection
    @tfield boolean?=false IsToggle
    @tfield Enum? TextXAlignment
    @tfield (self: Button) -> nil? OnActivated Called when the button is clicked
    @table ButtonProps
]]

export type ButtonProps = {
    Active: boolean?,
    Appearance: string?,
    Debounce: number?,
    Large: string?,
    Label: string?,
    Size: UDim2?,
    Width: OffsetOrUDim?,
    FullyRoundedCorners: boolean?,
    HasStroke: boolean?,
    StrokeColor: string?,
    Padding: number?,
    HorizontalAlignment: Enum.HorizontalAlignment?,
    IsNavigation: boolean?,
    NavDirection: string?,
    IsToggle: boolean?,
    TextXAlignment: Enum?,
    OnActivated: ((nil) -> nil)?,
    ZIndex: number?,
}

local ButtonPropDefaults = {
    Active = true,
    Appearance = "Filled",
    Debounce = 0,
    Large = false,
    Label = "",
    FullyRoundedCorners = false,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
}

local Button = React.Component:extend("Button")

function Button:init()
    self.shouldDebounce = false
    self.filledButtonStates = {
        "Filled",
    }
    self:setState({
        mouseIsOver = false,
        toggled = false,
    })
end

--- @lfunction Button Basic Button
--- @tparam ButtonProps props
function Button:render()
    local automaticSize = Enum.AutomaticSize.XY
    local size = self.props.Size

    -- only use width if size is not defined
    if size == nil then
        local hasWidth = self.props.Width ~= nil
        if hasWidth then
            local widthIsNumber = type(self.props.Width) == "number"
            if widthIsNumber then
                size = UDim2.new(0, self.props.Width, 0, 0)
            else
                size = UDim2.new(self.props.Width.Scale, self.props.Width.Offset, 0, 0)
                if self.props.Width.Scale ~= 0 or self.props.Width.Offset ~= 0 then
                    automaticSize = Enum.AutomaticSize.Y
                end
            end
        end
    end

    -- set defaults
    if self.props.Active == nil then
        self.props.Active = ButtonPropDefaults.Active
    end
    self.props.Appearance = self.props.Appearance ~= nil and self.props.Appearance or ButtonPropDefaults.Appearance
    if self.props.Large == nil then
        self.props.Large = ButtonPropDefaults.Large
    end
    self.props.Label = self.props.Label ~= nil and self.props.Label or ButtonPropDefaults.Label
    if self.props.FullyRoundedCorners == nil then
        self.props.FullyRoundedCorners = ButtonPropDefaults.FullyRoundedCorners
    end
    if self.props.Debounce == nil then
        self.props.Debounce = ButtonPropDefaults.Debounce
    end
    return withThemeContext(function(theme)
        local buttonLabelRow = Row({
            AutomaticSize = Enum.AutomaticSize.XY,
            Gaps = self.props.Label ~= "" and theme.Tokens.Sizes.Registered.Medium.Value or 0,
            HorizontalAlignment = self.props.HorizontalAlignment and self.props.HorizontalAlignment
                or ButtonPropDefaults.HorizontalAlignment,
        }, {
            NavLeft = self.props.IsNavigation
                and self.props.NavDirection == "back"
                and React.createElement("ImageLabel", {
                    Size = UDim2.fromOffset(9, 17),
                    BackgroundTransparency = 1,
                    Image = Manifest["nav-chevron-left"],
                    ImageColor3 = self:getTextColor(theme),
                    LayoutOrder = 0,
                } or nil),
            Label = Text({
                AutomaticSize = self:getLabelAutomaticSize(self.props),
                Size = self:getLabelSize(self.props, theme),
                Text = self.props.Label,
                Color = self:getTextColor(theme),
                Font = theme.Tokens.Typography.Button.Font,
                FontSize = self.props.Large and theme.Tokens.Typography.ButtonLarge.FontSize
                    or theme.Tokens.Typography.Button.FontSize,
                TextXAlignment = self.props.TextXAlignment or Enum.TextXAlignment.Left,
                ZIndex = self.props.ZIndex or 1,
                LayoutOrder = 1,
            }),
            NavRight = self.props.IsNavigation
                and self.props.NavDirection == "forward"
                and React.createElement("ImageLabel", {
                    Size = UDim2.fromOffset(9, 17),
                    BackgroundTransparency = 1,
                    Image = Manifest["nav-chevron-right"],
                    ImageColor3 = self:getTextColor(theme),
                    LayoutOrder = 2,
                } or nil),
            ImageLabel = (self.props.children and self.props.children.Image)
                or (self.props.children and self.props.children[1])
                or nil,
        })

        local childrenOrDefault = {}

        if self.props.Label and #self.props.Label > 0 then
            childrenOrDefault["Row"] = buttonLabelRow
        else
            if self.props.children then
                childrenOrDefault = self.props.children
            end
        end

        local imageLabel = nil
        if self.props.Image then
            imageLabel = self.props.Image
        elseif self.props[React.Children] and self.props[React.Children].Image then
            imageLabel = self.props[React.Children].Image
        end
        local buttonChildrenJoin = Dash.join(
            {
                UIPadding = React.createElement("UIPadding", {
                    PaddingLeft = self.props.Padding and UDim.new(0, self.props.Padding)
                        or UDim.new(0, self:getHorizontalPadding(theme)),
                    PaddingTop = self.props.Padding and UDim.new(0, self.props.Padding)
                        or UDim.new(0, self:getVerticalPadding(theme)),
                    PaddingRight = self.props.Padding and UDim.new(0, self.props.Padding)
                        or UDim.new(0, self:getHorizontalPadding(theme)),
                    PaddingBottom = self.props.Padding and UDim.new(0, self.props.Padding)
                        or UDim.new(0, self:getVerticalPadding(theme)),
                }),
                UICorner = React.createElement("UICorner", {
                    CornerRadius = self:getCornerRadius(theme),
                }),
                UIStroke = self:getUIStroke(theme),
                -- TODO: Add UIGradient for disabled state
                UIGradient = self.props.Active
                        and Dash.includes(self.filledButtonStates, self.props.Appearance)
                        and React.createElement("UIGradient", {
                            Color = self:getColorGradient(theme),
                            Rotation = 90,
                        })
                    or nil,
            },
            childrenOrDefault,
            {
                ImageLabel = self.props.IsToggle and self.state.toggled and self:getToggleImageLabel() or imageLabel,
            }
        )
        return React.createElement("TextButton", {
            Size = size or UDim2.new(self.props.Width, { 0, 0 }),
            AutomaticSize = self.props.AutomaticSize or automaticSize,
            Text = "",
            BackgroundColor3 = self:getBackgroundColor(theme),
            BackgroundTransparency = self:getBackgroundTransparency(),
            Active = self.props.Active,
            ZIndex = self.props.ZIndex or 1,
            LayoutOrder = self.props.LayoutOrder or 0,
            AutoButtonColor = false,
            [ReactRoblox.Event.Activated] = function()
                if self.props.Active then
                    if self.state.mouseIsOver then
                        self:setState({
                            mouseIsOver = false,
                        })
                    end
                    if self.props.OnActivated and not self.shouldDebounce then
                        if self.props.Debounce then
                            self.shouldDebounce = true
                            if self.props.Debounce >= 0 then
                                task.delay(self.props.Debounce, function()
                                    self.shouldDebounce = false
                                end)
                            end
                        end
                        self.props.OnActivated()
                    end
                    if self.props.IsToggle then
                        local toggledState = self.state.toggled
                        self:setState({
                            toggled = not toggledState,
                        })
                    end
                end
            end,
            [ReactRoblox.Event.MouseEnter] = function()
                if self.props.Active then
                    self:setState({
                        mouseIsOver = true,
                    })
                    if self.props.OnMouseEnter then
                        self.props.OnMouseEnter()
                    end
                end
            end,
            [ReactRoblox.Event.MouseLeave] = function()
                if self.props.Active then
                    self:setState({
                        mouseIsOver = false,
                    })
                    if self.props.OnMouseLeave then
                        self.props.OnMouseLeave()
                    end
                end
            end,
        }, buttonChildrenJoin)
    end)
end

function Button:getLabelAutomaticSize(props: ButtonProps)
    local hasChildren = props.children and Utilities.getTableSize(props.children) > 0

    if hasChildren then
        return Enum.AutomaticSize.XY
    end

    if props.Size or props.Width then
        return Enum.AutomaticSize.Y
    end
    return Enum.AutomaticSize.XY
end

function Button:getLabelSize(props: ButtonProps, theme)
    local horizontalPadding = self:getHorizontalPadding(theme) * 2
    local hasChildren = props.children and Utilities.getTableSize(props.children) > 0

    if hasChildren then
        return UDim2.fromOffset(0, 0)
    end

    if props.Size then
        if props.Size.X.Offset > 0 then
            return UDim2.fromOffset(props.Size.X.Offset - horizontalPadding, 0)
        end
        return UDim2.fromScale(props.Size.X.Scale, 0)
    elseif props.Width then
        local widthIsNumber = type(props.Width) == "number"
        if widthIsNumber then
            return UDim2.fromOffset(self.props.Width - horizontalPadding, 0)
        else
            if self.props.Width.Offset > 0 then
                return UDim2.fromOffset(self.props.Width.Offset - horizontalPadding)
            end

            return UDim2.new(self.props.Width.Scale, self.props.Width.Offset, 0, 0)
        end
    end
    return nil
end

function Button:getTextColor(theme)
    if self.props.Active and self.props.Active ~= nil then
        if Dash.includes(self.filledButtonStates, self.props.Appearance) then
            return theme.Tokens.Colors.InteractiveSurfaceText.Color
        end
        if self.props.Appearance == "Outline" or self.props.Appearance == "Borderless" then
            if self.state.mouseIsOver then
                return theme.Tokens.Colors.InteractiveTextEmphasized.Color
            else
                return theme.Tokens.Colors.InteractiveText.Color
            end
        end
    end
    if not self.props.Active then
        return theme.Tokens.Colors.DisabledSurfaceText.Color
    end
end

function Button:getBackgroundColor(theme): string
    if self.props.Active and self.props.Active ~= nil then
        if Dash.includes(self.filledButtonStates, self.props.Appearance) then
            -- a white background allows the UIGradient on top to render as intended (no blending)
            return Color3.fromRGB(255, 255, 255)
        end

        if self.props.Appearance == "Roblox" then
            if self.props.IsToggle and self.state.toggled then
                return Color3.fromRGB(255, 255, 255)
            end
            return Color3.new(0, 0, 0)
        end
    end
    if not self.props.Active then
        return theme.Tokens.Colors.DisabledSurface.Color
    end
end

function Button:getBackgroundTransparency()
    if self.props.Appearance == "Roblox" then
        return self.state.toggled and 1 or 0.53
    end

    if Dash.includes(self.filledButtonStates, self.props.Appearance) then
        return 0
    end

    return 1
end

function Button:getColorGradient(theme)
    local gradientA1 = theme.Tokens.Colors.InteractiveSurfaceGradientA1.Color
    local gradientA2 = theme.Tokens.Colors.InteractiveSurfaceGradientA2.Color
    local gradientB1 = theme.Tokens.Colors.InteractiveSurfaceGradientB1.Color
    local gradientB2 = theme.Tokens.Colors.InteractiveSurfaceGradientB2.Color
    local gradientColorSequence = nil

    if self.props.Appearance == "Filled" then
        if self.state.mouseIsOver then
            gradientColorSequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, gradientB1),
                ColorSequenceKeypoint.new(1, gradientB2),
            })
        else
            gradientColorSequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, gradientA1),
                ColorSequenceKeypoint.new(1, gradientA2),
            })
        end
        return gradientColorSequence
    end
end

function Button:getUIStroke(theme)
    if self.props.HasStroke or self.props.Appearance == "Outline" then
        local strokeColor = self.props.StrokeColor or theme.Tokens.Colors.Surface.Color
        if self.props.Appearance == "Outline" then
            strokeColor = self.props.StrokeColor or theme.Tokens.Colors.InteractiveLine.Color
            if self.state.mouseIsOver then
                strokeColor = theme.Tokens.Colors.InteractiveLineEmphasized.Color
            end
            if not self.props.Active then
                strokeColor = theme.Tokens.Colors.DisabledLine.Color
            end
        end
        return React.createElement("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Thickness = self.props.StrokeThickness or 2,
            Color = strokeColor,
        })
    end
    return nil
end

function Button:getToggleImageLabel()
    return React.createElement("ImageLabel", {
        Size = UDim2.fromOffset(12, 18),
        AutomaticSize = Enum.AutomaticSize.None,
        BackgroundTransparency = 1,
        Image = self.props.ImageToggleSrc,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
    })
end

function Button:getHorizontalPadding(theme): number
    if self.props.Appearance == "Borderless" then
        if self.props.TextXAlignment and self.props.TextXAlignment ~= Enum.TextXAlignment.Center then
            return 0
        end
        return theme.Tokens.Sizes.Registered.Medium.Value
    end

    if self.props.Large then
        return theme.Tokens.Sizes.Registered.Large.Value
    else
        return theme.Tokens.Sizes.Registered.XMedium.Value
    end
end

function Button:getVerticalPadding(theme): number
    if self.props.Large then
        return theme.Tokens.Sizes.Registered.XMedium.Value
    else
        return theme.Tokens.Sizes.Registered.Medium.Value
    end
end

function Button:getCornerRadius(theme): number
    if self.props.FullyRoundedCorners then
        return UDim.new(0.5, 0)
    else
        if self.props.Appearance == "Roblox" then
            return UDim.new(0, theme.Tokens.Sizes.Registered.Small.Value)
        else
            return UDim.new(0, theme.Tokens.Sizes.Registered.SmallPlus.Value)
        end
    end
end

function Button:didUpdate()
    if self.props.ButtonIsToggled ~= nil and self.props.ButtonIsToggled ~= self.state.toggled then
        local toggleViaProp = self.props.ButtonIsToggled
        self:setState({
            toggled = toggleViaProp,
        })
    end
end

return function(props: ButtonProps, children, image)
    if image then
        props["Image"] = image
    end
    return React.createElement(Button, props, children)
end
