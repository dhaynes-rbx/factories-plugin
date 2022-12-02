--!strict
local Manifest = require(script.Parent.Parent.Assets.Manifest)
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local BentoBlox = require(Packages.BentoBlox)
local Column = require(BentoBlox.Components.Column)
local Row = require(BentoBlox.Components.Row)
local Block = require(BentoBlox.Components.Block)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

local MEDIUM_HORIZONTAL_ARROW_WIDTH = 16
local MEDIUM_HORIZONTAL_ARROW_HEIGHT = 25
local MEDIUM_VERTICAL_ARROW_WIDTH = 25
local MEDIUM_VERTICAL_ARROW_HEIGHT = 16
local LARGE_HORIZONTAL_ARROW_WIDTH = 32
local LARGE_HORIZONTAL_ARROW_HEIGHT = 50
local LARGE_VERTICAL_ARROW_WIDTH = 50
local LARGE_VERTICAL_ARROW_HEIGHT = 32

type OffsetOrUDim = number | UDim
--- Module

--[[--
    @tfield UDim2? Position
    @tfield Vector2? AnchorPoint
    @tfield any? ref
    @tfield string?="Right" PointerSide
    @tfield number? PointerOffset
    @tfield Color3? PointerColor
    @tfield string?="Small" PointerSize
    @table Props
]]

export type Props = {
    Position: UDim2?,
    AnchorPoint: Vector2?,
    ref: any?,
    PointerSide: string?,
    PointerOffset: number?,
    PointerColor: Color3?,
    PointerSize: string?,
    Width: OffsetOrUDim?,
}

local PropDefaults = {
    Position = UDim2.new(0, 0, 0, 0),
    AnchorPoint = Vector2.new(0, 0),
    PointerSide = "Right",
    PointerOffset = 0,
    -- TODO: how should we access our theme tokens here?
    -- PointerColor = theme.Tokens.Colors.Surface.Color
    PointerSize = "Small",
}

local getPointer = function(props, zIndex)
    if props.PointerSide == "Top" then
        return Block({
            LayoutOrder = 0,
            Size = props.PointerSize == "Small" and UDim2.new(1, 0, 0, MEDIUM_VERTICAL_ARROW_HEIGHT)
                or UDim2.new(1, 0, 0, LARGE_VERTICAL_ARROW_HEIGHT),
            AutomaticSize = Enum.AutomaticSize.X,
            ZIndex = zIndex,
        }, {
            Arrow = Roact.createElement("ImageLabel", {
                Image = props.PointerSize == "Small" and Manifest["tip-medium-top"] or Manifest["tip-large-top"],
                ImageColor3 = props.PointerColor,
                Size = props.PointerSize == "Small"
                        and UDim2.fromOffset(MEDIUM_VERTICAL_ARROW_WIDTH, MEDIUM_VERTICAL_ARROW_HEIGHT)
                    or UDim2.fromOffset(LARGE_VERTICAL_ARROW_WIDTH, LARGE_VERTICAL_ARROW_HEIGHT),
                Position = UDim2.new(UDim.new(0.5, props.PointerOffset), UDim.new(0, 0)),
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundTransparency = 1,
                ZIndex = zIndex,
            }),
        })
    end

    if props.PointerSide == "Bottom" then
        return Block({
            LayoutOrder = 2,
            Size = props.PointerSize == "Small" and UDim2.new(1, 0, 0, MEDIUM_VERTICAL_ARROW_HEIGHT)
                or UDim2.new(1, 0, 0, LARGE_VERTICAL_ARROW_HEIGHT),
            AutomaticSize = Enum.AutomaticSize.X,
            ZIndex = zIndex,
        }, {
            Arrow = Roact.createElement("ImageLabel", {
                Image = props.PointerSize == "Small" and Manifest["tip-medium-bottom"] or Manifest["tip-large-bottom"],
                ImageColor3 = props.PointerColor,
                Size = props.PointerSize == "Small"
                        and UDim2.fromOffset(MEDIUM_VERTICAL_ARROW_WIDTH, MEDIUM_VERTICAL_ARROW_HEIGHT)
                    or UDim2.fromOffset(LARGE_VERTICAL_ARROW_WIDTH, LARGE_VERTICAL_ARROW_HEIGHT),
                Position = UDim2.new(UDim.new(0.5, props.PointerOffset), UDim.new(0, 0)),
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundTransparency = 1,
                ZIndex = zIndex,
            }),
        })
    end

    if props.PointerSide == "Left" then
        return Block({
            LayoutOrder = 0,
            Size = props.PointerSize == "Small" and UDim2.fromOffset(0, MEDIUM_HORIZONTAL_ARROW_WIDTH)
                or UDim2.fromOffset(0, LARGE_HORIZONTAL_ARROW_WIDTH),
            ZIndex = zIndex,
            AutomaticSize = Enum.AutomaticSize.X,
        }, {
            Arrow = Roact.createElement("ImageLabel", {
                Image = props.PointerSize == "Small" and Manifest["tip-medium-left"] or Manifest["tip-large-left"],
                ImageColor3 = props.PointerColor,
                Size = props.PointerSize == "Small"
                        and UDim2.fromOffset(MEDIUM_HORIZONTAL_ARROW_WIDTH, MEDIUM_HORIZONTAL_ARROW_HEIGHT)
                    or UDim2.fromOffset(LARGE_HORIZONTAL_ARROW_WIDTH, LARGE_HORIZONTAL_ARROW_HEIGHT),
                Position = UDim2.new(UDim.new(0, 0), UDim.new(0.5, props.PointerOffset)),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                ZIndex = zIndex,
            }),
        })
    end

    if props.PointerSide == "Right" then
        return Block({
            LayoutOrder = 2,
            Size = props.PointerSize == "Small" and UDim2.fromOffset(0, MEDIUM_HORIZONTAL_ARROW_WIDTH)
                or UDim2.fromOffset(0, LARGE_HORIZONTAL_ARROW_WIDTH),
            ZIndex = zIndex,
            AutomaticSize = Enum.AutomaticSize.X,
        }, {
            Arrow = Roact.createElement("ImageLabel", {
                Image = props.PointerSize == "Small" and Manifest["tip-medium-right"] or Manifest["tip-large-right"],
                ImageColor3 = props.PointerColor,
                Size = props.PointerSize == "Small"
                        and UDim2.fromOffset(MEDIUM_HORIZONTAL_ARROW_WIDTH, MEDIUM_HORIZONTAL_ARROW_HEIGHT)
                    or UDim2.fromOffset(LARGE_HORIZONTAL_ARROW_WIDTH, LARGE_HORIZONTAL_ARROW_HEIGHT),
                Position = UDim2.new(UDim.new(0, 0), UDim.new(0.5, props.PointerOffset)),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                ZIndex = zIndex,
            }),
        })
    end
