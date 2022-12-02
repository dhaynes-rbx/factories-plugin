-- !strict
function vector3FromObject(object: table): Vector3
    return Vector3.new(object.x, object.y, object.z)
end
return vector3FromObject
