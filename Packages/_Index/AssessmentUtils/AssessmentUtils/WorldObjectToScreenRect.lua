--!strict
local Dash = require(script.Parent.Parent.Dash)
local getWorldBounds = require(script.Parent.GetWorldBounds)
local getWorldCornersFromBounds = require(script.Parent.GetWorldCornersFromBounds)

return function(target: Instance | BasePart | Model | Vector3): Rect
    local orientation: CFrame | nil = nil
    local size: Vector3 | nil = nil
    local targetType = typeof(target)
    if targetType == "Vector3" then
        local position3: Vector3 = workspace.CurrentCamera:WorldToViewportPoint(target :: Vector3)
        local position2: Vector2 = Vector2.new(position3.X, position3.Y)
        return Rect.new(position2, position2)
    elseif targetType == "Instance" then
        if (target :: Instance):IsA("BasePart") then
            orientation, size = getWorldBounds(target :: BasePart)
        elseif (target :: Instance):IsA("Model") then
            orientation, size = getWorldBounds(target :: Model)
        end

        local worldCorners = getWorldCornersFromBounds(orientation :: CFrame, size :: Vector3)
        local screenCorners = Dash.collectArray(worldCorners, function(_: number, worldPoint: Vector3): Vector3
            return workspace.CurrentCamera:WorldToViewportPoint(worldPoint)
        end) :: { Vector3 }

        local minX = math.huge
        local minY = math.huge
        local maxX = -math.huge
        local maxY = -math.huge
        for i = 1, #screenCorners do
            minX = math.min(minX, screenCorners[i].X)
            minY = math.min(minY, screenCorners[i].Y)
            maxX = math.max(maxX, screenCorners[i].X)
            maxY = math.max(maxY, screenCorners[i].Y)
        end
        return Rect.new(Vector2.new(minX, minY), Vector2.new(maxX, maxY))
    end
end
