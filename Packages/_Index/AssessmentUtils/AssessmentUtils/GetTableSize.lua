-- !strict
function getTableSize(t): number
    if t.n and type(t.n) == "number" then
        return t.n
    end
    local count: number = 0
    for _: any, _: any in pairs(t) do
        count = count + 1
    end
    return count
end
return getTableSize
