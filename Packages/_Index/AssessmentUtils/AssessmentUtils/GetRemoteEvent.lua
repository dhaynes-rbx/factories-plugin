-- !strict
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[--
    Module with helper utility for handling remote events
]]

--[[--
    @function getRemoteEvent creates event with given name if it doesn't yet exist. Returns the event.
    @string name - The name of the event
    @tparam Function clientFunction - The function to be called when a client event is triggered
    @tparam Function serverFunction - The function to be called when a server event is triggered
    @treturn RemoteEvent - The created or preexisting remote event of the given name
]]
function getRemoteEvent(name: string, clientFunction: Function, serverFunction: Function)
    local event: RemoteEvent = ReplicatedStorage:FindFirstChild(name)
    if event == nil then
        event = Instance.new("RemoteEvent")
        event.Parent = ReplicatedStorage
        event.Name = name
    end

    if RunService:IsServer() and serverFunction then
        event.OnServerEvent:Connect(serverFunction)
    elseif RunService:IsClient() and clientFunction then
        event.OnClientEvent:Connect(clientFunction)
    end
    return event
end

return getRemoteEvent
