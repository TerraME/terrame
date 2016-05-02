cs = CellularSpace{
	xdim = 10
}

forEachCell(cs, function(cell)
	cell.w = cell.w + 1
end)

