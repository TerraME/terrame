-- @example A simple example with one Agent that moves randomly in space.

singleFooAgent = Agent{
	execute = function(self)
		local cell = self:getCell():getNeighborhood():sample()
		if cell:isEmpty() then
			self:move(cell)
		end
	end
}

cs = CellularSpace{
	xdim = 30
}

cs:createNeighborhood()

e = Environment{
	cs,
	singleFooAgent
}

e:createPlacement()

t = Timer{
	Event{action = singleFooAgent},
	Event{action = cs}
}

Map{
	target = singleFooAgent
}

t:execute(100)

