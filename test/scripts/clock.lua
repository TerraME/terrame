local timer

timer = Timer{
	ev1 = Event{priority =  1, action = function(event) timer:notify() end},
	ev2 = Event{priority = 10, action = function(event) timer:notify() end},
	ev3 = Event{priority = 10, action = function(event) timer:notify() end},
	ev4 = Event{priority = 10, action = function(event) timer:notify() end}
}

Clock{target = timer}
timer:execute(200)
	
_Gtme.killAllObservers()
