--!strict
return function(orientation: CFrame, size: Vector3): { [number]: Vector3 }
    local halfSize = size * 0.5
    local result = {}
    table.insert(result, orientation.Position + Vector3.new(halfSize.X, halfSize.Y, halfSize.Z))
    table.insert(result, orientation.Position + Vector3.new(halfSize.X, -halfSize.Y, halfSize.Z))
    table.insert(result, orientation.Position + Vector3.new(-halfSize.X, -halfSize.Y, halfSize.Z))
    table.insert(result, orientation.Position + Vector3.new(-halfSize.X, halfSize.Y, halfSize.Z))
    table.insert(result, orientation.Position + Vector3.new(-halfSize.X, -halfSize.Y, -halfSize.Z))
    table.insert(result, orientation.Position + Vector3.new(-halfSize.X, halfSize.Y, -halfSize.Z))
    table.insert(result, orientation.Position + Vector3.new(halfSize.X, halfSize.Y, -halfSize.Z))
    table.insert(result, orientation.Position + Vector3.new(halfSize.X, -halfSize.Y, -halfSize.Z))
    return result
end
