local FormatText = {}

FormatText.convertToIdText = function(text)
    local idText

    idText = text:gsub("[^%w_]+", ""):lower()

    return idText
end

return FormatText
