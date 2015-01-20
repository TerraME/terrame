
-- @example A simple model that describes water flowing out of a tube.

world = Cell{water = 40}

Chart{
    subject = world,
	yLabel = "Gallons"
}

world:notify(0)

t = Timer {
    Event {action = function(e)
        world.water = world.water - 5
        world:notify(e:getTime())
    end}
}

t:execute(8)
