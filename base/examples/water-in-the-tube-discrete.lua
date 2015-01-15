
-- @example A model that describes water flowing out of a tube. It uses
-- an observation step more frequent than the execution.

world = Cell{water = 40}

o = Observer{
    subject = world,
    type = "chart",
	xLabel = "Time",
	yLabel = "Gallons",
    attributes = {"water"}
}

t = Timer {
    Event {action = function()
        world.water = world.water - 5
    end},
    Event {time = 0, period = 0.25, action = function(e)
    	world:notify(e:getTime())
    end}
}

t:execute(8)
