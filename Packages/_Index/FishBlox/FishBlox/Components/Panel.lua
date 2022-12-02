--!strict
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local Dash = require(Packages.Dash)
local Utilities = require(Packages.Utilities)
local Text = require(script.Parent.Text)
local Button = require(script.Parent.Button)
local BentoBlox = require(Packages.BentoBlox)
local Block = require(BentoBlox.Components.Block)
local Column = require(BentoBlox.Components.Column)
local Row = require(BentoBlox.Components.Row)
local MultiparagraphText = require(script.Parent.MultiparagraphText)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

--- Module

type OffsetOrUDim = number | UDim
--[[--
    @tfield string?="" Content
    @tfield string?="" Title
    @tfield boolean?=false ShowClose
    @tfield number? Corners
    @tfield number? Debounce
    @tfield UDim2? Size
    @tfield boolean? HeightSizedToContent
    @tfield number? HeightOffset
    @tfield Enum? AutomaticSize
    @tfield (self:Panel)->nil? OnClosePanel Called when the close panel button is clicked
    @table PanelProps
]]

type PanelProps = {
    Content: string?,
    Debounce: number?,
    Title: string?,
    ShowClose: boolean?,
    Corners: number,
    Size: UDim2?,
    HeightSizedToContent: boolean?,
    HeightOffset: number?,
    AutomaticSize: Enum?,
}

local PanelPropDefaults = {
    Content = "",
    Title = "",
    ShowClose = false,
    Size = UDim2.fromOffset(400, 0),
    HeightSizedToContent = true,
    AutomaticSize = Enum.AutomaticSize.Y,
}

local hasTitleDivider = function(props, children)
    if props.Title and props.Title ~= nil then
        return true
    end

    if children and children["Title"] and children["Title"] ~= nil then
        return true
    end

    return false
end

local extractPaddingOffset = function(padding)
    if type(padding) == "table" then
        for _, value in pairs(padding) do
            if value.Offset then
                return value.Offset
            end
        end
    end
end

