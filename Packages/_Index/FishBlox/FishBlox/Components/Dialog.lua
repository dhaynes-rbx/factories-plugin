--!strict
local Manifest = require(script.Parent.Parent.Assets.Manifest)
local Packages = script.Parent.Parent.Parent
local React = require(Packages.React)
local Dash = require(Packages.Dash)
local BentoBlox = require(Packages.BentoBlox)
local Block = require(BentoBlox.Components.Block)
local Column = require(BentoBlox.Components.Column)
local Row = require(BentoBlox.Components.Row)
local Overlay = require(script.Parent.Overlay)
local Button = require(script.Parent.Button)
local Text = require(script.Parent.Text)
local MultiparagraphText = require(script.Parent.MultiparagraphText)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)
local sizedByShorthand = require(BentoBlox.Utilities.SizedByShorthand)

type OffsetOrUDim = number | UDim
--- Module

--[[--
    @tfield table? Primary
    @tfield table? Secondary
    @tfield string? Content
    @tfield number? ContentGaps
    @tfield number? Debounce
    @tfield UDim2? Size
    @tfield string?="Title" Title
    @tfield OffsetOrUDim?="UDim.new(0,528)" Width
    @tfield boolean?=false HasCloseButton
    @tfield boolean?=false HasBanner
    @tfield string?="" BannerType
    @tfield string?="" DefaultButtonLabel
    @tfield (nil) -> nil? DefaultOnActivated
    @table DialogProps
]]

export type DialogProps = {
    Primary: table?,
    Secondary: table?,
    Content: string?,
    ContentRichText: boolean?,
    Debounce: number?,
    Size: UDim2?,
    Title: string?,
    Width: OffsetOrUDim?,
    HasCloseButton: boolean?,
    DefaultButtonLabel: string?,
    DefaultOnActivated: ((nil) -> nil)?,
    DialogPreTitleRowSize: UDim2?,
}

local BANNER_WIDTH = 528
local BANNER_HEIGHT = 104

local DialogPropDefaults = {
    Title = "Title",
    Width = UDim.new(0, BANNER_WIDTH),
    HasCloseButton = false,
    DefaultButtonLabel = "Ok",
}

local getBannerImage = function(props)
    if props.BannerType == "attention" then
        return Manifest["header-attention"]
    elseif props.BannerType == "instruction" then
        return Manifest["header-instruction"]
    elseif props.BannerType == "success" then
        return Manifest["header-success"]
    end

    return ""
end

