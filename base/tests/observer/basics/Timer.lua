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
-- indirect, special, incidental, or caonsequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Pedro R. Andrade
-------------------------------------------------------------------------------------------

return{
	Timer = function(unitTest)
		local timer

		timer = Timer{
			Event{priority = 1, action = function(event) timer:notify() end},
			Event{priority = 2, action = function(event) timer:notify() end},
			Event{priority = 3, action = function(event) timer:notify() end},
			Event{priority = 4, action = function(event) timer:notify() end}
		}

		unitTest:delay()

		Clock{target = timer}
		timer:execute(50)
		unitTest:assert(true)
	end,
	notify = function(unitTest)
		local timer

		timer = Timer{
			ev1 = Event{priority =  1, action = function(event) timer:notify() end},
			ev2 = Event{priority = 10, action = function(event) timer:notify() end},
			ev3 = Event{priority = 10, action = function(event) timer:notify() end},
			ev4 = Event{priority = 10, action = function(event) timer:notify() end}
		}

		Clock{target = timer}
		timer:execute(50)

		unitTest:assert(true)
		unitTest:delay()
	end
}

