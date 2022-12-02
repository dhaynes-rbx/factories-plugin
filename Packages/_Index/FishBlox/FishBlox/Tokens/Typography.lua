--!strict

-- font size as seperate definitions consumed by the full typography defs

local placeholderDefaultFontColor = Color3.new(218 / 255, 218 / 255, 218 / 255)

export type TypographyToken = {
    Key: string,
    Description: string,
    Font: Enum.Font,
    FontSize: number,
    LineHeight: number,
    Color: Color3,
    SpaceAfter: number,
}

export type Typography = {
    Button: TypographyToken,
    ButtonLarge: TypographyToken,
    HeadlineXXLarge: TypographyToken,
    HeadlineXLarge: TypographyToken,
    HeadlineLarge: TypographyToken,
    HeadlineMedium: TypographyToken,
    HeadlineSmall: TypographyToken,
    Subheader: TypographyToken,
    BodyXLarge: TypographyToken,
    BodyLarge: TypographyToken,
    BodyMedium: TypographyToken,
    BodyMediumSemiBold: TypographyToken,
    BodySmall: TypographyToken,
    FieldLabel: TypographyToken,
    FieldValue: TypographyToken,
}

-- broad semantic categories in a typographic scale first
-- then components back register their specific semantic tokens into this map
local typographyTokens = { -- : { TypographyToken } = {
    Button = {
        Key = "Button",
        Description = "",
        Font = Enum.Font.GothamSemibold,
        FontSize = 18,
        LineHeight = 32 / 18,
        Color = placeholderDefaultFontColor,
    },
    ButtonLarge = {
        Key = "ButtonLarge",
        Description = "",
        Font = Enum.Font.GothamSemibold,
        FontSize = 24,
        LineHeight = 28 / 24,
        Color = placeholderDefaultFontColor,
    },
    HeadlineXXLarge = {
        Key = "HeadlineXXLarge",
        Description = "",
        Font = Enum.Font.GothamBold,
        FontSize = 64,
        LineHeight = 88 / 64,
        -- LetterSpacing = -2%
        Color = placeholderDefaultFontColor,
        SpaceAfter = 20, -- TODO: use size token
    },
    HeadlineXLarge = {
        Key = "HeadlineXLarge",
        Description = "",
        Font = Enum.Font.GothamBold,
        FontSize = 36,
        LineHeight = 48 / 36, -- Intended? This was value under auto in Figma
        -- LetterSpacing = -2%
        Color = placeholderDefaultFontColor,
        SpaceAfter = 20, -- TODO: use size token
    },
    HeadlineLarge = {
        Key = "HeadlineLarge",
        Description = "",
        Font = Enum.Font.GothamBold, -- Wants Medium
        FontSize = 32,
        LineHeight = 38 / 32,
        -- LetterSpacing -1%
        Color = placeholderDefaultFontColor,
        SpaceAfter = 20, -- TODO: use size token
    },
    HeadlineMedium = {
        Key = "HeadlineMedium",
        Description = "",
        Font = Enum.Font.GothamBold,
        FontSize = 24,
        LineHeight = 28 / 24,
        Color = placeholderDefaultFontColor,
        SpaceAfter = 16, -- TODO: use size token
    },
    HeadlineSmall = {
        Key = "HeadlineSmall",
        Description = "",
        Font = Enum.Font.GothamBold,
        FontSize = 20,
        LineHeight = 24 / 20,
        Color = placeholderDefaultFontColor,
        SpaceAfter = 16, -- TODO: use size token
    },
    Subheader = {
        Key = "Subheader",
        Description = "",
        Font = Enum.Font.GothamBold, -- Wants Black
        FontSize = 14,
        LineHeight = 20 / 14,
        -- ALL CAPS?
        -- LetterSpacing 8%
        Color = placeholderDefaultFontColor,
        SpaceAfter = 16, -- TODO: use size token
    },
    BodyXLarge = {
        Key = "BodyXLarge",
        Description = "",
        Font = Enum.Font.Gotham, -- GothamBook?
        FontSize = 24,
        LineHeight = 28 / 24,
        Color = placeholderDefaultFontColor,
    },
    BodyLarge = {
        Key = "BodyLarge",
        Description = "",
        Font = Enum.Font.Gotham, -- GothamBook?
        FontSize = 20,
        LineHeight = 32 / 20,
        Color = placeholderDefaultFontColor,
    },
    BodyMedium = {
        Key = "BodyMedium",
        Description = "",
        Font = Enum.Font.Gotham,
        FontSize = 18,
        LineHeight = 28 / 18,
        Color = placeholderDefaultFontColor,
    },
    BodyMediumSemiBold = {
        Key = "BodyMediumSemiBold",
        Description = "",
        Font = Enum.Font.GothamSemibold,
        FontSize = 18,
        LineHeight = 28 / 18,
        Color = placeholderDefaultFontColor,
    },
    BodySmall = {
        Key = "BodySmall",
        Description = "",
        Font = Enum.Font.Gotham,
        FontSize = 16,
        LineHeight = 24 / 16,
        Color = placeholderDefaultFontColor,
    },

    FieldLabel = {
        Key = "FieldLabel",
        Description = "",
        Font = Enum.Font.Gotham,
        FontSize = 14,
        LineHeight = 1,
        Color = Color3.new(164 / 255, 164 / 255, 165 / 255), -- A4A4A5
        -- ALL CAPS?
        -- LetterSpacing 5%
    },
    FieldValue = {
        Key = "FieldValue",
        Description = "",
        Font = Enum.Font.Gotham,
        FontSize = 14,
        LineHeight = 1,
        -- LetterSpacing 2%
        Color = placeholderDefaultFontColor,
    },
}

return typographyTokens
