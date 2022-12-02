--!strict
-- Color Scales are for design reference
-- but are not meant to be used directly in components
local colorFromHex = require(script.Parent.Parent.Utilities.ColorFromHex)

local GreyBlue = {
    ["100"] = colorFromHex("6B7687"),
    ["200"] = colorFromHex("5E6877"),
    ["300"] = colorFromHex("4F5967"),
    ["400"] = colorFromHex("3E4551"),
    ["500"] = colorFromHex("2F353E"),
    ["600"] = colorFromHex("20242A"),
    ["700"] = colorFromHex("181B1F"),
    ["800"] = colorFromHex("0C0E10"),
}

local WhiteGrey = {
    ["100"] = colorFromHex("FFFFFF"),
    ["200"] = colorFromHex("F6F6F6"),
    ["300"] = colorFromHex("EBEBEB"),
    ["400"] = colorFromHex("DADADA"),
    ["500"] = colorFromHex("CBCBCB"),
    ["600"] = colorFromHex("BABABA"),
    ["700"] = colorFromHex("A6A5A5"),
    ["800"] = colorFromHex("8E8E8E"),
}

local Blue = {
    ["100"] = colorFromHex("CDEDFE"),
    ["200"] = colorFromHex("9DD6FD"),
    ["300"] = colorFromHex("6FBAF9"),
    ["400"] = colorFromHex("4F9FF3"),
    ["500"] = colorFromHex("2178ED"),
    ["600"] = colorFromHex("195AC6"),
    ["700"] = colorFromHex("1342A2"),
    ["800"] = colorFromHex("0E2F7F"),
    ["900"] = colorFromHex("0A2167"),
}

local Green = {
    ["100"] = colorFromHex("C7FACF"),
    ["200"] = colorFromHex("95F7AC"),
    ["300"] = colorFromHex("61E78D"),
    ["400"] = colorFromHex("3DD07B"),
    ["500"] = colorFromHex("14B364"),
    ["600"] = colorFromHex("109661"),
    ["700"] = colorFromHex("0D7B5B"),
    ["800"] = colorFromHex("076454"),
    ["900"] = colorFromHex("084E49"),
}

local Yellow = {
    ["100"] = colorFromHex("FFF3BB"),
    ["200"] = colorFromHex("FDEAA1"),
    ["300"] = colorFromHex("FADA76"),
    ["400"] = colorFromHex("F6CA56"),
    ["500"] = colorFromHex("F0B129"),
    ["600"] = colorFromHex("CA8E1F"),
    ["700"] = colorFromHex("A46F17"),
    ["800"] = colorFromHex("815310"),
    ["900"] = colorFromHex("693F0D"),
}

local Red = {
    ["100"] = colorFromHex("FDDBD5"),
    ["200"] = colorFromHex("FCB3AD"),
    ["300"] = colorFromHex("F58486"),
    ["400"] = colorFromHex("E96674"),
    ["500"] = colorFromHex("DD3C5A"),
    ["600"] = colorFromHex("B92C53"),
    ["700"] = colorFromHex("981F4B"),
    ["800"] = colorFromHex("771642"),
    ["900"] = colorFromHex("610F3C"),
}

local Purple = {
    ["100"] = colorFromHex("EBD8FC"),
    ["200"] = colorFromHex("D7B4F9"),
    ["300"] = colorFromHex("BA8CF0"),
    ["400"] = colorFromHex("9F6FE2"),
    ["500"] = colorFromHex("7A46D0"),
    ["600"] = colorFromHex("5C33AF"),
    ["700"] = colorFromHex("43248F"),
    ["800"] = colorFromHex("2E1871"),
    ["900"] = colorFromHex("20115B"),
}

return {
    GreyBlue = GreyBlue,
    WhiteGrey = WhiteGrey,
    Blue = Blue,
    Green = Green,
    Yellow = Yellow,
    Red = Red,
    Purple = Purple,
}
