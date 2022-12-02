--!strict
local Packages = script.Parent.Parent.Parent
local BentoBlox = require(Packages.BentoBlox)
local Row = require(BentoBlox.Components.Row)
local Block = require(BentoBlox.Components.Block)
local SectionIndicator = require(script.SectionIndicator)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

type OffsetOrUDim = number | UDim
--- Module

--[[--
    @tfield number?=0 SectionCount
    @tfield num?=1 CurrentSectionIndex
    @tfield boolean?=false IsTutorial
    @table SectionTrackerProps
]]

type SectionTrackerProps = {
    SectionCount: number?,
    CurrentSectionIndex: number?,
    IsTutorial: boolean?,
    ZIndex: number?,
}

--- @lfunction SectionTracker
--- @tparam SectionTrackerProps props
return function(props)
    return withThemeContext(function(theme)
        local sectionIndicators = {}

        -- loop through sections and draw indicators
        if props.SectionCount then
            for index = 1, props.SectionCount do
                local indicator = SectionIndicator({
                    NumSection = index,
                    IsCurrent = index == props.CurrentSectionIndex,
                    IsTutorial = props.IsTutorial,
                    ZIndex = props.ZIndex,
                })
                table.insert(sectionIndicators, indicator)
            end
        end

        local sectionRow = Row({
            AutomaticSize = Enum.AutomaticSize.XY,
            Size = UDim2.new(1, 0, 0, 36),
            Gaps = theme.Tokens.Sizes.Registered.Medium.Value,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            ZIndex = props.ZIndex,
        }, sectionIndicators)

        local bottomPad = 16

        local sectionBlock = Block({
            Size = UDim2.fromOffset(0, 36),
            AutomaticSize = Enum.AutomaticSize.X,
            PaddingBottom = bottomPad,
            ZIndex = props.ZIndex,
        }, {
            -- Background line
            Block({
                Size = UDim2.new(1, -25, 0, 3),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 15, 0.5, bottomPad / 2),
                BackgroundColor = theme.Tokens.Colors.Line.Color,
                ZIndex = props.ZIndex,
            }, {}),
            sectionRow,
        })

        return sectionBlock
    end)
end
