--TODO: Make this manage the config folder structure that holds dataset data
local SceneConfig = {}

local function getOrCreateConfigFolders()
    local configFolder = game.Workspace:FindFirstChild("SceneConfig")
    if not configFolder then
        configFolder = Instance.new("Folder")
        configFolder.Name = "SceneConfig"
        configFolder.Parent = game.Workspace
    end
    return configFolder
end

function SceneConfig.updateDataset(obj)
    local folder = getOrCreateConfigFolders()
    obj.Parent = folder
end

return SceneConfig