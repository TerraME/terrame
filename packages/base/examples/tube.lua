-- @example A simple model that describes water flowing out of a tube.
-- @image tube.bmp

world = Cell{water = 40}

chart = Chart{
    target = world,
	yLabel = "Gallons"
}

world:notify(0)

t = Timer{
    Event{action = function()
        world.water = world.water - 5
        world:notify()
    end}
}

t:execute(8)

