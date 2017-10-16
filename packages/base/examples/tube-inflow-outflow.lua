-- @example A model that describes water flowing in and out of a tube.
-- This implementation also verifies does not allow to have negative
-- amounts of water in the tube.
-- @image tube-inflow-outflow.png

world = Cell{
	water = 40,
	execute = function(world)
		if world.water > 5 then
			world.water = world.water - 5
		else
			world.water = 0
		end
	end
}

chart = Chart{
	target = world,
	pen = "dash"
}

t = Timer{
	Event{action = world},
	Event{period = 10, action = function()
		world.water = world.water + 40 -- try another value
	end},
	Event{action = chart}
}

t:run(40)

