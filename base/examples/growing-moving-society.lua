-- @example A model with 100 moving and growing Agents.
-- @arg GROWTH_PROB The probability of an agent to reproduce in an
-- empty neighbor cell. The default value is 0.3.

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

e:createPlacement{max = 1}

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

Map{
	target = soc
}

t:execute(40)

