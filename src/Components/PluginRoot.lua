local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Selection = game:GetService("Selection")
local StudioService = game:GetService("StudioService")

local Root = script.Parent.Parent
local Packages = Root.Packages

local Utilities = require(Packages.Utilities)
local Dash = require(Packages.Dash)

local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Block = FishBloxComponents.Block
local Column = FishBloxComponents.Column
local Text = FishBloxComponents.Text
local Icon = FishBloxComponents.Icon
local Row = FishBloxComponents.Row

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
        showModal = false
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
            print("Dataset error!") --TODO: Find out why sometimes the DatasetInstance source gets deleted.
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
        dataset = dataset,
        datasetIsLoaded = datasetIsLoaded,
        panelStack = {currentPanel},
        selectedItem = nil,
        selectedMachine = nil,
        selectedMachineAnchor = nil,
        showModal = false,
        modalConfirmationCallback = Dash.noop(),
        modalCancellationCallback = Dash.noop(),
        modalTitle = "",
    })
    
    self.connections = {}    
end

function PluginRoot:updateDataset(dataset)
    SceneConfig.updateDatasetInstance(dataset)
    self:setState({
        dataset = dataset,
    })
    Dataset:updateDataset(dataset, self.state.currentMapIndex)
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
        self:changePanel(Panels.EditMachineUI)
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

function PluginRoot:setCurrentMap(mapIndex)
    --mute the listener for the machine deletion.
    if self.connections["MachineAnchorDeletion"] then
        self.connections["MachineAnchorDeletion"]:Disconnect()
        self.connections["MachineAnchorDeletion"] = nil
    end

    local currentMap = self.state.dataset["maps"][mapIndex]
    self.state.currentMapIndex = mapIndex
    Scene.instantiateMapMachineAnchors(currentMap)
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
        Block({
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

            EditDatasetUI = (self.state.currentPanel == Panels.EditDatasetUI) and React.createElement(EditDatasetUI, {
                CurrentMap = self.state.currentMap,
                CurrentMapIndex = self.state.currentMapIndex,
                Dataset = self.state.dataset,
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
                    local fileSaved = getfenv(0).plugin:PromptSaveSelection()
                    if fileSaved then
                        print("File saved")
                    end
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
                    Scene.instantiateMapMachineAnchors(currentMap)
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
                OnMachineEditClicked = function(machine, machineAnchor)
                    self:setState({selectedMachine = machine, selectedMachineAnchor = machineAnchor})
                    self:changePanel(Panels.EditMachineUI)
                    Selection:Set({machineAnchor})
                end,
                OnMachineDeleteClicked = function()
                    -- self:setState({
                    --     showModal = true,
                    --     modalConfirmationCallback = function()
                    --         Dataset:removeMachine(self.state.selectedMachine["id"])
                    --         Scene.removeMachineAnchor(self.state.selectedMachine)
                    --         self:showPreviousPanel()
                    --         self:setState({showModal = false})
                    --         self:updateDataset(self.state.dataset)
                    --     end,
                    --     modalCancellationCallback = function()
                    --         Scene.instantiateMachineAnchor(self.state.selectedMachine)
                    --         self:setState({showModal = false})
                    --         self:updateDataset(self.state.dataset)
                    --     end
                    -- })
                end
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
                OnOutputItemDeleteClicked = function(title, callback)
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
                CurrentMap = self.state.currentMap,
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
                CurrentMap = self.state.currentMap,
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
                UpdateItem = function(itemKey)
                    self:setState({selectedItem = self.state.dataset["maps"][self.state.currentMapIndex]["items"][itemKey]})
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

            
            EditPowerupUI = nil,

            MachineBillboardGUIs = self.state.datasetIsLoaded and MachineAnchorBillboardGuis({
                Items = self.state.dataset["maps"][self.state.currentMapIndex]["items"]
            }),

            ConnectionGizmos = self.state.datasetIsLoaded and ConnectionGizmos({
                CurrentMap = self.state.currentMap
            }),

            ConfirmationModal = self.state.showModal and (self.state.selectedMachine or self.state.selectedItem) and ConfirmationModal({
                Title = self.state.modalTitle,
                OnConfirm = function()
                    self.state.modalConfirmationCallback()
                end,
                OnCancel = function()
                    self.state.modalCancellationCallback()
                end,
            })
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

-- buttons.InitializeSceneButton = not self.state.sceneIsLoaded and Button({
--     Label = "Initialize Scene",
--     OnActivated = function()
--         Scene.loadScene()
--         self:setState({sceneIsLoaded = Scene.isLoaded()})
--     end
-- }) or nil

-- buttons.AddMachineButton = self.state.sceneIsLoaded and Button({
--     Label = "Add Machine",
--     OnActivated = function()
--         print("Machine added")
--     end
-- }) or nil

-- for i,_ in ipairs(self.state.machines) do
--     table.insert(buttons, Button({Label = "Machine "..i}))
-- end

-- local panel = Panel({Size = UDim2.new(0, 300, 1, 0)}, buttons)

-- if not self.state.sceneIsLoaded then
    --     children.InitializeSceneButton = Button({
    --         Label = "Initialize Scene",
    --         OnActivated = function()
    --             Scene.loadScene()
    --             self:setState({sceneIsLoaded = Scene.isLoaded()})
    --         end
    --     })
    -- end

    -- if self.state.sceneIsLoaded then 
    --     children.InitializeSceneButton = Button({
    --         Label = "Add Machine",
    --         OnActivated = function()
    --             print("Machine added")
    --         end
    --     })
    -- end
    
    -- children.Panel.Column = Column({
        --     Size = UDim2.fromScale(1, 0),
    --     AutomaticSize = Enum.AutomaticSize.Y,
    --     -- Gaps = theme.Tokens.Sizes.Registered.Small.Value,
    --     HorizontalAlignment = Enum.HorizontalAlignment.Center,
    --     VerticalAlignment = Enum.VerticalAlignment.Top,
    --     -- ZIndex = self.props.ZIndex,
    -- })
    
    -- if not self.state.sceneIsLoaded then
    --     children.Panel.Column.InitializeScene = React.createElement("TextButton", {
    --         Text = "Intialize Scene",
    --         TextColor3 = Color3.fromRGB(0, 0, 0),
    --         TextSize = 14,
    --         BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    --         Size = self.state.buttonSize,
    --         [React.Event.MouseButton1Click] = function()
    --             Scene.loadScene()
    --             self:setState({sceneIsLoaded = Scene.isLoaded()})
    --         end
    --     })
    -- end

    -- if self.state.sceneIsLoaded then
    --     children.Panel.Column.CreateMachine = React.createElement("TextButton", {
    --         Text = "Create Machine",
    --         TextColor3 = Color3.fromRGB(0, 0, 0),
    --         TextSize = 14,
    --         BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    --         Size = self.state.buttonSize,
    --         [React.Event.MouseButton1Click] = function()
    --             Scene.loadScene()
    --         end
    --     })

    --     local butt = React.createElement(Button, {Size = self.state.buttonSize})
    --     children.Panel.Column.TestButton = Block({Size = self.state.buttonSize}, butt)
    -- end
    