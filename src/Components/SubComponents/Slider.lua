--!strict
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = script.Parent.Parent.Parent.Packages

local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)

-- local Utilities = require(Packages.Utilities)

local FishBlox = require(Packages.FishBlox)
local FishBloxComponents = FishBlox.Components
local Button = FishBloxComponents.Button
local Block = FishBloxComponents.Block
local withThemeContext = FishBlox.WithThemeContext

export type Props = {
    Active: boolean,
    ShowScrubber: boolean,
    LayoutOrder: number,
    MeterSize: UDim2,
    OnDecrement: () -> nil,
    OnDragged: (value: number) -> nil,
    OnIncrement: () -> nil,
    OnMouseLeave: () -> nil,
    OnSet: (value: number) -> nil,
    ScrubberDiameter: number,
    Range: NumberRange,
    Value: number,
    ZIndex: number,
}

local CLICK_TIME = 0.2

function Slider(props: Props)
    props.Step = props.Step ~= nil and props.Step or 1
    local dragConnection: RBXScriptConnection?, setDragConnection: (RBXScriptConnection?) -> nil = React.useState(nil)
    local clickStartTime: number, setClickStartTime: (number) -> nil = React.useState(-1)
    local meterRef: { current: Frame | nil } = React.useRef(nil) :: { current: Frame | nil }
    local wasActive, setWasActive = React.useState(props.Active)

    React.useEffect(function()
        if wasActive and not props.Active and dragConnection then
            dragConnection:Disconnect()
            dragConnection = nil
        end
        if wasActive ~= props.Active then
            setWasActive(props.Active)
        end
    end)

    local getT = function(value: number)
        local meter = meterRef.current :: Frame
        local min = meter.AbsolutePosition.X
        local max = meter.AbsolutePosition.X + meter.AbsoluteSize.X
        return (math.clamp(value, min, max) - min) / (max - min)
    end

    local updatePosition = function(input: InputObject, _: boolean, set: boolean?)
        local t = getT(input.Position.X)
        if set == true then
            props.OnSet(t)
        else
            props.OnDragged(t)
        end
    end

    local t = props.Value / (props.Range.Max - props.Range.Min)

    local tryHandleIncrementDecrement = function(input: InputObject): boolean
        local tempClickStartTime = clickStartTime
        setClickStartTime(-1)
        if
            props.OnIncrement
            and props.OnDecrement
            and tempClickStartTime ~= -1
            and tick() - tempClickStartTime < CLICK_TIME
        then
            local newT = getT(input.Position.X)
            if newT < t then
                props.OnDecrement()
                return true
            elseif newT > t then
                props.OnIncrement()
                return true
            end
        end
        return false
    end

    return withThemeContext(function(theme)
        return React.createElement("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = props.LayoutOrder,
            Size = UDim2.new(props.MeterSize.Width, UDim.new(0, props.ScrubberDiameter)),
            ZIndex = props.ZIndex,
        }, {
            Meter = React.createElement("Frame", {
                Active = props.Active,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 0,
                -- TODO: replace with proper token
                BackgroundColor3 = Color3.fromRGB(72, 82, 98),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = props.MeterSize,
                ZIndex = props.ZIndex,
                ref = meterRef,
                [ReactRoblox.Event.InputBegan] = props.Active
                        and function(_: Frame, input: InputObject)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                setClickStartTime(tick())
                            end
                        end
                    or nil,
                [ReactRoblox.Event.InputEnded] = props.Active
                        and function(_: Frame, input: InputObject)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                tryHandleIncrementDecrement(input)
                            elseif props.OnMouseLeave and input.UserInputType == Enum.UserInputType.MouseMovement then
                                props.OnMouseLeave()
                            end
                        end
                    or nil,
            }, {
                UICorner = React.createElement("UICorner", {
                    CornerRadius = UDim.new(1),
                }),
                Inset = Block({
                    Active = false,
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor = (function()
                        if props.Active and props.ShowScrubber ~= false then
                            return theme.Tokens.Colors.InteractiveSurface.Color
                        elseif props.Active and not props.ShowScrubber then
                            -- TODO: replace with proper token
                            return Color3.fromRGB(203, 203, 203)
                        end
                        -- TODO: replace with proper token
                        return Color3.fromRGB(166, 165, 165)
                    end)(),
                    BackgroundTransparency = 0,
                    Corner = UDim.new(1),
                    Position = UDim2.fromScale(0, 0.5),
                    Size = UDim2.new(UDim.new(t, 0), props.MeterSize.Height),
                    ZIndex = props.ZIndex,
                }),
                Scrubber = props.ShowScrubber ~= false
                    and React.createElement("Frame", {
                        Active = props.Active,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        Position = UDim2.fromScale(t, 0.5),
                        Size = UDim2.fromOffset(props.ScrubberDiameter, props.ScrubberDiameter),
                        ZIndex = props.ZIndex + 2,
                        [ReactRoblox.Event.InputBegan] = props.Active
                                and function(_: Frame, input: InputObject)
                                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                        setDragConnection(UserInputService.InputChanged:Connect(updatePosition))
                                        setClickStartTime(tick())
                                    end
                                end
                            or nil,
                        [ReactRoblox.Event.InputEnded] = props.Active
                                and function(_: Frame, input: InputObject)
                                    if input.UserInputType == Enum.UserInputType.MouseButton1 and dragConnection then
                                        -- Cleanup connection
                                        dragConnection:Disconnect()
                                        setDragConnection(nil)
                                        if not tryHandleIncrementDecrement(input) then
                                            updatePosition(input, true, true)
                                        end
                                    elseif
                                        props.OnMouseLeave
                                        and input.UserInputType == Enum.UserInputType.MouseMovement
                                    then
                                        props.OnMouseLeave()
                                    end
                                end
                            or nil,
                    }, {
                        Content = React.createElement("TextButton", {
                            Active = props.Active,
                            AutoButtonColor = false,
                            BackgroundColor3 = props.Active and theme.Tokens.Colors.InteractiveSurface.Color
                                -- TODO: replace with proper token
                                or Color3.fromRGB(166, 165, 165),
                            BackgroundTransparency = 0,
                            Text = "",
                            Size = UDim2.fromScale(1, 1),
                            ZIndex = props.ZIndex + 1,
                        }, {
                            React.createElement("UICorner", {
                                CornerRadius = UDim.new(0.5, 0),
                            }),
                            React.createElement("UIStroke", {
                                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                Thickness = 4,
                                Color = Color3.new(1, 1, 1),
                            }),
                        }),
                    }),
            }),
        })
    end)
end

return function(props: Props)
    return React.createElement(Slider, props)
end
