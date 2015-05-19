-- @example A model with static agents that can reproduce to neighbor cells.

EMPTY = 0
FULL = 1

singleFooAgent = Agent{
	execute = function(self)
		local cell = self:getCell():getNeighborhood():sample()
		if cell.state == EMPTY and math.random() < 0.3 then
			local child = self:reproduce()
			child:move(cell)
			cell.state = FULL
		end
	end
}

soc = Society{
	instance = singleFooAgent,
	quantity = 10
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

t:execute(5)

