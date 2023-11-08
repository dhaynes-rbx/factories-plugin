local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")

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

function SceneConfig.replaceDatasetInstance(datasetInstance)
    local folder = getOrCreateFolder("SceneConfig", game.Workspace)
    local datasetFolder = getOrCreateFolder("Dataset", folder)
    if #datasetFolder:GetChildren() then
        datasetFolder:ClearAllChildren()
    end
    datasetInstance.Parent = datasetFolder
end

function SceneConfig.getDatasetInstance()
    local datasetFolder = Utilities.getValueAtPath(game.Workspace, "SceneConfig.Dataset")
    if datasetFolder then
        return datasetFolder:GetChildren()[1]
    end
    return nil
end

function SceneConfig.checkIfDatasetInstanceExists()
    local instance = SceneConfig.getDatasetInstance()
    if instance then
        return true
    else
        return false
    end
end

function SceneConfig.getDatasetInstanceAsTable()
    local str = SceneConfig.getDatasetInstance().Source
    return HttpService:JSONDecode(string.sub(str, #"return [[" + 1, #str - 2))
end

function SceneConfig.instantiateNewDatasetInstance()
    local file = StudioService:PromptImportFile()
    if not file then
        return nil
    end
    
    local newDatasetInstance = Instance.new("ModuleScript")
    newDatasetInstance.Source = "return [["..file:GetBinaryContents().."]]"
    
    newDatasetInstance.Name = file.Name:split(".")[1]
    newDatasetInstance.Parent = game.Workspace
    SceneConfig.replaceDatasetInstance(newDatasetInstance)

    return SceneConfig.getDatasetInstanceAsTable(), newDatasetInstance
end

function SceneConfig.updateDatasetInstance(dataset:table)
    local datasetInstance = SceneConfig.getDatasetInstance()
    datasetInstance.Source = "return [["..HttpService:JSONEncode(dataset).."]]"
end

function SceneConfig.getDatasetInstanceName()
    local dataset = SceneConfig.getDatasetInstance()
    if dataset then
        local str = dataset.Name:split("_")
        return str[#str]
    end
    return nil
end

--TODO: Make it so that you can change the name of the dataset
function SceneConfig.setDatasetInstanceName(name)
    SceneConfig.getDatasetInstance().Name = name
end

return SceneConfig