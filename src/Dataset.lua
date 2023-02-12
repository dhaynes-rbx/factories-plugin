local getTemplateItem = require(script.Parent.Helpers.getTemplateItem)
local getTemplateMachine = require(script.Parent.Helpers.getTemplateMachine)
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

--Returns items, minus the currency and none items
function Dataset:getValidItems(originalItems:table)
    local result = {}
    for k,v in originalItems do
        if v["id"] == "currency" or v["id"] == "none" then 
            continue 
        else
            result[v["id"]] = v
        end
    end
    return result
end

function Dataset:addMachine()
    local newMachine = getTemplateMachine()
    --TODO: check for duplicate id and coordinates
    table.insert(self.machines, newMachine)
    
    return newMachine
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

function Dataset:getMachineFromId(id)
    local machine = nil
    -- local num = 0
    for _,v in self.machines do
        if v["id"] == id then
            -- num = num + 1
            machine = v
        end
    end
    -- if num > 1 then
    --     assert(true, "ERROR! Duplicate machine id found in this map!")
    -- end
    return machine
end

--takes the MachineAnchor name as an input and returns X and Y coordinates.
function Dataset:getCoordinatesFromAnchorName(name)
    local x, y = table.unpack(string.split(string.sub(name, 2, #name - 1), ","))
    x = tonumber(x)
    y = tonumber(y)
    return x, y
end

--returns the machine data in the dataset, based on the coordinates provided
function Dataset:getMachineFromCoordinates(x, y)
    local machine = nil
    for _,v in self.machines do
        if v["coordinates"]["X"] == x and v["coordinates"]["Y"] == y then
            machine = v
        end
    end
    return machine
end

return Dataset