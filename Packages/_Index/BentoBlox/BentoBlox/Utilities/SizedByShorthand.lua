-- TODO: Support tokens in these values, e.g. Height: UDim | GapToken

type OffsetOrUDim = number | UDim
type Sizable = {
    Height: OffsetOrUDim?,
    Width: OffsetOrUDim?,
    Size: UDim2?, -- TODO: type Offset2OrUDim2 = { number } | UDim2
    AutomaticSize: Enum.AutomaticSize?,
}

-- not type corect when given a nil / non OffsetOrUDim value
local function asUDim(offsetOrUDim: OffsetOrUDim): UDim
    if type(offsetOrUDim) == "number" then
        return UDim.new(0, offsetOrUDim)
    else
        return offsetOrUDim
    end
end

--[[
Given Width, Height, Size and/or AutomaticSize property, return the resolved or default sizing parameters.
]]
--
local function sizedByProps(sizableProps: Sizable): {
    Size: UDim2,
    AutomaticSize: Enum.AutomaticSize,
}
    local automaticSize = sizableProps.AutomaticSize

    -- No need to provide Size if automatic sizing in both axis
    if automaticSize == Enum.AutomaticSize.XY then
        return { AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.new(0, 0, 0, 0) }
    end

    -- Only use Width or Height if Size is absent
    local size = sizableProps.Size
    if size == nil then
        local hasWidth = sizableProps.Width ~= nil
        local hasHeight = sizableProps.Height ~= nil
        -- If both Width and Height are provided set size by merging
        if hasWidth and hasHeight then
            -- TODO: Bug here? does UDim2.new actually accept (UDim, UDim) ?
            size = UDim2.new(asUDim(sizableProps.Width), asUDim(sizableProps.Height))
            automaticSize = Enum.AutomaticSize.None
        -- If Width only, set Automatic Y
        elseif hasWidth then
            local width = asUDim(sizableProps.Width)
            size = UDim2.new(width.Scale, width.Offset, 0, 0)
            automaticSize = automaticSize or Enum.AutomaticSize.Y
        -- If Height only, set Automatic X
        elseif hasHeight then
            local height = asUDim(sizableProps.Height)
            size = UDim2.new(0, 0, height.Scale, height.Offset)
            automaticSize = automaticSize or Enum.AutomaticSize.X
        -- no Height or Width, AutomaticSize may be set
        else
            -- fill parent width, grow height by content
            size = UDim2.new(1, 0, 0, 0)
            automaticSize = automaticSize or Enum.AutomaticSize.Y
        end
    end

    return {
        Size = size,
        AutomaticSize = automaticSize,
    }
end

return sizedByProps
