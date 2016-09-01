-- @example Implementation of a simple runoff model using geospatial data.
-- There is an initial rain in the highest cells.
-- The Neighborhood of a Cell is composed by its Moore neighbors that
-- have lower height.
-- Each cell then sends its water equally to all neighbors. 
-- @image runoff.bmp

cell = Cell{
	init = function(cell)
		cell.water = 0
	end,
	rain = function(cell)
		if cell.height > 200 then
			cell.water = cell.water + 200
		end
	end,
	logwater = function(cell)
		if cell.water < 1 then
			return 0
		else
			return math.log(cell.water)
		end
	end,
	runoff = function(cell)
		local quantity = cell.past.water / #cell:getNeighborhood()

		forEachNeighbor(cell, function(_, neighbor)
			neighbor.water = neighbor.water + quantity
		end)
	end
}

cs = CellularSpace{
	file = filePath("cabecadeboi.shp"),
	instance = cell,
	as = {height = "height_"}
}

cs:createNeighborhood{
	strategy = "mxn",
	filter = function(cell, cell2)
		return cell.height >= cell2.height
	end
}

map1 = Map{
	target = cs,
	select = "height",
	min = 0,
	max = 260,
	slices = 8,
	color = "Grays"
}

map2 = Map{
	target = cs,
	select = "logwater",
	min = 0,
	max = 30,
	slices = 15,
	color = "Blues"
}

timer = Timer{
	Event{action = function()
		cs:rain()
		return false
	end},
	Event{action = function()
		cs:synchronize()
		cs:init()
		cs:runoff()
	end},
	Event{action = map1},
	Event{action = map2}
}

timer:run(100)

