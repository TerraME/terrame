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
	setEvents = function(unitTest)
		unitTest:assert(true)
	end,
	setEvent = function(unitTest)
		unitTest:assert(true)
	end,
	getEvent = function(unitTest)
		unitTest:assert(true)
	end,
	getEvents = function(unitTest)
		unitTest:assert(true)
	end,
	reset = function(unitTest)
		unitTest:assert(true)
	end,
	Timer = function(unitTest)
		local timer = Timer()
		unitTest:assert_equal(type(timer), "Timer")

		local cont1 = 0

		local ev1 = Event {priority = 1, period = 5, time = 0, action = function(event)
			unitTest:assert_equal(event:getTime(), cont1)
			unitTest:assert_equal(event:getPriority(), 1)
			cont1 = cont1 + event:getPeriod()
		end}

		local t = Timer{ev1}

		unitTest:assert_type(t, "Timer")

		t:execute(100)
		unitTest:assert(cont1 == 105)

		local countEvent = 0
		local clock1 = Timer{
			Event{time = 0, action = function(event) 
				countEvent = countEvent + 1
			end}
		}

		clock1:execute(10)

		unitTest:assert_equal(countEvent, 11)

		local count = 0
		local ag1 = Agent{execute = function() count = count + 1 end}
		local ag2 = Agent{execute = function() count = count + 1 end}
		local c = Cell{}
		local cs = CellularSpace{xdim = 5}
		local t = Trajectory{target = cs}

		local soc = Society{instance = ag2, quantity = 5}

		t = Timer{
			Event{action = ag1},
			Event{action = soc},
			Event{action = c},
			Event{action = cs},
			Event{action = t}
		}

		t:execute(10)

		unitTest:assert_equal(60, count)
	end,
	add = function(unitTest)
		local cont = 0
		local timer2 = Timer{
			Event{action = function(event)
				cont = cont + 1
				unitTest:assert_not_nil(event)

				-- configuring the current event does not affects the TerraMEscheduler
				local evTime = event:getTime() + 2
				event:config(evTime , 2, 0) 
				unitTest:assert_equal(evTime, event:getTime())
				unitTest:assert_equal(2, event:getPeriod())
			end},

			Event{action = function(event)
				cont = cont + 1
				return false
			end}
		}

		unitTest:assert_equal(1, timer2:getTime())
		timer2:execute(6)
		unitTest:assert_equal(7, timer2:getTime()) 	-- TODO: se eu mandei executar ate o tempo 6,
												-- por que o tempo final eh 7?
		unitTest:assert_equal(7, cont)

		cont = 0
		timer2:execute(4)
		unitTest:assert_equal(7, timer2:getTime())
		unitTest:assert_equal(0, cont)

		cont = 0
		timer2:reset()
		unitTest:assert_equal(7, timer2:getTime())
		timer2:execute(4)
		unitTest:assert_equal(7, timer2:getTime())
		timer2:add(Event{ action = function(event)
			cont = cont + 1
		end})

		cont = 0
		timer2:execute(12)
		unitTest:assert_equal(13, timer2:getTime())
		unitTest:assert_equal(18, cont)
	end,
	execute = function(unitTest)
		local qt1 = 0
		local qt2 = 0
		local qt3 = 0

		local timer = Timer{
			Event{action = function()
				qt1 = qt1 + 1
			end},
			Event{time = 2, action = function()
				qt2 = qt2 + 1
			end},
			Event{time = 3, action = function()
				qt3 = qt3 + 1
			end}
		}

		timer:execute(4)

		unitTest:assert_equal(4, qt1)
		unitTest:assert_equal(3, qt2)
		unitTest:assert_equal(2, qt3)

		-- different priorities

		local orderToken = 0 -- Priority test token (position reserved to the Event for this timeslice)
		local timeMemory = 0 -- memory of time test variable 
		unitTest:assert_equal(orderToken, 0)
		local clock1 = Timer{
			Event{time = 0, priority = 0, action = function(event)
				timeMemory = event:getTime()
				unitTest:assert(orderToken <= 1)
				orderToken = 1
			end},
			Event{time = 1, period = 1, priority = 1, action = function(event) 
				if event:getTime() == timeMemory then 
					unitTest:assert_equal(1, orderToken)
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
			Event{time = -10, action = function(ev)
				cont = cont + 1
			end}
		}
	
		t:execute(-5)
		unitTest:assert_equal(cont, 6)

		--	time fraction
		local cont = 0
		local t = Timer{
			Event{time = 0, period = 0.1, action = function(ev)
				cont = cont + 0.1
			end}
		}
	
		t:execute(10)
		unitTest:assert_equal(cont, t:getTime())
	end,
	getTime = function(unitTest)
		local cont1 = 0

		local ev1 = Event{priority = 1, period = 5, time = 0, action = function(event)
			unitTest:assert_equal(event:getTime(), cont1)
			unitTest:assert_equal(event:getPriority(), 1)
			cont1 = cont1 + event:getPeriod()
		end}

		local cont2 = 50

		local ev2 = Event{period = 5, time = 50, action = function(event)
			unitTest:assert_equal(event:getPriority(), 0)
			unitTest:assert_equal(event:getTime(), cont2)
			cont2 = cont2 + event:getPeriod()
			if event:getTime() > 50 then return false end
		end}

		local t = Timer{ev1, ev2}

		t:execute(100)
		unitTest:assert_equal(cont1, 105)
		unitTest:assert_equal(cont2, 60)
	end,
	__tostring = function(unitTest)
		local t1 = Timer{
			Event{priority = 1, action = function(ev)
				ag1:execute(ev)
			end}
		}

		unitTest:assert_equal(tostring(t1), [[1       table of size 2
cObj_   userdata
events  table of size 1
]])
	end
}

