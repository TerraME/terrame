
NO_DATA	 = 0
INACTIVE1   = 1
INACTIVE2   = 2
INACTIVE3   = 3
INACTIVE4   = 4
INACTIVE5   = 5
RIVER	   = 6
FIREBREAK   = 7
BURNING	 = 8
BURNED	  = 9

cell = Cell{
	init = function(cell)
		cell.accumulation = cell.accuation

		if cell.firebreak == 1 then
			cell.state = FIREBREAK
		elseif cell.river == 1 then
			cell.state = RIVER
		elseif cell.fire == 1 then
			cell.state = BURNING
		else
			cell.state = cell.accumulation
		end
	end
}

cs = CellularSpace{
	file = filePath("emas.shp"),
	instance = cell
}

obs = Map{
	target = cs,
	select = "state",
	color = {"white", "green",   "green",   "green",   "green",   "green",   "blue", "brown",   "red",   "black"},
	value = {NO_DATA, INACTIVE1, INACTIVE2, INACTIVE3, INACTIVE4, INACTIVE5, RIVER,  FIREBREAK, BURNING, BURNED}
}

obs:save("emas.bmp")

clean()

