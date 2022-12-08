local Packages = script.Parent.Parent.Packages
local Dash = require(Packages.Dash)
local React = require(Packages.React)
local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components

local Block = FishBloxComponents.Block
local Button = FishBloxComponents.Button
local Column = FishBloxComponents.Column
local Gap = FishBloxComponents.Gap
local Panel = FishBloxComponents.Panel
local Row = FishBloxComponents.Row
local Text = FishBloxComponents.Text
local TextInput = FishBloxComponents.TextInput

export type Vector2RowProps = {
    Label: string,
    LayoutOrder: number,
    X: number,
    Y: number,
}

local function Vector2Row(props:Vector2RowProps)
    local inputBoxSize = 60
    return {
        Column = Column({
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = props.LayoutOrder,
        }, {
            Label = Text({
                Color = Color3.new(1,1,1),
                FontSize = 24,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                RichText = true,
                Text = props.Label..":",
                LayoutOrder = 1,
            }),
            --TODO: Update this once TextInput has LayoutOrder functionality
            Row = Row({
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.fromScale(1, 0),
                LayoutOrder = 3
            }, {
                XBlock = Block({
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = 1,
                    Width = inputBoxSize,
                },{
                    X = TextInput({
                        Label = "X",
                        Placeholder = "X",
                        Value = props.X,
                        Width = inputBoxSize,
                    }),
                }),
                Spacer = Block({ Width = 10, LayoutOrder = 2 }),
                YBlock = Block({
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = 2,
                    Width = inputBoxSize,
                }, {
                    Y = TextInput({
                        Label = "Y",
                        Placeholder = "Y",
                        Value = props.Y,
                        Width = inputBoxSize,
                    })
                })
            })
        })
    }
end

return function(props: Vector2RowProps)
    return React.createElement(Vector2Row, props)
end