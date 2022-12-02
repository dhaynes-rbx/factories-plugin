--!strict
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

--- Module

--[[--
    @tfield UDim2? Size
    @tfield UDim2? Position
    @table OverlayProps
]]

type OverlayProps = {
    Size: UDim2?,
    Position: UDim2?,
}

local OverlayPropDefaults = {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
}

--- @lfunction Overlay A semi-transparent screen cover
--- @tparam OverlayProps props
local function Overlay(props, children)
    return withThemeContext(function(theme)
        -- set defaults
        props.Size = props.Size ~= nil and props.Size or OverlayPropDefaults.Size
        props.Position = props.Position ~= nil and props.Position or OverlayPropDefaults.Position

        children = children or {}

        children["ClickBlocker"] = Roact.createElement("ImageButton", {
            Size = UDim2.fromScale(1, 1),
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ImageTransparency = 1,
            ZIndex = props.ZIndex or 1,
        })

        return Roact.createElement("Frame", {
            Size = props.Size,
            Position = props.Position,
            BackgroundColor3 = theme.Tokens.Colors.Overlay.Color,
            BackgroundTransparency = 0.5,
            ZIndex = props.ZIndex or 1,
        }, children)
    end)
end

return Overlay
