--!strict
local Packages = script.Parent.Parent.Parent
local Dash = require(Packages.Dash)
local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)
local sizedByShorthand = require(script.Parent.Parent.Utilities.SizedByShorthand)
local paddingByShorthand = require(script.Parent.Parent.Utilities.PaddingByShorthand)

--- Module

local visible = true

type OffsetOrUDim = number | UDim
export type Props = {
    Active: boolean?,
    AnchorPoint: Vector2?,
    AutomaticSize: Enum.AutomaticSize?,
    BackgroundColor: Color3?,
    BackgroundTransparency: number?,
    BlockClicks: boolean?,
    BorderColor3: Color3?,
    BorderSizePixel: number?,
    BorderMode: Enum?,
    Children: any,
    ClipsDescendants: boolean?,
    Corner: UDim?,
    Debounce: number?,
    FrameRef: any?,
    HasStroke: boolean?,
    Height: OffsetOrUDim?,
    LayoutOrder: number?,
    Name: string?,
    OnClick: () -> nil?,
    OnMouseEnter: () -> nil?,
    OnMouseLeave: () -> nil?,
    Padding: OffsetOrUDim | { OffsetOrUDim }?,
    PaddingHorizontal: OffsetOrUDim?,
    PaddingVertical: OffsetOrUDim?,
    PaddingTop: OffsetOrUDim?,
    PaddingRight: OffsetOrUDim?,
    PaddingBottom: OffsetOrUDim?,
    PaddingLeft: OffsetOrUDim?,
    Position: UDim2?,
    ref: any?,
    Size: OffsetOrUDim?,
    StrokeColor: Color3?,
    StrokeThickness: number?,
    Visible: boolean?,
    Width: OffsetOrUDim?,
    ZIndex: number?,
}

--- @function Block Layout element. Wrapper for Frame.
--- @tparam {
--- } props
function Block(props: Props)
    local debounce: boolean, setDebounce: (boolean) -> nil = React.useState(false)

    local sized = sizedByShorthand(props)
    local padding = paddingByShorthand(props)
    if props.Visible == nil then
        props.Visible = visible
    end

    local children = props.Children or {}

    if padding then
        children.UIPadding = React.createElement("UIPadding", padding)
    end

    if props.Corner then
        children.UICorner = React.createElement("UICorner", {
            CornerRadius = props.Corner,
        })
    end

    if props.HasStroke then
        children.UIStroke = React.createElement("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Thickness = props.StrokeThickness or 2,
            Color = props.StrokeColor or Color3.fromRGB(255, 255, 255),
        })
    end

    if props.BlockClicks or props.OnClick or props.OnMouseEnter or props.OnMouseLeave then
        local size: UDim2
        local position: UDim2
        if padding then
            size = UDim2.new(
                1,
                padding.PaddingLeft.Offset + padding.PaddingRight.Offset,
                1,
                padding.PaddingTop.Offset + padding.PaddingBottom.Offset
            )
            position = UDim2.fromOffset(-padding.PaddingLeft.Offset, -padding.PaddingTop.Offset)
        else
            size = UDim2.fromScale(1, 1)
            position = UDim2.new()
        end
        children.ClickHandler = React.createElement("TextButton", {
            Size = size,
            Position = position,
            Text = "",
            Active = false,
            BackgroundTransparency = 1,
            [ReactRoblox.Event.MouseButton1Click] = props.OnClick and function()
                if props.Debounce then
                    if debounce then
                        return
                    end
                    setDebounce(true)
                    task.delay(props.Debounce, function()
                        setDebounce(false)
                    end)
                end
                props.OnClick()
            end,
            [ReactRoblox.Event.MouseEnter] = props.OnMouseEnter,
            [ReactRoblox.Event.MouseLeave] = props.OnMouseLeave,
            ZIndex = props.ZIndex ~= nil and props.ZIndex or 1,
        })
    end

    local backgroundTransparency = props.BackgroundTransparency ~= nil and props.BackgroundTransparency or 1 -- default to transparent
    if props.BackgroundTransparency == nil and props.BackgroundColor then
        backgroundTransparency = 0
    end

    return React.createElement(
        "Frame",
        Dash.assign({
            BackgroundTransparency = backgroundTransparency,
            BackgroundColor3 = props.BackgroundColor, -- or props.Color?

            Size = sized.Size,
            AutomaticSize = sized.AutomaticSize,
            AnchorPoint = props.AnchorPoint,
            Position = props.Position,
            ZIndex = props.ZIndex ~= nil and props.ZIndex or 1,
            Active = props.Active or false,
            ClipsDescendants = props.ClipsDescendants or false,

            -- TODO: Add access to Color Tokens and replace border default with "Interactive Surface"
            BorderColor3 = props.BorderColor,
            BorderSizePixel = props.BorderSizePixel or 0,
            BorderMode = props.BorderMode or Enum.BorderMode.Outline,
            LayoutOrder = props.LayoutOrder or 0,
            Visible = props.Visible,
            Name = props.Name,
            ref = props.FrameRef,
        }),
        children
    )
end

return function(props: Props, children)
    if children then
        props.Children = children
    end
    -- TODO, should use forward ref here, but it's causing errors
    if props.ref then
        props = Dash.assign(props, { FrameRef = props.ref })
    end
    return React.createElement(Block, props)
end
