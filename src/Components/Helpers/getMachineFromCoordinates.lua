return function(x, y, map)
    local machine = nil
    for _,v in map["machines"] do
        if v["coordinates"]["X"] == x and v["coordinates"]["Y"] == y then
            machine = v
        end
    end
    return machine
end