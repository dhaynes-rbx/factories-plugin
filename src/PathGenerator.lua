local module = {}

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local partTemplate = Instance.new('Part')
partTemplate.Anchored = true
partTemplate.TopSurface = 'Smooth'
partTemplate.BottomSurface = 'Smooth'

local cylinderTemplate = partTemplate:Clone()
cylinderTemplate.Shape = Enum.PartType.Cylinder

local tau = math.pi*2
local abs = math.abs

function generateBend(innerRadius, width, thickness, angle, debugMode)
	if angle <=0 or angle > tau*(3/4) then
		warn("GenerateBend only properly supports angles between 0 and 270 degrees.")
	end
	local outerRadius = innerRadius + width

	local innerCircle = cylinderTemplate:Clone()
	innerCircle.Size = Vector3.new(thickness+1, innerRadius*2, innerRadius*2)
	innerCircle.CFrame = CFrame.Angles(0, 0, tau/4)

	local outerCircle = cylinderTemplate:Clone()
	outerCircle.Size = Vector3.new(thickness, outerRadius*2, outerRadius*2)
	outerCircle.CFrame = CFrame.Angles(0, 0, tau/4)

	local edge1 = partTemplate:Clone()
	if angle <= tau/2 then
		edge1.Size = Vector3.new(outerRadius*2+1, thickness+1, outerRadius*2*2+1)
		edge1.CFrame = CFrame.new(-edge1.Size.X/2, 0, 0)
	else
		edge1.Size = Vector3.new(outerRadius*2+1, thickness+1, outerRadius*2+1)
		edge1.CFrame = CFrame.new(-edge1.Size.X/2, 0, -edge1.Size.Z/2)
	end

	local edge2 = edge1:Clone()
	if angle <= tau/2 then
		edge2.CFrame = CFrame.Angles(0, -angle, 0) * CFrame.new(edge2.Size.X/2, 0, 0)
	else
		edge2.CFrame = CFrame.Angles(0, -angle, 0) * CFrame.new(edge2.Size.X/2, 0, -edge2.Size.Z/2)
	end

	outerCircle.Parent = ReplicatedStorage
	local bend = outerCircle:SubtractAsync({innerCircle, edge1, edge2})
	bend.PivotOffset = bend.CFrame:ToObjectSpace(CFrame.new(0,0,0))

	if debugMode then
		edge1.Color = Color3.new(0,0,1)
		edge1.Transparency = .5
		edge1.Parent = bend

		edge2.Color = Color3.new(1,0,0)
		edge2.Transparency = .5
		edge2.Parent = bend
	end

	return bend
end

function generateBasicPath(p1, p2, width, thickness, desiredRadius)
	if p1.Z > p2.Z then
		p1, p2 = p2, p1
	end

	local length = abs(p2.Z - p1.Z)
	local height = abs(p2.X - p1.X)
	local midPos = (p1+p2)*.5
	
	local centerRadius = desiredRadius or height/2

	if centerRadius*2 > length then
		centerRadius = length/2
	end
	if centerRadius*2 > height then
		centerRadius = height/2
	end

	local partLength = length/2 - centerRadius

	local bendingUp = p2.X-p1.X > 0 and 1 or -1
	local extraBendRot = bendingUp == 1 and tau/2 or -tau/4

	local part1Length = partLength
	local bend1Height = centerRadius
	local vertPartLength = height - centerRadius*2
	local bend2Height = centerRadius
	local part2Length = partLength

	local components = {}

	if part1Length > 0 then
		local part1 = partTemplate:clone()
		part1.Size = Vector3.new(width, thickness, part1Length)
		part1.CFrame = CFrame.new(p1 + Vector3.new(0, 0, part1Length*.5))
		table.insert(components, part1)
	end

	if bend1Height > 0 then
		local bend1 = generateBend(bend1Height - width/2, width, thickness, tau/4)
		bend1:PivotTo(CFrame.new(Vector3.new(p1.X + centerRadius*bendingUp, p1.Y, p1.Z+part1Length )) * CFrame.Angles(0,extraBendRot,0))
		table.insert(components, bend1)
	end

	if vertPartLength > 0 then
		local vertPart = partTemplate:clone()
		vertPart.Size = Vector3.new(width, thickness, vertPartLength)
		vertPart.CFrame = CFrame.new(midPos) * CFrame.Angles(0,tau/4,0)
		table.insert(components, vertPart)
	end

	if bend2Height > 0 then
		local bend2 = generateBend(bend2Height - width/2, width, thickness, tau/4)
		bend2:PivotTo(CFrame.new(Vector3.new(p2.X - centerRadius*bendingUp, p2.Y, p2.Z-part2Length)) * CFrame.Angles(0,extraBendRot + tau/2,0))
		table.insert(components, bend2)
	end

	if part2Length > 0 then
		local part2 = partTemplate:clone()
		part2.Size = Vector3.new(width, thickness, part2Length)
		part2.CFrame = CFrame.new(p2 + Vector3.new(0, 0, part2Length*-.5))
		table.insert(components, part2)
	end


	local primaryPart = table.remove(components,1)
	primaryPart.Parent = ReplicatedStorage
	local path = primaryPart:UnionAsync(components)
	path.Locked = true
	
	return path
end

module.GenerateBend = generateBend	--(innerRadius, width, thickness, angle)
module.GenerateBasicPath = generateBasicPath	--(p1, p2, width, thickness)

return module