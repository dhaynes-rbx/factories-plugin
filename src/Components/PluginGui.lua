local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Block = FishBloxComponents.Block
local ThemeProvider = FishBloxComponents.ThemeProvider
local themes = FishBloxComponents.Themes
local Panel = FishBloxComponents.Panel

local EditFactoryUI = require(script.Parent.EditFactoryUI)
local EditMachineUI = require(script.Parent.EditMachineUI)
local InitializeFactoryUI = require(script.Parent.InitializeFactoryUI)

local Scene = require(script.Parent.Parent.Scene)

local PluginGui = React.Component:extend("PluginGui")

function PluginGui:init()
    self:setState({
        sceneIsLoaded = Scene.isLoaded(),
        buttonSize = UDim2.fromOffset(200, 50),
        machines = Scene.getMachines(),
        currentPanel = 0
    })
end

function PluginGui:render()

    local props = {
        sceneIsLoaded = not Scene.isLoaded(),
    }

    if self.state.sceneIsLoaded then 
        self:setState({currentPanel = 1})
    end

    return React.createElement("ScreenGui", {}, {
        InitializeFactoryUI = self.state.currentPanel == 0 and React.createElement(InitializeFactoryUI, {
            callback = function() 
                self:setState({currentPanel = 1})
                getfenv(0).plugin:SelectRibbonTool(Enum.RibbonTool.Select, UDim2.new())
            end
        }, {}),
        EditFactoryUI = self.state.currentPanel == 1 and React.createElement(EditFactoryUI, props, {}),
        EditMachineUI = self.state.currentPanel == 2 and React.createElement(EditMachineUI, props, {}),
        EditProductListUI = nil,
        EditPowerupListUI = nil
    })
end

return PluginGui

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
    