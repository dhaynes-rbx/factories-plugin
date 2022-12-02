--!strict
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local themes = require(script.Parent.Themes)

export type ThemeContext = {
    ThemeKey: string,
    Tokens: any, -- Tokens can be straight pass through of map OR can be a function transforming map based on FontSizeBase, HighContrast
    LargeText: boolean, -- Large Text inherit from parent ThemeContext
    HighContrast: boolean, -- Contrast Mode, inherit from parent ThemeContext
}

-- This `defaultThemeContext` is a fallback for when ThemeContext is used without ThemeProvider
-- but in all practical use cases ThemeProvider should be used
-- as it pre-processes to tokens and allows high contrast and font size to be dynamic
local defaultThemeContext: ThemeContext = {
    ThemeKey = themes.Default.ThemeKey,
    Tokens = themes.Default.Tokens,
    LargeText = false,
    HighContrast = false,
}

local themeContext = Roact.createContext(defaultThemeContext)

return themeContext
