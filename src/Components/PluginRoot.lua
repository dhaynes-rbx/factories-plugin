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

local DebugUI = require(script.Parent.DebugUI)
local EditDatasetUI = require(script.Parent.EditDatasetUI)
local EditFactoryUI = require(script.Parent.EditFactoryUI)
local EditMachineUI = require(script.Parent.EditMachineUI)
local EditMachinesListUI = require(script.Parent.EditMachinesListUI)
local EditItemsListUI = require(script.Parent.EditItemsListUI)
local EditPowerupsListUI = require(script.Parent.EditPowerupsListUI)
local InitializeFactoryUI = require(script.Parent.InitializeFactoryUI)
local Modal = require(script.Parent.Modal)
local ConnectionGizmos = require(script.Parent.ConnectionGizmos)

local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Constants = require(script.Parent.Parent.Constants)
local Panels = Constants.Panels
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
    local machines = nil
    local items = nil
    local powerups = nil
    if SceneConfig.getDatasetInstance() then
        dataset = SceneConfig.getDatasetAsTable()
        if not dataset then
            print("Dataset error!") --TODO: Find out why sometimes the DatasetInstance source gets deleted.
        else
            datasetIsLoaded = true
            currentMap = dataset["maps"][2] --TODO: Make functionality to toggle between maps.
            machines = currentMap["machines"]
            items = currentMap["items"]
            powerups = currentMap["powerups"]
        end
    end
    local currentPanel = not Scene.isLoaded() and Panels.InitializeFactoryUI or Panels.EditDatasetUI
    self:setState({
        currentMap = currentMap,
        currentPanel = currentPanel,
        dataset = dataset,
        datasetIsLoaded = datasetIsLoaded,
        items = items,
        machines = machines,
        panelStack = {currentPanel},
        powerups = powerups,
        selectedMachineAnchor = nil,
    })
    
    --Setup the machine selection. If you select a machine in the world, then the EditMachineUI should be displayed.
    --Otherwise, revert to EditFactoryUI.
    local onSelectionChanged = function()
        if #Selection:Get() >= 1 then
            local obj = Selection:Get()[1]
            if SceneConfig.checkIfDatasetInstanceExists() and Scene.isMachine(obj) then
                self:setState({selectedMachineAnchor = obj})
                self:changePanel(Panels.EditMachineUI)
            end
        end
    end
    
    self.connections = {}
    table.insert(self.connections, Selection.SelectionChanged:Connect(onSelectionChanged))
end

function PluginRoot:updateDataset(dataset)
    SceneConfig.updateDataset(dataset)
    self:setState({dataset = dataset})
end

function PluginRoot:render()
    -- print("Dataset at beginning of render...", self.state.dataset)
    
    Studio.setSelectionTool()

    local billboardGuis = {}
    local datasetIsLoaded = self.state.dataset ~= nil and self.state.dataset ~= "NONE"
    if datasetIsLoaded then

        for _,machineAnchor in Scene.getMachineAnchors() do
            local x,y = getCoordinatesFromAnchorName(machineAnchor.Name)
            local map = self.state.dataset["maps"][2]
            local machine = getMachineFromCoordinates(x, y, map)
            local outputsString = ""
            for i,output in machine["outputs"] do
                local separator = i > 1 and ", " or ""
                outputsString = outputsString..separator..output
            end
            add(billboardGuis, React.createElement("BillboardGui", {
                Adornee = machineAnchor,
                AlwaysOnTop = true,
                Size = UDim2.new(0, 100, 0, 20),
            }, {
                Column = Column({
                    AutomaticSize = Enum.AutomaticSize.Y,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center
                }, {
                    Text = Text({
                        Color = Color3.new(1,1,1),
                        FontSize = 16,
                        LayoutOrder = 1,
                        Text = "("..x..","..y..")"
                    }),
                    Text2 = Text({
                        Color = Color3.new(1,1,1),
                        FontSize = 16,
                        LayoutOrder = 2,
                        Size = UDim2.fromOffset(0, 35),
                        Text = outputsString,
                    })
                })
            }))
        end
    end

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
                Dataset = self.state.dataset,
                Title = self.state.currentPanel..": "..self.state.currentMap["id"],
                
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
                    self:changePanel(Panels.EditPowerupsListUI)
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

                    local currentMap = dataset["maps"][2]
                    self:setState({dataset = dataset, datasetIsLoaded = true, currentMap = currentMap})
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
                OnMachineEditClicked = function(machineAnchor)
                    Selection:Set({machineAnchor})
                end
            }),

            EditItemsListUI = self.state.currentPanel == Panels.EditItemsListUI and EditItemsListUI({
                CurrentMap = self.state.currentMap,
                Dataset = self.state.dataset,
                OnClosePanel = function()
                    self:showPreviousPanel()
                end,
                UpdateDataset = function(dataset)
                    self:updateDataset(dataset)
                end,
            }),

            EditPowerupsListUI = self.state.currentPanel == Panels.EditPowerupsListUI and EditPowerupsListUI({
                CurrentMap = self.state.currentMap,
                Dataset = self.state.dataset,
                OnClosePanel = function()
                    self:showPreviousPanel()
                end,
                UpdateDataset = function(dataset)
                    self:updateDataset(dataset) 
                end,
            }),

            EditMachineUI = self.state.currentPanel == Panels.EditMachineUI and React.createElement(EditMachineUI, {
                Dataset = self.state.dataset,
                --TODO: Change this to take the machine data object as an input, not the anchor
                MachineAnchor = self.state.selectedMachineAnchor, 
                OnClosePanel = function()
                    Selection:Set({})
                    self:showPreviousPanel()
                end,
                UpdateDataset = function(dataset)
                    self:updateDataset(dataset)
                end,
            }, {}),
            
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
    