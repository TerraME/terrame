
-- @example A model with static agents that can reproduce.

EMPTY = 0
FULL = 1

singleFooAgent = Agent {
	execute = function(self)
		cell = self:getCell():getNeighborhood():sample()
		if cell.state == EMPTY and math.random() < 0.3 then
			child = self:reproduce()
			child:move(cell)
			cell.state = FULL
		end
		cell = self:getCell():getNeighborhood():sample()
		if cell.state == EMPTY then
			self:move(cell)
		end
	end
}

soc = Society{
	instance = singleFooAgent,
	quantity = 10
}

cs = CellularSpace {
	xdim = 100
}

cs:createNeighborhood()

e = Environment {
	cs,
	soc
}

e:createPlacement{max = 1}

Chart{
	subject = soc
}

soc:notify(0)

t = Timer {
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

t:execute(5)

