local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Selection = game:GetService("Selection")
local StudioService = game:GetService("StudioService")

local Root = script.Parent.Parent
local Packages = Root.Packages

-- local Utilities = require(Packages.Utilities)
local Dash = require(Packages.Dash)

local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Block = FishBloxComponents.Block
local Column = FishBloxComponents.Column
local Text = FishBloxComponents.Text
local Icon = FishBloxComponents.Icon
local Row = FishBloxComponents.Row
local Panel = FishBloxComponents.Panel
local Button = FishBloxComponents.Button
local TextInput = FishBloxComponents.TextInput

local ConnectionGizmos = require(script.Parent.ConnectionGizmos)
local EditDatasetUI = require(script.Parent.EditDatasetUI)
local EditFactoryUI = require(script.Parent.EditFactoryUI)
local EditItemsListUI = require(script.Parent.EditItemsListUI)
local EditItemUI = require(script.Parent.EditItemUI)
local EditMachineUI = require(script.Parent.EditMachineUI)
local ConfirmationModal = require(script.Parent.Modals.ConfirmationModal)
local MachineAnchorBillboardGuis = require(script.Parent.MachineAnchorBillboardGuis)
local ImageSelectorUI = require(script.Parent.ImageSelectorUI)


local Constants = require(script.Parent.Parent.Constants)
local Dataset = require(script.Parent.Parent.Dataset)
-- local Input = require(script.Parent.Parent.Input)
local Panels = Constants.Panels
local Scene = require(script.Parent.Parent.Scene)
local DatasetInstance = require(script.Parent.Parent.DatasetInstance)
local Studio = require(script.Parent.Parent.Studio)

local App = React.Component:extend("PluginGui")

local add = require(script.Parent.Parent.Helpers.add)
local Manifest = require(script.Parent.Parent.Manifest)
local FactoryFloor = require(script.Parent.FactoryFloor)