--- @lfunction Panel A basic panel
--- @tparam PanelProps props
local function Panel(props: PanelProps, children)
    return withThemeContext(function(theme)
        -- set defaults
        if props.ShowClose == nil then
            props.ShowClose = PanelPropDefaults.ShowClose
        end
        props.Size = props.Size ~= nil and props.Size or PanelPropDefaults.Size
        if props.HeightSizedToContent == nil then
            props.HeightSizedToContent = PanelPropDefaults.HeightSizedToContent
        end
        props.AutomaticSize = props.AutomaticSize ~= nil and props.AutomaticSize or PanelPropDefaults.AutomaticSize

        children = children or {}

        local titleChildren = props.Title ~= nil
                and {
                    PanelTitleText = Text({
                        Text = props.Title,
                        RichText = true,
                        Color = theme.Tokens.Colors.Text.Color,
                        Font = theme.Tokens.Typography.HeadlineMedium.Font,
                        FontSize = theme.Tokens.Typography.HeadlineMedium.FontSize,
                        LayoutOrder = 0,
                        ZIndex = props.ZIndex or 1,
                    }),
                }
            or {}
        local contentChildren = props.Content ~= nil
                and {
                    PanelContentText = MultiparagraphText({
                        Component = Text({
                            Text = props.Content,
                            RichText = true,
                            Color = theme.Tokens.Colors.Text.Color,
                            Font = theme.Tokens.Typography.BodyMedium.Font,
                            FontSize = theme.Tokens.Typography.BodyMedium.FontSize,
                            LineHeight = theme.Tokens.Typography.BodyMedium.LineHeight,
                            LayoutOrder = 0,
                            ZIndex = props.ZIndex or 1,
                        }),
                        Gaps = theme.Tokens.Sizes.Registered.XMedium.Value,
                    }),
                }
            or {}

        -- handle children
        -- if children table is an array, each element will be added as contentChildren
        if children[1] ~= nil then
            for index, value in ipairs(children) do
                value["props"]["LayoutOrder"] = index
                contentChildren["AdditionalChild" .. index] = value
            end
        else
            -- if children table has key "Title", override Title prop
            if children["Title"] and children["Title"] ~= nil then
                children["Title"]["props"]["LayoutOrder"] = 1
                titleChildren["PanelTitleText"] = nil
                titleChildren["AdditionalChild"] = children["Title"]
            end
            -- if children table has key "Content", override Content prop
            if children["Content"] and children["Content"] ~= nil then
                children["Content"]["props"]["LayoutOrder"] = 1
                contentChildren["PanelContentText"] = nil
                contentChildren["AdditionalChild"] = children["Content"]
            end
            -- if children table has different string keys, add them to contentChildren
            for key, value in pairs(children) do
                if type(key) == "string" then
                    if key ~= "Title" and key ~= "Content" then
                        value["props"]["LayoutOrder"] = 2
                        contentChildren[key] = value
                    end
                end
            end
        end

        local panelChildren = {
            PanelBlock = Block({
                Size = UDim2.new(1, 0, props.AutomaticSize ~= Enum.AutomaticSize.None and 0 or 1, 0),
                AutomaticSize = props.AutomaticSize,
            }, {
                PanelColumn = Column({
                    Size = UDim2.fromScale(1, 0),
                    AutomaticSize = props.AutomaticSize,
                }, {
                    -- Title default "slot"
                    PanelTitleColumn = Utilities.getTableSize(titleChildren) ~= 0
                            and Column({
                                AutomaticSize = Enum.AutomaticSize.XY,
                                PaddingVertical = children["Title"] == nil
                                        and theme.Tokens.Sizes.Registered.XMedium.Value
                                    or 0,
                                PaddingHorizontal = children["Title"] == nil
                                        and theme.Tokens.Sizes.Registered.Large.Value
                                    or 0,
                                LayoutOrder = 0,
                                ZIndex = props.ZIndex or 1,
                            }, titleChildren)
                        or nil,
                    -- Title divider
                    PanelTitleDividerRow = hasTitleDivider(props, children) and Row({
                        Size = UDim2.new(1, 0, 0, 1),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        LayoutOrder = 1,
                        ZIndex = props.ZIndex or 1,
                    }, {
                        PanelTitleDivider = Roact.createElement("Frame", {
                            Size = UDim2.new(1, 0 - 2, 0, 1),
                            BackgroundColor3 = theme.Tokens.Colors.LineSubtle.Color,
                            ZIndex = props.ZIndex or 1,
                            BorderSizePixel = 0,
                        }),
                    }),
                    -- Content default "slot"
                    PanelContentColumn = Utilities.getTableSize(contentChildren) ~= 0
                        and Column({
                            AutomaticSize = props.HeightSizedToContent and Enum.AutomaticSize.Y
                                or Enum.AutomaticSize.None,
                            Size = UDim2.new(1, 0, props.HeightSizedToContent and 0 or 1, props.HeightOffset or 0),
                            Padding = children["Content"] == nil and theme.Tokens.Sizes.Registered.Large.Value or 0,
                            Gaps = theme.Tokens.Sizes.Registered.XMedium.Value,
                            LayoutOrder = 2,
                            ZIndex = props.ZIndex or 1,
                        }, contentChildren),
                }),
                CloseButtonBlock = props.ShowClose and Block({
                    Size = UDim2.fromOffset(
                        theme.Tokens.Sizes.Registered.XLarge.Value,
                        theme.Tokens.Sizes.Registered.XLarge.Value
                    ),
                    Position = UDim2.new(1, -theme.Tokens.Sizes.Registered.XLarge.Value, 0, 0),
                    ZIndex = props.ZIndex or 1,
                }, {
                    CloseButton = Button({
                        Debounce = props.Debounce,
                        Size = UDim2.fromScale(1, 1),
                        Padding = theme.Tokens.Sizes.Registered.Medium.Value,
                        Appearance = "Borderless",
                        OnActivated = props.OnClosePanel,
                        ZIndex = props.ZIndex or 1,
                    }, {
                        Image = Roact.createElement("ImageLabel", {
                            Size = UDim2.fromOffset(
                                theme.Tokens.Sizes.Registered.Medium.Value,
                                theme.Tokens.Sizes.Registered.Medium.Value
                            ),
                            AutomaticSize = Enum.AutomaticSize.None,
                            BackgroundTransparency = 1,
                            Image = "rbxassetid://6990919691",
                            ImageColor3 = theme.Tokens.Colors.InteractiveLine.Color,
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            ZIndex = props.ZIndex or 1,
                        }),
                    }),
                }) or nil,
            }),
        }
        local panelChildrenJoin = Dash.join({
            UICorner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(0, props.Corners or theme.Tokens.Sizes.Registered.SmallPlus.Value),
            }),
        }, panelChildren)
        return Roact.createElement("Frame", {
            Position = props.Position,
            AnchorPoint = props.AnchorPoint,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = props.Size,
            BackgroundColor3 = theme.Tokens.Colors.Surface.Color,
            ZIndex = props.ZIndex or 1,
            [Roact.Ref] = props[Roact.Ref],
        }, panelChildrenJoin)
    end)
end

return Panel
