-- @example A simple fire spread model.
-- @arg finalTime The final simulation time. The default value is 20.
-- @image fire-spread.bmp

STEPS = 80

-- automaton states
NO_DATA     = 0
INACTIVE1   = 1
INACTIVE2   = 2
INACTIVE3   = 3
INACTIVE4   = 4
INACTIVE5   = 5
RIVER       = 6
FIREBREAK   = 7
BURNING     = 8
BURNED      = 9

-- probability matrix
I =	{{0.100, 0.250, 0.261, 0.273, 0.285},
	 {0.113, 0.253, 0.264, 0.276, 0.288},
	 {0.116, 0.256, 0.267, 0.279, 0.291},
	 {0.119, 0.259, 0.270, 0.282, 0.294},
	 {0.122, 0.262, 0.273, 0.285, 0.297}}

randomObj = Random{seed = 100}

cell = Cell{
	execute = function(cell)
		forEachNeighbor(cell, function(cell, neigh)
			if neigh.state <= INACTIVE5 then
				local p = randomObj:number()
				if p < I[cell.accumulation][neigh.accumulation] then
					neigh.state = BURNING
				end
			end
		end)
		cell.state = BURNED
	end,
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

config = getConfig()

cs = CellularSpace{
	dbType = config.dbType,
	host = config.host,
	user = config.user,
	password = config.password,
	database = "emas",
	theme = "cells1000x1000",
	select = {"firebreak", "river", "accumulation", "fire", "state"},
	instance = cell
}

obs = Map{
	target = cs,
	select = "state",
	color = {"white", "green",   "green",   "green",   "green",   "green",   "blue", "brown",   "red",   "black"},
	value = {NO_DATA, INACTIVE1, INACTIVE2, INACTIVE3, INACTIVE4, INACTIVE5, RIVER,  FIREBREAK, BURNING, BURNED}
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

t:execute(STEPS)