end

local renderContainer = function(props, children)
    local zIndex = props.ZIndex or 1
    if props.PointerSide == "Top" or props.PointerSide == "Bottom" then
        return Column({
            AutomaticSize = (function()
                local hasWidth = props.Width ~= nil

                if hasWidth then
                    return Enum.AutomaticSize.Y
                end

                return Enum.AutomaticSize.XY
            end)(),
            Size = (function()
                local hasWidth = props.Width ~= nil

                if hasWidth then
                    local widthIsNumber = type(props.Width) == "number"
                    if widthIsNumber then
                        return UDim2.new(0, props.Width, 0, 0)
                    else
                        return UDim2.new(props.Width.Scale, props.Width.Offset, 0, 0)
                    end
                end
            end)(),
            Position = props.Position,
            AnchorPoint = props.AnchorPoint,
            Ref = props.ref,
            ZIndex = zIndex,
        }, {
            ArrowBlock = getPointer(props, zIndex),
            PointerBlockInner = Block({
                Size = UDim2.fromScale(0, 0),
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                ZIndex = zIndex,
            }, {
                PointerBlockInnerColumn = Column(
                    { AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.fromScale(0, 0), ZIndex = zIndex },
                    {
                        BodyColumn = Column({
                            AutomaticSize = Enum.AutomaticSize.XY,
                            LayoutOrder = 1,
                            ZIndex = zIndex,
                        }, children),
                    }
                ),
            }),
        })
    else
        return Row({
            AutomaticSize = Enum.AutomaticSize.XY,
            Position = props.Position,
            AnchorPoint = props.AnchorPoint,
            ref = props.ref,
            ZIndex = zIndex,
        }, {
            ArrowBlock = getPointer(props, zIndex),
            PointerBlockInner = Block({
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                ZIndex = zIndex,
            }, {
                PointerBlockInnerColumn = Column({
                    AutomaticSize = Enum.AutomaticSize.XY,
                    ZIndex = zIndex,
                }, {
                    BodyColumn = Column({
                        AutomaticSize = Enum.AutomaticSize.XY,
                        LayoutOrder = 1,
                        ZIndex = zIndex,
                    }, children),
                }),
            }),
        })
    end
end

--- @lfunction PointerBlock A transparent block that handles laying out a content container and an arrow tip.
--- @tparam Props props
local function PointerBlock(props: Props, children)
    return withThemeContext(function(theme)
        -- set defaults
        props.PointerSide = props.PointerSide ~= nil and props.PointerSide or PropDefaults.PointerSide
        props.AnchorPoint = props.AnchorPoint ~= nil and props.AnchorPoint or PropDefaults.AnchorPoint
        props.PointerOffset = props.PointerOffset ~= nil and props.PointerOffset or PropDefaults.PointerOffset
        props.PointerColor = props.PointerColor ~= nil and props.PointerColor or theme.Tokens.Colors.Surface.Color
        props.PointerSize = props.PointerSize ~= nil and props.PointerSize or PropDefaults.PointerSize

        children = children or {}

        -- Rendered as a column if PointerPosition is "Top" or "Bottom," otherwise as a row
        local pointerBlockContainer = renderContainer(props, children)

        return pointerBlockContainer
    end)
end

return PointerBlock
