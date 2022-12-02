-- This module represents the ability to proxy an input function

-- The TestUtils module registers a proxy to allow it to fake user input
-- when its used. This code is required to ship in production, TestUtils is
-- completely stripped in production code

type ProxyFunction = (string, func: () -> any, metadata: { [string]: any }?) -> any

local proxyFunction: ProxyFunction = nil

local function setProxy(func: ProxyFunction)
    proxyFunction = func
end

local function bind(name: string, func: (...any) -> nil, metadata: { [string]: any }?)
    if proxyFunction then
        return proxyFunction(name, func, metadata)
    end
    return func
end

return {
    bind = bind,
    setProxy = setProxy,
}
