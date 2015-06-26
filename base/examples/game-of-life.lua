-- @example Implementation of Conway's Game of Life.
-- It creates the initial distribution of alive cells randomly.
-- @arg PROBABILITY The probability of a Cell to be alive in the
-- beginning of the simulation. The default value is 0.15.
-- @arg TURNS The number of simulation steps. The default value is 20.

-- [[
PROBABILITY = 0.15
TURNS = 20

r = Random{seed = 12345}

cell = Cell{
	init = function(cell)
		local v = r:number()
		if v <= PROBABILITY then
			cell.state = "alive"
		else
			cell.state = "dead"
		end
	end,
	countAlive = function(cell)
		local count = 0
		forEachNeighbor(cell, function(cell, neigh)
			if neigh.past.state == "alive" then
				count = count + 1
			end
		end)
		return count
	end,
	execute = function(cell)
		local n = cell:countAlive()
		if cell.state == "alive" and (n > 3 or n < 2) then
			cell.state = "dead"
		elseif cell.state == "dead" and n == 3 then
			cell.state = "alive"
		else
			cell.state = cell.past.state
		end 
	end
}

cs = CellularSpace{
	xdim = 50,
	instance = cell
}	   

cs:createNeighborhood()
-- [[
lifeLeg = _Gtme.Legend{
	grouping = "uniquevalues",
	colorBar = {
		{color = "black", value = "alive"},
		{color = "white", value = "dead"}
	},
	size = 1,
	pen = 2
}

obs = _Gtme.Observer{
	target = cs,
	attributes = {"state"},
	legends = {lifeLeg}
}
--]]

timer = Timer{
	Event{action = function()
		cs:synchronize()
		cs:execute()
--		cs:notify()
	end}
}

timer:execute(TURNS)
--]]

