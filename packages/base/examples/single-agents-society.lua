-- @example A model with 30 moving Agents.
-- @image single-agents-society.bmp

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

t = Timer{
	Event{action = soc},
	Event{action = cs}
}

m = Map{
	target = soc,
	symbol = "smile",
	color = "yellow",
	background = "darkGreen",
	size = 25
}

t:execute(100)

