-- @example A model with 30 moving agents.

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

Map{
	target = soc,
	size = 25,
	symbol = "scorpion"
}

t:execute(100)

