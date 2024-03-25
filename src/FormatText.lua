local FormatText = {}

FormatText.convertToIdText = function(text)
    local idText

    idText = text:gsub("[^%w_]+", ""):lower()

    return idText
end

FormatText.numbersOnly = function(value)
    if tonumber(value) then
        return value
    else
        return value:gsub("%D+", "")
    end
end

return FormatText
