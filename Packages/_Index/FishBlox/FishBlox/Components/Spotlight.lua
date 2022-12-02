--!strict
local Camera = workspace:WaitForChild("Camera")
local Manifest = require(script.Parent.Parent.Assets.Manifest)
local Packages = script.Parent.Parent.Parent
local React = require(Packages.React)
local BentoBlox = require(Packages.BentoBlox)
local Block = require(BentoBlox.Components.Block)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

local SPACING = 10
local TUTORIAL_Z_INDEX = 4000

--- Module

--[[--
    @tfield boolean? BlockClicks
    @tfield Vector2? TargetSize
    @tfield Vector2? TargetPosition
    @tfield number? OffsetX
    @tfield number? OffsetY
    @table SpotlightProps
]]

export type SpotlightProps = {
    BlockClicks: boolean?, -- default true
    OffsetX: number?,
    OffsetY: number?,
    TargetPosition: Vector2?,
    TargetSize: Vector2?,
}

local getFrameXPosition = function(pos)
    if pos then
        return pos.X
    end
    return 0
end

local getFrameRightXPosition = function(pos, size)
    if pos and size then
        return pos.X + size.X
    end
    return 0
end

local getFrameYPosition = function(pos, size)
    if pos and size then
        return pos.Y + size.Y
    end
    return 0
end

local getFrameWidth = function(size)
    if size then
        return size.X
    end
    return 0
end

local getFrameRightWidth = function(pos, size)
    if pos and size then
        return Camera.ViewportSize.X - (pos.X + size.X)
    end
    return 0
end

local getFrameTopHeight = function(pos)
    if pos then
        return pos.Y
    end
    return 0
end

local getFrameBottomHeight = function(pos, size)
    if pos and size then
        return Camera.ViewportSize.Y - (pos.Y + size.Y)
    end
    return 0
end

--- @lfunction Spotlight A Spotlight for focusing on a UI element
--- @tparam SpotlightProps props
function Spotlight(props: SpotlightProps)
    local targetSize = props.TargetSize and Vector2.new(math.round(props.TargetSize.X), math.round(props.TargetSize.Y))
        or Vector2.new(0, 0)
    local targetPosition = props.TargetPosition
            and Vector2.new(math.round(props.TargetPosition.X), math.round(props.TargetPosition.Y))
        or Vector2.new(0, 0)
    local offsetX = props.OffsetX and math.round(props.OffsetX) or 0
    local offsetY = props.OffsetY and math.round(props.OffsetY) or 0
    local blockClicks = true
    if props.BlockClicks ~= nil then
        blockClicks = props.BlockClicks
    end

    return withThemeContext(function(theme)
        local zIndex = props.ZIndex or TUTORIAL_Z_INDEX
        return React.createElement("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ZIndex = zIndex,
        }, {
            -- Focus: maps to the target and provides the border
            Focus = React.createElement("ImageLabel", {
                Position = UDim2.fromOffset(targetPosition.X - SPACING - offsetX, targetPosition.Y - SPACING + offsetY),
                Size = UDim2.fromOffset(targetSize.X + SPACING * 2, targetSize.Y + SPACING * 2),
                Image = Manifest["spotlight-focus"],
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(12, 12, 52, 52),
                SliceScale = 1,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = zIndex,
            }),
            -- Above target
            Top = Block({
                Position = UDim2.fromOffset(getFrameXPosition(targetPosition) - SPACING - offsetX, 0),
                Size = UDim2.fromOffset(
                    getFrameWidth(targetSize) + SPACING * 2,
                    getFrameTopHeight(targetPosition) - SPACING + offsetY
                ),
                BackgroundColor = Color3.new(0, 0, 0),
                BackgroundTransparency = 0.5,
                BlockClicks = blockClicks,
                ZIndex = zIndex,
            }),
            -- Right of target, full height of viewport
            Right = Block({
                Position = UDim2.fromOffset(getFrameRightXPosition(targetPosition, targetSize) + SPACING - offsetX, 0),
                Size = UDim2.new(0, getFrameRightWidth(targetPosition, targetSize) - SPACING, 1, 0),
                BackgroundColor = Color3.new(0, 0, 0),
                BackgroundTransparency = 0.5,
                BlockClicks = blockClicks,
                ZIndex = zIndex,
            }),
            -- Below target
            Bottom = Block({
                Position = UDim2.fromOffset(
                    getFrameXPosition(targetPosition) - SPACING - offsetX,
                    getFrameYPosition(targetPosition, targetSize) + SPACING + offsetY
                ),
                Size = UDim2.fromOffset(
                    getFrameWidth(targetSize) + SPACING * 2,
                    getFrameBottomHeight(targetPosition, targetSize)
                ),
                BackgroundColor = Color3.new(0, 0, 0),
                BackgroundTransparency = 0.5,
                BlockClicks = blockClicks,
                ZIndex = zIndex,
            }),
            -- Left of target, full height of viewport
            Left = Block({
                Size = UDim2.new(0, getFrameWidth(targetPosition) - SPACING - offsetX, 1, 0),
                BackgroundColor = Color3.new(0, 0, 0),
                BackgroundTransparency = 0.5,
                BlockClicks = blockClicks,
                ZIndex = zIndex,
            }),
        })
    end)
end

return Spotlight
