-- @example A model with 30 moving agents.

singleFooAgent = Agent{
	execute = function(self)
		local cell = self:getCell():getNeighborhood():sample()
		if cell.state == "empty" then
			self:getCell().state = "empty"
			self:move(cell)
			cell.state = "full"
		end
	end
}

soc = Society{
	instance = singleFooAgent,
	quantity = 20
}

cs = CellularSpace{
	xdim = 30
}

cs:createNeighborhood()

e = Environment{
	cs,
	soc
}

e:createPlacement{max = 1}

t = Timer{
	Event{action = soc},
	Event{action = cs}
}

forEachCell(cs, function(cell)
	cell.state = "empty"
end)

Map{
	target = cs,
	select = "state",
	color = {"black", "white"},
	value = {"full", "empty"}
}

t:execute(100)

