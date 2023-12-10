local getOrCreateFolder = require(script.Parent.Helpers.getOrCreateFolder)
local Dash = require(script.Parent.Packages.Dash)

local MapData = {}

function MapData.write(mapData:table, sceneName:string)
    local folder = getOrCreateFolder("MapData", game.Workspace)
    folder:ClearAllChildren()
    local moduleScript = Instance.new("ModuleScript")
    moduleScript.Source = "return "..Dash.pretty(mapData, {multiline = true, indent = "\t", depth = 10, noQuotes = false})
    moduleScript.Name = sceneName and sceneName.."-Data" or "MapData"
    moduleScript.Parent = folder
end

return MapData