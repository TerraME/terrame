-- @example A simple example with one Agent that moves randomly in space.

singleFooAgent = Agent{
	execute = function(self)
		self:walk()
	end
}

cs = CellularSpace{
	xdim = 10
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

m = Map{
	target = singleFooAgent,
	symbol = "turtle"
}

t:execute(100)

