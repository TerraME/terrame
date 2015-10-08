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

		t:execute(100)
		unitTest:assert(cont1 == 105)

		local countEvent = 0
		local clock1 = Timer{
			Event{start = 0, action = function(event) 
				countEvent = countEvent + 1
			end}
		}

		clock1:execute(10)

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

		t:execute(10)

		unitTest:assertEquals(60, count)
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

		unitTest:assertEquals(tostring(t1), [[1       Event
cObj_   userdata
events  table of size 1
time    number [-inf]
]])
	end,
	add = function(unitTest)
		local cont = 0
		local timer2 = Timer{}

		timer2:add(Event{action = function(event)
			cont = cont + 1
			unitTest:assertType(event, "Event")
			unitTest:assertEquals(1, event:getPeriod())
		end})

		timer2:add(Event{action = function(event)
			cont = cont + 1
			return false
		end})

		timer2:execute(6)
		unitTest:assertEquals(6, timer2:getTime())
		unitTest:assertEquals(7, cont)
	end,
	execute = function(unitTest)
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

		timer:execute(4)

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
				if event:getTime() == timeMemory then 
					unitTest:assertEquals(1, orderToken)
				else
					error("OUT OF ORDER: TerraME (CRASH!!!) was expected.")
				end
				timeMemory = event:getTime()
				orderToken = 0
			end}
		}
		clock1:execute(3)

		-- negative time
		local cont = 0
		local t = Timer{
			Event{start = -10, action = function(ev)
				cont = cont + 1
			end}
		}
	
		t:execute(-5)
		unitTest:assertEquals(cont, 6)

		--	time fraction
		local cont = 0
		local t = Timer{
			Event{start = 0.1, period = 0.1, action = function(ev)
				cont = cont + 0.1
			end}
		}
	
		t:execute(10)
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

		t:execute(100)
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
			Event{action = function(event)
				cont = cont + 1
				return false
			end}
		}

		timer2:execute(6)
		unitTest:assertEquals(6, timer2:getTime())
		unitTest:assertEquals(7, cont)

		cont = 0
		timer2:reset()
		timer2:execute(4)
		unitTest:assertEquals(4, timer2:getTime())
		unitTest:assertEquals(0, cont)

		cont = 0
		timer2:reset()
		timer2:add(Event{ action = function(event)
			cont = cont + 1
		end})

		cont = 0
		timer2:execute(12)
		unitTest:assertEquals(12, timer2:getTime())
		unitTest:assertEquals(18, cont)
	end
}

