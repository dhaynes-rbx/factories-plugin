--!strict
local Manifest = require(script.Parent.Parent.Assets.Manifest)
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
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
    @tfield boolean?=false TutorialMode
    @tfield table? TimerState
    @tfield (() -> number)? GetTime
    @tfield number SectionNumber
    @table TopBarProps
]]

export type TopBarProps = {
    Height: OffsetOrUDim?,
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
    Height = UDim.new(0, 42),
    Content = "",
    TutorialMode = false,
}

local ROBLOX_BUTTON_OFFSET = 44
local HELP_BUTTON_WIDTH = 32
local LEFT_TOOLBAR_OFFSET = ROBLOX_BUTTON_OFFSET + HELP_BUTTON_WIDTH

--- @lfunction TopBar The bar at the top of a task that contains a slot for utilities (e.g. Help) and content (e.g. Timer)
--- @tparam TopBarProps props
local function TopBar(props: TopBarProps, children: { [string | number]: Roact.Element }?)
    return withThemeContext(function(theme)
        props.Height = props.Height ~= nil and props.Height or TopBarPropDefaults.Height
        props.Content = props.Content ~= nil and props.Content or TopBarPropDefaults.Content
        props.TutorialMode = props.TutorialMode ~= nil and props.TutorialMode or TopBarPropDefaults.TutorialMode

        local hasHeight = props.Height ~= nil
        if hasHeight then
            local heightIsNumber = type(props.Height) == "number"
            if heightIsNumber then
                local heightAsUDim = UDim.new(0, props.Height)
                props.Height = heightAsUDim
            end
        end

        local helpButtonBlock = props.ShowHelpButton ~= nil
                and props.ShowHelpButton == true
                and Block({
                    Size = UDim2.fromOffset(HELP_BUTTON_WIDTH, HELP_BUTTON_WIDTH),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, ROBLOX_BUTTON_OFFSET, 0.5, -1),
                    -- Offset up by 1px to align to Roblox button
                    ZIndex = props.ZIndex or 1,
                }, {
                    HelpButton = Button({
                        IsToggle = true,
                        ButtonIsToggled = props.HelpButtonIsToggled,
                        ImageToggleSrc = Manifest["icon-help-inverted"],
                        Appearance = "Roblox",
                        Size = UDim2.fromScale(1, 1),
                        OnActivated = props.OnClickHelpButton,
                        Padding = 0,
                        ZIndex = props.ZIndex or 1,
                    }, {
                        Image = Roact.createElement("ImageLabel", {
                            Size = UDim2.fromOffset(12, 18),
                            AutomaticSize = Enum.AutomaticSize.None,
                            BackgroundTransparency = 1,
                            Image = Manifest["icon-help"],
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            ZIndex = props.ZIndex or 1,
                        }),
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
            Size = UDim2.new(UDim.new(1, 0), props.Height),
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
