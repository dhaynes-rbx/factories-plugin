local Packages = script.Parent.Parent.Parent.Packages
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Column = FishBloxComponents.Column
local TextInput = FishBloxComponents.TextInput
local Text = FishBloxComponents.Text
local Button = FishBloxComponents.Button
local Panel = FishBloxComponents.Panel
local Overlay = FishBloxComponents.Overlay
local Row = FishBloxComponents.Row

local Modal = require(script.Parent.Modal)

local Scene = require(script.Parent.Parent.Parent.Scene)

type Props = {
    Key: string,
    OnClosePanel: any,
    OnConfirm: any,
    Value: string | number,
    ValueType: string,
}

local function ConfirmationModal(props: Props)
    
    local showError, setShowError = React.useState(false)
    
    local ModalElements = {
        Row = Row({
            AutomaticSize = Enum.AutomaticSize.Y,
            Gaps = 8,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            PaddingHorizontal = 20,
            PaddingVertical = 20,
            ZIndex = 2,
        },
        {
            Button1 = Button({
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Label = "Confirm",
                LayoutOrder = 100,
                OnActivated = function() 
                    props.OnConfirm()
                end,
                TextXAlignment = Enum.TextXAlignment.Center,
                Width = UDim.new(0, 200),
                ZIndex = 2,
            }),
            Button2 = Button({
                Appearance = "Outline",
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Label = "Cancel",
                LayoutOrder = 200,
                OnActivated = function() 
                    props.OnCancel()
                end,
                TextXAlignment = Enum.TextXAlignment.Center,
                Width = UDim.new(0, 200),
                ZIndex = 2,
            }),
        })
        
    }

    return Modal({
        ModalElements = ModalElements,
        ShowClose = false,
        Title = "Do you want to remove this machine from the dataset?",
    })
end

return function(props)
    return React.createElement(ConfirmationModal, props)
end