local getOrCreateFolder = require(script.Parent.Helpers.getOrCreateFolder)
local Dash = require(script.Parent.Packages.Dash)

local MapData = {}

function MapData.write(mapData:table)
    local folder = getOrCreateFolder("MapData", game.Workspace)
    folder:ClearAllChildren()
    local moduleScript = Instance.new("ModuleScript")
    moduleScript.Source = "return "..Dash.pretty(mapData, {multiline = true, indent = "\t", depth = 10, noQuotes = false})
    -- print(Dash.pretty(mapData, {multiline = true, indent = "\t", depth = 10, noQuotes = false}))
    moduleScript.Name = "MapData"
    moduleScript.Parent = folder
end

return MapData