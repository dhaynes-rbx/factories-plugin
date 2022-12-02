-- Modified version of https://github.com/diegogub/lua-jsonpatch
-- MIT License: https://github.com/diegogub/lua-jsonpatch/blob/f09149123e3be04388b48c9ca263ba70925de703/lua-jsonpatch-0-7.rockspec#L12
--
-- Differences:
--   Defaults to REPLACE if no OP is specified
--   Uses 1 based indices for arrays like lua, so is not compatible with a standard JSON patch
--
local _M = {}

-- actions
local ops = {
    replace = {
        op = "",
        path = "",
        value = "",
    },
    add = {
        op = "",
        path = "",
        value = "",
    },
    remove = {
        op = "",
        path = "",
    },
    copy = {
        op = "",
        from = "",
        path = "",
    },
    move = {
        op = "",
        from = "",
        path = "",
    },
    test = {
        op = "",
        path = "",
        value = "",
    },
}

-- shorter version of actions
local ops_short = {
    replace = "r",
    add = "a",
    remove = "d",
    copy = "c",
    move = "m",
    test = "t",
}

local ops_long = {
    r = "replace",
    a = "add",
    d = "remove",
    c = "copy",
    m = "move",
    t = "test",
}

-- decode_token , decodes json token
local decode_token = function(token)
    local t = ""
    t = string.gsub(token, "~0", "~")
    t = string.gsub(t, "~1", "/")
    if tonumber(t) ~= nil then
        return tonumber(t)
    else
        -- -1 will indicate last index of array
        if t == "-" then
            return -1
        end
        return t
    end
end

local split_path = function(path)
    local t = {}
    for p in string.gmatch(path, "([^/]*)") do
        if p ~= "" then
            table.insert(t, decode_token(p))
        end
    end
    return t
end

-- set_path, creates path and puts value on it
_M.set_path = function(obj, path, value)
    if type(obj) ~= "table" then
        return false, nil, "Has to be a object to set value"
    end
    local parts = split_path(path)
    for i, k in ipairs(parts) do
    end
end

-- check_path, return if exist and value of path, and error
_M.check_path = function(obj, path)
    if type(obj) ~= "table" then
        return false, nil, "Has to be a object to check path"
    end

    local parts = split_path(path)
    local exist = false
    local value = nil

    if #parts == 0 then
        return true, obj, nil
    end

    local cur = obj
    for i, k in ipairs(parts) do
        if type(k) == "number" then
            if k == -1 then
                k = #cur
            end
        end

        local val = cur[k]
        if val == nil and i ~= #parts then
            return false, nil, "Path does not exist"
        else
            if val ~= nil and i == #parts then
                return true, val, nil
            end

            -- continue
            if val ~= nil and i ~= #parts then
                if type(val) == "table" then
                    cur = val
                else
                    return false, nil, "Path does not exist"
                end
            end
        end
    end

    return false, nil, "Path does not exist.."
end

-- build_path , returns a clean patch from any object and error
local build_patch = function(obj, spec)
    local patch = {}
    for k, v in pairs(spec) do
        local value = obj[k]
        if value == nil then
            return {}, "Missing key in patch:" .. k
        else
            patch[k] = value
        end
    end
    return patch, nil
end

local make_short_op = function(op)
    local so = ops_short[op]
    if so == nil then
        local exist = ops_long[op]
        if exist then
            return op, nil
        else
            return op, "Invalid op:" .. op
        end
    else
        return so, nil
    end
end

-- check_op checks is operation exist and matches spec
local check_patch = function(patch)
    local op = patch.op or "replace"
    if type(op) ~= "string" then
        return false, "Invalid operation."
    end
    for k, spec in pairs(ops) do
        if k == op or ops_short[k] == op then
            for sk, v in pairs(spec) do
                local value = patch[sk]
                if value == nil and sk ~= "op" then
                    return "Missing key in patch:" .. sk
                end
            end
            return nil
        end
    end

    return false, {}
end

_M.verbose = false

-- validate, validates json patch and it's format, returning flag, clean patch and error
_M.validate = function(patch)
    if type(patch) ~= "table" then
        return false, "Patch must be array of operations"
    end

    for i, p in ipairs(patch) do
        if type(p) ~= "table" then
            return false, "Each operation should be a Array."
        end

        local err = check_patch(p)
        if err then
            return false, "Invalid operation [" .. i .. "]: " .. err
        end
    end

    return true, nil
end

