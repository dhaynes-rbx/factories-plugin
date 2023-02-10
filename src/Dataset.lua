local getTemplateItem = require(script.Parent.Components.Helpers.getTemplateItem)
local Dataset = {}

Dataset.dataset = {}
Dataset.currentMap = {}
Dataset.items = {}
Dataset.machines = {}

function Dataset:updateDataset(dataset, currentMapIndex)
    self.dataset = dataset
    self.currentMap = dataset["maps"][currentMapIndex]
    self.items = self.currentMap["items"]
    self.machines = self.currentMap["machines"]
end

function Dataset:changeItemId(itemKey, newName)
    local items = self.items
    local oldName = itemKey
    local newItem = table.clone(items[itemKey])
    newItem["id"] = newName
    items[newName] = newItem
    items[oldName] = nil

    local machines = self.machines
    for i,machine in machines do
        if machine["outputs"] then
            for j,output in machine["outputs"] do
                if output == oldName then
                    machines[i]["outputs"][j] = newName
                end
            end
        end
    end
end

function Dataset:addItem()
    local items = self.items
    local newItem = getTemplateItem()
    local newItemId = newItem["id"]
    
    local duplicateIdCount = 0
    for _,item in items do
        if string.match(item["id"], "templateItem") then
            duplicateIdCount += 1
        end
    end

    newItemId = duplicateIdCount > 0 and newItemId..tostring(duplicateIdCount) or newItemId
    newItem["id"] = newItemId
    items[newItemId] = newItem
    
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

function Dataset:removeMachine(machineKey)
    local machines = self.machines
    local indexToRemove = nil
    for i,machine in machines do
        if machine["id"] == machineKey then
            indexToRemove = i
        end
    end
    if indexToRemove then
        table.remove(machines, indexToRemove)
    end
end

function Dataset:getMachineFromMachineAnchor(machineAnchor:Instance)
    local debugId = machineAnchor:GetAttribute("debugId")
    local counter = 0
    local machine = nil
    for _,machineObj in self.machines do
        if machineObj["machineAnchor"] and machineObj["machineAnchor"] == debugId then
            machine = machineObj
            counter += 1
        end
    end

    if counter > 1 then
        print("Error! More than one machine refers to this anchor!")
    end

    return machine
end

return Dataset