local InputService = game:GetService("UserInputService")
local Selection = game:GetService("Selection")

local Scene = require(script.Parent.Scene)

local getCoordinatesFromAnchorName = require(script.Parent.Components.Helpers.getCoordinatesFromAnchorName)
local getMachineFromCoordinates = require(script.Parent.Components.Helpers.getMachineFromCoordinates)

local Input = {}

function Input.listenForMachineMouseInput(map:table, callback:any)
    return InputService.InputEnded:Connect(function(input:InputObject)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
    
        local selection = Selection:Get()[1]
        if selection then
            if Scene.isMachineAnchor(selection) then
                --Register that the machine may have been moved.
                local position = selection.PrimaryPart.CFrame.Position
                local x,y = getCoordinatesFromAnchorName(selection.Name)
                local machine = getMachineFromCoordinates(x,y, map)
                local worldPosition = Vector3.new(
                    machine["worldPosition"]["X"],
                    machine["worldPosition"]["Y"],
                    machine["worldPosition"]["Z"]
                )
                if position ~= worldPosition then
                    machine["worldPosition"]["X"] = position.X
                    machine["worldPosition"]["Y"] = position.Y
                    machine["worldPosition"]["Z"] = position.Z
                    callback()
                end
            end
        end
    end)
end

return Input