-- iterates over object until path found, return: obj location,
local follow_path = function(arr, obj, exist)
    local key = ""
    for i, k in ipairs(arr) do
        key = k
        if type(key) == "number" then
            if key < 0 then
                key = #obj
            end

            local val = obj[key]
            if type(val) == "table" and i < #arr then
                obj = val
            else
                if val == nil then
                    if exist then
                        return obj, "", "Error, key " .. table.concat(arr, "/") .. " should exist"
                    else
                        return obj, key, nil
                    end
                end
            end
        else
            local val = obj[key]
            if type(val) == "table" then
                if i < #arr then
                    obj = val
                end
            else
                if val == nil then
                    if exist then
                        return obj, "", "Error, key " .. table.concat(arr, "/") .. " should exist"
                    else
                        return obj, key, nil
                    end
                end
            end
        end
    end

    return obj, key, nil
end

local do_op = function(op, arr, obj, value, exist)
    local obj, key, err = follow_path(arr, obj, exist)
    if err then
        return err
    end

    if op == "replace" then
        obj[key] = value
    end

    if op == "remove" then
        if type(key) == "number" then
            table.remove(obj, key)
        else
            obj[key] = nil
        end
    end

    if op == "add" then
        if type(key) == "number" then
            if key == #obj then
                table.insert(obj, key + 1, value)
            elseif key == #obj + 1 then
                table.insert(obj, key, value)
            else
                if key == 1 then
                    table.insert(obj, key, value)
                else
                    table.insert(obj, key - 1, value)
                end
            end
        else
            obj[key] = value
        end
    end

    return nil
end

local do_mv = function(obj, from, to, copy)
    local obj1, key1, err = follow_path(from, obj, false)
    if err then
        return err
    end

    local obj2, _, err = follow_path(to, obj, false)
    if err then
        return err
    end

    if copy then
        obj2[key1] = obj1[key1]
    else
        obj2[key1] = obj1[key1]

        local err = do_op("remove", from, obj, "", true)
        if err then
            return err
        end
    end
end

-- apply, applies a patch to a object, returning error status
_M.apply = function(obj, patches)
    if type(obj) ~= "table" then
        return "Patchs can only be applied to tables"
    end

    local obj_copy = obj

    -- validates patch and clear it
    local ok, err = _M.validate(patches)
    if not ok then
        return err
    end

    -- execute all patches
    for _, patch in ipairs(patches) do
        local op = patch.op or "replace"

        if op == "replace" then
            err = do_op("replace", split_path(patch.path), obj_copy, patch.value, true)
            if err then
                return err
            end
        elseif op == "add" then
            err = do_op("add", split_path(patch.path), obj_copy, patch.value, false)
            if err then
                return err
            end
        elseif op == "remove" then
            err = do_op("remove", split_path(patch.path), obj_copy, patch.value, true)
            if err then
                return err
            end
        elseif op == "move" then
            err = do_mv(obj_copy, split_path(patch.from), split_path(patch.path), false)
            if err then
                return err
            end
        elseif op == "copy" then
            err = do_mv(obj_copy, split_path(patch.from), split_path(patch.path), true)
            if err then
                return err
            end
        end
    end

    return err
end

_M.compress = function(patches)
    local compress_patches = {}
    for i, p in ipairs(patches) do
        local ok, err = _M.validate(p)
        if not ok then
            return {}, "Invalid patch:" .. err
        end

        local short_op = make_short_op(p.op or "replace")
        local compressed = false

        if short_op == "r" or short_op == "a" or short_op == "t" then
            local patch = { short_op, p.path, p.value }
            table.insert(compress_patches, patch)
            compressed = true
        elseif short_op == "d" then
            local patch = { short_op, p.path }
            table.insert(compress_patches, patch)
            compressed = true
        elseif short_op == "c" or short_op == "m" then
            local patch = { short_op, p.from, p.path }
            table.insert(compress_patches, patch)
            compressed = true
        end

        if not compressed then
            return {}, "failed to compress patchs, op not supported"
        end
    end

    return compress_patches, nil
end

_M.decompress = function(patches)
    local d_patches = {}
    for i, p in ipairs(patches) do
        local patch = {}
        local op = p[1]
        local decompressed = false

        if op == "r" or op == "a" or op == "t" then
            patch["op"] = ops_long[op]
            patch["path"] = p[2]
            patch["value"] = p[3]
            table.insert(d_patches, patch)
            decompressed = true
        end

        if op == "d" then
            patch["op"] = ops_long[op]
            patch["path"] = p[2]
            table.insert(d_patches, patch)
            decompressed = true
            decompressed = true
        end

        if op == "c" or op == "m" then
            patch["op"] = ops_long[op]
            patch["from"] = p[2]
            patch["path"] = p[3]
            table.insert(d_patches, patch)
            decompressed = true
        end

        if not decompressed then
            return {}, "Failed to decompress patches"
        end
    end

    return d_patches, nil
end

return _M
