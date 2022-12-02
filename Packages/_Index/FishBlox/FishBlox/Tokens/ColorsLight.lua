--!strict
local colorScales = require(script.Parent.ColorScales)

export type ColorToken = {
    Key: string?,
    Description: string?,
    Color: Color3?,
    Transparency: number?,
    OverSurfaces: table,
}

export type Colors = {
    Surface: ColorToken,
    SurfaceInverted: ColorToken,
    Line: ColorToken,
    Text: ColorToken,
    TextInverted: ColorToken,
    TextSubtle: ColorToken,
    TextEmphasized: ColorToken,
    WarningText: ColorToken,
    InteractiveText: ColorToken,
    InteractiveTextEmphasized: ColorToken,
    InteractiveLine: ColorToken,
    InteractiveLineEmphasized: ColorToken,
    LineSubtle: ColorToken,
    InteractiveSurface: ColorToken,
    InteractiveSurfaceGradientA1: ColorToken,
    InteractiveSurfaceGradientA2: ColorToken,
    InteractiveSurfaceGradientB1: ColorToken,
    InteractiveSurfaceGradientB2: ColorToken,
    InteractiveSurfaceText: ColorToken,
    DisabledSurface: ColorToken,
    DisabledSurfaceText: ColorToken,
    DisabledLine: ColorToken,
    InstructionSurface: ColorToken,
    InstructionSurfaceSubtle: ColorToken,
    InstructionText: ColorToken,
    InstructionTextSubtle: ColorToken,
    InstructionOutline: ColorToken,
    Overlay: ColorToken,
    AttentionLine: ColorToken,
    AttentionFill: ColorToken,
    AttentionText: ColorToken,
    ProgressTrack: ColorToken,
    InteractiveFill: ColorToken,
    DefaultLine: ColorToken,
    InteractiveLineSubtle: ColorToken,
    TextSubdued: ColorToken,
    TextError: ColorToken,
}

local surface: ColorToken = {
    Key = "Surface",
    Description = "The default backing of our UI",
    Color = colorScales.WhiteGrey["100"],
    Transparency = 0,
    OverSurfaces = {},
}

local surfaceInverted: ColorToken = {
    Key = "SurfaceInverted",
    Description = "The opposite default backing of our UI",
    Color = colorScales.GreyBlue["600"],
    Transparency = 0,
    OverSurfaces = {},
}

