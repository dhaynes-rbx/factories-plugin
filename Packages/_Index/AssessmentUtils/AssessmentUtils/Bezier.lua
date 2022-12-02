--!strict

--[[--
    @classmod Bezier class representing bezier to calculate points along the curve
]]

local Bezier = {}

function quadraticBezier(t: number, p0: Vector3, p1: Vector3, p2: Vector3)
    return (1 - t) ^ 2 * p0 + 2 * (1 - t) * t * p1 + t ^ 2 * p2
end

function cubicBezier(t: number, p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3)
    return (1 - t) ^ 3 * p0 + 3 * (1 - t) ^ 2 * t * p1 + 3 * (1 - t) * t ^ 2 * p2 + t ^ 3 * p3
end

function length(n: number, func, ...)
    local sum, ranges, sums = 0, {}, {}
    for i = 0, n - 1 do
        local p1, p2 = func(i / n, ...), func((i + 1) / n, ...)
        local dist = (p2 - p1).magnitude
        ranges[sum] = { dist, p1, p2 }
        table.insert(sums, sum)
        sum = sum + dist
    end
    return sum, ranges, sums
end

Bezier.Types = {
    Quadratic = "quadratic",
    Cubic = "cubic",
}

--[[--
    @function constructor instantiates new instances
    @string type - function type, quadratic | cubic
    @number n - number of points on the curve
    @tparam {Vector3} controlPoints - Array of control points
]]
function Bezier.new(type: string, n: number, controlPoints: { Vector3 })
    local self = setmetatable({}, { __index = Bezier })
    self.func = type == Bezier.Types.Quadratic and quadraticBezier or cubicBezier
    local sum, ranges, sums = length(n, self.func, unpack(controlPoints))
    self.n = n
    self.points = controlPoints
    self.length = sum
    self.ranges = ranges
    self.sums = sums
    return self
end

--[[--
    @function setControlPoints sets new control points and rebuilds cache
    @tparam {Vector3} controlPoints - Array of control points
]]
function Bezier:setControlPoints(controlPoints: { Vector3 })
    local sum, ranges, sums = length(self.n, self.func, unpack(controlPoints))
    self.points = controlPoints
    self.length = sum
    self.ranges = ranges
    self.sums = sums
end

--[[--
    @function calculate Calculates an individual timestep that is not a percentage of distance. This method does not make use of the cache and is therefore less performant.
    @number t - The timestep requested [0, 1]
]]
function Bezier:calculate(t: number)
    -- if you don't need t to be a percentage of distance
    return self.func(t, unpack(self.points))
end

--[[--
    @function calculateFixed Calculates an individual timestep that is a percentage of distance. This method does make use of the cache and is therefore more performant, but less precise depending on n.
    @number t - The timestep requested [0, 1]
]]
function Bezier:calculateFixed(t: number)
    local T, near = t * self.length, 0
    for _, n in next, self.sums do
        if (T - n) < 0 then
            break
        end
        near = n
    end
    local set = self.ranges[near]
    local percent = (T - near) / set[1]
    return set[2], set[3], percent
end

return Bezier
