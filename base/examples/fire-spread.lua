-- FIRE SPREAD MODELS
-- (C) 2010 INPE AND UFOP


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

-- global variables
STEPS        = 20  -- numero de iteracoes do modelo
burned_total = 0   -- estatistica

-- Create a legend for Observer Map
stateLeg = Legend{
	type = "number",
	grouping = "uniquevalue",
	slices = 5,
	precision = 6,
	maximum = BURNED,
	minimum = NO_DATA,
	colorBar = {
		{color = {255, 255, 255}, value = NO_DATA   },
		{color = {192, 255, 192}, value = INACTIVE1 },
		{color = {128, 255, 128}, value = INACTIVE2 },
		{color = {64, 255, 64},   value = INACTIVE3 },
		{color = {32, 255, 32},   value = INACTIVE4 },
		{color = {0, 255, 0},     value = INACTIVE5 },
		{color = {0, 0, 255},     value = RIVER     },
		{color = {128, 64, 64},   value = FIREBREAK },
		{color = {255, 0, 0},     value = BURNING   },
		{color = {0, 0, 0},       value = BURNED    }
		-- ,{{0, 0, 0}, 		BURNED		}
	}
}

-- matriz de probabilidades
I =	{{0.100, 0.250, 0.261, 0.273, 0.285},
	 {0.113, 0.253, 0.264, 0.276, 0.288},
	 {0.116, 0.256, 0.267, 0.279, 0.291},
	 {0.119, 0.259, 0.270, 0.282, 0.294},
	 {0.122, 0.262, 0.273, 0.285, 0.297}}

config = getConfig()

cs = CellularSpace{
	dbType = config.dbType,
	host = config.host,
	database = "db_emas",
	user = config.user,
	password = config.password,
	theme = "cells1000x1000",
	select = {"firebreak", "river", "accumulation", "fire", "state"}
}

--[[
obs = Observer{
	subject = cs,
	type = "map",
	attributes = {"state"},
	legends = {stateLeg}
}

cs:createNeighborhood()

-- create and calculate the "state" cell's attribute
forEachCell(cs, function(cell)
	if cell.firebreak == 1 then
		cell.state = FIREBREAK
	elseif cell.river == 1 then
		cell.state = RIVER
	elseif cell.fire == 1 then
		cell.state = BURNING
	else
		cell.state = cell.accumulation
	end
end)

local seed = os.time()
seed = seed % 1000000

local randomObj = Random { seed = seed }

-- model execution
for t = 1, STEPS do
	itF = Trajectory{
		target = cs,
		select = function(cell) return cell.state == BURNING end
	}

	forEachCell(itF, function(cell)
		forEachNeighbor(cell, function(cell,neigh)
			if (neigh ~= cell and neigh.state <= INACTIVE5) then
				p = randomObj:number()
				if p < I[cell.accumulation][neigh.accumulation] then
					neigh.state = BURNING
				end
			end
		end)
		cell.state = BURNED
		burned_total = burned_total + 1
	end)
	cs:notify()
end
--]]

