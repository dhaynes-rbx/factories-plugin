--!strict
local Roact = require(script.Parent.Parent.Parent.Roact)

type GapProps = {
    Size: number -- OffsetOrUDim,,,
}

function Gap(propsOrNumber: (GapProps | number))
    local sizeAsOffsetNumber = type(propsOrNumber) == "table" and propsOrNumber.Size or propsOrNumber
    -- TODO: Gap within a Row / Column should size in that axis
    local inRow = false
    -- e.g. Gap in a Column sets Height and 100% Width
    local size = UDim2.new(1, 0, 0, sizeAsOffsetNumber)
    -- e.g. Gap in a Row sets Width and 100% Height
    if inRow then
        size = UDim2.new(0, sizeAsOffsetNumber, 1, 0)
    end

    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        Size = size,
        AutomaticSize = Enum.AutomaticSize.None,
    })
end

return Gap
