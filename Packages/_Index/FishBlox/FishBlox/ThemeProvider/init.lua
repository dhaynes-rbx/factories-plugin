--!strict
local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)
local themes = require(script.Themes)
local themeContext = require(script.ThemeContext)

local tokensByLargeTextSetting = require(script.LargeGuiTokenTransforms)

--- Module

--[[--
    @tfield string?="Default" Theme
    @tfield boolean?=false LargeText
    @tfield boolean?=false HighContrast
    @table ThemeProviderProps
]]

export type Theme = themes.Theme

type ThemeProviderProps = {
    Theme: (themes.Theme | string)?, -- Theme or theme name or nil (Default)
    LargeText: boolean?,
    HighContrast: boolean?,
}

--- @lfunction ThemeProvider A Context Provider to provide a ThemeContext to all its children
--- @tparam ThemeProviderProps props
function ThemeProvider(props: ThemeProviderProps, children)
    props.Theme = props.Theme or themes.Default
    props.LargeText = props.LargeText or false
    props.HighContrast = props.HighContrast or false
    local resolvedTheme = typeof(props.Theme) == "string" and themes[props.Theme] or props.Theme
    local preprocessedThemeContext: themeContext.ThemeContext = {
        ThemeKey = resolvedTheme.ThemeKey,
        Tokens = tokensByLargeTextSetting(props.LargeText, resolvedTheme.Tokens),
        LargeText = props.LargeText,
        HighContrast = props.HighContrast,
    }

    return Roact.createElement(themeContext.Provider, {
        value = preprocessedThemeContext,
    }, children)
end

return ThemeProvider
