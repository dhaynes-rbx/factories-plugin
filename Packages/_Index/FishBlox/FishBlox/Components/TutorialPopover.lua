--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Manifest = require(script.Parent.Parent.Assets.Manifest)
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local BentoBlox = require(Packages.BentoBlox)
local Column = require(BentoBlox.Components.Column)
local Row = require(BentoBlox.Components.Row)
local Block = require(BentoBlox.Components.Block)
local Button = require(script.Parent.Button)
local Text = require(script.Parent.Text)
local MultiparagraphText = require(script.Parent.MultiparagraphText)
local PointerBlock = require(script.Parent.PointerBlock)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

local TUTORIAL_Z_INDEX = 4000
type OffsetOrUDim = number | UDim
--- Module

--[[--
    @tfield UDim2? Position
    @tfield Vector2? AnchorPoint
    @tfield string?="Content" Content
    @tfield number?=0 Debounce
    @tfield boolean?=false HidePointer
    @tfield string?="Right" PointerSide
    @tfield number? PointerOffset
    @tfield string?="Small" PointerSize
    @tfield boolean?=false ShowAdvance
    @tfield number?=0 Steps
    @tfield number?=0 Step
    @tfield OffsetOrUDim?="UDim.new(1,0)" Width
    @tfield table? Objectives
    @tfield any? ref
    @tfield (self: Button) -> nil? OnOk Called when the OK button is clicked
    @table Props
]]

export type Props = {
    Position: UDim2?,
    AnchorPoint: Vector2?,
    Content: string?,
    ContentRichText: boolean?,
    Debounce: number?,
    HidePointer: boolean?,
    PointerSide: string?,
    PointerOffset: number?,
    PointerSize: string?,
    ShowAdvance: boolean?,
    Steps: number?,
    Step: number?,
    Width: OffsetOrUDim?,
    Position: UDim2?,
    ShowSteps: boolean?,
    Objectives: table?,
    ObjectivesTitle: string?,
    ref: any?,
    OnOk: ((nil) -> nil)?,
}

local PropDefaults = {
    Position = UDim2.new(0, 0, 0, 0),
    AnchorPoint = Vector2.new(0, 0),
    Content = "TutorialPopover Content",
    HidePointer = false,
    PointerSide = "Right",
    PointerOffset = 0,
    PointerSize = "Small",
    ShowAdvance = false,
    Steps = 0,
    Step = 0,
    Width = UDim.new(0, 300),
    ShowSteps = false,
}

local renderContainer = function(props, theme, pieces)
    local container = nil
    local zIndex = props.ZIndex or TUTORIAL_Z_INDEX
    container = Column({
        Width = props.Width,
        Position = props.HidePointer and props.Position or UDim2.new(0, 0, 0, 0),
        AnchorPoint = props.HidePointer and props.AnchorPoint or Vector2.new(0, 0),
        Ref = props.HidePointer and props.ref or nil,
        ZIndex = zIndex,
    }, {
        TooltipBlock = Block({
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 0,
            BackgroundColor = theme.Tokens.Colors.InstructionSurface.Color,
            LayoutOrder = 1,
            Corner = UDim.new(0, theme.Tokens.Sizes.Registered.SmallPlus.Value),
            HasStroke = true,
            StrokeColor = theme.Tokens.Colors.InstructionOutline.Color,
            ZIndex = zIndex,
        }, {
            TooltipBlockColumn = Column({ ZIndex = zIndex, AutomaticSize = Enum.AutomaticSize.XY }, {
                HeaderRowBlock = props.ShowSteps and Block({
                    Size = UDim2.fromScale(0, 0),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 0,
                    BackgroundColor = theme.Tokens.Colors.InstructionSurfaceSubtle.Color,
                    LayoutOrder = 0,
                    Corner = UDim.new(0, theme.Tokens.Sizes.Registered.SmallPlus.Value),
                    ZIndex = zIndex,
                }, {
                    HeaderRow = pieces.headerRow,
                }) or nil,
                BodyColumn = pieces.bodyColumn,
            }),
        }),
    })

    return container
end

