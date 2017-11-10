--[[ [previous](05-neighborhood.lua) | [contents](00-contents.lua) | [next](07-model-sir.lua) ]]

timer = Timer{
	Event{action = function()
		print("Rained")
	end}
}

timer:run(10)

cell = Cell{
	water = 0,
	execute = function(self)
		self.water = self.water + 1
	end
}

world = CellularSpace{
	xdim = 50,
	instance = cell
}

map = Map{
	target = world,
	select = "water",
	min = 0,
	max = 40,
	color = "Blues",
	slices = 5
}

timer = Timer{
	Event{action = world},
	Event{action = map}
}

timer:run(40)

