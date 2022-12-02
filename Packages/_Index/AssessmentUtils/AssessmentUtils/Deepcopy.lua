-- !strict
function deepcopy(orig: table, copies): table
    copies = copies or {}
    local origType: type = type(orig)
    local copy: any
    if origType == "table" then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for origKey, origValue in next, orig, nil do
                copy[deepcopy(origKey, copies)] = deepcopy(origValue, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
return deepcopy
