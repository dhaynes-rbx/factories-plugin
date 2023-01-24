return function()
    local template = {
        id = "none",
        type = "maker",
        locName = "None",
        thumb = "",
        asset = "Assets.Machines.Machine-Default",
        defaultProductionDelay = 0,
        defaultMaxStorage = 100,
        state = "ready",
        currentOutputIndex = 1,
        currentOutputCount = 40,
        outputRange = {
            min = 0,
            max = 50
        },
        outputs = {},
        sources = {},
        storage = {},
        coordinates = {
            X = -1,
            Y = -1
        },
        supportsPowerup = true,
        worldPosition = {
            X = 0,
            Y = 0,
            Z = 0,
        }
    }
    return template
end