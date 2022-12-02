--!strict
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local Otter = require(Packages.Otter)
local Text = require(script.Parent.Text)
local BentoBlox = require(Packages.BentoBlox)
local Column = require(BentoBlox.Components.Column)
local Row = require(BentoBlox.Components.Row)
local Button = require(script.Parent.Button)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

type OffsetOrUDim = number | UDim
--- Module

--[[--
    @tfield string?="Title" Title
    @tfield string?="Content" Content
    @tfield OffsetOrUDim?="UDim.new(1,0)" Width
    @tfield boolean?=false Open
    @table FoldingFrameProps
]]

type FoldingFrameProps = {
    Title: string?,
    Content: string?,
    Width: OffsetOrUDim?,
    Open: boolean?,
}

local FoldingFramePropDefaults = {
    Content = "Content",
    Title = "Title",
    Width = UDim.new(1, 0),
    Open = false,
}

local FoldingFrame = Roact.Component:extend("FoldingFrame")

function FoldingFrame:init()
    self:setState({
        frameOpen = false,
        frameFullyClosed = true,
        isOpening = false,
        -- TODO: remove once we figure out how to dynamically size header and retain animation functionality
        temporaryHeaderHeight = 30,
    })
    self.bodyFrameRef = Roact.createRef()
    self.motor = Otter.createSingleMotor(0)
    self.motor:onStep(function(value)
        self.bodyFrameRef:getValue().Size = UDim2.new(1, 0, value, -self.state.temporaryHeaderHeight)

        if self.bodyFrameRef:getValue().AbsoluteSize.Y <= 20 then
            self:setState({
                frameOpen = false,
                frameFullyClosed = true,
            })
        else
            self:setState({
                frameOpen = true,
                frameFullyClosed = false,
            })
        end
    end)
end

--- @lfunction FoldingFrame A frame with a folding accordion behavior
--- @tparam FoldingFrameProps props
function FoldingFrame:render()
    self.props.Open = self.props.Open ~= nil and self.props.Open or FoldingFramePropDefaults.Open
    local hasWidth = self.props.Width ~= nil
    if hasWidth then
        local widthIsNumber = type(self.props.Width) == "number"
        if widthIsNumber then
            local widthAsUDim = UDim.new(0, self.props.Width)
            self.props.Width = widthAsUDim
        end
    end

    self.props.Title = self.props.Title ~= nil and self.props.Title or FoldingFramePropDefaults.Title
    self.props.Content = self.props.Content ~= nil and self.props.Content or FoldingFramePropDefaults.Content
    self.props.Width = self.props.Width ~= nil and self.props.Width or FoldingFramePropDefaults.Width

    -- handle toggle button image orientation
    local imageRectOffset: Vector2 = Vector2.new(0, 0)
    local imageRectSize: Vector2 = Vector2.new(0, 0)

    return withThemeContext(function(theme)
        if self.state.frameOpen then
            imageRectOffset = Vector2.new(0, self.state.temporaryHeaderHeight)
            imageRectSize = Vector2.new(self.state.temporaryHeaderHeight, -self.state.temporaryHeaderHeight)
        end

        -- header frame
        local headerRow: Row = Row({
            Size = UDim2.new(1, 0, 0, self.state.temporaryHeaderHeight),
            AutomaticSize = Enum.AutomaticSize.Y,
            PaddingTop = theme.Tokens.Sizes.Registered.Small.Value,
            PaddingBottom = theme.Tokens.Sizes.Registered.Small.Value,
            PaddingLeft = theme.Tokens.Sizes.Registered.Small.Value,
            Color = theme.Tokens.Colors.Surface.Color,
            BackgroundTransparency = 0,
            BorderSize = 0,
            ZIndex = 2,
        }, {
            -- TODO: this should be an IconButton when it's implemented (controlled padding)
            HeaderToggleButton = Button(
                {
                    Size = UDim2.new(0, 0, 0, 16),
                    BorderSize = 0,
                    ZIndex = 2,
                    OnActivated = function(rbx)
                        if self.state.frameOpen then
                            self:setState({ isOpening = false })
                            self.motor:setGoal(Otter.spring(0))
                        else
                            self:setState({ isOpening = true })
                            self.motor:setGoal(Otter.spring(1))
                        end
                    end,
                    LayoutOrder = 0,
                },
                {},
                Roact.createElement("ImageLabel", {
                    Size = UDim2.new(
                        0,
                        theme.Tokens.Sizes.Registered.Large.Value,
                        0,
                        theme.Tokens.Sizes.Registered.Large.Value
                    ),
                    Image = "rbxassetid://6812932553",
                    ImageRectOffset = imageRectOffset,
                    ImageRectSize = imageRectSize,
                    ScaleType = Enum.ScaleType.Fit,
                    BackgroundTransparency = 1,
                    ZIndex = 2,
                })
            ),
            HeaderTextRow = Row({
                Size = UDim2.new(1, -self.state.temporaryHeaderHeight, 1, 0),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                ZIndex = 2,
                LayoutOrder = 1,
            }, {
                HeaderText = Text({
                    Size = UDim2.new(0, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Text = self.props.Title,
                    Font = theme.Tokens.Typography.HeadlineSmall.Font,
                    FontSize = theme.Tokens.Typography.HeadlineSmall.FontSize,
                    Color = theme.Tokens.Colors.Text.Color,
                    ZIndex = 2,
                }),
            }),
        })

        -- body (expanding/contracting) frame
        local bodyColumn = Column({
            Position = UDim2.new(0, 0, 0, self.state.temporaryHeaderHeight),
            AutomaticSize = Enum.AutomaticSize.None,
            Color = self.props.BodyBackgroundColor or theme.Tokens.Colors.Surface.Color,
            BackgroundTransparency = 0,
            LayoutOrder = 2,
            Padding = theme.Tokens.Sizes.Registered.Medium.Value,
            BorderSize = 0,
            Ref = self.bodyFrameRef,
        }, {
            BodyText = Text({
                Text = self.props.Content,
                Font = theme.Tokens.Typography.BodySmall.Font,
                FontSize = theme.Tokens.Typography.BodySmall.FontSize,
                LineHeight = theme.Tokens.Typography.BodySmall.LineHeight,
                Color = theme.Tokens.Colors.Text.Color,
                Visible = not self.state.frameFullyClosed,
            }),
        })

        local containerFrame = Roact.createElement("Frame", {
            Size = UDim2.new(self.props.Width, UDim.new(0, 220)),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
        }, {
            HeaderRow = headerRow,
            BodyColumn = bodyColumn,
        })

        return containerFrame
    end)
end

function FoldingFrame:didMount()
    if self.props.Open then
        self:setState({ isOpening = true })
        self.motor:setGoal(Otter.spring(1))
    end
end

return function(props)
    return Roact.createElement(FoldingFrame, props)
end
