-- @example A simple example with one Agent that moves randomly in space.

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

cs = CellularSpace{
	xdim = 30
}

cs:createNeighborhood()

e = Environment{
	cs,
	singleFooAgent
}

e:createPlacement()

t = Timer{
	Event{action = singleFooAgent},
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

