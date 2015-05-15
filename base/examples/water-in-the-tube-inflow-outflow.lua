-- @example A model that describes water flowing in and out of a tube.

world = Cell{water = 40}

Chart{
    subject = world,
	pen = "dash"
}

t = Timer{
    Event{action = function()
    	if world.water > 5 then
	        world.water = world.water - 5
	    else
	    	world.water = 0
	    end
    end},
    Event{start = 10, period = 10, action = function()
    	world.water = world.water + 40 -- also try 60
    end},
    Event{start = 0, action = function(e)
    	world:notify(e:getTime())
    end}
}

t:execute(40)

