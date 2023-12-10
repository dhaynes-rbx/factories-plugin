local Packages = script.Parent.Parent.Parent.Packages
local React = require(Packages.React)
local Dash = require(Packages.Dash)

local ControlPoint = require(script.Parent.ControlPoint)
local BeltSegment = require(script.Parent.BeltSegment)

local getOrCreateFolder = require(script.Parent.Parent.Parent.Helpers.getOrCreateFolder)
local worldPositionToVector3 = require(script.Parent.Parent.Parent.Helpers.worldPositionToVector3)

local Types = require(script.Parent.Parent.Parent.Types)

type Props = {
    ClickRect: Rect,
    Creating: boolean,
    Editing: boolean,
    Name: string,
    Subdivisions: number,
    StartPosition: Vector3,
    EndPosition: Vector3,
}

type ControlPoint = {
    Name: string,
    Position: Vector3,
}

type BeltSegment = {
    Name: string,
    StartPoint: ControlPoint,
    EndPoint: ControlPoint,
}

local function getControlPointIndex(name): string
    local _, suffix = name:find("ControlPoint")
    return name:sub(suffix + 1, #name)
end

local function getPreviousIndex(name): number
    local index = getControlPointIndex(name)
    local prevIndex = index - 1
    if prevIndex == 0 then
        return nil
    end

    return prevIndex
end

local function refreshControlPoints(conveyor: Model): { ControlPoint }
    local controlPoints = {}
    local controlPointParts = conveyor.ControlPoints:GetChildren()
    table.sort(controlPointParts, function(a, b)
        return a.Name < b.Name
    end)
    for _, controlPointPart in controlPointParts do
        controlPoints[controlPointPart.Name] = {
            Position = controlPointPart.Position,
            Name = controlPointPart.Name,
        }
    end
    return controlPoints
end

local function refreshBeltSegments(controlPoints): { BeltSegment }
    local beltSegments = {}

    for _, point in controlPoints do
        local prevIndex = getPreviousIndex(point.Name)
        if not prevIndex then
            continue
        end
        local prevPoint = controlPoints["ControlPoint" .. prevIndex]
        local beltSegmentName = prevPoint.Name .. "-" .. point.Name

        beltSegments[beltSegmentName] = {
            Name = beltSegmentName,
            EndPoint = point,
            StartPoint = prevPoint,
        }
    end

    return beltSegments
end

function Conveyor(props: Props)
    local conveyorFolder: Model, setConveyorFolder: (Model) -> nil = React.useState(nil)
    local controlPoints: { ControlPoint }, setControlPoints: ({ ControlPoint }) -> nil = React.useState({})

    local children = {}

    React.useEffect(function()
        --Create a model to hold the control points
        local beltDataFolder = getOrCreateFolder("BeltData", game.Workspace)
        local folder: Folder = beltDataFolder:FindFirstChild(props.Name)
        if folder then
            controlPoints = refreshControlPoints(folder)
        else
            folder = Instance.new("Folder")
            folder.Name = props.Name
            folder.Parent = beltDataFolder

            controlPoints["ControlPoint1"] = {}
            controlPoints["ControlPoint1"].Name = "ControlPoint1"
            controlPoints["ControlPoint1"].Position = props.StartPosition
            controlPoints["ControlPoint2"] = {}
            controlPoints["ControlPoint2"].Name = "ControlPoint2"
            controlPoints["ControlPoint2"].Position = props.EndPosition
        end

        getOrCreateFolder("ControlPoints", folder)
        getOrCreateFolder("BeltSegments", folder):ClearAllChildren()

        setConveyorFolder(folder)
        setControlPoints(controlPoints)

        return function()
            if folder then
                folder:Destroy()
            end
        end
    end, {})

    --Subdivide hook
    React.useEffect(function()
        if not conveyorFolder then
            return
        end

        local newControlPoints = {}
        --Subdivide the conveyor belt.
        local keys: table = Dash.keys(controlPoints)
        table.sort(keys, function(a, b)
            return a < b
        end)

        local startPoint = table.clone(controlPoints[keys[1]])
        local endPoint = table.clone(controlPoints[keys[#keys]])

        local numPoints = 2 + props.Subdivisions
        endPoint.Name = "ControlPoint" .. numPoints

        newControlPoints[startPoint.Name] = startPoint
        newControlPoints[endPoint.Name] = endPoint

        for i = 1, numPoints, 1 do
            newControlPoints["ControlPoint" .. i] = {
                Name = "ControlPoint" .. i,
                Position = startPoint.Position:Lerp(endPoint.Position, (i - 1) / (numPoints - 1)),
            }
        end

        conveyorFolder:FindFirstChild("BeltSegments"):ClearAllChildren()
        setControlPoints(newControlPoints)
    end, { props.Subdivisions })

    React.useEffect(function()
        local keys: table = Dash.keys(controlPoints)
        table.sort(keys, function(a, b)
            return a < b
        end)

        if #keys > 1 then
            local startPoint = controlPoints[keys[1]]
            startPoint.Position = props.StartPosition
            local endPoint = controlPoints[keys[#keys]]
            endPoint.Position = props.EndPosition

            setControlPoints(table.clone(controlPoints))
        end
    end, {
        props.StartPosition.X,
        props.StartPosition.Z,
        props.EndPosition.X,
        props.EndPosition.Z
    })

    local controlPointComponents = {}
    for _, point in controlPoints do
        controlPointComponents[point.Name] = ControlPoint({
            Name = point.Name,
            Conveyor = conveyorFolder,
            PartRef = point.PartRef,
            Position = point.Position,
            UpdatePosition = function(controlPointName: string, position: Vector3)
                local updatedControlPoints = table.clone(controlPoints)
                updatedControlPoints[controlPointName].Position = position
                setControlPoints(updatedControlPoints)
            end,
        })
    end

    local beltSegmentComponents = {}
    local beltSegments = refreshBeltSegments(controlPoints)
    for _, segment in beltSegments do
        beltSegmentComponents[segment.Name] = BeltSegment({
            Name = segment.Name,
            Conveyor = conveyorFolder,
            StartPoint = table.clone(segment.StartPoint),
            EndPoint = table.clone(segment.EndPoint),
        })
    end

    children = Dash.join(controlPointComponents, beltSegmentComponents)

    return React.createElement(React.Fragment, {}, children)
end

return function(props: Props)
    return React.createElement(Conveyor, props)
end
