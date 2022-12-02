-- !strict
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function getRemoteFunction(name: string, serverFunction: Function)
    -- When running under roblox-cli, the process is a client and a server
    -- in one, so we need to check if we have a serverFunction too
    if RunService:IsServer() and serverFunction then
        assert(ReplicatedStorage:FindFirstChild(name) == nil, "Function already exists")
        -- selene: allow(incorrect_standard_library_use)
        local remoteFunction = Instance.new("RemoteFunction", ReplicatedStorage)
        remoteFunction.Name = name
        remoteFunction.OnServerInvoke = serverFunction
        return remoteFunction
    elseif RunService:IsClient() then
        return ReplicatedStorage:WaitForChild(name)
    end
end

return getRemoteFunction
