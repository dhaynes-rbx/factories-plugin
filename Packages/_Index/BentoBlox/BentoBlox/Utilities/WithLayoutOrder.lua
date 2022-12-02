--!strict
local prefixPattern = "^(_%d+_)" -- e.g. _1_ with capture group for 1 or more digits

function layoutOrderFromNameOrIndex(nameOrIndex)
    local orderFromKey = tonumber(nameOrIndex)
    if orderFromKey then -- was an numeric index or index like key
        return { orderFromKey, nameOrIndex }
    else -- string key, we split on our convention and see if we get a number or nil
        local prefix = string.match(nameOrIndex, prefixPattern)
        local newIndex = nil
        local newKeyName = ""

        if prefix ~= nil then
            newIndex = string.gsub(prefix, "_", "")
            newKeyName = string.gsub(nameOrIndex, prefixPattern, "")
            return { tonumber(newIndex), newKeyName }
        else
            newKeyName = nameOrIndex
            return { newIndex, newKeyName }
        end
    end
end

function insertWithLayoutOrder(intoTable, nameOrIndex: string, roactComponent: any, duringInitialization: boolean)
    -- TODO: warn if value is not a reactComponent (how to test)
    -- "The WithLayoutOrder helper should only be used on tables of Roact Components"

    local metatable = getmetatable(intoTable)

    local orderFromKey = layoutOrderFromNameOrIndex(nameOrIndex)
    local cleanedKey = orderFromKey
    local order = roactComponent.props.LayoutOrder or orderFromKey[1] or (metatable.__highestLayoutOrder + 1)

    if roactComponent.props.LayoutOrder ~= nil and orderFromKey[1] ~= nil then
        print("A component at key `${nameOrIndex}` has both a prefix and LayoutOrder. Using LayoutOrder value of ${LayoutOrder}.")
    end

    if duringInitialization and roactComponent.props.LayoutOrder == nil and orderFromKey[1] == nil then
        print("A component at key `${nameOrIndex}` has no set LayoutOrder.")
        print("Initializing a table with `WithLayoutOrder` requires providing a LayoutOrder,")
        print("either via prefixing the name e.g. `_1_Example = Roact.createComponent(...)`")
        print("or via a LayoutOrder prop e.g. `Example = Roact.createComponent(..., { LayoutOrder = 1 })`.")
        print("Otherwise, the order will be arbitrary.")
    end

    if metatable.__seenLayoutOrder[order] then
        -- warn if LayoutOrder collides
        print("A component is already set to LayoutOrder ${value} (collision by key `${nameOrIndex}`);")
    end
    -- Mark this LayoutOrder as seen
    metatable.__seenLayoutOrder[order] = true
    -- TODO: need a removeIndex to mark as nil (hmmm or is that a problem since can have collisions? maybe this is a reference count instead of a boolean?)

    -- If this is new highest mark that
    if order > metatable.__highestLayoutOrder then
        metatable.__highestLayoutOrder = order
    end

    -- Actually set the LayoutOrder in the component
    roactComponent.props.LayoutOrder = order
    -- Then add it to the table
    -- After stripping the prefix
    rawset(intoTable, cleanedKey[2], roactComponent)

    -- Q. does __newIndex return?
end

--- Converts a table to a metatable that sets LayoutOrder via index or key prefix (e.g. `_1_`)
function withLayoutOrder(initalTable)
    local DURING_INITIALIZATION = true
    local withLayoutOrderMetatable = {} -- this is the metatable
    -- creating it in function to give unique instances and track values uniquely for each wrapped table (needed?)

    -- Set metatable internal state
    withLayoutOrderMetatable.__seenLayoutOrder = {}
    withLayoutOrderMetatable.__highestLayoutOrder = 0
    -- Set metatable functions
    withLayoutOrderMetatable.__newindex = insertWithLayoutOrder

    -- Create a new table and assign it that metatable
    local newOrderedTable = {}
    setmetatable(newOrderedTable, withLayoutOrderMetatable)

    -- Process initalTable into new table metatable
    -- First handle ipairs?
    for index, maybeRoactComponent in ipairs(initalTable) do
        -- instead of table.insert(newOrderedTable, index, maybeRoactComponent)
        -- we call directly to handle special casing errors during init
        insertWithLayoutOrder(newOrderedTable, index, maybeRoactComponent, DURING_INITIALIZATION)
        -- Oh... but will the insert in there double call metatable?
        -- removing after adding (so not reprocessed in key loop)
    end
    -- Then handle keys?
    -- Do in one pass? I'm not sure this initialization pass meets tests
    for key, maybeRoactComponent in pairs(initalTable) do
        insertWithLayoutOrder(newOrderedTable, key, maybeRoactComponent, DURING_INITIALIZATION)
    end

    return newOrderedTable -- Q. is the fact that this is a new table a problem? e.g. references to old table?
end

return withLayoutOrder