local renderObjectives = function(props, theme)
    local objectiveRows = {}
    local objectives = props.Objectives
    local zIndex = props.ZIndex or TUTORIAL_Z_INDEX
    local bulletBlock = Block({
        Size = UDim2.fromOffset(theme.Tokens.Sizes.Registered.Large.Value, theme.Tokens.Sizes.Registered.Medium.Value),
        ZIndex = zIndex,
    }, {
        Bullet = Roact.createElement("Frame", {
            Size = UDim2.fromOffset(
                theme.Tokens.Sizes.Registered.Medium.Value,
                theme.Tokens.Sizes.Registered.Medium.Value
            ),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            ZIndex = zIndex,
        }, {
            UICorner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(0.5, 0),
            }),
        }),
    })
    local bulletComplete = Roact.createElement("Frame", {
        Size = UDim2.fromOffset(theme.Tokens.Sizes.Registered.Large.Value, theme.Tokens.Sizes.Registered.Large.Value),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = zIndex,
    }, {
        UICorner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0.5, 0),
        }),
        Checkmark = Roact.createElement("ImageLabel", {
            Image = Manifest["checkmark"],
            ImageColor3 = theme.Tokens.Colors.InstructionSurface.Color,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(
                0,
                theme.Tokens.Sizes.Registered.Medium.Value,
                0,
                theme.Tokens.Sizes.Registered.Medium.Value
            ),
            BackgroundTransparency = 1,
            ZIndex = zIndex,
        }, nil),
    })

    local completeCount = 0
    for _, objective in ipairs(objectives) do
        local name = Text({
            Size = UDim2.new(
                1,
                -theme.Tokens.Sizes.Registered.Medium.Value - theme.Tokens.Sizes.Registered.Large.Value,
                0,
                0
            ),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = objective.name,
            RichText = true,
            Color = theme.Tokens.Colors.InstructionText.Color,
            Font = theme.Tokens.Typography.BodyMedium.Font,
            FontSize = theme.Tokens.Typography.BodyMedium.FontSize,
            LineHeight = theme.Tokens.Typography.BodyMedium.LineHeight,
            LayoutOrder = 1,
            ZIndex = zIndex,
        })
        local row = Row({
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Gaps = theme.Tokens.Sizes.Registered.Medium.Value,
            ZIndex = zIndex,
        }, {
            Bullet = objective.complete == true and bulletComplete or bulletBlock,
            Name = name,
        })
        table.insert(objectiveRows, row)

        if objective.complete == true then
            completeCount += 1
        end
    end

    if completeCount == #objectives then
        -- render the "Completed!" bar
        local completedRow = Row({
            Size = UDim2.new(1, 0, 0, theme.Tokens.Sizes.Registered.Large.Value),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            ZIndex = zIndex,
        }, {
            CompletedText = Text({
                Text = "Completed!",
                TextXAlignment = Enum.TextXAlignment.Center,
                Color = theme.Tokens.Typography.HeadlineSmall.Color,
                Font = theme.Tokens.Typography.HeadlineSmall.Font,
                FontSize = theme.Tokens.Typography.HeadlineSmall.FontSize,
                LayoutOrder = 1,
                ZIndex = zIndex,
            }),
        })

        table.insert(objectiveRows, completedRow)
    end

    return Column({ Gaps = theme.Tokens.Sizes.Registered.Medium.Value, ZIndex = zIndex }, objectiveRows)
end

