--!strict
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local BentoBlox = require(Packages.BentoBlox)
local Row = require(BentoBlox.Components.Row)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

--- Module

--[[--
    @tfield number?=0 Offset
    @tfield number?=6 DashHeight
    @tfield number?=5 DashWidth
    @tfield number?=5 DashGap
    @tfield Vector3? Start
    @tfield Vector3? End
    @table LineProps
]]

type LineProps = {
    Active: boolean?,
    Offset: number?,
    DashHeight: number?,
    DashWidth: number?,
    DashGap: number?,
    Start: Vector3,
    End: Vector3,
    ZIndex: number?,
    BackgroundColor3: Color3,
    BackgroundTransparency: number,
}

local LinePropDefaults = {
    Active = true,
    Offset = 0,
    DashHeight = 6,
    DashWidth = 5,
    DashGap = 5,
}

--- @lfunction Line A generic line in screen space.
--- @tparam LineProps props
local function Line(props)
    return withThemeContext(function(theme)
        -- set defaults
        props.Offset = props.Offset ~= nil and props.Offset or LinePropDefaults.Offset
        props.DashGap = props.DashGap ~= nil and props.DashGap or LinePropDefaults.DashGap
        if props.Active == nil then
            props.Active = LinePropDefaults.Active
        end

        local offset: Vector3 = props.Start - props.End
        local center: Vector3 = props.End + offset / 2
        local distance = offset.Magnitude
        local angle = math.deg(math.atan2(offset.Y, offset.X))

        local dashCount = 1
        local dashWidth = distance - props.DashGap * 2

        if props.Dashes then
            dashCount = distance / (props.DashWidth + props.DashGap)
            dashWidth = props.DashWidth
        end

        local dashes = {}
        for _ = 1, dashCount do
            table.insert(
                dashes,
                Roact.createElement("ImageLabel", {
                    BackgroundColor3 = props.BackgroundColor3 or theme.Tokens.Colors.InteractiveLine.Color,
                    Size = UDim2.new(0, dashWidth, 1, 0),
                    Active = props.Active,
                    ZIndex = props.ZIndex or 1,
                    BorderSizePixel = props.BorderSizePixel or 0,
                    BackgroundTransparency = props.BackgroundTransparency or 0,
                })
            )
        end

        return Roact.createElement("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(distance, props.DashHeight),
            AutomaticSize = Enum.AutomaticSize.None,
            Active = props.Active,
            ZIndex = props.ZIndex or 1,
            Position = UDim2.fromOffset(center.X, center.Y + props.Offset),
            Rotation = angle,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BorderSizePixel = 0,
        }, {
            Row({
                Size = UDim2.fromScale(1, 1),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Gaps = props.DashGap,
            }, dashes),
        })
    end)
end

return Line
