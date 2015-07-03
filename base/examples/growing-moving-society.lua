-- @example A model with 100 moving and growing agents.
-- @arg GROWTH_PROB The probability of an agent to reproduce in an
-- empty neighbor cell. The default value is 0.3.

GROWTH_PROB = 0.3

singleFooAgent = Agent{
	execute = function(self)
		local cell = self:getCell():getNeighborhood():sample()
		if cell.state == "empty" and math.random() < GROWTH_PROB then
			local child = self:reproduce()
			child:move(cell)
			cell.state = "full"
		end
		cell = self:getCell():getNeighborhood():sample()
		if cell.state == "empty" then
			self:getCell().state = "empty"
			self:move(cell)
			cell.state = "full"
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

forEachCell(cs, function(cell)
	cell.state = "empty"
end)

forEachAgent(soc, function(agent)
	agent:getCell().state = "full"
end)

Map{
	target = cs,
	select = "state",
	color = {"black", "white"},
	value = {"full", "empty"}
}

t:execute(40)

