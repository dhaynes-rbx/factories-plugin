local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Packages = script.Parent.Parent.Packages
local Dash = require(Packages.Dash)
local React = require(Packages.React)
local Roact = require(Packages.Roact)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Block = FishBloxComponents.Block
local Button = FishBloxComponents.Button
local Column = FishBloxComponents.Column
local Gap = FishBloxComponents.Gap
local Panel = FishBloxComponents.Panel
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

local Modal = require(script.Parent.Modal)
local SmallButtonWithLabel = require(script.Parent.SmallButtonWithLabel)
local SmallLabel = require(script.Parent.SmallLabel)
local SidePanel = require(script.Parent.SidePanel)

local Scene = require(script.Parent.Parent.Scene)
local SceneConfig = require(script.Parent.Parent.SceneConfig)
local Studio = require(script.Parent.Parent.Studio)

local add = require(script.Parent.Helpers.add)
local getMachineFromCoordinates = require(script.Parent.Helpers.getMachineFromCoordinates)

type Props = {

}

local function EditItemsListUI(props: Props)

    local modalEnabled, setModalEnabled = React.useState(false)
    local currentFieldKey, setCurrentFieldKey = React.useState(nil)
    local currentFieldValue, setCurrentFieldValue = React.useState(nil)
    local currentFieldCallback, setCurrentFieldCallback = React.useState(nil)

    --use this to create a consistent layout order that plays nice with Roact
    local index = 0
    local getLayoutOrderIndex = function()
        index = index + 1
        return index
    end

    local map = props.CurrentMap

    local children = {}
    local items = map["items"]
    local itemKeys = Dash.keys(items)
    table.sort(itemKeys, function(a,b)  --Do this to make sure buttons show in alphabetical order
        return a:lower() < b:lower()
    end)
    for _,itemKey in itemKeys do
        add(children, Button({
            Label = itemKey,
            LayoutOrder = getLayoutOrderIndex(),
            OnActivated = function()
                props.ShowEditItemPanel(itemKey)
            end
        }))
    end

    return React.createElement(React.Fragment, nil, {
        SidePanel({
            Title = "Edit Items List",
            ShowClose = true,
            OnClosePanel = props.OnClosePanel,
        }, children),
        -- Modal = modalEnabled and Modal({
        --     Key = currentFieldKey,
        --     OnConfirm = function(value)
        --         currentFieldCallback(value)
        --         props.UpdateDataset(props.Dataset)
        --     end,
        --     OnClosePanel = function()
                -- setModalEnabled(false)
                -- setCurrentFieldKey(nil)
                -- setCurrentFieldValue(nil)
                -- setCurrentFieldCallback(nil)
            -- end,
            -- Value = currentFieldValue,
    })
end

return function(props)
    return React.createElement(EditItemsListUI, props)
end