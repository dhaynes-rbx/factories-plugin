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
    local valueType, setValueType = React.useState(nil)

    --use this to create a consistent layout order that plays nice with Roact
    local index = 0
    local getLayoutOrderIndex = function()
        index = index + 1
        return index
    end

    local createTextChangingButton = function(key:string | number, object:table, isNumber:boolean)
        return SmallButtonWithLabel({
            ButtonLabel = tostring(object[key]),
            Label = key..": ",
            LayoutOrder = getLayoutOrderIndex(),
            OnActivated = function()
                if isNumber then
                    setValueType("number")
                else
                    setValueType("string")
                end
                --set modal enabled
                setModalEnabled(true)
                setCurrentFieldKey(key)
                setCurrentFieldValue(object[key])
                setCurrentFieldCallback(function()
                    return function(value)
                        object[key] = value
                        
                        --if the value being changed is a Machine's coordinates, then we need to update the MachineAnchor's name as well.
                        --This is because when you select a MachineAnchor, it uses the Name to query which Machine the anchor refers to.
                        if props.MachineAnchor and (key == "X" or key == "Y") then
                            props.MachineAnchor.Name = "("..tostring(object["X"])..","..tostring(object["Y"])..")"
                        end

                        setModalEnabled(false)
                        Studio.setSelectionTool()
                    end
                end)
            end,
        })
    end

    local map = props.CurrentMap


    local children = {}
    local items = map["items"]
    for _,item in items do
        add(children, createTextChangingButton("id", item))
    end

    return SidePanel({
            Title = "Edit Items List",
            ShowClose = true,
            OnClosePanel = props.OnClosePanel,
        }, children
    )
end

return function(props)
    return React.createElement(EditItemsListUI, props)
end