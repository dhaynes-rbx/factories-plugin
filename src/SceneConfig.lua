local Packages = script.Parent.Packages
local Utilities = require(Packages.Utilities)

--TODO: Make this manage the config folder structure that holds dataset data
local SceneConfig = {}

local function getOrCreateFolder(name:string, parent:Instance)
    local folder = parent:FindFirstChild(name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = parent
    end
    return folder
end

function SceneConfig.replaceDataset(obj)
    local folder = getOrCreateFolder("SceneConfig", game.Workspace)
    local datasetFolder = getOrCreateFolder("Dataset", folder)
    if #datasetFolder:GetChildren() then
        datasetFolder:ClearAllChildren()
    end
    obj.Parent = datasetFolder
end

function SceneConfig.getDatasetInstance()
    local datasetFolder = Utilities.getValueAtPath(game.Workspace, "SceneConfig.Dataset")
    if datasetFolder then
        return datasetFolder:GetChildren()[1]
    end
    return nil
end

function SceneConfig.getDatasetName()
    local dataset = SceneConfig.getDatasetInstance()
    if dataset then
        local str = dataset.Name:split("_")
        return str[#str]
    end
    return nil
end

return SceneConfig