-- @example Simulation of a Society with 30 moving Agents.
-- @image single-agents-society.png

singleFooAgent = Agent{
	execute = function(self)
		local cell = self:getCell():getNeighborhood():sample()
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
	xdim = 10
}

cs:createNeighborhood()

e = Environment{
	cs,
	soc
}

e:createPlacement{max = 5}

m = Map{
	target = soc,
	symbol = "smile",
	color = "yellow",
	background = "darkGreen",
	size = 25
}

t = Timer{
	Event{action = soc},
	Event{action = m}
}

t:run(100)

