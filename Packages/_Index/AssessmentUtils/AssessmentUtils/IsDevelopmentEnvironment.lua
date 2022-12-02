--!strict
local RunService = game:GetService("RunService")

function isDevelopmentEnvironment(): boolean
    -- When running under roblox-cli, the run service doesn't report itself
    -- as studio, so we need to look for the ProcessService as a hint
    return RunService:IsStudio() or pcall(function()
        -- selene: allow(incorrect_standard_library_use)
        game:GetService("ProcessService") --ignore
    end)
end

return isDevelopmentEnvironment
