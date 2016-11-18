-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.

-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this software and its documentation.
--
-------------------------------------------------------------------------------------------

return{
	Event = function(unitTest)
		local error_func = function()
			event = Event{start = "time", period = 2, priority = -1, action = function() end}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("start", "number", "time"))

		error_func = function()
			event = Event(2)
		end
		unitTest:assertError(error_func, namedArgumentsMsg())

		error_func = function()
			event = Event{}
		end
		unitTest:assertError(error_func, "Argument 'action' is mandatory.")

		error_func = function()
			event = Event{period = "1", priority = 1, action = function() end}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("period", "number", "1"))

		error_func = function()
			event = Event{period = -1, priority = 1, action = function() end}
		end
		unitTest:assertError(error_func, incompatibleValueMsg("period", "positive number (except zero)", -1))

		error_func = function()
			event = Event{period = 2, priority = true, action = function() end}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("priority", "number", true))

		error_func = function()
			event = Event{period = 2, priority = "aaa", action = function() end}
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
			event = Event{start = 0.5, period = 2, priority = "medium", action = function() end}
		end
		unitTest:assertError(error_func, defaultValueMsg("priority", 0))

		error_func = function()
			event = Event{period = 0, priority = 1, action = function() end}
		end
		unitTest:assertError(error_func, incompatibleValueMsg("period", "positive number (except zero)", 0))

		error_func = function()
			event = Event{period = 2, priority = 1, action = -5.5}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("action", "one of the TerraME types or a function", -5.5))

		error_func = function()
			event = Event{message = function() end}
		end
		unitTest:assertError(error_func, "Argument 'message' is deprecated, use 'action' instead.")

		error_func = function()
			event = Event{action = function() end, myperiod = function() end}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("myperiod", "period"))

		error_func = function()
			event = Event{period = 1, priority = 1, action = function() end}
		end
		unitTest:assertError(error_func, defaultValueMsg("period", 1))

		error_func = function()
			event = Event{start = 1, priority = 1, action = function() end}
		end
		unitTest:assertError(error_func, defaultValueMsg("start", 1))

		error_func = function()
			event = Event{priority = 0, action = function() end}
		end
		unitTest:assertError(error_func, defaultValueMsg("priority", 0))

		local t = Timer{
			Event{action = function()
				customError("aaa")
			end}
		}

		error_func = function()
			t:run(2)
		end
		unitTest:assertError(error_func, "aaa")

		local ag = Agent{
			execute = 2
		}

		error_func = function()
			Event{action = ag}
		end
		unitTest:assertError(error_func, "Incompatible types. Attribute 'execute' from Agent should be a function, got number.")

		local soc = Society{
			instance = Agent{a = 2},
			quantity = 4,
			execute = 2
		}

		error_func = function()
			Event{action = soc}
		end
		unitTest:assertError(error_func, "Incompatible types. Attribute 'execute' from Society should be a function, got number.")

		local cs = CellularSpace{
			xdim = 3,
			execute = 2
		}

		error_func = function()
			Event{action = cs}
		end
		unitTest:assertError(error_func, "Incompatible types. Attribute 'execute' from CellularSpace should be a function, got number.")

		error_func = function()
			Event{action = cs, priority = "medium"}
		end
		unitTest:assertError(error_func, defaultValueMsg("priority", 0))

		local cell = Cell{}

		error_func = function()
			Event{action = cell, priority = "medium"}
		end
		unitTest:assertError(error_func, defaultValueMsg("priority", 0))

		local agent = Agent{}

		error_func = function()
			Event{action = agent, priority = "medium"}
		end
		unitTest:assertError(error_func, defaultValueMsg("priority", 0))

		soc = Society{instance = Agent{}, quantity = 2}

		error_func = function()
			Event{action = soc, priority = "medium"}
		end
		unitTest:assertError(error_func, defaultValueMsg("priority", 0))

		local group = Group{target = soc}

		error_func = function()
			Event{action = group, priority = "high"}
		end
		unitTest:assertError(error_func, defaultValueMsg("priority", -5))

		local traj = Trajectory{target = cs}

		error_func = function()
			Event{action = traj, priority = "high"}
		end
		unitTest:assertError(error_func, defaultValueMsg("priority", -5))
	end,
	config = function(unitTest)
		local event = Event{action = function() end}

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

