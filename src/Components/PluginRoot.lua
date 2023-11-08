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
local Button = FishBloxComponents.Button

local ConnectionGizmos = require(script.Parent.ConnectionGizmos)
local EditDatasetUI = require(script.Parent.EditDatasetUI)
local EditFactoryUI = require(script.Parent.EditFactoryUI)
local EditItemsListUI = require(script.Parent.EditItemsListUI)
local EditItemUI = require(script.Parent.EditItemUI)
local EditMachinesListUI = require(script.Parent.EditMachinesListUI)
local EditMachineUI = require(script.Parent.EditMachineUI)
local EditPowerupsListUI = require(script.Parent.EditPowerupsListUI)
local InitializeFactoryUI = require(script.Parent.InitializeFactoryUI)
local ConfirmationModal = require(script.Parent.Modals.ConfirmationModal)
local MachineAnchorBillboardGuis = require(script.Parent.MachineAnchorBillboardGuis)
local ImageSelectorUI = require(script.Parent.ImageSelectorUI)

-- local ConveyorBelts = require(script.Parent.ConveyorBelts)

local Constants = require(script.Parent.Parent.Constants)
local Dataset = require(script.Parent.Parent.Dataset)
local Input = require(script.Parent.Parent.Input)
local Panels = Constants.Panels
local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Studio = require(script.Parent.Parent.Studio)

local PluginRoot = React.Component:extend("PluginGui")

local add = require(script.Parent.Parent.Helpers.add)
local Manifest = require(script.Parent.Parent.Manifest)


