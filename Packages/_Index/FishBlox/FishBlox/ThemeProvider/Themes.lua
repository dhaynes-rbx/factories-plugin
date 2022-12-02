--!strict
local Tokens = script.Parent.Parent.Tokens
local colorTokens = require(Tokens.Colors)
local colorTokensLight = require(Tokens.ColorsLight)
local colorTokensWireframe = require(Tokens.ColorsWireframe)
local sizeTokens = require(Tokens.Sizes)
local typographyTokens = require(Tokens.Typography)
local cornerRadius = require(Tokens.CornerRadius)
local strokeWidth = require(Tokens.StrokeWidth)

export type Theme = {
    ThemeKey: string,
    Tokens: {
        Colors: colorTokens.Colors,
        Sizes: sizeTokens.Sizes,
        CornerRadius: cornerRadius.CornerRadius,
        Typography: typographyTokens.Typography,
        StrokeWidth: strokeWidth.StrokeWidth,
    },
    -- HighContrastOverrideTokens
    -- HighContrastTokenTransformFn :: default is look to overrides use that, else use original
    -- LargeFontOverrideTokens
    -- LargeFontTokenTransformFn :: default is look to overrides use that, else shift up font by base
}

local DarkTheme: Theme = {
    ThemeKey = "Dark",
    Tokens = {
        Colors = colorTokens,
        Sizes = sizeTokens,
        CornerRadius = cornerRadius,
        Typography = typographyTokens,
        StrokeWidth = strokeWidth,
    },
}

local LightTheme: Theme = {
    ThemeKey = "Light",
    Tokens = {
        Colors = colorTokensLight,
        Sizes = sizeTokens,
        CornerRadius = cornerRadius,
        Typography = typographyTokens,
        StrokeWidth = strokeWidth,
    },
}

local WireframeTheme: Theme = {
    ThemeKey = "Wireframe",
    Tokens = {
        Colors = colorTokensWireframe,
        Sizes = sizeTokens,
        CornerRadius = cornerRadius,
        Typography = typographyTokens,
        StrokeWidth = strokeWidth,
    },
}

return {
    Default = DarkTheme,
    Dark = DarkTheme,
    Light = LightTheme,
    Wireframe = WireframeTheme,
}
