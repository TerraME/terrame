-- @example A model with 100 moving and growing Agents.
-- An Agent moves to an empty random cell in each time step and
-- reproduces if it finds another empty random cell, given a
-- probability.
-- @arg GROWTH_PROB The probability of an agent to reproduce in an
-- empty neighbor cell. The default value is 0.3.
-- @image growing-moving-society.png

GROWTH_PROB = 0.3

local pgrowth = Random{p = GROWTH_PROB}

singleFooAgent = Agent{
	execute = function(self)
		local cell = self:getCell():getNeighborhood():sample()
		if cell:isEmpty() and pgrowth:sample() then
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

chart = Chart{
	target = soc
}

map = Map{
	target = cs,
	grouping = "placement",
	value = {0, 1},
	color = {"green", "red"}
}

t = Timer{
	Event{action = soc},
	Event{action = cs},
	Event{action = chart},
	Event{action = map}
}

t:run(40)

