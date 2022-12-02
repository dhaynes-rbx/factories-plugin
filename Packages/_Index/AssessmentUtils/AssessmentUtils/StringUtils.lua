-- !strict
function firstToUpper(str: string): string
    return str:sub(1, 1):upper() .. str:sub(2)
end

function firstToLower(str: string): string
    return str:sub(1, 1):lower() .. str:sub(2)
end

function allFirstsToUpper(str: string): string
    local split: table = string.split(str, " ")
    for index: number, value: string in pairs(split) do
        split[index] = firstToUpper(value)
    end
    return table.concat(split, " ")
end

return {
    firstToUpper = firstToUpper,
    firstToLower = firstToLower,
    allFirstsToUpper = allFirstsToUpper,
}
