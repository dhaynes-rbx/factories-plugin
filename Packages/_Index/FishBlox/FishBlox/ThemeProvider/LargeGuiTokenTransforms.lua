--!strict
local Packages = script.Parent.Parent.Parent
local Dash = require(Packages.Dash)

function mapNestedValues(entry, targetKey, transformer)
    if type(entry) == "table" then
        return Dash.map(entry, function(value, key)
            if key == targetKey then
                return transformer(value)
                -- Assuming we don't touch nested values under a transformed key (e.g. no mapNestedValues here)
            else
                return mapNestedValues(value)
            end
        end)
    else
        return entry
    end
end

-- Sizes
-- Iterate recursively and set all Value to 2x
function scaleSizes(sizes)
    return mapNestedValues(sizes, "Value", function(value)
        return value * 2
    end)
end

-- Typography
-- Set all size related values to 2x
function scaleTypography(typography)
    -- ASSUMPTION: currently there is no nesting in Typography tokens
    return Dash.map(typography, function(textStyle, key)
        local transformedTextStyle = {
            FontSize = textStyle.FontSize * 2,
            LineHeight = textStyle.LineHeight * 2, -- (does this work as it's a percentage)
            SpaceBefore = textStyle.SpaceBefore and textStyle.SpaceBefore * 2 or nil,
            SpaceAfter = textStyle.SpaceAfter and textStyle.SpaceAfter * 2 or nil,
            -- TODO: merge all other properties instead of manually copying
            Font = textStyle.Font,
            Color = textStyle.Color,
        }

        -- ROBLOX LIMITATION: Text size caps at 100
        if transformedTextStyle.FontSize > 100 then
            warn("Typography for key " .. key .. " will be limited to 100 (not " .. typography[key].FontSize .. ")")
        end

        return transformedTextStyle
    end)
end

-- This is a very naive way to do this. Just doubles all sizing and typeography tokens.
-- So naive that perhaps UIScale 200% is a better approach
function tokensByLargeTextSetting(largeText: boolean, tokens: any) -- TODO: Fishblox.Theme.Tokens?
    return {
        Sizes = largeText and scaleSizes(tokens.Sizes) or tokens.Sizes,
        Typography = largeText and scaleTypography(tokens.Typography) or tokens.Typography,
        Colors = tokens.Colors,
        CornerRadius = tokens.CornerRadius,
    }
end

return tokensByLargeTextSetting
