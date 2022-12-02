--!strict
local Packages = script.Parent.Parent.Parent
local TutorialPopover = require(script.Parent.TutorialPopover)

local TUTORIAL_Z_INDEX = 4000
local HORIZONTAL_ARROW_WIDTH = 21
local HORIZONTAL_ARROW_HEIGHT = 35
local VERTICAL_ARROW_WIDTH = 35
local VERTICAL_ARROW_HEIGHT = 21

type OffsetOrUDim = number | UDim
--- Module

--[[--
    @tfield string?="Content" Content
    @tfield number? ContentGaps
    @tfield boolean?=false HideArrow
    @tfield boolean?=false ShowAdvance
    @tfield string?="top" ArrowPosition
    @tfield number?=0 ArrowOffset
    @tfield number?=0 Steps
    @tfield number?=0 Step
    @tfield OffsetOrUDim?="UDim.new(1,0)" Width
    @tfield table? Objectives
    @tfield (self: Button) -> nil? OnOk Called when the OK button is clicked
    @table TutorialTooltipProps
]]

type TutorialTooltipProps = {
    Content: string?,
    ContentRichText: boolean?,
    HideArrow: boolean?,
    ShowAdvance: boolean?,
    ArrowPosition: string?,
    ArrowOffset: number?,
    Steps: number?,
    Step: number?,
    Width: OffsetOrUDim?,
    Position: UDim2?,
    ShowSteps: boolean?,
    Objectives: table?,
    ObjectivesTitle: string?,
    OnOk: ((nil) -> nil)?,
}

local TutorialTooltipPropDefaults = {
    Content = "TutorialTooltip Content",
    HideArrow = false,
    ShowAdvance = false,
    ArrowPosition = "top",
    ArrowOffset = 0,
    Steps = 0,
    Step = 0,
    Width = UDim.new(0, 300),
    ShowSteps = false,
}

local translatePointerString = function(str)
    local newStr = {
        top = "Top",
        right = "Right",
        bottom = "Bottom",
        left = "Left",
    }
    return newStr[str]
end

local translateProps = function(props)
    local newProps = {}
    for key, value in pairs(props) do
        if key == "HideArrow" then
            newProps["HidePointer"] = value
        elseif key == "ArrowPosition" then
            newProps["PointerSide"] = translatePointerString(value)
        elseif key == "ArrowOffset" then
            newProps["PointerOffset"] = UDim.new(0.5, value)
        else
            newProps[key] = value
        end
    end

    newProps["PointerSize"] = "Medium"

    return newProps
end

--- @lfunction TutorialTooltip A tooltip used during tutorials that can be advanced
--- @tparam TutorialTooltipProps props
local function TutorialTooltip(props: TutorialTooltipProps, children)
    props.Width = props.Width ~= nil and props.Width or TutorialTooltipPropDefaults.Width

    -- add arrow to width if arrow position is "left" or "right"
    -- TODO: Add logic to handle if width prop is already a number (now assumes its a UDim2)
    if not props.HideArrow and (props.ArrowPosition == "left" or props.ArrowPosition == "right") then
        local widthOffset = props.Width.Offset
        local widthWithArrow = widthOffset + HORIZONTAL_ARROW_WIDTH
        props.Width = UDim.new(0, widthWithArrow)
    end

    props.ShowAdvance = props.ShowAdvance ~= nil and props.ShowAdvance or TutorialTooltipPropDefaults.ShowAdvance
    props.ArrowPosition = props.ArrowPosition ~= nil and props.ArrowPosition
        or TutorialTooltipPropDefaults.ArrowPosition
    props.ArrowOffset = props.ArrowOffset ~= nil and props.ArrowOffset or TutorialTooltipPropDefaults.ArrowOffset
    props.Steps = props.Steps ~= nil and props.Steps or TutorialTooltipPropDefaults.Steps

    if props.ShowSteps == nil then
        props.ShowSteps = TutorialTooltipPropDefaults.ShowSteps
    end

    -- handle Objectives
    if props.Objectives ~= nil then
        props.HideArrow = true
        props.ShowSteps = true
        props.ShowAdvance = false
        if props.ObjectivesTitle == nil then
            props.ObjectivesTitle = "Tutorial Objective"
        end
    end

    -- Translate props to TutorialPopover format
    local newProps = translateProps(props)

    return TutorialPopover(newProps, children)
end

return TutorialTooltip
