-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP.
--
-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.
--
-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--          Pedro R. Andrade (pedro.andrade@inpe.br)
-------------------------------------------------------------------------------------------

return {
	Timer = function(unitTest)
		local timer = Timer()
		unitTest:assertEquals(type(timer), "Timer")
		unitTest:assertEquals(timer:getTime(), -math.huge)

		local cont1 = 0

		local ev1 = Event {priority = 1, period = 5, start = 0, action = function(event)
			unitTest:assertEquals(event:getTime(), cont1)
			unitTest:assertEquals(event:getPriority(), 1)
			cont1 = cont1 + event:getPeriod()
		end}

		local t = Timer{ev1}

		unitTest:assertType(t, "Timer")

		t:run(100)
		unitTest:assert(cont1 == 105)

		local countEvent = 0
		local clock1 = Timer{
			Event{start = 0, action = function()
				countEvent = countEvent + 1
			end}
		}

		clock1:run(10)

		unitTest:assertEquals(countEvent, 11)

		local count = 0
		local ag1 = Agent{execute = function() count = count + 1 end}
		local ag2 = Agent{execute = function() count = count + 1 end}
		local c = Cell{}
		local cs = CellularSpace{xdim = 5}

		forEachCell(cs, function(cell)
			cell.value = Random():integer(10)
		end)

		local traj = Trajectory{target = cs, greater = function(c1, c2) return c1.value > c2.value end}


		local soc = Society{instance = ag2, quantity = 5}

		t = Timer{
			Event{action = ag1},
			Event{action = soc},
			Event{action = c},
			Event{action = cs},
			Event{action = traj}
		}

		t:run(10)

		unitTest:assertEquals(60, count)

		local counter = 0

		t = Timer{
			Event{action = function(ev)
				ev:config{
					time = ev.time + 1,
					period = ev.period + 1,
					priority = ev.priority + 1
				}
				unitTest:assertType(ev.parent, "Timer")
				counter = counter + 1
			end}
		}

		t:run(15)

		unitTest:assertEquals(counter, 4)
		unitTest:assertEquals(t.events[1].time, 19)
		unitTest:assertEquals(t.events[1].period, 5)
		unitTest:assertEquals(t.events[1].priority, 4)
	end,
	addReplacement = function(unitTest)
		local timer = Timer{}

		local c = Cell{
			dist = 1,
			dist10 = 2,
			dist20 = 3
		}

		local cs = CellularSpace{
			xdim = 10,
			instance = c
		}

		local ag = Agent{
			dist = 1,
			dist10 = 2,
			dist20 = 3
		}

		local soc = Society{
			quantity = 10,
			instance = ag
		}

		timer:addReplacement{
			target = cs,
			select = {"dist10", "dist20"},
			attribute = "dist",
			time = {10, 20}
		}

		timer:addReplacement{
			target = soc,
			select = {"dist10", "dist20"},
			attribute = "dist",
			time = {10, 25}
		}

		unitTest:assertEquals(cs:dist(), 100)
		unitTest:assertEquals(soc:dist(), 10)
		unitTest:assertEquals(#timer, 4)

		timer:run(13)
		unitTest:assertEquals(cs:dist(), 200)
		unitTest:assertEquals(soc:dist(), 20)
		unitTest:assertEquals(#timer, 2)

		timer:run(20)
		unitTest:assertEquals(cs:dist(), 300)
		unitTest:assertEquals(soc:dist(), 20)
		unitTest:assertEquals(#timer, 1)
	end,
	clear = function(unitTest)
		local timer = Timer{
			Event{action = function() end},
			Event{period = 2, action = function() end}
		}

		timer:clear()

		unitTest:assertEquals(#timer:getEvents(), 0)
	end,
	getEvents = function(unitTest)
		local timer = Timer{
			Event{action = function()
				print("each time step")
			end},
			Event{period = 2, action = function()
				print("each two time steps")
			end}
		}

		unitTest:assertEquals(#timer:getEvents(), 2)
	end,
	__len = function(unitTest)
		local timer = Timer{
			Event{action = function()
				print("each time step")
			end},
			Event{period = 2, action = function()
				print("each two time steps")
			end}
		}

		unitTest:assertEquals(#timer, 2)

		timer = Timer{}
		unitTest:assertEquals(#timer, 0)
	end,
	__tostring = function(unitTest)
		local t1 = Timer{
			Event{priority = 1, action = function(ev)
				ag1:execute(ev)
			end}
		}

		unitTest:assertEquals(tostring(t1), [[cObj_   userdata
events  vector of size 1
time    number [-inf]
]], 8)
	end,
	add = function(unitTest)
		local cont = 0
		local timer2 = Timer{}

		timer2:add(Event{action = function(event)
			cont = cont + 1
			unitTest:assertType(event, "Event")
			unitTest:assertEquals(1, event:getPeriod())
		end})

		timer2:add(Event{action = function()
			cont = cont + 1
			return false
		end})

		timer2:add{
			period = 2,
			action = function(event)
				cont = cont + 1
				unitTest:assertType(event, "Event")
				unitTest:assertEquals(2, event:getPeriod())
			end
		}

		timer2:run(6)
		unitTest:assertEquals(6, timer2:getTime())
		unitTest:assertEquals(10, cont)
	end,
	run = function(unitTest)
		local qt1 = 0
		local qt2 = 0
		local qt3 = 0

		local timer = Timer{
			Event{action = function()
				qt1 = qt1 + 1
			end},
			Event{start = 2, action = function()
				qt2 = qt2 + 1
			end},
			Event{start = 3, action = function()
				qt3 = qt3 + 1
			end}
		}

		timer:run(4)

		unitTest:assertEquals(4, qt1)
		unitTest:assertEquals(3, qt2)
		unitTest:assertEquals(2, qt3)

		-- different priorities
		local orderToken = 0 -- Priority test token (position reserved to the Event for this timeslice)
		local timeMemory = 0 -- memory of time test variable
		unitTest:assertEquals(orderToken, 0)
		local clock1 = Timer{
			Event{start = 0, action = function(event)
				timeMemory = event:getTime()
				unitTest:assert(orderToken <= 1)
				orderToken = 1
			end},
			Event{priority = 1, action = function(event)
				unitTest:assertEquals(event:getTime(), timeMemory)
				unitTest:assertEquals(1, orderToken)

				timeMemory = event:getTime()
				orderToken = 0
			end}
		}

		clock1:run(3)

		local result = ""

		timer = Timer{
			Event{action = function(event)
				result = result.."time "..event:getTime().." event 1 priority "..event:getPriority().."\n"
			end},
			Event{period = 2, action = function(event)
				result = result.."time "..event:getTime().." event 2 priority "..event:getPriority().."\n"
			end},
			Event{start = 3, action = function(event)
				result = result.."time "..event:getTime().." event 3 priority "..event:getPriority().."\n"
			end}
		}

		timer:run(4)

		unitTest:assertEquals(result, [[
time 1 event 1 priority 0
time 1 event 2 priority 0
time 2 event 1 priority 0
time 3 event 3 priority 0
time 3 event 2 priority 0
time 3 event 1 priority 0
time 4 event 3 priority 0
time 4 event 1 priority 0
]])

		-- negative time
		local cont = 0
		local t = Timer{
			Event{start = -10, action = function()
				cont = cont + 1
			end}
		}

		t:run(-5)
		unitTest:assertEquals(cont, 6)

		--	time fraction
		cont = 0
		t = Timer{
			Event{start = 0.1, period = 0.1, action = function()
				cont = cont + 0.1
			end}
		}

		t:run(10)
		unitTest:assertEquals(cont, t:getTime(), 0.0000000001)
	end,
	getTime = function(unitTest)
		local cont1 = 0

		local ev1 = Event{priority = 1, period = 5, start = 0, action = function(event)
			unitTest:assertEquals(event:getTime(), cont1)
			unitTest:assertEquals(event:getPriority(), 1)
			cont1 = cont1 + event:getPeriod()
		end}

		local cont2 = 50

		local ev2 = Event{period = 5, start = 50, action = function(event)
			unitTest:assertEquals(event:getPriority(), 0)
			unitTest:assertEquals(event:getTime(), cont2)
			cont2 = cont2 + event:getPeriod()
			if event:getTime() > 50 then return false end
		end}

		local t = Timer{ev1, ev2}

		t:run(100)
		unitTest:assertEquals(cont1, 105)
		unitTest:assertEquals(cont2, 60)
	end,
	reset = function(unitTest)
		local cont = 0
		local timer2 = Timer{
			Event{action = function(event)
				cont = cont + 1
				unitTest:assertType(event, "Event")

				unitTest:assertEquals(1, event:getPeriod())
			end},
			Event{action = function()
				cont = cont + 1
				return false
			end}
		}

		timer2:run(6)
		unitTest:assertEquals(6, timer2:getTime())
		unitTest:assertEquals(7, cont)

		cont = 0
		timer2:reset()
		timer2:run(4)
		unitTest:assertEquals(4, timer2:getTime())
		unitTest:assertEquals(0, cont)

		cont = 0
		timer2:reset()
		timer2:add(Event{ action = function()
			cont = cont + 1
		end})

		cont = 0
		timer2:run(12)
		unitTest:assertEquals(12, timer2:getTime())
		unitTest:assertEquals(18, cont)
	end
}

