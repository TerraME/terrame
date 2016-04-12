-- @example A simple example with one Agent that moves randomly in space.
-- @image single-agent.bmp

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

m = Map{
	target = singleFooAgent,
	symbol = "turtle",
	background = "green"
}

t = Timer{
	Event{action = singleFooAgent},
	Event{action = m}
}

t:run(100)

