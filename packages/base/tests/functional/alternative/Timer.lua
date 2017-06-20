-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

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

return {
	Timer = function(unitTest)
		local error_func = function()
			Timer(2)
		end

		unitTest:assertError(error_func, tableArgumentMsg())

		error_func = function()
			Timer{Cell()}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Event", Cell()))

		error_func = function()
			Timer{b = Cell()}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("b", "Event", Cell()))
	end,
	add = function(unitTest)
		local timer = Timer{
			Event{period = 2, action = function() end}
		}

		local error_func = function()
			timer:add(nil)
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		timer = Timer{
			Event{period = 2, action = function() end}
		}

		error_func = function()
			timer:add("ev")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Event", "ev"))

		timer:run(10)

		local warning_func = function()
			timer:add(Event{period = 2, action = function() end})
		end

		unitTest:assertWarning(warning_func, "Adding an Event with time (1) before the current simulation time (10).")
	end,
	addReplacement = function(unitTest)
		local timer = Timer{}

		local error_func = function()
			timer:addReplacement()
		end

		unitTest:assertError(error_func, tableArgumentMsg())

		local cs = CellularSpace{
			xdim = 10
		}

		error_func = function()
			timer:addReplacement{
				target = timer,
				select = {"roads2010", "roads2020"},
				attribute = "roads",
				time = {2010, 2020}
			}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("target", "CellularSpace or Society", timer))

		error_func = function()
			timer:addReplacement{
				target = cs,
				select = 2,
				attribute = "attr",
				time = {2010, 2020, 2030}
			}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("select", "table", 2))

		error_func = function()
			timer:addReplacement{
				target = cs,
				select = {"roads2010", "roads2020"},
				attribute = 2,
				time = {2010, 2020, 2030}
			}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("attribute", "string", 2))

		error_func = function()
			timer:addReplacement{
				target = cs,
				select = {"roads2010", "roads2020"},
				attribute = "attr",
				time = 2
			}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("time", "table", 2))

		error_func = function()
			timer:addReplacement{
				target = cs,
				select = {"roads2010", "roads2020"},
				attribute = "roads",
				time = {2010, 2020, 2030}
			}
		end

		unitTest:assertError(error_func, "The size of argument 'time' should be 2, got 3.")

		error_func = function()
			timer:addReplacement{
				target = cs,
				select = {"roads2010", "roads2020"},
				attribute = "roads",
				time = {2010, 2020}
			}
		end

		unitTest:assertError(error_func, "Attribute 'roads2010' does not exist in the Cells.")

		local soc = Society{
			instance = Agent{},
			quantity = 10
		}

		error_func = function()
			timer:addReplacement{
				target = soc,
				select = {"roads2010", "roads2020"},
				attribute = "roads",
				time = {2010, 2020}
			}
		end

		unitTest:assertError(error_func, "Attribute 'roads2010' does not exist in the Agents.")
	end,
	run = function(unitTest)
		local timer = Timer{
			Event{period = 2, action = function()
			end}
		}

		local error_func = function()
			timer:run()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		timer = Timer{
			Event{period = 2, action = function()
			end}
		}

		error_func = function()
			timer:run("2")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "number", "2"))

		timer = Timer{
			Event{period = 2, action = function()
			end}
		}

		timer:run(10)
		local warning_func = function()
			timer:run(2)
		end

		unitTest:assertWarning(warning_func, "Simulating until a time (2) before the current simulation time (10).")
	end
}

