return function()
    local template = {
        thumb = "icon-none",
        id = "templateItem",
        requirements = {
            {
                count = 1,
                itemId = "currency"
            }
        },
        asset = "",
        locName = "Template Item"
    }
    return template
end