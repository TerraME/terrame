-- @example A model that describes water flowing out of a tube. It uses
-- an observation step more frequent than the execution.

world = Cell{water = 40}

Chart{
    target = world,
	yLabel = "Gallons",
}

t = Timer{
    Event{action = function()
        world.water = world.water - 5
    end},
    Event{start = 0, period = 0.25, action = function(e)
    	world:notify(e:getTime())
    end}
}

t:execute(8)

