local Types = require(script.Parent.Types)
local getTemplateItem = require(script.Parent.Helpers.getTemplateItem)
local getTemplateMachine = require(script.Parent.Helpers.getTemplateMachine)
local Constants = require(script.Parent.Constants)
local Root = script.Parent
local Packages = Root.Packages
local Dash = require(Packages.Dash)
local DatasetInstance = require(script.Parent.DatasetInstance)
local Scene = require(script.Parent.Scene)
local Dataset = {}

Dataset.dataset = {}
Dataset.currentMap = {}
Dataset.items = {}
Dataset.machines = {}

local function cleanMachines(machines:table, items:table)
    --Clean the machine sources, make sure that it is nil if there are no source ids. We do this because machines in Factories, "sources" might == nil.
    for _,machine in machines do
        if machine["sources"] and #machine["sources"] == 0 then
            machine["sources"] = nil
        end
    end

    for _,machine in machines do
        local machineType = Constants.MachineTypes.maker
        for _,itemId in machine["outputs"] do
            if items[itemId]["value"] then
                --If this machine has an output that has a value, then it's a makerSeller.
                machineType = Constants.MachineTypes.makerSeller
                --TODO: Check other machines to see if they use this machine as a source. If so, something is wrong.
            end
        end
        if machine["sources"] == nil then
            if machineType == Constants.MachineTypes.makerSeller then
                machineType = Constants.MachineTypes.invalid
            else
                machineType = Constants.MachineTypes.purchaser
            end
        end
        if machine["sources"] == nil and #machine["outputs"] == 0 then
            machineType = Constants.MachineTypes.invalid
        end
        machine["type"] = machineType

        if machineType == Constants.MachineTypes.makerSeller then
            machine["asset"] = Constants.MachineAssetPaths.makerSeller
        elseif machineType == Constants.MachineTypes.purchaser then
            machine["asset"] = Constants.MachineAssetPaths.purchaser
        else
            machine["asset"] = Constants.MachineAssetPaths.maker
        end
    end
end

function Dataset:checkForErrors()
    local datasetError = Constants.Errors.None
    --Check for duplicate IDs
    for _,machine in self.machines do
        if self:duplicateCoordinatesExist(machine.coordinates) then
            datasetError = Constants.Errors.DuplicateCoordinatesError
            warn(datasetError)
        end
        if machine["type"] == Constants.MachineTypes.invalid then
            datasetError = Constants.Errors.InvalidMachine
            warn(datasetError)
        end
    end
    return datasetError
end

function Dataset:getDataset()
    return DatasetInstance.read()
end

function Dataset:updateDataset(dataset, currentMapIndex)
    DatasetInstance.write(dataset)
    self.dataset = dataset
    self.currentMap = dataset["maps"][currentMapIndex]
    self.items = self.currentMap["items"]
    self.machines = self.currentMap["machines"]

    cleanMachines(self.machines, self.items)

end

function Dataset:getMap(mapIndex:number)
    return self.dataset["maps"][mapIndex]
end


function Dataset:changeItemId(itemKey, newName)
    --check for naming collisions
    newName = self:resolveDuplicateId(newName, self.items)

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

    --Loop through all items. Make sure if this new item is a requirement for another item, to change its id there too.
    for _,item in self.items do
        if item["requirements"] then
            for _,req in item["requirements"] do
                if req["itemId"] == oldName then
                    req["itemId"] = newName
                end
            end
        end
    end
    
    return newName
end

function Dataset:addItem()
    local items = self.items
    local newItem = getTemplateItem()
    local newItemId = self:resolveDuplicateId(newItem["id"], self.items)
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

function Dataset:resolveDuplicateId(idToCheck:string, tableToCheck:table)
    local dupeCounter = 0
    local function checkIds(id)
        local newId = id
        for _,item in tableToCheck do
            if item.id == id then
                dupeCounter = dupeCounter + 1
                newId = checkIds(idToCheck..tostring(dupeCounter))
            end
        end
        return newId
    end

    return checkIds(idToCheck)
end

function Dataset:resolveDuplicateCoordinates(coordinatesToCheck:{X:number, Y:number}, tableToCheck:table)
    local dupeCounter = 0
    local function checkCoords(coords)
        local newCoords = coords
        for _,machine:Types.Machine in tableToCheck do
            local dupeXFound = false
            local dupeYFound = false
            if machine.coordinates.X == coords.X then
                dupeXFound = true
            end
            if machine.coordinates.Y == coords.Y then
                dupeYFound = true
            end
            if dupeXFound and dupeYFound then
                dupeCounter = dupeCounter + 1
                newCoords = checkCoords({X = coords.X, Y = coords.Y + 1})
            end
        end
        return newCoords
    end
    return checkCoords(coordinatesToCheck)
end

function Dataset:duplicateCoordinatesExist(coordinatesToCheck:{X:number, Y:number})
    local dupeCounter = 0
    for _,machine in self.machines do
        local existingX = false
        local existingY = false
        if machine.coordinates.X == coordinatesToCheck.X then
            existingX = true
        end
        if machine.coordinates.Y == coordinatesToCheck.Y then
            existingY = true
        end
        if existingX and existingY then
            dupeCounter = dupeCounter + 1
        end
    end
    return dupeCounter > 1
end

function Dataset:addMachine()
    local newMachine = getTemplateMachine()
    -- check for duplicate id
    newMachine.id = self:resolveDuplicateId(newMachine.id, self.machines)
    newMachine.coordinates = self:resolveDuplicateCoordinates(newMachine.coordinates, self.machines)

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
    for _,v in self.machines do
        if v["id"] == id then
            machine = v
        end
    end
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
-- function Dataset:getMachineFromCoordinates(x, y)
--     local machine = nil
--     for _,v in self.machines do
--         if v["coordinates"]["X"] == x and v["coordinates"]["Y"] == y then
--             machine = v
--         end
--     end
--     return machine
-- end

return Dataset