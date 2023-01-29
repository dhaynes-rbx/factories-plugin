local Dataset = {}

Dataset.dataset = {}
Dataset.currentMap = {}

function Dataset:updateDataset(dataset, currentMapIndex)
    self.dataset = dataset
    self.currentMap = dataset["maps"][currentMapIndex]
    print(currentMapIndex)
end

function Dataset:removeItem(itemKey)
    local items = self.currentMap["items"]
end

return Dataset