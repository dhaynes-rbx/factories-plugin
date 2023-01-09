local Packages = script.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Column = FishBloxComponents.Column
local TextInput = FishBloxComponents.TextInput
local Text = FishBloxComponents.Text
local Button = FishBloxComponents.Button
local Panel = FishBloxComponents.Panel
local Overlay = FishBloxComponents.Overlay
local Scene = require(script.Parent.Parent.Scene)

type Props = {
    
}

local function boxGizmo(machine)
    return React.createElement("BoxHandleAdornment", {
        AdornCullingMode = Enum.AdornCullingMode.Never,
        AlwaysOnTop = true,
        Color3 = Color3.new(0, 1, 0),
    })
end

local function ConnectionGizmos(props: Props)

    local gizmos = {}
    -- local boxes = {}
    -- local machineAnchors = Scene.getMachineAnchors()
    -- for _,machineAnchor in machineAnchors do
    --     local sources = machine["sources"]
    --     local outputs = machine["outputs"]
    --     if sources then
    --         for _,source in sources do
                
    --         end
    --     end
    -- end

    
    return React.createElement("Folder", {
        Name = "Connection Gizmos",
    }, gizmos)
end

return function(props)
    return ConnectionGizmos(props)
end