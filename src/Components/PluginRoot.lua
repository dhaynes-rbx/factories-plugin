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

local ConnectionGizmos = require(script.Parent.ConnectionGizmos)
local EditDatasetUI = require(script.Parent.EditDatasetUI)
local EditFactoryUI = require(script.Parent.EditFactoryUI)
local EditItemsListUI = require(script.Parent.EditItemsListUI)
local EditItemUI = require(script.Parent.EditItemUI)
local EditMachinesListUI = require(script.Parent.EditMachinesListUI)
local EditMachineUI = require(script.Parent.EditMachineUI)
local EditPowerupsListUI = require(script.Parent.EditPowerupsListUI)
local InitializeFactoryUI = require(script.Parent.InitializeFactoryUI)
local Modal = require(script.Parent.Modal)

local Constants = require(script.Parent.Parent.Constants)
local Input = require(script.Parent.Parent.Input)
local Panels = Constants.Panels
local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Studio = require(script.Parent.Parent.Studio)

local PluginRoot = React.Component:extend("PluginGui")

local add = require(script.Parent.Helpers.add)
local getCoordinatesFromAnchorName = require(script.Parent.Helpers.getCoordinatesFromAnchorName)
local getMachineFromCoordinates = require(script.Parent.Helpers.getMachineFromCoordinates)

function PluginRoot:setPanel()
    self:setState({currentPanel = self.state.panelStack[#self.state.panelStack]})
    Studio.setSelectionTool()
end

function PluginRoot:changePanel(panelId)
    if panelId == self.state.panelStack[#self.state.panelStack] then
        Studio.setSelectionTool()
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
    local machines = nil
    local items = nil
    local powerups = nil
    if SceneConfig.getDatasetInstance() then
        dataset = SceneConfig.getDatasetAsTable()
        if not dataset then
            print("Dataset error!") --TODO: Find out why sometimes the DatasetInstance source gets deleted.
        else
            datasetIsLoaded = true
            currentMap = dataset["maps"][currentMapIndex] --TODO: Make functionality to toggle between maps.
            machines = currentMap["machines"]
            items = currentMap["items"]
            powerups = currentMap["powerups"]
        end
    end
    local currentPanel = not Scene.isLoaded() and Panels.InitializeFactoryUI or Panels.EditDatasetUI
    self:setState({
        currentMap = currentMap, --TODO: remove this, use index instead
        currentMapIndex = currentMapIndex,
        currentPanel = currentPanel,
        dataset = dataset,
        datasetIsLoaded = datasetIsLoaded,
        items = items,
        machines = machines,
        panelStack = {currentPanel},
        powerups = powerups,
        selectedItem = nil,
        selectedMachine = nil,
        selectedMachineAnchor = nil,
    })
    
    --Setup the machine selection. If you select a machine in the world, then the EditMachineUI should be displayed.
    --Otherwise, revert to EditFactoryUI.
    local onSelectionChanged = function()
        if #Selection:Get() >= 1 then
            local selectedObj = Selection:Get()[1]
            if SceneConfig.checkIfDatasetInstanceExists() and Scene.isMachineAnchor(selectedObj) then
                local x,y = getCoordinatesFromAnchorName(selectedObj.Name)
                local machine = getMachineFromCoordinates(x, y, self.state.currentMap)
                --If we set selectedMachine to nil, then it will not trigger a re-render for the machine prop.
                if not machine then 
                    machine = React.None 
                end
                self:setState({
                    selectedMachine = machine,
                    selectedMachineAnchor = selectedObj
                })
                self:changePanel(Panels.EditMachineUI)
            end
        end
    end
    
    self.connections = {}
    self.connections["Selection"] = Selection.SelectionChanged:Connect(onSelectionChanged)
end

function PluginRoot:updateDataset(dataset)
    SceneConfig.updateDataset(dataset)
    self:setState({
        dataset = dataset,
    })
end

function PluginRoot:render()
    Studio.setSelectionTool()

    if self.connections["MachineInput"] then
        self.connections["MachineInput"]:Disconnect()
    end
    self.connections["MachineInput"] = Input.listenForMachineMouseInput(
        self.state.currentMap,
        function()
            self:updateDataset(self.state.dataset)
        end)

    local billboardGuis = {}
    local datasetIsLoaded = self.state.dataset ~= nil and self.state.dataset ~= "NONE"
    if datasetIsLoaded then

        for _,machineAnchor in Scene.getMachineAnchors() do
            local x,y = getCoordinatesFromAnchorName(machineAnchor.Name)
            
            local machine = getMachineFromCoordinates(x, y, self.state.currentMap)
            if machine then
                local outputsString = ""
                for i,output in machine["outputs"] do
                    local separator = i > 1 and ", " or ""
                    outputsString = outputsString..separator..output
                end
                add(billboardGuis, React.createElement("BillboardGui", {
                    Adornee = machineAnchor,
                    AlwaysOnTop = true,
                    Size = UDim2.new(0, 150, 0, 100),
                }, {
                    Column = Column({
                        AutomaticSize = Enum.AutomaticSize.Y,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center
                    }, {
                        Text1 = Text({
                            Color = Color3.new(1,1,1),
                            FontSize = 16,
                            LayoutOrder = 1,
                            Text = machine["id"]
                        }),
                        Text2 = Text({
                            Color = Color3.new(1,1,1),
                            FontSize = 16,
                            LayoutOrder = 2,
                            Text = "Makes: "..outputsString,
                        }),
                        Text3 = Text({
                            Color = Color3.new(1,1,1),
                            FontSize = 16,
                            LayoutOrder = 3,
                            Text = "("..x..","..y..")"
                        }),
                    })
                }))
            end
        end
    end

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

                SetCurrentMap = function(val)
                    local currentMap = self.state.dataset["maps"][val]
                    self:setState({currentMapIndex = val, currentMap = currentMap})
                    Scene.instantiateAllMachineAnchors(currentMap)
                    game.Workspace:SetAttribute("CurrentMapIndex", val)
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
                    SceneConfig.updateDataset(self.state.dataset)
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
                    saveFile:Destroy()
                end,

                ImportDataset = function()
                    local dataset, newDatasetInstance = SceneConfig.importNewDataset()
                    
                    if not newDatasetInstance then
                        return
                    end
                    --if for some reason the dataset is deleted, then make sure that the app state reflects that.
                    newDatasetInstance.AncestryChanged:Connect(function(_,_)
                        self:setState({dataset = "NONE", datasetIsLoaded = false})
                    end)
                    
                    local currentMap = dataset["maps"][self.state.currentMapIndex]
                    self:setState({dataset = dataset, datasetIsLoaded = true, currentMap = currentMap})
                    Scene.instantiateAllMachineAnchors(currentMap)
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

                AddMissingMachineAnchor = function(machine)
                    local anchor = Scene.instantiateMachineAnchor(machine)
                    Selection:Set({anchor})
                end,
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
            }),

            EditItemUI = self.state.currentPanel == Panels.EditItemUI and EditItemUI({
                CurrentMap = self.state.currentMap,
                Dataset = self.state.dataset,
                Item = self.state.selectedItem,
                
                OnClosePanel = function()
                    self:showPreviousPanel()
                    self:setState({selectedItem = nil})
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

            MachineBillboardGUIs = React.createElement("Folder", {
                Name = "BillboardGUIs"
            }, billboardGuis),

            ConnectionGizmos = self.state.datasetIsLoaded and ConnectionGizmos({
                CurrentMap = self.state.currentMap
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
    