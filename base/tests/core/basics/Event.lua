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

return{
	Event = function(unitTest)
		local event = Event{action = function() end}

		unitTest:assert_equal(event[1]:getTime(), 1)
		unitTest:assert_equal(event[1]:getPeriod(), 1)
		unitTest:assert_equal(event[1]:getPriority(), 0)
		unitTest:assert_equal(type(event[1]), "Event")

		event = Event{time = 0.5, period = 2, priority = 1, action = function(event) end}

		unitTest:assert_equal(event[1]:getTime(), 0.5)
		unitTest:assert_equal(event[1]:getPeriod(), 2)
		unitTest:assert_equal(event[1]:getPriority(), 1)
	
		event = Event{time = -1, period = 2, priority = -5.2, action = function(event) end}

		unitTest:assert_equal(event[1]:getTime(), -1)
		unitTest:assert_equal(event[1]:getPeriod(), 2)
		unitTest:assert_equal(event[1]:getPriority(), -5.2)
	end,
	config = function(unitTest)
		local event = Event{time = 1, action = function(event) end}

		event:config(0.5, 2, 1)

		unitTest:assert_equal(event[1]:getTime(), 0.5)
		unitTest:assert_equal(event[1]:getPeriod(), 2)
		unitTest:assert_equal(event[1]:getPriority(), 1)
	
		event:config(1)

		unitTest:assert_equal(event[1]:getTime(), 1)
		unitTest:assert_equal(event[1]:getPeriod(), 2)
		unitTest:assert_equal(event[1]:getPriority(), 1)
	end,
	getType = function(unitTest)
		local event = Event{action = function() end}

		unitTest:assert_equal(type(event[1]), "Event")
	end,
	getTime = function(unitTest)
		local event = Event{time = -10, action = function(event) end}
		unitTest:assert_equal(event[1]:getTime(), -10)
		event:config(0.5)
		unitTest:assert_equal(event[1]:getTime(), 0.5)	
	end,
	getPeriod = function(unitTest)
		local event = Event{period = 2, action = function(event) end}
		unitTest:assert_equal(event[1]:getPeriod(), 2)
		event:config(0, 3)
		unitTest:assert_equal(event[1]:getPeriod(), 3)	
	end,
	getPriority = function(unitTest)
		local event = Event{priority = -10, action = function(event) end}
		unitTest:assert_equal(event[1]:getPriority(), -10)
		event:config(0, 1, 2)
		unitTest:assert_equal(event[1]:getPriority(), 2)	
	end,
	--TODO: Comentei este teste porque o Event nao tem getParent. 
	-- getParent = function(unitTest)
	-- 	local event = Event{priority = -10, action = function(event) end}
		
	-- 	unitTest:assert_nil(event:getParent())

	-- 	local timer = Timer{event}

	-- 	unitTest:assert_equal(event:getParent(), timer)
	-- end
}

