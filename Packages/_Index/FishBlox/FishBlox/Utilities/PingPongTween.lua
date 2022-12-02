--!strict
local TweenService = game:GetService("TweenService");
local TweenConfig = TweenInfo; -- alias for a more logical name

-- TODO: Wrapping this in a Promise could be a cleaner way to manage
-- e.g. https://eryn.io/roblox-lua-promise/lib/Examples.html#cancellable-animation-sequence

function pingPongTween (instance: Instance, pingGoal: Dictionary<any>, pongGoal: Dictionary<any>, duration: number, transits: number, onTransitsCompleted: (() -> nil)?)
    -- setup some closure state
    local tweenConfig = TweenConfig.new(duration);
    local transitsCompleted = 0;
    local nextTweenToPong = true;
    -- define a chainable function to call on complete
    local onCompleteTransit = nil;
    onCompleteTransit = function ()
        if transitsCompleted < transits then
            transitsCompleted = transitsCompleted + 1;
            -- setup another tween
            if nextTweenToPong then
                nextTweenToPong = false;
                local tween = TweenService:Create(instance, tweenConfig, pongGoal);
                tween.Completed:Connect(onCompleteTransit);
                tween:Play();
                return tween;
            else
                nextTweenToPong = true;
                local tween = TweenService:Create(instance, tweenConfig, pingGoal);
                tween.Completed:Connect(onCompleteTransit);
                tween:Play();
                return tween;
            end
        else
            if onTransitsCompleted ~= nil then
                return onTransitsCompleted();
            end
            return nil;
        end
    end
    -- kick off ping pong
    onCompleteTransit();
end

return pingPongTween
