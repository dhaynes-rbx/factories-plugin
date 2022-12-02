-- !strict
local tlsStorage = {}

local function getStorage(name: string)
    local current = coroutine.running() or "main"
    local storage = tlsStorage[current]

    if not storage then
        storage = {}
        tlsStorage[current] = storage
    end

    return storage
end

local TLS = {
    __mode = "k",
    __index = function(self, k)
        return getStorage()[k]
    end,
    __newindex = function(self, k, v)
        local storage = getStorage()
        storage[k] = v
    end,
}
return setmetatable({}, TLS)
