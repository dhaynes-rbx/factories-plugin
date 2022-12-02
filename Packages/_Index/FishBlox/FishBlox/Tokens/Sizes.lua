--!strict
local colorFromHex = require(script.Parent.Parent.Utilities.ColorFromHex)

local sizes = {}

export type SizeToken = {
    Key: string,
    Value: number,
    GridAligned: boolean,
    SpacerColor: Color3?,
}

export type Sizes = {
    Scale: { [number]: SizeToken },
    Shared: { [number]: SizeToken },
    Registered: {
        -- Scale
        SmallMinus: SizeToken,
        Small: SizeToken,
        SmallPlus: SizeToken,
        Medium: SizeToken,
        MediumPlus: SizeToken,
        XMedium: SizeToken,
        XMediumPlus: SizeToken,
        Large: SizeToken,
        XLarge: SizeToken,
        XXlarge: SizeToken,
        --Shared
        ControlHeight: SizeToken,
        -- Dialog
        Dialog__WidthSmall: SizeToken,
        Dialog__WidthMedium: SizeToken,
        Dialog__WidthLarge: SizeToken,
        Dialog__CornerRadiusLargeOutside: SizeToken,
    },
    registerSizeToken: (string, number, Color3?) -> SizeToken,
}

function registerSizeToken(key: string, value: number, colorForSpacer: Color3?)
    local token = {
        Key = key,
        Value = value,
        GridAligned = (value % 8 == 0), -- divisble by 8 with no remainder
        SpacerColor = colorForSpacer,
    }
    sizes[key] = token
    return token
end

-- 1. Providing a generic 8pt/8px scale as a base
-- Not named because order is important
local scale = {
    registerSizeToken("SmallMinus", 4, colorFromHex("#FF5A5F")),
    registerSizeToken("Small", 8, colorFromHex("#FE810A")),
    registerSizeToken("SmallPlus", 12, colorFromHex("#FEC90A")),
    registerSizeToken("Medium", 16, colorFromHex("#2DB783")),
    registerSizeToken("MediumPlus", 20, colorFromHex("#06D6E4")),
    registerSizeToken("XMedium", 24, colorFromHex("#009FD9")),
    registerSizeToken("XMediumPlus", 28, colorFromHex("#007DF0")),
    registerSizeToken("Large", 32, colorFromHex("#5968E2")),
    registerSizeToken("XLarge", 64, colorFromHex("#C654E5")),
    registerSizeToken("XXlarge", 128, colorFromHex("#8814A8")),
}

-- 2. Also registering any shared semantic size tokens
local shared = {
    registerSizeToken("ControlHeight", 50), -- used by buttons, text inputs, and other inputs to allow them to match up vertically when used in a line together
}

-- 3. Components then back register specific semantic size tokens

-- Dialog
registerSizeToken("Dialog__WidthSmall", 424)
registerSizeToken("Dialog__WidthMedium", 528)
registerSizeToken("Dialog__WidthLarge", 640)
registerSizeToken("Dialog__CornerRadiusLargeOutside", 24)

-- EXPORT
return {
    Scale = scale,
    Shared = shared,
    Registered = sizes,
    registerSizeToken = registerSizeToken,
}
