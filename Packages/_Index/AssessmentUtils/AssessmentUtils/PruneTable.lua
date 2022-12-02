--!strict
export type PruneHandler = (any, any) -> boolean

function pruneTable(table: table, shouldPrune: PruneHandler): table
    for key, value in pairs(table) do
        if shouldPrune(key, value) then
            table[key] = nil
        elseif typeof(value) == "table" then
            pruneTable(value, shouldPrune)
        end
    end
    return table
end
return pruneTable
