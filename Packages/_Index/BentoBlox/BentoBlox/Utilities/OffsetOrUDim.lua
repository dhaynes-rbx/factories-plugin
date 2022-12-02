--!strict
type OffsetOrUDim = number | UDim;

-- not type corect when given a nil / non OffsetOrUDim value
local function asUDim(offsetOrUDim: OffsetOrUDim): UDim
    if type(offsetOrUDim) == "number" then
        return UDim.new(0, offsetOrUDim)
    else
        return offsetOrUDim
    end
end

return asUDim
