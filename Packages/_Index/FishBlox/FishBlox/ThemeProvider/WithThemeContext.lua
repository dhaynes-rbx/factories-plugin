--!strict
local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local ThemeContext = require(script.Parent.ThemeContext)
local Themes = require(script.Parent.Themes)

-- Shorthand function to access theme context
function withThemeContext(renderFn: (theme: Themes.Theme) -> any)
    return Roact.createElement(ThemeContext.Consumer, {
        render = renderFn,
    })
end

return withThemeContext

--[[
Usage in components:
```Button.lua
function Button(props, children)
    return withThemeContext(function (theme)
        local buttonChildren = children or Text({ Color = theme.Tokens.Color.InteractiveSurface })
        return Block({ Color = theme.Tokens.Color.InteractiveSurface, }, buttonChildren)
    end)
end

return Button;
```
]]
--
