--!strict
type OffsetOrUDim = number | UDim;
type PaddingShorthand = OffsetOrUDim | { OffsetOrUDim };
-- type PaddingShorthand2Axis = { "1": OffsetOrUDim, "2": OffsetOrUDim };
-- type PaddingShorthand4Axis = { "1": OffsetOrUDim, 2: OffsetOrUDim, 3: OffsetOrUDim, 4: OffsetOrUDim };

type PaddingShorthandProps = {
    Padding: PaddingShorthand?,
    -- Overides a single value Padding in corresponding axis, if present
    -- (will not override a {h, v} or {top, right, bottom, left})
    PaddingHorizontal: OffsetOrUDim?,
    PaddingVertical: OffsetOrUDim?,
    -- Highest precedence
    PaddingTop: OffsetOrUDim?,
    PaddingRight: OffsetOrUDim?,
    PaddingBottom: OffsetOrUDim?,
    PaddingLeft: OffsetOrUDim?,
}

type PaddingFinal = {
    PaddingTop: UDim,
    PaddingRight: UDim,
    PaddingBottom: UDim,
    PaddingLeft: UDim
}

-- not type corect when given a nil / non OffsetOrUDim value
-- TODO replace with require on dedicated helper
local function asUDim (offsetOrUdim: OffsetOrUDim) : UDim
    if type(offsetOrUdim) == "number" then
        return UDim.new(0, offsetOrUdim);
    else
        return offsetOrUdim
    end
end

--[[
Given various Padding definitions, from shorthand to explicit, expand out final padding.

Specific paddings override base padding.
```
{ Padding = 10, PaddingTop = 20 } => {
    PaddingTop = 20,
    PaddingRight = 10,
    PaddingBottom = 10,
    PaddingLeft = 10
}
```
]]--
local function paddingByShorthandProps(props: PaddingShorthandProps) : (PaddingFinal | nil)
    
    -- No Padding (all values nil or 0):
    if
        (
            props.Padding == nil or
            props.Padding == 0 or
            type(props.Padding) == "table" and (
                (props.Padding[1] == nil or props.Padding[1] == 0) and
                (props.Padding[2] == nil or props.Padding[2] == 0) and
                (props.Padding[3] == nil or props.Padding[3] == 0) and
                (props.Padding[4] == nil or props.Padding[4] == 0)
                -- two argument array { horizontal, vertical } also covered by above case
            )
        )
        and
        (
            (props.PaddingTop == nil or props.PaddingTop == 0) and
            (props.PaddingRight == nil or props.PaddingRight == 0) and
            (props.PaddingBottom == nil or props.PaddingBottom == 0) and
            (props.PaddingLeft == nil or props.PaddingLeft == 0)
        )
        and
        (
            (props.PaddingHorizontal == nil or props.PaddingHorizontal == 0) and
            (props.PaddingVertical == nil or props.PaddingVertical == 0)
        )
    then
        return nil -- return nil so consumer can skip creating padding objects
    end

    -- Expand PaddingHorizontal and PaddingVertical to UDims if numbers
    props.PaddingHorizontal = asUDim(props.PaddingHorizontal);
    props.PaddingVertical = asUDim(props.PaddingVertical);

    -- Expand single number or UDim Padding to indicies
    -- if type(props.Padding) == "number" or type(props.Padding) == "UDim" then
    if type(props.Padding) ~= "table" then
        -- note that PaddingHorizontal and PaddingVertical override single values
        local padding = asUDim(props.Padding)
        props.Padding = {
            props.PaddingVertical or padding,
            props.PaddingHorizontal or padding,
            props.PaddingVertical or padding,
            props.PaddingHorizontal or padding
        }
    -- Expand Padding table/array of length two {h, v} into length 4 array {top, right, bottom, left}
    elseif props.Padding.length == 2 then
        -- note that PaddingHorizontal and PaddingVertical override their shorthand equivalents
        props.Padding = {
            props.PaddingVertical or props.Padding[2],
            props.PaddingHorizontal or props.Padding[1],
            props.PaddingVertical or props.Padding[2],
            props.PaddingHorizontal or props.Padding[1]
        }
    end

    -- And lastly PaddingTop, etc... override any previous level of specificity
    return {
        PaddingTop = asUDim(props.PaddingTop or props.Padding[1]),
        PaddingRight = asUDim(props.PaddingRight or props.Padding[2]),
        PaddingBottom = asUDim(props.PaddingBottom or props.Padding[3]), 
        PaddingLeft = asUDim(props.PaddingLeft or props.Padding[4])
        -- is there extra work being done above that could just be this or statement?
    }
end

return paddingByShorthandProps