--- @lfunction Dialog A basic modal dialog composed with a semi-transparent overlay
--- @tparam DialogProps props
local function Dialog(props: DialogProps, children)
    props.Title = props.Title ~= nil and props.Title or DialogPropDefaults.Title
    props.Width = props.Width ~= nil and props.Width or DialogPropDefaults.Width
    if props.HasCloseButton == nil then
        props.HasCloseButton = DialogPropDefaults.HasCloseButton
    end
    props.DefaultButtonLabel = props.DefaultButtonLabel ~= nil and props.DefaultButtonLabel
        or DialogPropDefaults.DefaultButtonLabel
    return withThemeContext(function(theme): string
        local primaryButton = nil
        if props.Primary then
            local primaryProps = {
                Debounce = props.Debounce,
            }
            for key, value in pairs(props.Primary) do
                primaryProps[key] = value
            end
            primaryButton = Button(primaryProps)
        end

        local secondaryButton = nil
        if props.Secondary then
            local secondaryProps = {
                Debounce = props.Debounce,
            }
            for key, value in pairs(props.Secondary) do
                secondaryProps[key] = value
            end
            secondaryButton = Button(secondaryProps)
        end

        local sized = sizedByShorthand(props)

        local titleChildren = {
            DialogTitleText = Text({
                Text = props.Title,
                Color = theme.Tokens.Colors.Text.Color,
                Font = theme.Tokens.Typography.HeadlineMedium.Font,
                FontSize = theme.Tokens.Typography.HeadlineMedium.FontSize,
                LineHeight = theme.Tokens.Typography.HeadlineMedium.LineHeight,
                TextXAlignment = props.TitleTextXAlignment or Enum.TextXAlignment.Left,
                LayoutOrder = 0,
                ZIndex = props.ZIndex or 1,
            }),
        }

        local titleDivider = React.createElement("Frame", {
            Size = UDim2.new(1, -2, 1, 0),
            BackgroundColor3 = theme.Tokens.Colors.LineSubtle.Color,
            ZIndex = props.ZIndex or 1,
        })

        local contentChildren = props.Content
                and {
                    DialogContentText = MultiparagraphText({
                        Component = Text({
                            Text = props.Content,
                            Color = theme.Tokens.Colors.Text.Color,
                            Font = theme.Tokens.Typography.BodyMedium.Font,
                            FontSize = theme.Tokens.Typography.BodyMedium.FontSize,
                            LineHeight = theme.Tokens.Typography.BodyMedium.LineHeight,
                            RichText = props.ContentRichText or false,
                            LayoutOrder = 0,
                            ZIndex = props.ZIndex or 1,
                        }),
                        Gaps = props.ContentGaps,
                    }),
                }
            or {}

        local defaultButtons = {
            PrimaryButton = primaryButton,
            SecondaryButton = secondaryButton,
        }

        local defaultButtonTable = {
            ButtonRow = Row({
                Gaps = theme.Tokens.Sizes.Registered.Medium.Value,
                HorizontalAlignment = props.ButtonAlignment or Enum.HorizontalAlignment.Left,
                ZIndex = props.ZIndex or 1,
            }, defaultButtons),
        }

        local footerChildren = {
            DefaultButtonRow = Row({
                Size = UDim2.fromScale(1, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                HorizontalAlignment = props.ButtonAlignment or Enum.HorizontalAlignment.Left,
                PaddingTop = theme.Tokens.Sizes.Registered.Medium.Value,
                ZIndex = props.ZIndex or 1,
            }, {
                DefaultButton = Button({
                    Appearance = "Filled",
                    Debounce = props.Debounce,
                    Label = props.DefaultButtonLabel,
                    OnActivated = props.DefaultOnActivated,
                    LayoutOrder = 1,
                    ZIndex = props.ZIndex or 1,
                }),
            }),
        }

        -- handle children
        if children then
            -- if children table is an array, each element will be added as contentChildren
            if children[1] ~= nil then
                for index, value in ipairs(children) do
                    value["props"]["LayoutOrder"] = index
                    contentChildren["AdditionalChild" .. index] = value
                end
            else
                -- if children table has key "Title", add to titleChildren
                if children["Title"] and children["Title"] ~= nil then
                    children["Title"]["props"]["LayoutOrder"] = 1
                    titleChildren["AdditionalChild"] = children["Title"]
                end
                -- if children table has key "Content", add to contentChildren
                if children["Content"] and children["Content"] ~= nil then
                    children["Content"]["props"]["LayoutOrder"] = 1
                    contentChildren["AdditionalChild"] = children["Content"]
                end
                -- if children table has key "Footer", replace default content of footerChildren
                if children["Footer"] and children["Footer"] ~= nil then
                    children["Footer"]["props"]["LayoutOrder"] = 0
                    footerChildren = {}
                    footerChildren["AdditionalChild"] = children["Footer"]
                end
                -- if children table has different string keys, add them to contentChildren
                for key, value in pairs(children) do
                    if type(key) == "string" then
                        if key ~= "Title" and key ~= "Content" and key ~= "Footer" then
                            value["props"]["LayoutOrder"] = 2
                            contentChildren[key] = value
                        end
                    end
                end
            end
        end

        local dialogChildren = {
            DialogBannerImage = props.HasBanner and React.createElement("ImageLabel", {
                Size = UDim2.fromOffset(BANNER_WIDTH, BANNER_HEIGHT),
                BackgroundTransparency = 1,
                Image = getBannerImage(props),
                ZIndex = (props.ZIndex and props.ZIndex + 1) or 2,
            }) or nil,
            CloseButtonBlock = props.HasCloseButton and Block({
                Size = UDim2.fromOffset(30, 30),
                Position = UDim2.new(1, -45, 0, 0),
                ZIndex = props.ZIndex or 1,
            }, {
                CloseButton = Button({
                    Debounce = props.Debounce,
                    Size = UDim2.fromScale(1, 1),
                    Padding = theme.Tokens.Sizes.Registered.SmallMinus.Value,
                    OnActivated = props.OnCloseDialog,
                    ZIndex = props.ZIndex or 1,
                }, {
                    Image = React.createElement("ImageLabel", {
                        Size = UDim2.fromScale(1, 1),
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://6902342783",
                        ZIndex = props.ZIndex or 1,
                    }),
                }),
            }) or nil,
            DialogBlock = Block({}, {
                DialogColumn = Column({ Gaps = theme.Tokens.Sizes.Registered.Medium.Value }, {
                    -- Pre-Title "slot"
                    -- Initially used for composing task progress track into dialog
                    DialogPreTitleRow = props.DialogPreTitleContent
                            and Row({
                                AutomaticSize = props.DialogPreTitleRowSize and Enum.AutomaticSize.None
                                    or Enum.AutomaticSize.Y,
                                Size = props.DialogPreTitleRowSize or UDim2.fromScale(1, 0),
                                LayoutOrder = 0,
                                PaddingHorizontal = 42,
                                VerticalAlignment = props.DialogPreTitleVerticalAlignment
                                    or Enum.VerticalAlignment.Center,
                                ZIndex = props.ZIndex or 1,
                            }, props.DialogPreTitleContent)
                        or nil,

                    -- Title "slot"
                    DialogTitleRow = Row({
                        LayoutOrder = 1,
                        PaddingHorizontal = 42,
                        PaddingTop = props.HasBanner and BANNER_HEIGHT + theme.Tokens.Sizes.Registered.Medium.Value
                            or 0,
                        HorizontalAlignment = props.TitleRowHorizontalAlignment or Enum.HorizontalAlignment.Left,
                    }, titleChildren),

                    -- Title Divider
                    DialogTitleDividerRow = Row({
                        Size = UDim2.new(1, 0, 0, 1),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        LayoutOrder = 2,
                    }, {
                        DialogTitleDivider = titleDivider,
                    }),

                    -- Content "slot"
                    DialogContentColumn = Column({
                        LayoutOrder = 3,
                        PaddingHorizontal = 42,
                    }, contentChildren),

                    -- Footer "slot"
                    DialogFooter = children and children["Footer"] and children["Footer"] ~= nil and Column({
                        LayoutOrder = 4,
                        PaddingHorizontal = 42,
                    }, footerChildren) or Row({
                        LayoutOrder = 3,
                        PaddingHorizontal = 42,
                    }, defaultButtonTable),
                }),
            }),
        }
        local dialogChildrenJoin = Dash.join({
            UIPadding = React.createElement("UIPadding", {
                PaddingTop = UDim.new(0, props.HasBanner and 0 or theme.Tokens.Sizes.Registered.XMedium.Value),
                PaddingBottom = UDim.new(0, theme.Tokens.Sizes.Registered.Large.Value),
            }),
            UICorner = React.createElement("UICorner", {
                CornerRadius = UDim.new(0, theme.Tokens.Sizes.Registered.Dialog__CornerRadiusLargeOutside.Value),
            }),
        }, dialogChildren)

        local dialogFrame = React.createElement("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = sized.Size,
            AutomaticSize = sized.AutomaticSize,
            BackgroundColor3 = theme.Tokens.Colors.Surface.Color,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            ZIndex = props.ZIndex or 1,
        }, dialogChildrenJoin)

        -- returns Overlay component with Dialog as a child
        return Overlay({ ZIndex = props.ZIndex or 1 }, { Dialog = dialogFrame })
    end)
end

return Dialog
