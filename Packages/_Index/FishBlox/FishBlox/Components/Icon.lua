--!strict
local Manifest = require(script.Parent.Parent.Assets.Manifest)
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

--- Module

--[[--
    @tfield string? Size
    @tfield string? Image
    @tfield Color3? Color
    @table IconProps
]]
type IconProps = {
    Size: string?,
    Image: string?,
    Color: Color3?,
}

local IconPropDefaults = {
    Size = "Medium",
    Image = "Checkmark",
}

local Name = {
    Checkmark = "checkmark",
    ChevronDown = "chevron-down",
    ChevronUp = "chevron-up",
    ChevronLeft = "chevron-left",
    ChevronRight = "chevron-right",
    Cross = "cross",
    Lock = "lock",
    Pause = "pause",
    Play = "play",
}

local Size = {
    Name = {
        XSmall = "xsmall",
        Small = "small",
        Medium = "medium",
        Large = "large",
        XLarge = "xlarge",
    },
    Dimensions = {
        XSmall = 16,
        Small = 21,
        Medium = 24,
        Large = 32,
        XLarge = 64,
    },
}

--- @lfunction Icon An icon image
--- @tparam IconProps props
local function Icon(props)
    return withThemeContext(function(theme)
        -- set defaults
        props.Size = props.Size ~= nil and Size.Name[props.Size] and props.Size or IconPropDefaults.Size
        props.Image = props.Image ~= nil and Name[props.Image] and props.Image or IconPropDefaults.Image

        return Roact.createElement("ImageLabel", {
            Size = UDim2.fromOffset(Size.Dimensions[props.Size], Size.Dimensions[props.Size]),
            BackgroundTransparency = 1,
            Image = Manifest[Name[props.Image] .. "-" .. Size.Name[props.Size]],
            ImageColor3 = props.Color,
        })
    end)
end

return Icon
