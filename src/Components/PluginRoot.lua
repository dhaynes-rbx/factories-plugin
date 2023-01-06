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

local DebugUI = require(script.Parent.DebugUI)
local EditDatasetUI = require(script.Parent.EditDatasetUI)
local EditFactoryUI = require(script.Parent.EditFactoryUI)
local EditMachineUI = require(script.Parent.EditMachineUI)
local InitializeFactoryUI = require(script.Parent.InitializeFactoryUI)
local Modal = require(script.Parent.Modal)

local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Constants = require(script.Parent.Parent.Constants)
local Panels = Constants.Panels

local PluginRoot = React.Component:extend("PluginGui")

function PluginRoot:setCurrentPanel(panelId)
    self:setState({currentPanel = panelId})
    getfenv(0).plugin:SelectRibbonTool(Enum.RibbonTool.Select, UDim2.new())
end

function PluginRoot:init()
    getfenv(0).plugin:SelectRibbonTool(Enum.RibbonTool.Select, UDim2.new())

    self.machines = Scene.getMachines()
    
    local dataset = "NONE"
    if SceneConfig.getDatasetInstance() then
        dataset = SceneConfig.getDatasetAsTable()
    end
    self:setState({
        currentPanel = not Scene.isLoaded() and Panels.InitializeFactoryUI or Panels.EditDatasetUI,
        selectedMachineAnchor = nil,
        dataset = dataset
    })
    
    --Setup the machine selection. If you select a machine in the world, then the EditMachineUI should be displayed.
    --Otherwise, revert to EditFactoryUI.
    local onSelectionChanged = function()
        if #Selection:Get() >= 1 then
            local obj = Selection:Get()[1]
            if self.state.datasetIsLoaded and Scene.isMachine(obj) then
                self:setState({selectedMachineAnchor = obj})
                self:setCurrentPanel(Panels.EditMachineUI)
            end
        end
    end
    
    self.connections = {}
    table.insert(self.connections, Selection.SelectionChanged:Connect(onSelectionChanged))
end

function PluginRoot:render()

    --TODO: Figure out why the ribbon tool keeps getting set to None
    getfenv(0).plugin:SelectRibbonTool(Enum.RibbonTool.Select, UDim2.new())

    return React.createElement("ScreenGui", {}, {
        Block({
            PaddingLeft = 20,
            PaddingRight = 20,
            PaddingTop = 20,
            PaddingBottom = 90,
            Size = UDim2.new(1, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X
        }, {
            InitializeFactoryUI = (self.state.currentPanel == Panels.InitializeFactoryUI) and React.createElement(InitializeFactoryUI, {
                Dataset = self.state.dataset,
                OnInitializeScene = function()
                    Scene.loadScene()
                    self:setCurrentPanel(Panels.EditDatasetUI)
                end
                
            }, {}),

            EditDatasetUI = (self.state.currentPanel == Panels.EditDatasetUI) and React.createElement(EditDatasetUI, {
                Dataset = self.state.dataset,
                Title = self.state.currentPanel,
                
                ShowEditFactoryPanel = function()
                    print("Showing factory panel...")
                    self:setCurrentPanel(Panels.EditFactoryUI)
                end,

                ImportDataset = function()
                    local dataset, newDatasetInstance = SceneConfig.importNewDataset()
                    --if for some reason the dataset is deleted, then make sure that the app state reflects that.
                    newDatasetInstance.AncestryChanged:Connect(function(_,_)
                        self:setState({dataset = "NONE", datasetIsLoaded = false})
                    end)

                    self:setState({dataset = dataset, datasetIsLoaded = true})
                end,


                ExportDataset = function()
                    SceneConfig.updateDataset(self.state.dataset)
                    local saveFile = SceneConfig.getDatasetInstance()
                    Selection:Set({saveFile})
                    local fileSaved = getfenv(0).plugin:PromptSaveSelection()
                    if fileSaved then
                        print("File saved")
                    end
                end,
            }),

            EditFactoryUI = self.state.currentPanel == Panels.EditFactoryUI and React.createElement(EditFactoryUI, {
                Dataset = self.state.dataset,
                OnClosePanel = function()
                    self:setCurrentPanel(Panels.EditDatasetUI)
                end,
                UpdateDataset = function(dataset)
                    self:setState({dataset = dataset})
                    SceneConfig.updateDataset(dataset)
                end,
            }, {}),

            EditMachineUI = self.state.currentPanel == Panels.EditMachineUI and React.createElement(EditMachineUI, {
                Dataset = self.state.dataset,
                MachineAnchor = self.state.selectedMachineAnchor,
                OnClosePanel = function()
                    Selection:Set({})
                    self:setCurrentPanel(Panels.EditDatasetUI)
                end
            }, {}),
            
            EditProductListUI = nil,
            EditPowerupListUI = nil,
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
    