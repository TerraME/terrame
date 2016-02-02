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
		local error_func = function()
			event = Event{start = "time", period = 2, priority = -1, action = function(event) end}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("start", "number", "time"))

		error_func = function()
			event = Event(2)
		end
		unitTest:assertError(error_func, namedArgumentsMsg())

		error_func = function()
			event = Event{period = "1", priority = 1, action = function(event) end}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("period", "number", "1"))

		error_func = function()
			event = Event{period = -1, priority = 1, action = function(event) end}
		end
		unitTest:assertError(error_func, incompatibleValueMsg("period", "positive number (except zero)", -1))

		error_func = function()
			event = Event{period = 2, priority = true, action = function(event) end}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("priority", "number", true))

		error_func = function()
			event = Event{period = 2, priority = "aaa", action = function(event) end}
		end

		local options = {
			high = true,
			low = true,
			medium = true,
			veryhigh = true,
			verylow = true
		}

		unitTest:assertError(error_func, switchInvalidArgumentMsg("aaa", "priority", options))

		error_func = function()
			event = Event{period = 0, priority = 1, action = function() end}
		end
		unitTest:assertError(error_func, incompatibleValueMsg("period", "positive number (except zero)", 0))

		error_func = function()
			event = Event{period = 2, priority = 1, action = -5.5}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("action", "one of the types from the set [Agent, Automaton, Cell, CellularSpace, function, Group, Society, Timer, Trajectory]", -5.5))

		error_func = function()
			event = Event{message = function() end}
		end
		unitTest:assertError(error_func, "Argument 'message' is deprecated, use 'action' instead.")

		error_func = function()
			event = Event{myaction = function() end}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("myaction", "action"))

		error_func = function()
			event = Event{period = 1, priority = 1, action = function(event) end}
		end
		unitTest:assertError(error_func, defaultValueMsg("period", 1))

		error_func = function()
			event = Event{start = 1, priority = 1, action = function(event) end}
		end
		unitTest:assertError(error_func, defaultValueMsg("start", 1))

		error_func = function()
			event = Event{priority = 0, action = function(event) end}
		end
		unitTest:assertError(error_func, defaultValueMsg("priority", 0))

		local t = Timer{
			Event{action = function()
				customError("aaa")
			end}
		}

		error_func = function()
			t:execute(2)
		end
		unitTest:assertError(error_func, "aaa")
	end,
	config = function(unitTest)
		local event = Event{action = function(event) end}

		local error_func = function()
			event:config()
		end
		unitTest:assertError(error_func, tableArgumentMsg())

		error_func = function()
			event:config{perod = false}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("perod", "period"))

		error_func = function()
			event:config{period = false}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("period", "number", false))

		error_func = function()
			event:config{period = 0}
		end
		unitTest:assertError(error_func, incompatibleValueMsg("period", "positive number (except zero)", 0))

		error_func = function()
			event:config{priority = false}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("priority", "number", false))

		error_func = function()
			event:config{time = false}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("time", "number", false))
	end
}