local line: ColorToken = {
    Key = "Line",
    Description = "The default line color",
    Color = colorScales.GreyBlue["600"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local text: ColorToken = {
    Key = "Text",
    Description = "The default text color",
    Color = colorScales.GreyBlue["700"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local textInverted: ColorToken = {
    Key = "TextInverted",
    Description = "The opposite default text color",
    Color = colorScales.WhiteGrey["400"],
    Transparency = 0,
    OverSurfaces = { surfaceInverted },
}

local textSubtle: ColorToken = {
    Key = "TextSubtle",
    Description = "For less important secondary or repeated label text",
    Color = colorScales.GreyBlue["100"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local textEmphasized: ColorToken = {
    Key = "TextEmphasized",
    Description = "To draw attention to text.",
    Color = colorScales.GreyBlue["800"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local warningText: ColorToken = {
    Key = "WarningText",
    Description = "To draw high attention to a piece of text.",
    Color = colorScales.Yellow["500"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local interactiveText: ColorToken = {
    Key = "InteractiveText",
    Description = "To show text that is interactive, e.g. clickable links.",
    Color = colorScales.Blue["600"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local interactiveTextEmphasized: ColorToken = {
    Key = "InteractiveTextEmphasized",
    Description = "To show text that is interactive and highlighted/hovered",
    Color = colorScales.Blue["700"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local interactiveSurface: ColorToken = {
    Key = "InteractiveSurface",
    Description = "Interactive surface, such as a button.",
    Color = colorScales.Blue["100"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local interactiveSurfaceSubtle: ColorToken = {
    Key = "InteractiveSurfaceSubtle",
    Description = "A subtle interactive surface, used when hovering.",
    Color = colorScales.Blue["800"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local interactiveSurfaceGradientA1: ColorToken = {
    Key = "InteractiveSurfaceGradientA1",
    Description = "Gradient transition color for interactive surfaces",
    Color = colorScales.Blue["500"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local interactiveSurfaceGradientA2: ColorToken = {
    Key = "InteractiveSurfaceGradientA2",
    Description = "Gradient transition color for interactive surfaces",
    Color = colorScales.Blue["600"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local interactiveSurfaceGradientB1: ColorToken = {
    Key = "InteractiveSurfaceGradientB1",
    Description = "Gradient transition color for interactive surfaces",
    Color = colorScales.Blue["500"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local interactiveSurfaceGradientB2: ColorToken = {
    Key = "InteractiveSurfaceGradientB2",
    Description = "Gradient transition color for interactive surfaces",
    Color = colorScales.Blue["700"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local interactiveSurfaceText: ColorToken = {
    Key = "InteractiveSurfaceText",
    Description = "Text drawn on top an interactive surface, such as a button.",
    Color = colorScales.WhiteGrey["100"],
    Transparency = 0,
    OverSurfaces = { interactiveSurface },
}

local interactiveLine: ColorToken = {
    Key = "InteractiveLine",
    Description = "Interactive line.",
    Color = colorScales.Blue["500"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local interactiveLineEmphasized: ColorToken = {
    Key = "InteractiveLineEmphasized",
    Description = "Interactive line with more attention.",
    Color = colorScales.Blue["700"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local lineSubtle: ColorToken = {
    Key = "LineSubtle",
    Description = "Subtle line that can be used to divide sections.",
    Color = colorScales.GreyBlue["400"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local disabledSurface: ColorToken = {
    Key = "DisabledSurface",
    Description = "Disabled interactive surface, such as a disabled button.",
    Color = colorScales.WhiteGrey["400"],
    Transparency = 0,
    OverSurfaces = {},
}

local disabledSurfaceText: ColorToken = {
    Key = "DisabledSurfaceText",
    Description = "Disabled text.",
    Color = colorScales.GreyBlue["500"],
    Transparency = 0,
    OverSurfaces = { disabledSurface },
}

local disabledLine: ColorToken = {
    Key = "DisabledLine",
    Description = "Disabled line.",
    Color = colorScales.GreyBlue["600"],
    Transparency = 0,
    OverSurfaces = { disabledSurface },
}

local instructionSurface: ColorToken = {
    Key = "InstructionSurface",
    Description = "Instruction surface, such as a tooltip.",
    Color = colorScales.Purple["600"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local instructionSurfaceSubtle: ColorToken = {
    Key = "InstructionSurfaceSubtle",
    Description = "A less important instruction surface, such as a tooltip.",
    Color = colorScales.Purple["700"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local instructionText: ColorToken = {
    Key = "InstructionText",
    Description = "Text drawn on top of an instruction surface, such as a tooltip.",
    Color = colorScales.WhiteGrey["100"],
    Transparency = 0,
    OverSurfaces = { instructionSurface },
}

local instructionTextSubtle: ColorToken = {
    Key = "InstructionTextSubtle",
    Description = "For less important secondary or repeated label text on an instruction surface, such as a tooltip.",
    Color = colorScales.Purple["100"],
    Transparency = 0,
    OverSurfaces = { instructionSurfaceSubtle },
}

local instructionOutline: ColorToken = {
    Key = "InstructionOutline",
    Description = "The outline color of an instruction surface.",
    Color = colorScales.Purple["300"],
    Transparency = 0,
    OverSurfaces = { instructionSurface },
}

local overlay: ColorToken = {
    Key = "Overlay",
    Description = "A semitransparent black veil.",
    Color = Color3.fromRGB(0, 0, 0),
    Transparency = 0,
    OverSurfaces = {},
}

local attentionLine: ColorToken = {
    Key = "AttentionLine",
    Description = "Attention line.",
    Color = colorScales.Yellow["500"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local attentionFill: ColorToken = {
    Key = "AttentionFill",
    Description = "Attention fill.",
    Color = colorScales.Yellow["500"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local attentionText: ColorToken = {
    Key = "AttentionText",
    Description = "Attention text.",
    Color = colorScales.Yellow["700"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local interactiveFill: ColorToken = {
    Key = "InteractiveFill",
    Description = "Interactive fill.",
    Color = colorScales.Blue["500"],
    Transparency = 0.3,
    OverSurfaces = { surface },
}

local defaultLine: ColorToken = {
    Key = "DefaultLine",
    Description = "The default stroke around a surface.",
    Color = colorScales.GreyBlue["100"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local interactiveLineSubtle: ColorToken = {
    Key = "InteractiveLineSubtle",
    Description = "A subtle interactive line.",
    Color = colorScales.Blue["400"],
    Transparency = 0.4,
    OverSurfaces = { surface },
}

local textSubdued: ColorToken = {
    Key = "TextSubdued",
    Description = "For less important secondary or repeated label text",
    Color = colorScales.WhiteGrey["600"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local textError: ColorToken = {
    Key = "TextError",
    Description = "Text to inform user of an error.",
    Color = colorScales.Red["600"],
    Transparency = 0,
    OverSurfaces = { surface },
}

local progressTrack = {
    StepStyle = {
        Attention = {
            Stroke = {
                Key = "Stroke",
                Description = "Attention step stroke style for ProgressTrack",
                Color = colorScales.Yellow["600"],
                Transparency = 0,
                OverSurfaces = { surface },
            },
            Fill = {
                Key = "Fill",
                Description = "Attention step fill style for ProgressTrack",
                Color = colorScales.Yellow["300"],
                Transparency = 0,
                OverSurfaces = { surface },
            },
            Text = {
                Key = "Text",
                Description = "Attention step text style for ProgressTrack",
                Color = colorScales.GreyBlue["800"],
                Transparency = 0,
                OverSurfaces = { surface },
            },
        },
        Tutorial = {
            Stroke = {
                Key = "Stroke",
                Description = "Tutorial step stroke style for ProgressTrack",
                Color = colorScales.Purple["500"],
                Transparency = 0,
                OverSurfaces = { surface },
            },
            Fill = {
                Key = "Fill",
                Description = "Tutorial step fill style for ProgressTrack",
                Color = colorScales.Purple["200"],
                Transparency = 0,
                OverSurfaces = { surface },
            },
            Text = {
                Key = "Text",
                Description = "Tutorial step text style for ProgressTrack",
                Color = colorScales.GreyBlue["800"],
                Transparency = 0,
                OverSurfaces = { surface },
            },
        },
        Default = {
            Stroke = {
                Key = "Stroke",
                Description = "Default step stroke style for ProgressTrack",
                Color = colorScales.GreyBlue["300"],
                Transparency = 0,
                OverSurfaces = { surface },
            },
            Fill = {
                Key = "Fill",
                Description = "Default step fill style for ProgressTrack",
                Color = colorScales.WhiteGrey["500"],
                Transparency = 0,
                OverSurfaces = { surface },
            },
            Text = {
                Key = "Text",
                Description = "Default step text style for ProgressTrack",
                Color = colorScales.GreyBlue["600"],
                Transparency = 0,
                OverSurfaces = { surface },
            },
        },
    },
}

return {
    Surface = surface,
    SurfaceInverted = surfaceInverted,
    Line = line,
    Text = text,
    TextInverted = textInverted,
    TextSubtle = textSubtle,
    TextEmphasized = textEmphasized,
    WarningText = warningText,
    InteractiveText = interactiveText,
    InteractiveTextEmphasized = interactiveTextEmphasized,
    InteractiveLine = interactiveLine,
    InteractiveLineEmphasized = interactiveLineEmphasized,
    LineSubtle = lineSubtle,
    InteractiveSurface = interactiveSurface,
    InteractiveSurfaceSubtle = interactiveSurfaceSubtle,
    InteractiveSurfaceGradientA1 = interactiveSurfaceGradientA1,
    InteractiveSurfaceGradientA2 = interactiveSurfaceGradientA2,
    InteractiveSurfaceGradientB1 = interactiveSurfaceGradientB1,
    InteractiveSurfaceGradientB2 = interactiveSurfaceGradientB2,
    InteractiveSurfaceText = interactiveSurfaceText,
    DisabledSurface = disabledSurface,
    DisabledSurfaceText = disabledSurfaceText,
    DisabledLine = disabledLine,
    InstructionSurface = instructionSurface,
    InstructionSurfaceSubtle = instructionSurfaceSubtle,
    InstructionText = instructionText,
    InstructionTextSubtle = instructionTextSubtle,
    InstructionOutline = instructionOutline,
    Overlay = overlay,
    AttentionLine = attentionLine,
    attentionFill = attentionFill,
    AttentionText = attentionText,
    ProgressTrack = progressTrack,
    InteractiveFill = interactiveFill,
    DefaultLine = defaultLine,
    InteractiveLineSubtle = interactiveLineSubtle,
    TextSubdued = textSubdued,
    TextError = textError,
}
