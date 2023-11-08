local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")

local Packages = script.Parent.Packages
local Utilities = require(Packages.Utilities)

--TODO: Make this manage the config folder structure that holds dataset data
local DatasetInstance = {}

local function getOrCreateFolder(name:string, parent:Instance)
    local folder = parent:FindFirstChild(name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = parent
    end
    return folder
end

function DatasetInstance.replaceDatasetInstance(datasetInstance)
    local datasetFolder = getOrCreateFolder("Dataset", game.Workspace)
    if #datasetFolder:GetChildren() then
        datasetFolder:ClearAllChildren()
    end
    datasetInstance.Parent = datasetFolder
end

function DatasetInstance.getDatasetInstance()
    local datasetFolder = Utilities.getValueAtPath(game.Workspace, "Dataset")
    if datasetFolder then
        return datasetFolder:GetChildren()[1]
    end
    return nil
end
                                                                                    
function DatasetInstance.checkIfDatasetInstanceExists()
    local instance = DatasetInstance.getDatasetInstance()
    if instance then
        return true
    else
        return false
    end
end

function DatasetInstance.getDatasetInstanceAsTable()
    local str = DatasetInstance.getDatasetInstance().Source
    return HttpService:JSONDecode(string.sub(str, #"return [[" + 1, #str - 2))
end

function DatasetInstance.instantiateNewDatasetInstance()
    local file = StudioService:PromptImportFile()
    if not file then
        return nil
    end
    
    local newDatasetInstance = Instance.new("ModuleScript")
    newDatasetInstance.Source = "return [["..file:GetBinaryContents().."]]"
    
    newDatasetInstance.Name = file.Name:split(".")[1]
    newDatasetInstance.Parent = game.Workspace
    DatasetInstance.replaceDatasetInstance(newDatasetInstance)

    return DatasetInstance.getDatasetInstanceAsTable(), newDatasetInstance
end

function DatasetInstance.updateDatasetInstance(dataset:table)
    local datasetInstance = DatasetInstance.getDatasetInstance()
    datasetInstance.Source = "return [["..HttpService:JSONEncode(dataset).."]]"
end

function DatasetInstance.getDatasetInstanceName()
    local dataset = DatasetInstance.getDatasetInstance()
    if dataset then
        local str = dataset.Name:split("_")
        return str[#str]
    end
    return nil
end

--TODO: Make it so that you can change the name of the dataset
function DatasetInstance.setDatasetInstanceName(name)
    DatasetInstance.getDatasetInstance().Name = name
end

return DatasetInstance