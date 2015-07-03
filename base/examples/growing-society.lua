-- @example A model with static agents that can reproduce to neighbor cells.

singleFooAgent = Agent{
	execute = function(self)
		local cell = self:getCell():getNeighborhood():sample()
		if cell.state == "empty" and math.random() < 0.3 then
			local child = self:reproduce()
			child:move(cell)
			cell.state = "full"
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

t:execute(120)

