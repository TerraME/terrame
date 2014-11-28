
-- @example A simple implementation of Sugarscape model.
-- It is based on Epstein and Axtell's book Growing Artificial Societies.

cell = Cell{
	init = function()
		cell.sugar = math.random(0, 4)
	end
}

cs = CellularSpace{
	xdim = 20,
	instance = cell
}

cs:createNeighborhood()

rand = Random{}

agent = Agent{
	init = function(ag)
		ag.wealth = rand:integer(10, 30)
		ag.age    = rand:integer(10, 40)
		ag.placed = rand:integer(0, 8)
	end,
	execute = function(ag)
		ag.age = ag.age + 1
	end
}

soc = Society{
	instance = agent,
	quantity = 20
}

env = Environment{cs, soc}
env:createPlacement()

--[[
Chart{subject = soc}

Map{
	subject    = cs,
	select =     "color",
	--grouping   = "equalsteps",
	--maximum    = 4,
	--minimum    = 0,
	--slices     = 5,
	values     = {0, 1, 2, 3, 4},
	colors     = "Reds"
}
-]]
