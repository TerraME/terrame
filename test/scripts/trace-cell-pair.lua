

cs = CellularSpace{
	xdim = 10
}

forEachCellPair(cs, cs, function(cell)
	cell.w = cell.w + 1
end)

