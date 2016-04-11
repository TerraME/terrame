-- @example A simple spread model that uses geospatial data.
-- It simulates a fire in Parque Nacional das Emas, in Goias state,
-- Brazil. It has probabilities for fire spread according to the
-- biomass stored in each cell. \
-- This model was proposed by Almeida, Rodolfo M., et al. (in portuguese)
-- 'Simulando padroes de incendios no Parque Nacional das Emas, Estado de
-- Goias, Brasil.' X Simposio Brasileiro de Geoinfoamatica (2008).
-- @arg STEPS The final simulation time. The default value is 80.
-- @image fire-spread.bmp

STEPS = 80

-- automaton states
NODATA     = 0
BIOMASS1   = 1
BIOMASS2   = 2
BIOMASS3   = 3
BIOMASS4   = 4
BIOMASS5   = 5
RIVER       = 6
FIREBREAK   = 7
BURNING     = 8
BURNED      = 9

-- probability matrix according to the levels of forest
-- I[X][Y] is the probability of a burning cell with BIOMASSX
-- to spread fire to a cell with BIOMASSY
I =	{{0.100, 0.250, 0.261, 0.273, 0.285},
	 {0.113, 0.253, 0.264, 0.276, 0.288},
	 {0.116, 0.256, 0.267, 0.279, 0.291},
	 {0.119, 0.259, 0.270, 0.282, 0.294},
	 {0.122, 0.262, 0.273, 0.285, 0.297}}

randomObj = Random{seed = 600}

cell = Cell{
	execute = function(cell)
		forEachNeighbor(cell, function(cell, neigh)
			if neigh.state <= BIOMASS5 then
				local p = randomObj:number()
				if p < I[cell.accumulation][neigh.accumulation] then
					neigh.state = BURNING
				end
			end
		end)
		cell.state = BURNED
	end,
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

Map{
	target = cs,
	select = "state",
	color = {"white", "lightGreen",   "lightGreen",   "green",   "darkGreen",   "darkGreen",   "blue", "brown",   "red",   "black"},
	value = {NODATA, BIOMASS1, BIOMASS2, BIOMASS3, BIOMASS4, BIOMASS5, RIVER,  FIREBREAK, BURNING, BURNED},
	label = {"NoData", "Biomass1", "Biomass2", "Biomass3", "Biomass4", "Biomass5", "River", "Firebreak", "Burning", "Burned"}
}

cs:createNeighborhood()

itF = Trajectory{
	target = cs,
	select = function(cell) return cell.state == BURNING end
}

t = Timer{
	Event{action = function()
		itF:execute()
		cs:notify()
		itF:filter()
	end}
}

t:run(STEPS)

