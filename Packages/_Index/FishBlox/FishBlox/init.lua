--!strict
local BentoBloxComponents = require(script.Parent.BentoBlox).Components

return {
    Components = {
        -- Fishblox
        QuestionTracker = require(script.Components.QuestionTracker),
        RadioButtonGroup = require(script.Components.RadioButtonGroup),
        SectionTracker = require(script.Components.SectionTracker),
        Button = require(script.Components.Button),
        Checkbox = require(script.Components.Checkbox),
        Dialog = require(script.Components.Dialog),
        FoldingFrame = require(script.Components.FoldingFrame),
        Icon = require(script.Components.Icon),
        Line = require(script.Components.Line),
        LoadingScreen = require(script.Components.LoadingScreen),
        MultiparagraphText = require(script.Components.MultiparagraphText),
        NavigationButton = require(script.Components.NavigationButton),
        Overlay = require(script.Components.Overlay),
        Panel = require(script.Components.Panel),
        PointerBlock = require(script.Components.PointerBlock),
        ProgressTrack = require(script.Components.ProgressTrack),
        Spotlight = require(script.Components.Spotlight),
        TaskTimer = require(script.Components.TaskTimer),
        Text = require(script.Components.Text),
        TextInput = require(script.Components.TextInput),
        ToolBar = require(script.Components.ToolBar),
        Tooltip = require(script.Components.Tooltip),
        TopBar = require(script.Components.TopBar),
        TutorialPopover = require(script.Components.TutorialPopover),
        TutorialTooltip = require(script.Components.TutorialTooltip),

        -- Bentoblox
        Block = require(BentoBloxComponents.Block),
        Column = require(BentoBloxComponents.Column),
        Gap = require(BentoBloxComponents.Gap),
        Row = require(BentoBloxComponents.Row),
    },
    Tokens = {
        Colors = require(script.Tokens.Colors),
        ColorScales = require(script.Tokens.ColorScales),
        ColorsLight = require(script.Tokens.ColorsLight),
        ColorsWireframe = require(script.Tokens.ColorsWireframe),
        CorderRadius = require(script.Tokens.CornerRadius),
        Sizes = require(script.Tokens.Sizes),
        StrokeWidth = require(script.Tokens.StrokeWidth),
        Typography = require(script.Tokens.Typography),
    },
    ThemeProvider = require(script.ThemeProvider),
    Themes = require(script.ThemeProvider.Themes),
    WithThemeContext = require(script.ThemeProvider.WithThemeContext),
    Manifest = require(script.Assets.Manifest),
}
