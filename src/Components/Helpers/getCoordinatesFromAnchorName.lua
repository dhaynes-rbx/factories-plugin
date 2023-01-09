--takes the MachineAnchor name as an input and returns X and Y coordinates.
return function(name)
    local x, y = table.unpack(string.split(string.sub(name, 2, #name - 1), ","))
    x = tonumber(x)
    y = tonumber(y)
    return x, y
end