--!strict
local Roact = require(script.Parent.Parent.Parent.Roact)
local Dash = require(script.Parent.Parent.Parent.Dash)
local sizedByShorthand = require(script.Parent.Parent.Utilities.SizedByShorthand)
local paddingByShorthand = require(script.Parent.Parent.Utilities.PaddingByShorthand)
type OffsetOrUDim = number | UDim
export type Props = {
    AutomaticSize: Enum.AutomaticSize?,
    Color: Color3?,
    BackgroundTransparency: number?,
    BorderSizePixel: number?,
    CornerRadius: number?,
    Gaps: number?,
    Height: OffsetOrUDim?,
    HorizontalAlignment: Enum.HorizontalAlignment?,
    LayoutOrder: number?,
    Padding: OffsetOrUDim | { OffsetOrUDim }?,
    PaddingHorizontal: OffsetOrUDim?,
    PaddingVertical: OffsetOrUDim?,
    PaddingTop: OffsetOrUDim?,
    PaddingRight: OffsetOrUDim?,
    PaddingBottom: OffsetOrUDim?,
    PaddingLeft: OffsetOrUDim?,
    Position: UDim2?,
    AnchorPoint: Vector2?,
    Ref: any?,
    Size: OffsetOrUDim?,
    SortOrder: Enum.SortOrder?,
    VerticalAlignment: Enum.VerticalAlignment?,
    Width: OffsetOrUDim?,
    ZIndex: number?,
}

-- TODO: enforce children be type "table of RoactElements" or padding and layout get destroyed
function Column(props, children)
    local sized = sizedByShorthand(props)
    local padding = paddingByShorthand(props)

    local childrenInColumn = Dash.join(
        {
            UIPadding = padding and Roact.createElement("UIPadding", padding) or nil,
            UIListLayout = Roact.createElement("UIListLayout", {
                SortOrder = props.SortOrder or Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Left,
                VerticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Top,
                Padding = props.Gaps and UDim.new(0, props.Gaps) or nil, -- TODO: support offsetOrUdim
            }),
            UICorner = props.CornerRadius and Roact.createElement("UICorner", {
                CornerRadius = UDim.new(0, props.CornerRadius),
            }) or nil,
        },
        children -- orderedChildren
        -- TODO:
        -- iterate these and give them a layout order by source order (or use LayoutOrder if specified.. and skip?)
    )

    return Roact.createElement("Frame", {
        BackgroundColor3 = props.Color, -- Q. BackgroundColor3
        BackgroundTransparency = props.Color and (props.BackgroundTransparency or 0) or 1,
        Size = sized.Size,
        AutomaticSize = sized.AutomaticSize,
        Position = props.Position or UDim2.new(0, 0, 0, 0),
        AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
        BorderSizePixel = props.BorderSize or 0,
        LayoutOrder = props.LayoutOrder,
        ZIndex = props.ZIndex or 1,
        [Roact.Ref] = props.Ref,
    }, childrenInColumn)
end

return Column
