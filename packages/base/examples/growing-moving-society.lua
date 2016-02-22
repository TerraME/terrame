-- @example A model with 100 moving and growing Agents.
-- An Agent moves to an empty random cell in each time step and
-- reproduces if it finds another empty random cell, given a
-- probability.
-- @arg GROWTH_PROB The probability of an agent to reproduce in an
-- empty neighbor cell. The default value is 0.3.
-- @image growing-moving-society.bmp

GROWTH_PROB = 0.3

singleFooAgent = Agent{
	execute = function(self)
		local cell = self:getCell():getNeighborhood():sample()
		if cell:isEmpty() and math.random() < GROWTH_PROB then
			local child = self:reproduce()
			child:move(cell)
		end
		cell = self:getCell():getNeighborhood():sample()
		if cell:isEmpty() then
			self:move(cell)
		end
	end
}

soc = Society{
	instance = singleFooAgent,
	quantity = 100
}

cs = CellularSpace{
	xdim = 100
}

cs:createNeighborhood()

e = Environment{
	cs,
	soc
}

e:createPlacement{}

Chart{
	target = soc
}

soc:notify(0)

t = Timer{
	Event{action = soc},
	Event{action = cs},
	Event{action = function(e)
		soc:notify(e)
	end}
}

map = Map{
	target = cs,
	grouping = "placement",
	value = {0, 1},
	color = {"green", "red"}
}

t:run(40)

