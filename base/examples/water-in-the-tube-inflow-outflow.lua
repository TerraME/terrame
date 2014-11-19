
-- @example A model that describes water flowing in and out of a tube.

world = Cell{water = 40}

o = Observer{
    subject = world,
    type = "chart",
    attributes = {"water"}
}

t = Timer {
    Event {time = 1, period = 1, action = function()
    	if world.water > 5 then
	        world.water = world.water - 5
	    else
	    	world.water = 0
	    end
    end},
    Event {time = 10, period = 10, action = function()
    	world.water = world.water + 40 -- also try 60
    end},
    Event {time = 0, period = 1, action = function(e)
    	world:notify(e:getTime())
    end}
}

t:execute(40)