function App:setPanel()
    Studio.setSelectionTool()
    self:setState({
        currentPanel = self.state.panelStack[#self.state.panelStack],
        showModal = false,
        highlightedMachineAnchor = React.None,
    })
end

function App:changePanel(panelId)

    Studio.setSelectionTool()
    if panelId == self.state.panelStack[#self.state.panelStack] then
        return
    end
    if panelId == Panels.EditDatasetUI then
        table.clear(self.state.panelStack)
    end
    table.insert(self.state.panelStack, panelId)
    self:setPanel()
end

function App:showPreviousPanel()
    local stack = self.state.panelStack
    table.remove(stack, #stack)
    self:setPanel()
end

function App:init()
    Studio.setSelectionTool()
    
    local dataset = "NONE"
    local datasetIsLoaded = false
    local currentMap = nil
    --If the map index has been saved as an attribute, load this map when reloading the plugin.
    -- local currentMapIndex = (game.Workspace:FindFirstChild("Dataset") and game.Workspace.Dataset:GetAttribute("CurrentMapIndex")) or 1
    local currentMapIndex = 2
    if DatasetInstance.checkIfDatasetInstanceExists() then
        dataset = Dataset:getDataset()
        if not dataset then
            warn("Dataset error!") --TODO: Find out why sometimes the DatasetInstance source gets deleted.
        else
            datasetIsLoaded = true
            currentMap = dataset["maps"][currentMapIndex]
            Dataset:updateDataset(dataset, currentMapIndex)
        end
    else
        Scene.loadScene()
        --if there's no scene and no dataset instance, then load everything.
        local templateDataset, newDatasetInstance = DatasetInstance.loadTemplateDataset()
        
        if not newDatasetInstance then
            return
        end
        --if for some reason the dataset is deleted, then make sure that the app state reflects that.
        newDatasetInstance.AncestryChanged:Connect(function(_,_)
            self:setState({dataset = "NONE", datasetIsLoaded = false})
        end)
        
        currentMap = templateDataset["maps"][currentMapIndex]
        self:muteMachineDeletionConnection()
        Scene.updateAllMapAssets(currentMap)
        self:setState({datasetIsLoaded = true})
        self:updateDataset(templateDataset)
    end

    local currentPanel = Panels.EditDatasetUI
    self:setState({
        currentMap = currentMap, --TODO: remove this, use index instead
        currentMapIndex = currentMapIndex,
        currentPanel = currentPanel,
        datasetError = Constants.Errors.None,
        dataset = dataset,
        datasetIsLoaded = datasetIsLoaded,
        highlightedMachineAnchor = nil,
        modalCancellationCallback = Dash.noop(),
        modalConfirmationCallback = Dash.noop(),
        modalTitle = "",
        panelStack = {currentPanel},
        selectedItem = nil,
        selectedMachine = nil,
        selectedMachineAnchor = nil,
        showModal = false,
    })
    
    self.connections = {}    
end

--TODO: Anything that modifies the dataset should be done via the Dataset class. Currently the dataset is being modified here
--and passed around. This could cause problems down the road.
function App:updateDataset(dataset)
    Dataset:updateDataset(dataset, self.state.currentMapIndex)
    -- Scene.updateAllConveyorBelts(dataset["maps"][self.state.currentMapIndex])
    self:setState({
        dataset = dataset,
        datasetError = Dataset:checkForErrors(),
    })
end

function App:updateConnections()
    -- if not self.state.datasetIsLoaded then return end
    -- if self.connections["Selection"] then
    --     self.connections["Selection"]:Disconnect()
    -- end
    -- self.connections["Selection"] = Input.listenForMachineSelection(self.state.currentMap, function(machine, selectedObj)
    --     self:setState({
    --         selectedMachineAnchor = selectedObj,
    --         selectedMachine = machine,
    --     })
    --     if machine then
    --         self:changePanel(Panels.EditMachineUI)
    --     end
    -- end)

    -- if self.connections["MachineInput"] then
    --     self.connections["MachineInput"]:Disconnect()
    -- end
    -- self.connections["MachineInput"] = Input.listenForMachineDrag(
    --     self.state.currentMap,
    --     function()
    --         self:updateDataset(self.state.dataset)
    --     end
    -- )

    -- if self.connections["MachineAnchorDeletion"] then
    --     self.connections["MachineAnchorDeletion"]:Disconnect()
    -- end
    -- self.connections["MachineAnchorDeletion"] = Input.listenForMachineAnchorDeletion(
    --     function()
    --         self:setState({
    --             showModal = true,
    --             modalTitle = "Would you like to delete "..self.state.selectedMachine["id"].."from the dataset?",
    --             modalConfirmationCallback = function()
    --                 Dataset:removeMachine(self.state.selectedMachine["id"])
    --                 Scene.removeMachineAnchor(self.state.selectedMachine)
    --                 self:showPreviousPanel()
    --                 self:setState({showModal = false})
    --                 self:updateDataset(self.state.dataset)
    --             end,
    --             modalCancellationCallback = function()
    --                 Scene.instantiateMachineAnchor(self.state.selectedMachine)
    --                 self:setState({showModal = false})
    --                 self:updateDataset(self.state.dataset)
    --             end
    --         })
    --     end
    -- )

    -- if self.connections["MachineAnchorDuplication"] then
    --     self.connections["MachineAnchorDuplication"]:Disconnect()
    -- end
    -- self.connections["MachineAnchorDuplication"] = Input.listenForMachineDuplication(
    --     function(machineObj:table, selectedObj:Instance)
    --         if self.connections["Selection"] then
    --             self.connections["Selection"]:Disconnect()
    --         end

    --         self:setState({
    --             selectedMachine = machineObj,
    --             selectedMachineAnchor = selectedObj,
    --         })
    --         self:changePanel(Constants.EditDatasetUI)
    --         Selection:Set({selectedObj})
    --         Studio.setSelectionTool()
    --     end
    -- )
end

function App:muteMachineDeletionConnection()
    --mute the listener for the machine deletion.
    -- if self.connections and self.connections["MachineAnchorDeletion"] then
    --     self.connections["MachineAnchorDeletion"]:Disconnect()
    --     self.connections["MachineAnchorDeletion"] = nil
    -- end
end

function App:setCurrentMap(mapIndex)
    self:muteMachineDeletionConnection()

    local currentMap = self.state.dataset["maps"][mapIndex]
    self.state.currentMapIndex = mapIndex
    Scene.updateAllMapAssets(currentMap)
    self:updateDataset(self.state.dataset)
    self:setState({
        currentMapIndex = mapIndex, 
        currentMap = currentMap,
        selectedItem = nil,
        selectedMachine = nil,
        selectedMachineAnchor = nil,
        showModal = false
    })

    game.Workspace.Dataset:SetAttribute("CurrentMapIndex", mapIndex)
end

function App:render()
    Studio.setSelectionTool()

    if self.state.datasetIsLoaded then
        self:updateConnections()
    end

    return React.createElement("ScreenGui", {}, {
        TopBar = Block({
            BackgroundColor = Color3.fromRGB(32, 36, 42),
            Size = UDim2.new(1,0,0,42),
        }),
        PluginRoot = self.state.datasetIsLoaded and Block({
            PaddingLeft = 10,
            PaddingRight = 10,
            PaddingTop = 10,
            PaddingBottom = 10,
            Size = UDim2.new(1, 0, 1, -42),
            Position = UDim2.new(0,0,0,42),
            AutomaticSize = Enum.AutomaticSize.X
        }, {

            AddMachineButton = Block({
                AnchorPoint = Vector2.new(1, 1),
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundColor = Color3.fromRGB(27, 42, 53),
                Corner = UDim.new(0,24),
                Padding = 12,
                Position = UDim2.new(1, 0, 1, 0),
                Size = UDim2.new(0, 200,0, 50),
            }, {
                Button = Button({
                    Label = "Add Machine",
                    TextXAlignment = Enum.TextXAlignment.Center,
                    OnActivated = function()
                        local newMachine = Dataset:addMachine()
                        local anchor = Scene.instantiateMachineAnchor(newMachine)
                        self:setState({selectedMachine = newMachine, selectedMachineAnchor = anchor})
                        self:changePanel(Panels.EditMachineUI)
                        Selection:Set({anchor})
                        self:updateDataset(self.state.dataset)
                    end,
                })
            }),

            EditDatasetUI = (self.state.currentPanel == Panels.EditDatasetUI) and React.createElement(EditDatasetUI, {
                CurrentMap = self.state.currentMap,
                CurrentMapIndex = self.state.currentMapIndex,
                Dataset = self.state.dataset,
                Error = self.state.datasetError,
                
                Title = self.state.currentPanel,

                SetCurrentMap = function(mapIndex)
                    self:setCurrentMap(mapIndex)
                end,
                
                ShowEditFactoryUI = function()
                    self:changePanel(Panels.EditFactoryUI)
                end,

                ShowEditItemsListUI = function()
                    self:changePanel(Panels.EditItemsListUI)
                end,
                
                ExportDataset = function()
                    DatasetInstance.write(self.state.dataset)
                    local datasetInstance = DatasetInstance.getDatasetInstance()
                    local saveFile = datasetInstance:Clone()
                    saveFile.Source = string.sub(saveFile.Source, #"return [[" + 1, #saveFile.Source - 2)
                    saveFile.Name = saveFile.Name.."_TEMP_SAVE_FILE"
                    saveFile.Parent = datasetInstance.Parent
                    Selection:Set({saveFile})
                    local fileSaved = getfenv(0).plugin:PromptSaveSelection()
                    if fileSaved then
                        print("File saved")
                    end
                    Selection:Set({})
                    saveFile:Destroy()
                end,

                ImportDataset = function()
                    local dataset, newDatasetInstance = DatasetInstance.instantiateNewDatasetInstance()
                    
                    if not newDatasetInstance then
                        return
                    end
                    --if for some reason the dataset is deleted, then make sure that the app state reflects that.
                    newDatasetInstance.AncestryChanged:Connect(function(_,_)
                        self:setState({dataset = "NONE", datasetIsLoaded = false})
                    end)
                    
                    local currentMap = dataset["maps"][self.state.currentMapIndex]
                    self:setState({dataset = dataset, datasetIsLoaded = true, currentMap = currentMap})
                    self:muteMachineDeletionConnection()
                    Scene.updateAllMapAssets(currentMap)
                    self:updateDataset(dataset)
                end,

                UpdateDataset = function(dataset)
                    self:updateDataset(dataset)
                end,

                UpdateSceneName = function(name)
                    self.state.dataset["maps"][self.state.currentMapIndex]["scene"] = name
                    self:updateDataset(self.state.dataset)
                end,

                UpdateDatasetName = function(name)

                end
            }),

            EditFactoryUI = self.state.currentPanel == Panels.EditFactoryUI and React.createElement(EditFactoryUI, {
                CurrentMap = self.state.currentMap,
                Dataset = self.state.dataset,
                OnClosePanel = function()
                    self:showPreviousPanel()
                end,
                UpdateDataset = function(dataset) self:updateDataset(dataset) end,
            }, {}),

            -- EditMachinesListUI = self.state.currentPanel == Panels.EditMachinesListUI and EditMachinesListUI({
            --     CurrentMap = self.state.currentMap,
            --     Dataset = self.state.dataset,

            --     OnClosePanel = function()
            --         self:showPreviousPanel()
            --     end,
            --     UpdateDataset = function(dataset)
            --         self:updateDataset(dataset)
            --     end,
            --     OnMachineEditClicked = function(machine:table, machineAnchor:Instance)
            --         self:setState({selectedMachine = machine, selectedMachineAnchor = machineAnchor})
            --         self:changePanel(Panels.EditMachineUI)
            --         Selection:Set({machineAnchor})
            --     end,
            --     OnMachineDeleteClicked = function(machineId:string)
            --         local machineObj = Dataset:getMachineFromId(machineId)
            --         self:setState({
            --             showModal = true,
            --             selectedMachine = Dataset:getMachineFromId(machineId),
            --             modalConfirmationCallback = function()
            --                 if self.connections["MachineAnchorDeletion"] then
            --                     self.connections["MachineAnchorDeletion"]:Disconnect()
            --                 end
                            
            --                 Scene.removeMachineAnchor(machineObj)
            --                 Dataset:removeMachine(machineId)
            --                 self:setState({showModal = false})
            --                 self:updateDataset(self.state.dataset)
            --             end,
            --             modalCancellationCallback = function()
            --                 self:setState({
            --                     showModal = false,
            --                     selectedMachine = nil,
            --                     selectedMachineAnchor = nil,
            --                 })
            --             end,
            --             modalTitle = "Would you like to delete "..machineObj["id"].."?"
            --         })
            --     end,
            --     HighlightMachineAnchor = function(machine:table)
            --         if machine then
            --             local anchor = machine and Scene.getAnchorFromMachine(machine) or nil
            --             self:setState({highlightedMachineAnchor = anchor})
            --         else
            --             self:setState({highlightedMachineAnchor = React.None})
            --         end
                    
            --     end,
            -- }),
            
            EditMachineUI = self.state.currentPanel == Panels.EditMachineUI and React.createElement(EditMachineUI, {
                CurrentMap = self.state.currentMap,
                Dataset = self.state.dataset,
                Machine = self.state.selectedMachine,
                MachineAnchor = self.state.selectedMachineAnchor,

                AddMachineAnchor = function(machineObj)
                    Scene.addMachineAnchor(machineObj)
                end,
                OnClosePanel = function()
                    Selection:Set({})
                    self:showPreviousPanel()
                end,
                OnDeleteButtonClicked = function(title, callback)
                    self:setState({
                        showModal = true,
                        modalConfirmationCallback = function()
                            self:setState({showModal = false})
                            callback()
                        end,
                        modalCancellationCallback = function()
                            self:setState({showModal = false})
                        end,
                        modalTitle = title,
                    })
                end,
                OnOutputItemEditClicked = function(itemKey)
                    self:changePanel(Panels.EditItemUI)
                    self:setState({selectedItem = self.state.dataset["maps"][self.state.currentMapIndex]["items"][itemKey]})
                end,
                UpdateDataset = function(dataset)
                    self:updateDataset(dataset)
                end,
            }, {}),

            EditItemsListUI = self.state.currentPanel == Panels.EditItemsListUI and EditItemsListUI({
                CurrentMapIndex = self.state.currentMapIndex,
                Dataset = self.state.dataset,

                ShowEditItemPanel = function(itemKey)
                    self:changePanel(Panels.EditItemUI)
                    self:setState({selectedItem = self.state.dataset["maps"][self.state.currentMapIndex]["items"][itemKey]})
                end,
                OnClosePanel = function()
                    self:showPreviousPanel()
                end,
                UpdateDataset = function(dataset)
                    self:updateDataset(dataset)
                end,
                OnItemDeleteClicked = function(itemKey)
                    self:setState({
                        showModal = true,
                        selectedItem = self.state.dataset["maps"][self.state.currentMapIndex]["items"][itemKey],
                        modalConfirmationCallback = function()
                            Dataset:removeItem(itemKey)
                            self:setState({showModal = false})
                            self:updateDataset(self.state.dataset)
                        end,
                        modalCancellationCallback = function()
                            self:setState({showModal = false})
                        end,
                        modalTitle = "Do you want to remove "..itemKey.." from the dataset?"
                    })
                end
            }),

            EditItemUI = self.state.currentPanel == Panels.EditItemUI and EditItemUI({
                CurrentMapIndex = self.state.currentMapIndex,
                Dataset = self.state.dataset,
                Item = self.state.selectedItem,
                
                OnClosePanel = function()
                    self:showPreviousPanel()
                    self:setState({selectedItem = nil})
                end,
                OnDeleteRequirementClicked = function(title, callback)
                    self:setState({
                        showModal = true,
                        modalConfirmationCallback = function()
                            callback()
                            self:setState({
                                showModal = false,
                            })
                        end,
                        modalCancellationCallback = function()
                            self:setState({showModal = false})
                        end,
                        modalTitle = title,
                    })
                end,
                ShowEditItemPanel = function(itemKey)
                    self:changePanel(Panels.EditItemUI)
                    self:setState({selectedItem = self.state.dataset["maps"][self.state.currentMapIndex]["items"][itemKey]})
                end,
                ShowImageSelector = function()
                    self:changePanel(Panels.ImageSelectorUI)
                end,
                UpdateDataset = function(dataset)
                    self:updateDataset(dataset)
                end,
            }),
            ImageSelectorUI = self.state.currentPanel == Panels.ImageSelectorUI and ImageSelectorUI({
                OnClosePanel = function()
                    self:showPreviousPanel()
                    self:setState({selectedItem = nil})
                end,
                OnClick = function(imageKey)
                    local item = self.state.dataset["maps"][self.state.currentMapIndex]["items"][self.state.selectedItem["id"]]
                    item["thumb"] = imageKey
                    self:updateDataset(self.state.dataset)
                    self:showPreviousPanel()
                end,
            }),
            
            EditPowerupUI = nil,

            MachineBillboardGUIs = self.state.datasetIsLoaded and MachineAnchorBillboardGuis({
                Items = self.state.dataset["maps"][self.state.currentMapIndex]["items"],
                HighlightedAnchor = self.state.highlightedMachineAnchor
            }),

            ConfirmationModal = self.state.showModal and (self.state.selectedMachine or self.state.selectedItem) and ConfirmationModal({
                Title = self.state.modalTitle,
                OnConfirm = function()
                    self.state.modalConfirmationCallback()
                end,
                OnCancel = function()
                    self.state.modalCancellationCallback()
                end,
            }),

            FactoryFloor = FactoryFloor({
                Machines = self.state.dataset.maps[self.state.currentMapIndex].machines,
                OnMachineSelect = function(machine, selectedObj)
                        self:setState({
                            selectedMachineAnchor = selectedObj,
                            selectedMachine = machine,
                        })
                        if machine then
                            self:changePanel(Panels.EditMachineUI)
                        end
                    end,
                OnClearSelection = function()
                    self:setState({
                        selectedMachineAnchor = nil,
                        selectedMachine = nil,
                    })
                    self:changePanel(Panels.EditDatasetUI)
                end,
                UpdateMachinePositions = function()
                    self:updateDataset(self.state.dataset)
                end,
            }),
        })
    })
end

function App:componentWillUnmount()
    for _,v in self.connections do
        v:Disconnect()
        v = nil
    end
    table.clear(self.connections)
end

return App