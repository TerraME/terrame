-- @example A simple model that describes water flowing out of a tube.
-- @image tube.png

world = Cell{
	water = 40,
	execute = function(world)
        world.water = world.water - 5
	end
}

chart = Chart{
    target = world,
	yLabel = "Gallons"
}

t = Timer{
    Event{action = world},
	Event{action = chart}
}

t:run(10)

