local getTemplateItem = require(script.Parent.Components.Helpers.getTemplateItem)
local Dataset = {}

Dataset.dataset = {}
Dataset.currentMap = {}
Dataset.items = {}

function Dataset:updateDataset(dataset, currentMapIndex)
    self.dataset = dataset
    self.currentMap = dataset["maps"][currentMapIndex]
    self.items = self.currentMap["items"]
end

function Dataset:changeItemName(itemKey, newName)
    local items = self.items
    local oldName = items[itemKey]["id"]
    local newItem = table.clone(items[itemKey])
    newItem["id"] = newName
    items[newName] = newItem
    items[oldName] = nil
end

function Dataset:addItem()
    local items = self.items
    print("Items:", items)
    local newItem = getTemplateItem()
    items[newItem["id"]] = newItem
    print("New Item: ", newItem)
    return newItem
end

function Dataset:removeItem(itemKey)
    local items = self.items
    if not self.currentMap then
        self.currentMap = self.dataset["maps"][game.Workspace:GetAttribute("CurrentMapIndex")]
    end
    local machines = self.currentMap["machines"]

    --remove the item as an output from all machines.
    for _,machine in machines do
        local indexToRemove = 0
        for i,output in machine["outputs"] do
            if output == itemKey then
                indexToRemove = i
            end
        end
        table.remove(machine["outputs"], indexToRemove)
    end

    --remove the item as a requirement for all items
    for _,item in items do
        if not item["requirements"] then continue end
        local indexToRemove = 0
        for i,requirement in item["requirements"] do
            if requirement["itemId"] == itemKey then
                indexToRemove = i
            end
        end
        table.remove(item["requirements"], indexToRemove)
    end

    items[itemKey] = nil
end

return Dataset