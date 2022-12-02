--!strict
local Packages = script.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local Manifest = require(script.Parent.Parent.Parent.Assets.Manifest)
local BentoBlox = require(Packages.BentoBlox)
local Block = require(BentoBlox.Components.Block)
local Column = require(BentoBlox.Components.Column)
local Row = require(BentoBlox.Components.Row)
local Text = require(script.Parent.Parent.Text)
local withThemeContext = require(script.Parent.Parent.Parent.ThemeProvider.WithThemeContext)

local BASE_SIZE_CURRENT = 38
local BASE_SIZE = 20
type OffsetOrUDim = number | UDim
--- Module

--[[--
    @tfield number? NumSection
    @tfield string?="" Value
    @tfield boolean?=false IsCurrent
    @tfield boolean?=false IsTutorial
    @table SectionIndicatorProps
]]

type SectionIndicatorProps = {
    NumSection: number?,
    IsCurrent: boolean?,
    IsTutorial: boolean?,
    ZIndex: number?,
}

local getImage = function(props)
    if props.IsCurrent then
        if props.IsTutorial then
            return Manifest["section-tracker-item-tutorial-current"]
        end
        return Manifest["section-tracker-item-current"]
    end
    return Manifest["section-tracker-item"]
end

--- @lfunction SectionIndicator
--- @tparam SectionIndicatorProps props
function SectionIndicator(props)
    return Roact.createElement("ImageLabel", {
        Size = props.IsCurrent and UDim2.fromOffset(BASE_SIZE_CURRENT, BASE_SIZE_CURRENT) or UDim2.fromOffset(
            BASE_SIZE,
            BASE_SIZE
        ),
        Image = getImage(props),
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        ZIndex = props.ZIndex,
    })
end

return SectionIndicator
