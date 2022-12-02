-- !strict
local Packages = script.Parent.Parent
local Dash = require(Packages.Dash)
local HttpService = game:GetService("HttpService")

local Http = {}

function Http:new(baseUrl: string)
    local http = {}
    setmetatable(http, self)
    self.__index = self
    http.baseUrl = baseUrl
    http.headers = {
        ["Content-Type"] = "application/json",
    }
    return http
end

function Http:setAuthorization(auth: string)
    self.headers["Authorization"] = auth
end

function Http:get(url: string, options: table | nil)
    return self:request("GET", url, nil, options)
end

function Http:post(url: string, data: {}, options: table | nil)
    return self:request("POST", url, data, options)
end

function Http:put(url: string, data: {}, options: table | nil)
    return self:request("PUT", url, data, options)
end

function Http:delete(url: string, options: table | nil)
    return self:request("DELETE", url, nil, options)
end

function Http:request(method: string, url: string, data: table | nil, options: table | nil)
    local request = {
        Method = method,
        Url = self:buildUrl(url),
        Headers = options and options.headers and Dash.join(self.headers, options.headers) or self.headers,
    }
    if data ~= nil then
        request["Body"] = HttpService:JSONEncode(data)
    end

    local success, response = xpcall(function()
        local response = HttpService:RequestAsync(request)
        local result = {
            success = response.Success,
            statusCode = response.StatusCode,
            statusMessage = response.StatusMessage,
            data = response.Headers["content-type"] == "application/json" and HttpService:JSONDecode(response.Body) or response.Body,
            headers = response.Headers,
        }
        return result
    end, function(err)
        return {
            success = false,
            statusCode = 0,
            statusMessage = err,
        }
    end)
    return response
end

function Http:buildUrl(url: string)
    if string.sub(url, 1, 4) == "http" then
        return url
    end
    return self.baseUrl .. url
end

return Http
