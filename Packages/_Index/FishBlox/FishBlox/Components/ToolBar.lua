--!strict
local Packages = script.Parent.Parent.Parent
local Text = require(script.Parent.Text)
local BentoBlox = require(Packages.BentoBlox)
local Block = require(BentoBlox.Components.Block)
local Column = require(BentoBlox.Components.Column)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

--- Module

type OffsetOrUDim = number | UDim
--[[--
    @tfield OffsetOrUDim?="UDim.new(0, 62)," Height
    @tfield table?={} Left
    @tfield string?="" Content
    @tfield table?={} Right
    @table ToolBarProps
]]

type ToolBarProps = { Height: OffsetOrUDim?, Left: table?, Content: string?, Right: table? }

local ToolBarPropDefaults = {
    Height = UDim.new(0, 66),
    Content = "",
}

--- @lfunction ToolBar A bar that contains slots for task actions like navigation
--- @tparam ToolBarProps props
local function ToolBar(props: ToolBarProps, children)
    return withThemeContext(function(theme)
        props.Height = props.Height ~= nil and props.Height or ToolBarPropDefaults.Height
        props.Content = props.Content ~= nil and props.Content or ToolBarPropDefaults.Content

        local hasHeight = props.Height ~= nil
        if hasHeight then
            local heightIsNumber = type(props.Height) == "number"
            if heightIsNumber then
                local heightAsUDim = UDim.new(0, props.Height)
                props.Height = heightAsUDim
            end
        end

        local leftBlock = Block({
            Size = UDim2.fromScale(0.25, 1),
        }, {
            LeftColumn = Column({
                Size = UDim2.fromScale(1, 1),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                PaddingTop = theme.Tokens.Sizes.Registered.Small.Value,
                PaddingLeft = theme.Tokens.Sizes.Registered.Medium.Value,
                PaddingBottom = theme.Tokens.Sizes.Registered.Small.Value,
            }, {
                Button = props.Left,
            }),
        })

        local contentBlock = Block({ Size = UDim2.fromScale(0, 0), AutomaticSize = Enum.AutomaticSize.XY }, {
            ContentColumn = Column({
                AutomaticSize = Enum.AutomaticSize.XY,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }, {
                Text = typeof(props.Content) == "string" and Text({
                    Text = props.Content,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Color = theme.Tokens.Typography.HeadlineLarge.Color,
                    Font = theme.Tokens.Typography.HeadlineLarge.Font,
                    FontSize = theme.Tokens.Typography.HeadlineLarge.FontSize,
                }),
                Content = typeof(props.Content) ~= "string" and props.Content,
            }),
        })

        local rightBlock = Block({
            Size = UDim2.fromScale(0.25, 1),
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.fromScale(1, 0),
        }, {
            RightColumn = Column({
                Size = UDim2.fromScale(1, 1),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                PaddingTop = theme.Tokens.Sizes.Registered.Small.Value,
                PaddingRight = theme.Tokens.Sizes.Registered.Medium.Value,
                PaddingBottom = theme.Tokens.Sizes.Registered.Small.Value,
            }, {
                Button = props.Right,
            }),
        })

        local toolBarBlock = Block({
            Size = UDim2.new(UDim.new(1, 0), props.Height),
            Position = UDim2.fromOffset(0, 42),
            BackgroundTransparency = 0,
            BackgroundColor = theme.Tokens.Colors.Surface.Color,
            LayoutOrder = 1,
        }, {
            Left = leftBlock,
            Content = Block({
                Size = UDim2.fromScale(0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                AutomaticSize = Enum.AutomaticSize.Y,
            }, {
                Column = Column({ HorizontalAlignment = Enum.HorizontalAlignment.Center }, {
                    Block = contentBlock,
                }),
            }),
            Right = rightBlock,
        })

        return toolBarBlock
    end)
end

return ToolBar
