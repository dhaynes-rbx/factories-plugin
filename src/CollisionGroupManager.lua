local PhysicsService = game:GetService("PhysicsService")
-- local Globals = {
--     COLLISION_GROUP = "VT_CachedCollisionGroup",
--     HIDDEN = "VT_Hidden",
--     HIDDEN_NAME_SUB = "%[HIDDEN%]% ",
--     HIDDEN_NAME_TAG = "[HIDDEN] ",
--     INVISIBLE = "VT_IsInvisible",
--     INVISIBLE_NAME_TAG = "*",
--     ENABLED = "VT_Enabled",
--     TRANSPARENCY = "VT_CachedTransparency",
-- }

local SELECTABLE_GROUP = "StudioSelectable"
local UNSELECTABLE_GROUP = "Unselectable"

local CollisionGroupMgr = {}

function CollisionGroupMgr:MakeUnselectable(model: Model)
    if not PhysicsService:IsCollisionGroupRegistered(UNSELECTABLE_GROUP) and not self:MaxCollisionGroupsReached() then
        PhysicsService:RegisterCollisionGroup(UNSELECTABLE_GROUP)
        PhysicsService:CollisionGroupSetCollidable("Default", UNSELECTABLE_GROUP, false)
        PhysicsService:CollisionGroupSetCollidable(SELECTABLE_GROUP, UNSELECTABLE_GROUP, false)
    end
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CollisionGroup = UNSELECTABLE_GROUP
        end
    end
end

function CollisionGroupMgr:HasTooManyExistingGroups(): boolean
    local neededGroups = 0
    if not PhysicsService:IsCollisionGroupRegistered(UNSELECTABLE_GROUP) then
        neededGroups += 1
    end
    if not PhysicsService:IsCollisionGroupRegistered(SELECTABLE_GROUP) then
        neededGroups += 1
    end
    local existingGroups = #PhysicsService:GetRegisteredCollisionGroups()
    local maxGroups = PhysicsService:GetMaxCollisionGroups()
    return existingGroups + neededGroups > maxGroups
end

function CollisionGroupMgr:MaxCollisionGroupsReached()
    if CollisionGroupMgr:HasTooManyExistingGroups() then
        warn(
            "Factories Plugin: Cannot hide object because you've reached the max allowable CollisionGroups (32). Remove a CollisionGroup to proceed"
        )
        return true
    else
        return false
    end
end

-- function CollisionGroupMgr:CreateHiddenCollisionGroup()
--     if not PhysicsService:IsCollisionGroupRegistered(SELECTABLE_GROUP) then
--         PhysicsService:RegisterCollisionGroup(SELECTABLE_GROUP)
--     end
--     if not PhysicsService:IsCollisionGroupRegistered(Globals.HIDDEN) then
--         PhysicsService:RegisterCollisionGroup(Globals.HIDDEN)
--     end
--     PhysicsService:CollisionGroupSetCollidable("Default", Globals.HIDDEN, false)
--     PhysicsService:CollisionGroupSetCollidable(SELECTABLE_GROUP, Globals.HIDDEN, false)
-- end

-- function CollisionGroupMgr:AddToHiddenCollisionGroup(obj)
--     if obj:IsA("BasePart") == false then
--         return
--     end
--     self:CreateHiddenCollisionGroup()
--     --stash the name of the existing collision group as an attribute.
--     local collisionGroupName = obj.CollisionGroup
--     --if it's nil, then that means it belongs to a collision group that doesn't exist. So put it in default.
--     if collisionGroupName == Globals.HIDDEN then
--         collisionGroupName = "Default"
--     end
--     obj:SetAttribute(Globals.COLLISION_GROUP, collisionGroupName)
--     obj.CollisionGroup = Globals.HIDDEN
-- end

-- function CollisionGroupMgr:RemoveFromHiddenCollisionGroup(obj)
--     if obj:IsA("BasePart") == false then
--         return
--     end

--     if PhysicsService:IsCollisionGroupRegistered(Globals.HIDDEN) then
--         local containsPart = (obj.CollisionGroup == Globals.HIDDEN)
--         if containsPart then
--             local attribute = obj:GetAttribute(Globals.COLLISION_GROUP)
--             if not attribute then
--                 attribute = "Default"
--             end
--             obj.CollisionGroup = attribute
--             obj:SetAttribute(Globals.COLLISION_GROUP, nil)
--         end
--     end
-- end
-- function CollisionGroupMgr:RemoveHiddenCollisionGroup()
--     if PhysicsService:IsCollisionGroupRegistered(Globals.HIDDEN) then
--         PhysicsService:UnregisterCollisionGroup(Globals.HIDDEN)
--     end
-- end

return CollisionGroupMgr
