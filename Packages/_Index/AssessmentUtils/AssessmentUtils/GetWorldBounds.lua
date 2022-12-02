--!strict
return function(target: Instance | BasePart | Model): (CFrame, Vector3)
    if (target :: Instance):IsA("BasePart") then
        -- Take advantage of model bounding box accessor by injecting a model between target and parent
        local partTarget = target :: BasePart
        local temp = Instance.new("Model")
        temp.Parent = partTarget.Parent
        partTarget.Parent = temp
        temp.PrimaryPart = partTarget

        -- Actually get bounds
        local orientation, size = temp:GetBoundingBox()

        -- Cleanup temp model
        partTarget.Parent = temp.Parent
        temp:Destroy()

        return orientation, size
    elseif (target :: Instance):IsA("Model") then
        return (target :: Model):GetBoundingBox()
    end
end
