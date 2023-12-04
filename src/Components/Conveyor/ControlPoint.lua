local Packages = script.Parent.Parent.Parent.Packages
local React = require(Packages.React)

type Props = {
    Conveyor:Model,
    Name:string,
    Position:Vector3,
    UpdatePosition:any,
}

function ControlPoint(props:Props)
    local controlPart:Part, setControlPart = React.useState()
    
    React.useEffect(function()

        local existingPart = props.Conveyor.ControlPoints:FindFirstChild(props.Name)
        if existingPart then
            existingPart:Destroy()
        end

        local part = Instance.new("Part")
        part.Position = props.Position
        part.Anchored = true
        part.Size = Vector3.new(1,1,1)
        part.Color = Color3.new(1,0,0)
        part.Name = props.Name
        part.Parent = props.Conveyor.ControlPoints
        
        setControlPart(part)
        
    end, {})

    React.useEffect(function()
        local connection:RBXScriptConnection = nil
        if controlPart then
            connection = controlPart.Changed:Connect(function(property:string)
                if property == "Position" then
                    props.UpdatePosition(props.Name, controlPart.CFrame.Position)
                end
            end)

            controlPart:PivotTo(CFrame.new(props.Position))
        end

        return function()
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)

    return React.createElement(React.Fragment, {}, {})
end

return function(props:Props)
    return React.createElement(ControlPoint, props)
end