function PluginRoot:setPanel()
    Studio.setSelectionTool()
    self:setState({
        currentPanel = self.state.panelStack[#self.state.panelStack],
        showModal = false,
        highlightedMachineAnchor = React.None,
    })
end

function PluginRoot:changePanel(panelId)

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

function PluginRoot:showPreviousPanel()
    local stack = self.state.panelStack
    table.remove(stack, #stack)
    self:setPanel()
end

function PluginRoot:init()
    Studio.setSelectionTool()

    self.machinesAnchors = Scene.getMachineAnchors()
    
    local dataset = "NONE"
    local datasetIsLoaded = false
    local currentMap = nil
    local currentMapIndex = game.Workspace:GetAttribute("CurrentMapIndex") or 1 --Stash the index in an attribute for when you load/unload the plugin.
    if SceneConfig.getDatasetInstance() then
        dataset = SceneConfig.getDatasetInstanceAsTable()
        if not dataset then
            warn("Dataset error!") --TODO: Find out why sometimes the DatasetInstance source gets deleted.
        else
            datasetIsLoaded = true
            currentMap = dataset["maps"][currentMapIndex]
            Dataset:updateDataset(dataset, currentMapIndex)
        end
    end
    local currentPanel = not Scene.isLoaded() and Panels.InitializeFactoryUI or Panels.EditDatasetUI
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

function PluginRoot:updateDataset(dataset)
    SceneConfig.updateDatasetInstance(dataset)
    self:setState({
        dataset = dataset,
        datasetError = Dataset:checkForErrors(),
    })
    Dataset:updateDataset(SceneConfig.getDatasetInstanceAsTable(), self.state.currentMapIndex)
end

function PluginRoot:updateConnections()
    if not self.state.datasetIsLoaded then return end
    if self.connections["Selection"] then
        self.connections["Selection"]:Disconnect()
    end
    self.connections["Selection"] = Input.listenForMachineSelection(self.state.currentMap, function(machine, selectedObj)
        self:setState({
            selectedMachineAnchor = selectedObj,
            selectedMachine = machine,
        })
        if machine then
            self:changePanel(Panels.EditMachineUI)
        end
    end)

    if self.connections["MachineInput"] then
        self.connections["MachineInput"]:Disconnect()
    end
    self.connections["MachineInput"] = Input.listenForMachineDrag(
        self.state.currentMap,
        function()
            self:updateDataset(self.state.dataset)
        end
    )

    if self.connections["MachineAnchorDeletion"] then
        self.connections["MachineAnchorDeletion"]:Disconnect()
    end
    self.connections["MachineAnchorDeletion"] = Input.listenForMachineAnchorDeletion(
        function()
            self:setState({
                showModal = true,
                modalTitle = "Would you like to delete "..self.state.selectedMachine["id"].."from the dataset?",
                modalConfirmationCallback = function()
                    Dataset:removeMachine(self.state.selectedMachine["id"])
                    Scene.removeMachineAnchor(self.state.selectedMachine)
                    self:showPreviousPanel()
                    self:setState({showModal = false})
                    self:updateDataset(self.state.dataset)
                end,
                modalCancellationCallback = function()
                    Scene.instantiateMachineAnchor(self.state.selectedMachine)
                    self:setState({showModal = false})
                    self:updateDataset(self.state.dataset)
                end
            })
        end
    )

    if self.connections["MachineAnchorDuplication"] then
        self.connections["MachineAnchorDuplication"]:Disconnect()
    end
    self.connections["MachineAnchorDuplication"] = Input.listenForMachineDuplication(
        function(machineObj:table, selectedObj:Instance)
            if self.connections["Selection"] then
                self.connections["Selection"]:Disconnect()
            end

            self:setState({
                selectedMachine = machineObj,
                selectedMachineAnchor = selectedObj,
            })
            self:changePanel(Constants.EditDatasetUI)
            Selection:Set({selectedObj})
            Studio.setSelectionTool()
        end
    )
end

function PluginRoot:muteMachineDeletionConnection()
    --mute the listener for the machine deletion.
    if self.connections["MachineAnchorDeletion"] then
        self.connections["MachineAnchorDeletion"]:Disconnect()
        self.connections["MachineAnchorDeletion"] = nil
    end
end

function PluginRoot:setCurrentMap(mapIndex)
    self:muteMachineDeletionConnection()

    local currentMap = self.state.dataset["maps"][mapIndex]
    self.state.currentMapIndex = mapIndex
    self:updateDataset(self.state.dataset)
    Dataset:updateMap(currentMap) --Do this to make sure machineAnchor IDs get registered in the dataset.
    Scene.instantiateMapMachineAnchors(mapIndex)
    game.Workspace:SetAttribute("CurrentMapIndex", mapIndex)
    self:updateDataset(self.state.dataset)
    self:setState({
        currentMapIndex = mapIndex, 
        currentMap = currentMap,
        selectedItem = nil,
        selectedMachine = nil,
        selectedMachineAnchor = nil,
        showModal = false
    })
end

function PluginRoot:render()
    Studio.setSelectionTool()
    self:updateConnections()

    local mapName = self.state.currentMap and self.state.currentMap["id"] or ""

    return React.createElement("ScreenGui", {}, {
        PluginRoot = Block({
            PaddingLeft = 20,
            PaddingRight = 20,
            PaddingTop = 20,
            PaddingBottom = 20,
            Size = UDim2.new(1, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X
        }, {
            InitializeFactoryUI = (self.state.currentPanel == Panels.InitializeFactoryUI) and React.createElement(InitializeFactoryUI, {
                Dataset = self.state.dataset,
                OnInitializeScene = function()
                    Scene.loadScene()
                    self:changePanel(Panels.EditDatasetUI)
                end
            }, {}),

            AddMachineButton = self.state.datasetIsLoaded and Block({
                Size = UDim2.new(0, 200,0, 50),
                Position = UDim2.new(1, -25, 1, -50),
                AnchorPoint = Vector2.new(1, 0),
            }, {
                Button({
                Label = "Add Machine",
                AutomaticSize = Enum.AutomaticSize.XY,
                TextXAlignment = Enum.TextXAlignment.Center,
                OnActivated = function()
                    local newMachine = Dataset:addMachine()
                    local anchor = Scene.instantiateMachineAnchor(newMachine)
                    self:setState({selectedMachine = newMachine, selectedMachineAnchor = anchor})
                    self:changePanel(Panels.EditMachineUI)
                    Selection:Set({anchor})
                    self:updateDataset(self.state.dataset)
                end,
                
            })}),
            

            EditDatasetUI = (self.state.currentPanel == Panels.EditDatasetUI) and React.createElement(EditDatasetUI, {
                CurrentMap = self.state.currentMap,
                CurrentMapIndex = self.state.currentMapIndex,
                Dataset = self.state.dataset,
                Error = self.state.datasetError,
                
                Title = self.state.currentPanel..": "..mapName,

                SetCurrentMap = function(mapIndex)
                    self:setCurrentMap(mapIndex)
                end,
                
                ShowEditFactoryPanel = function()
                    self:changePanel(Panels.EditFactoryUI)
                end,

                ShowEditMachinesListUI = function()
                   self:changePanel(Panels.EditMachinesListUI)
                end,

                ShowEditItemsListUI = function()
                    self:changePanel(Panels.EditItemsListUI)
                end,

                ShowEditPowerupsListUI = function()
                    -- self:changePanel(Panels.EditPowerupsListUI)
                end,
                
                ExportDataset = function()
                    SceneConfig.updateDatasetInstance(self.state.dataset)
                    local datasetInstance = SceneConfig.getDatasetInstance()
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
                    local dataset, newDatasetInstance = SceneConfig.instantiateNewDatasetInstance()
                    
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
                    Scene.instantiateMapMachineAnchors(self.state.currentMapIndex)
                    self:updateDataset(dataset)
                end,

                UpdateDataset = function(dataset) 
                    self:updateDataset(dataset) 
                end,

                
            }),

            EditFactoryUI = self.state.currentPanel == Panels.EditFactoryUI and React.createElement(EditFactoryUI, {
                CurrentMap = self.state.currentMap,
                Dataset = self.state.dataset,
                OnClosePanel = function()
                    self:showPreviousPanel()
                end,
                UpdateDataset = function(dataset) self:updateDataset(dataset) end,
            }, {}),

            EditMachinesListUI = self.state.currentPanel == Panels.EditMachinesListUI and EditMachinesListUI({
                CurrentMap = self.state.currentMap,
                Dataset = self.state.dataset,

                OnClosePanel = function()
                    self:showPreviousPanel()
                end,
                UpdateDataset = function(dataset)
                    self:updateDataset(dataset)
                end,
                OnMachineEditClicked = function(machine:table, machineAnchor:Instance)
                    self:setState({selectedMachine = machine, selectedMachineAnchor = machineAnchor})
                    self:changePanel(Panels.EditMachineUI)
                    Selection:Set({machineAnchor})
                end,
                OnMachineDeleteClicked = function(machineId:string)
                    local machineObj = Dataset:getMachineFromId(machineId)
                    self:setState({
                        showModal = true,
                        selectedMachine = Dataset:getMachineFromId(machineId),
                        modalConfirmationCallback = function()
                            if self.connections["MachineAnchorDeletion"] then
                                self.connections["MachineAnchorDeletion"]:Disconnect()
                            end
                            
                            Scene.removeMachineAnchor(machineObj)
                            Dataset:removeMachine(machineId)
                            self:setState({showModal = false})
                            self:updateDataset(self.state.dataset)
                        end,
                        modalCancellationCallback = function()
                            self:setState({
                                showModal = false,
                                selectedMachine = nil,
                                selectedMachineAnchor = nil,
                            })
                        end,
                        modalTitle = "Would you like to delete "..machineObj["id"].."?"
                    })
                end,
                HighlightMachineAnchor = function(machine:table)
                    if machine then
                        local anchor = machine and Scene.getAnchorFromMachine(machine) or nil
                        self:setState({highlightedMachineAnchor = anchor})
                    else
                        self:setState({highlightedMachineAnchor = React.None})
                    end
                    
                end,
            }),
            
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
            
            -- EditPowerupsListUI = self.state.currentPanel == Panels.EditPowerupsListUI and EditPowerupsListUI({
            --     CurrentMap = self.state.currentMap,
            --     Dataset = self.state.dataset,
            --     OnClosePanel = function()
            --         self:showPreviousPanel()
            --     end,
            --     UpdateDataset = function(dataset)
            --         self:updateDataset(dataset) 
            --     end,
            -- }),
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

            -- ConveyorBelts = self.state.datasetIsLoaded and ConveyorBelts({
            --     CurrentMap = self.state.currentMap,
            -- }),

            -- ConnectionGizmos = self.state.datasetIsLoaded and ConnectionGizmos({
            --     CurrentMap = self.state.currentMap
            -- }),

            ConfirmationModal = self.state.showModal and (self.state.selectedMachine or self.state.selectedItem) and ConfirmationModal({
                Title = self.state.modalTitle,
                OnConfirm = function()
                    self.state.modalConfirmationCallback()
                end,
                OnCancel = function()
                    self.state.modalCancellationCallback()
                end,
            }),

            -- TempPanel = Panel({
            --     Position = UDim2.new(0, 500, 0, 0),
            -- })
        })
    })
end

function PluginRoot:componentWillUnmount()
    for _,v in self.connections do
        v:Disconnect()
        v = nil
    end
    table.clear(self.connections)
end

return PluginRoot