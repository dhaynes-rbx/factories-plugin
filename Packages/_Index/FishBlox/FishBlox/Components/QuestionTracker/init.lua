--!strict
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local BentoBlox = require(Packages.BentoBlox)
local Row = require(BentoBlox.Components.Row)
local Block = require(BentoBlox.Components.Block)
local QuestionIndicator = require(script.QuestionIndicator)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

type OffsetOrUDim = number | UDim
--- Module

--[[--
    @tfield table?={} Questions
    @tfield num?=1 CurrentQuestionIndex
    @table QuestionTrackerProps
]]

type QuestionTrackerProps = { Questions: table?, CurrentQuestionIndex: number? }

local QuestionTracker = Roact.Component:extend("QuestionTracker")

function QuestionTracker:init() end

--- @lfunction QuestionTracker
--- @tparam QuestionTrackerProps props
function QuestionTracker:render()
    return withThemeContext(function(theme)
        local questionIndicators = {}

        -- loop through questions and draw indicators
        if self.props.Questions then
            for index, question in ipairs(self.props.Questions) do
                local indicator = QuestionIndicator({
                    NumQuestion = index,
                    IsCurrent = index == self.props.CurrentQuestionIndex,
                    Completed = question.Completed,
                    Hovered = question.Hovered,
                    Selected = question.Selected,
                    OnMouseEnter = function(num)
                        self:handleHover(num, true)
                    end,
                    OnMouseLeave = function(num)
                        self:handleHover(num, false)
                    end,
                    OnActivated = function(num)
                        if self.props.OnActivated then
                            self.props.OnActivated(num)
                        end
                    end,
                })
                table.insert(questionIndicators, indicator)
            end
        end

        local questionRow = Row({
            Size = UDim2.new(1, 0, 0, 36),
            Gaps = theme.Tokens.Sizes.Registered.Medium.Value,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
        }, questionIndicators)

        local questionBlock = Block({ Size = UDim2.fromOffset(0, 36), AutomaticSize = Enum.AutomaticSize.X }, {
            -- Background line
            Block({
                Size = UDim2.new(1, -10, 0, 3),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 5, 0.5, 0),
                BackgroundColor = theme.Tokens.Colors.InteractiveLine.Color,
                BackgroundTransparency = 0.8,
            }, {}),
            questionRow,
        })

        return questionBlock
    end)
end

function QuestionTracker:handleHover(num, hovered)
    local questions = self.props.Questions
    questions[num].Hovered = hovered
end

function QuestionTracker:handleSelected() end

return function(props)
    return Roact.createElement(QuestionTracker, props)
end
