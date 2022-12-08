--!strict
local Manifest = require(script.Parent.Parent.Assets.Manifest)
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local React = require(Packages.React)
local Text = require(script.Parent.Text)
local Button = require(script.Parent.Button)
local TaskTimer = require(script.Parent.TaskTimer)
local BentoBlox = require(Packages.BentoBlox)
local Block = require(BentoBlox.Components.Block)
local Row = require(BentoBlox.Components.Row)
local withThemeContext = require(script.Parent.Parent.ThemeProvider.WithThemeContext)

--- Module

type OffsetOrUDim = number | UDim
--[[--
    @tfield OffsetOrUDim?="UDim.new(0, 42)," Height
    @tfield table?={} Utilities
    @tfield string?="" Content
    @tfield boolean?=false ShowHelpButton
    @tfield boolean?=false HelpButtonIsToggled
    @tfield boolean?=false TutorialMode
    @tfield table? TimerState
    @tfield (() -> number)? GetTime
    @tfield number SectionNumber
    @table TopBarProps
]]

export type TopBarProps = {
    Content: string?, -- Callbacks
    ShowHelpButton: boolean?,
    TutorialMode: boolean?,
    OnClickHelpButton: () -> nil?,
    HelpButtonIsToggled: boolean?,
    SectionNumber: number,
    TimerState: any?,
    GetTime: () -> number?,
    ZIndex: number?,
    Minimal: boolean?,
}

local TopBarPropDefaults = {
    Content = "",
    TutorialMode = false,
    HelpButtonIsToggled = false,
}

local ROBLOX_BUTTON_OFFSET = 44
local HELP_BUTTON_SIZE = 32
local LEFT_TOOLBAR_OFFSET = ROBLOX_BUTTON_OFFSET + HELP_BUTTON_SIZE

--- @lfunction TopBar The bar at the top of a task that contains a slot for utilities (e.g. Help) and content (e.g. Timer)
--- @tparam TopBarProps props
local function TopBar(props: TopBarProps, children: { [string | number]: Roact.Element }?)
    -- defaults
    props.Content = props.Content ~= nil and props.Content or TopBarPropDefaults.Content
    props.TutorialMode = props.TutorialMode ~= nil and props.TutorialMode or TopBarPropDefaults.TutorialMode
    props.HelpButtonIsToggled = if props.HelpButtonIsToggled ~= nil then props.HelpButtonIsToggled else TopBarPropDefaults.HelpButtonIsToggled
    -- state
    local helpLabelShowing, setHelpLabelShowing = React.useState(false)


    return withThemeContext(function(theme)
        local helpButtonBlock = props.ShowHelpButton ~= nil
                and props.ShowHelpButton == true
                and Block({
                    Size = UDim2.fromOffset(0, HELP_BUTTON_SIZE),
                    AutomaticSize = Enum.AutomaticSize.X,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, ROBLOX_BUTTON_OFFSET, 0.5, -1),
                    -- Offset up by 1px to align to Roblox button
                    ZIndex = props.ZIndex or 1,
                }, {
                    HelpButton = Button({
                        IsToggle = true,
                        ButtonIsToggled = props.HelpButtonIsToggled,
                        Appearance = "Roblox",
                        Size = UDim2.fromScale(1, 1),
                        Padding = 0,
                        ZIndex = props.ZIndex or 1,
                        OnActivated = props.OnClickHelpButton,
                        OnHighlighted = function () setHelpLabelShowing(true) end,
                        OnUnhighlighted = function () setHelpLabelShowing(false) end,
                    }, {
                        Row({
                            Gaps = 4,
                            VerticalAlignment = Enum.VerticalAlignment.Top
                        }, {
                            ImageBlock = Block({
                                Size = UDim2.fromOffset(HELP_BUTTON_SIZE, HELP_BUTTON_SIZE),
                            }, {
                                Image = Roact.createElement("ImageLabel", {
                                    Size = UDim2.fromOffset(12, 18),
                                    AutomaticSize = Enum.AutomaticSize.None,
                                    BackgroundTransparency = 1,
                                    Image = if props.HelpButtonIsToggled then Manifest["icon-help-inverted"] else Manifest["icon-help"],
                                    AnchorPoint = Vector2.new(0.5, 0.5),
                                    Position = UDim2.fromScale(0.5, 0.5),
                                    ZIndex = props.ZIndex or 1,
                                }),
                            }),
        
                            -- we are padding the label with a block because button doesn't support asymetric padding.
                            Label = if helpLabelShowing then Block({
                                PaddingRight = 16,
                                Size = UDim2.fromScale(0, 1),
                                AutomaticSize = Enum.AutomaticSize.X,
                            }, {
                                Text({
                                    ZIndex = props.ZIndex or 1,
                                    Size = UDim2.fromScale(0, 1),
                                    AutomaticSize = Enum.AutomaticSize.X,
                                    FontSize = 18, -- ignore theme because matching Roblox
                                    Text = "Get Help",
                                    Color =  if props.HelpButtonIsToggled then Color3.new(0,0,0) else Color3.new(1,1,1),
                                    TextYAlignment = Enum.TextYAlignment.Center,
                                })
                            }) else nil
                        })
                    }),
                })
            or nil

        local contentBlock = (
            props.TimerState
            and props.GetTime
            and TaskTimer({
                TimerState = props.TimerState,
                GetTime = props.GetTime,
                InTutorial = props.TutorialMode,
                SectionNumber = props.SectionNumber,
            })
        )
            or Block({
                Size = UDim2.new(1, -LEFT_TOOLBAR_OFFSET - theme.Tokens.Sizes.Registered.SmallPlus.Value, 1, 0),
                Position = UDim2.new(0, LEFT_TOOLBAR_OFFSET + theme.Tokens.Sizes.Registered.SmallPlus.Value, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
            }, {
                Text = Text({
                    Size = UDim2.fromScale(1, 1),
                    AutomaticSize = Enum.AutomaticSize.None,
                    Text = props.Content,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    Color = theme.Tokens.Typography.BodyMedium.Color,
                    Font = theme.Tokens.Typography.BodyMedium.Font,
                    FontSize = theme.Tokens.Typography.BodyMedium.FontSize,
                }),
            })

        local topBarBlock = Block({
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundTransparency = props.Minimal and 1 or 0,
            BackgroundColor = props.TutorialMode == false and theme.Tokens.Colors.Surface.Color
                or theme.Tokens.Colors.InstructionSurface.Color,
            PaddingHorizontal = theme.Tokens.Sizes.Registered.SmallPlus.Value,
            PaddingVertical = theme.Tokens.Sizes.Registered.SmallMinus.Value,
            LayoutOrder = 0,
        }, {
            HelpButtonBlock = helpButtonBlock,
            ContentBlock = contentBlock,
        })

        return topBarBlock
    end)
end

return TopBar
