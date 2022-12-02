--!strict
function colorFromHex(hex: string): Color3
    hex = hex:gsub("#", "")
    return Color3.new(
        tonumber("0x" .. hex:sub(1, 2)) / 255,
        tonumber("0x" .. hex:sub(3, 4)) / 255,
        tonumber("0x" .. hex:sub(5, 6)) / 255
    )
end

return colorFromHex