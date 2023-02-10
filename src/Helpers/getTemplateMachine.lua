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
        -- sources = {}, --We should probably not have an empty table here, since it might confuse existing game logic. Not all machines have a source table.
        storage = {},
        coordinates = {
            X = -999,
            Y = -999
        },
        supportsPowerup = true,
        worldPosition = {
            X = -52.049,
            Y = 0.802,
            Z = 47.449,
        },
        machineAnchor = -1
    }
    return template
end