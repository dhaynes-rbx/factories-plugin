return function()
    local template = {
        id = "templateMachine",
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
            max = 50,
        },
        outputs = {},
        -- sources = {}, --We should probably not have an empty table here, since it might confuse existing game logic. Not all machines have a source table.
        storage = {},
        coordinates = {
            X = 0,
            Y = 0,
        },
        supportsPowerup = true,
        worldPosition = {
            X = -54.614,
            Y = 1.05,
            Z = 21.419,
        },
        machineAnchor = -1,
    }
    return template
end
