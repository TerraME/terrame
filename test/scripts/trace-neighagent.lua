cs = CellularSpace{
	xdim = 10
}

cs:createNeighborhood()

soc = Society{
	quantity = 50,
	instance = Agent{}
}

env = Environment{cs, soc}
env:createPlacement{}

forEachNeighborAgent(soc:sample(), function()
	w = w + 1
end)

