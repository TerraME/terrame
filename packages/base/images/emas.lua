-- automaton states
NODATA     = 0
BIOMASS1   = 1
BIOMASS2   = 2
BIOMASS3   = 3
BIOMASS4   = 4
BIOMASS5   = 5
RIVER      = 6
FIREBREAK  = 7
BURNING    = 8
BURNED     = 9

cell = Cell{
	init = function(cell)
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
	instance = cell,
	as = {
		accumulation = "maxcover" -- test also with "mincover"
	}
}

map = Map{
	target = cs,
	select = "state",
	color = {"white",  "lightGreen", "lightGreen", "green",    "darkGreen", "darkGreen", "blue",  "brown",     "red",     "black"},
	value = {NODATA,   BIOMASS1,     BIOMASS2,     BIOMASS3,   BIOMASS4,    BIOMASS5,    RIVER,   FIREBREAK,   BURNING,   BURNED},
	label = {"NoData", "Biomass1",   "Biomass2",   "Biomass3", "Biomass4",  "Biomass5",  "River", "Firebreak", "Burning", "Burned"}
}


map:save("emas.bmp")

clean()