--- @lfunction TutorialPopover A tooltip used during tutorials that can be advanced
--- @tparam Props props
local function TutorialPopover(props: Props)
    -- set defaults
    props.Position = props.Position ~= nil and props.Position or PropDefaults.Position
    props.AnchorPoint = props.AnchorPoint ~= nil and props.AnchorPoint or PropDefaults.AnchorPoint
    props.Width = props.Width ~= nil and props.Width or PropDefaults.Width
    props.ShowAdvance = props.ShowAdvance ~= nil and props.ShowAdvance or PropDefaults.ShowAdvance
    props.Steps = props.Steps ~= nil and props.Steps or PropDefaults.Steps
    props.PointerSide = props.PointerSide ~= nil and props.PointerSide or PropDefaults.PointerSide
    props.PointerSize = props.PointerSize ~= nil and props.PointerSize or PropDefaults.PointerSize
    props.PointerOffset = props.PointerOffset ~= nil and props.PointerOffset or PropDefaults.PointerOffset
    if props.ShowSteps == nil then
        props.ShowSteps = PropDefaults.ShowSteps
    end

    -- handle Objectives
    if props.Objectives ~= nil then
        props.HidePointer = true
        props.ShowSteps = true
        props.ShowAdvance = false
        if props.ObjectivesTitle == nil then
            props.ObjectivesTitle = "Tutorial Objective"
        end
    end

    return withThemeContext(function(theme)
        -- objectives
        local objectivesColumn = nil
        if props.Objectives ~= nil then
            objectivesColumn = renderObjectives(props, theme)
        end

        local zIndex = props.ZIndex or TUTORIAL_Z_INDEX

        -- advance button
        local advanceButton = Button({
            Debounce = props.Debounce,
            Label = "OK",
            OnActivated = props.OnOk,
            LayoutOrder = 1,
            Corner = UDim.new(0, theme.Tokens.Sizes.Registered.Medium.Value),
            HasStroke = true,
            StrokeColor = Color3.fromRGB(255, 255, 255),
            ZIndex = zIndex,
        }, nil, nil)

        local tooltipPieces = {
            -- header row
            headerRow = Row({
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.fromScale(1, 0),
                PaddingHorizontal = theme.Tokens.Sizes.Registered.XMedium.Value,
                PaddingVertical = theme.Tokens.Sizes.Registered.Small.Value,
                LayoutOrder = 0,
                ZIndex = zIndex,
            }, {
                StepText = Text({
                    Text = props.Objectives == nil and "Step " .. tostring(props.Step) .. " of " .. tostring(
                        props.Steps
                    ) or props.ObjectivesTitle,
                    Color = theme.Tokens.Colors.InstructionTextSubtle.Color,
                    Font = theme.Tokens.Typography.Subheader.Font,
                    FontSize = theme.Tokens.Typography.Subheader.FontSize,
                    Visible = props.Steps > 0 or props.Objectives ~= nil,
                    ZIndex = zIndex,
                }),
            }),

            -- bodyColumn
            bodyColumn = Column({
                LayoutOrder = 1,
                Padding = theme.Tokens.Sizes.Registered.XMedium.Value,
                Gaps = theme.Tokens.Sizes.Registered.Medium.Value,
                AutomaticSize = Enum.AutomaticSize.XY,
                ZIndex = zIndex,
            }, {
                Content = MultiparagraphText({
                    Component = Text({
                        Text = props.Content,
                        RichText = props.ContentRichText or false,
                        Color = theme.Tokens.Colors.InstructionText.Color,
                        Font = theme.Tokens.Typography.BodyMedium.Font,
                        FontSize = theme.Tokens.Typography.BodyMedium.FontSize,
                        LineHeight = theme.Tokens.Typography.BodyMedium.LineHeight,
                        LayoutOrder = 0,
                        Width = UDim.new(1, 0),
                        ZIndex = zIndex,
                    }),
                    Gaps = theme.Tokens.Sizes.Registered.XMedium.Value,
                }),
                ObjectivesColumn = objectivesColumn,
                AdvanceButtonRow = props.ShowAdvance and Row({}, {
                    AdvanceButton = advanceButton,
                }) or nil,
            }),
        }

        local tooltipContainer = renderContainer(props, theme, tooltipPieces)

        -- Compose into PointerBlock if it needs the arrow
        if props.HidePointer ~= nil and props.HidePointer then
            return tooltipContainer
        else
            local pointerBlock = PointerBlock({
                Position = props.Position,
                AnchorPoint = props.AnchorPoint,
                ref = props.ref,
                PointerColor = theme.Tokens.Colors.InstructionOutline.Color,
                PointerSide = props.PointerSide,
                PointerSize = props.PointerSize,
                PointerOffset = props.PointerOffset,
                ZIndex = zIndex,
                Width = props.Width,
            }, tooltipContainer)

            return pointerBlock
        end
    end)
end

return TutorialPopover
