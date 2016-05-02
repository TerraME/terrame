cs = CellularSpace{
	xdim = 10
}

cs:createNeighborhood()

forEachNeighborhood(cs.cells[1], function()
	w = w + 1
end)

