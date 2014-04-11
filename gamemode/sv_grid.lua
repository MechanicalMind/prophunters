
ClassGrid = class()
local Grid = ClassGrid

function Grid:initialize(sqsize, sizeleft, sizeup, sizeright, sizedown)
	self.squares = {}
	if sizeleft then
		self.sizeLeft = sizeleft
		self.sizeRight = sizeright
		self.sizeDown = sizedown
		self.sizeUp = sizeup
	end

	self.sqsize = sqsize
end

function Grid:getWidth()
	return self.sizeLeft + self.sizeRight + 1
end

function Grid:getHeight()
	return self.sizeUp + self.sizeDown + 1
end

function Grid:setSquare(x, y, abc)
	local str = x .. ":" .. y
	self.squares[str] = abc
end

function Grid:getSquare(x, y)
	local str = x .. ":" .. y
	return self.squares[str]
end

function Grid:checkSquare(x, y)
	if x < -self.sizeLeft then return true end
	if x > self.sizeRight then return true end
	if y < -self.sizeUp then return true end
	if y > self.sizeDown then return true end
	return self:getSquare(x, y) != nil
end

function Grid:countEmptySquares(x1, y1, x2, y2)
	local c = 0
	for x = x1, x2 do
		for y = y1, y2 do
			if self:getSquare(x, y) == nil then
				c = c + 1
			end
		end
	end
	return c
end

function Grid:generateWalkable()
	local empty = Grid(self.sqsize, self.sizeLeft, self.sizeUp, self.sizeRight, self.sizeDown)

	for x = -self.sizeLeft, self.sizeRight do
		for y = -self.sizeUp, self.sizeDown do
			local sq = self:getSquare(x, y)
			if !IsValid(sq) || sq.gridWalkable then
				empty:setSquare(x, y, {x = x, y = y, sq = self:getSquare(x, y)})
			end
		end
	end

	return empty
end


function Grid:generateEmpty()
	local empty = Grid(self.sqsize, self.sizeLeft, self.sizeUp, self.sizeRight, self.sizeDown)

	for x = -self.sizeLeft, self.sizeRight do
		for y = -self.sizeUp, self.sizeDown do
			local sq = self:getSquare(x, y)
			if !IsValid(sq) then
				empty:setSquare(x, y, {x = x, y = y, sq = self:getSquare(x, y)})
			end
		end
	end

	return empty
end
