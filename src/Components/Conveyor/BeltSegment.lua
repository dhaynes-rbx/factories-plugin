local Packages = script.Parent.Parent.Parent.Packages

local React = require(Packages.React)

local PathGenerator = require(script.Parent.Parent.Parent.PathGenerator)
local thickness = 0.5
local width = 1.5

type Props = {
    Conveyor: Folder,
    Name: string,
    EndPoint: table,
    StartPoint: table,
}

function BeltSegment(props: Props)
    local beltPart, setBeltPart = React.useState(nil)
    local children = {}

    React.useEffect(function()
        for _, child in props.Conveyor.BeltSegments:GetChildren() do
            if child.Name == props.Name then
                child:Destroy()
            end
        end

        local part =
            PathGenerator.GenerateBasicPath(props.StartPoint.Position, props.EndPoint.Position, width, thickness)
        if part then
            part.Name = props.Name
            part.Parent = props.Conveyor.BeltSegments
            setBeltPart(part)
        else
            print("Belt Segment part is invalid. Check to see if the segment length was too short.")
        end
    end, {})

    React.useEffect(function()
        if not props.Conveyor then
            return
        end

        if beltPart then
            beltPart:Destroy()

            local newPart =
                PathGenerator.GenerateBasicPath(props.StartPoint.Position, props.EndPoint.Position, width, thickness)
            newPart.Name = props.Name
            newPart.Parent = props.Conveyor.BeltSegments
            setBeltPart(newPart)
        end
    end, {
        props.StartPoint.Position.X,
        props.StartPoint.Position.Y,
        props.EndPoint.Position.X,
        props.EndPoint.Position.Y,
    })

    return React.createElement(React.Fragment, {}, children)
end

return function(props: Props)
    return React.createElement(BeltSegment, props)
end
