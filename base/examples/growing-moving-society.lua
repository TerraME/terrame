-- @example A model with 100 moving and growing agents.
-- @arg GROWTH_PROB The probability of an agent to reproduce in an
-- empty neighbor cell. The default value is 0.3.

GROWTH_PROB = 0.3

EMPTY = 0
FULL = 1

singleFooAgent = Agent{
	execute = function(self)
		local cell = self:getCell():getNeighborhood():sample()
		if cell.state == EMPTY and math.random() < GROWTH_PROB then
			local child = self:reproduce()
			child:move(cell)
			cell.state = FULL
		end
		cell = self:getCell():getNeighborhood():sample()
		if cell.state == EMPTY then
			self:getCell().state = EMPTY
			self:move(cell)
			cell.state = FULL
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
	cell.state = EMPTY
end)

forEachAgent(soc, function(agent)
	agent:getCell().state = FULL
end)

--[[

leg = Legend {
	grouping = "uniquevalue",
	colorBar = {
		{value = EMPTY, color = "white"},
		{value = FULL, color = "black"}
	}
}

Observer {
	subject = cs,
	attributes = {"state"},
	legends = {leg}
}
--]]
t:execute(40)

