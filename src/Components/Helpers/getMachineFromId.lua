return function(id, map)
    local machine = nil
    -- local num = 0
    for _,v in map["machines"] do
        if v["id"] == id then
            -- num = num + 1
            machine = v
        end
    end
    -- if num > 1 then
    --     assert(true, "ERROR! Duplicate machine id found in this map!")
    -- end
    return machine
end