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
	notify = function(unitTest)
		local t = Timer{Event{action = function() end}}

		t:execute(5)

		local error_func = function()
			t:notify("not_int")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Event or positive number, got string.")

		error_func = function()
			t:notify(-1)
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter '#1' expected Event or positive number, got -1.")
	end,
	Timer = function(unitTest)
		local error_func = function()
			local timer = Timer{Cell()}
		end

		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '1' expected Event, table, or userdata, got Cell.")
	end,
	add = function(unitTest)
		local timer = Timer{
			Event{time = 1, period = 2, priority = 0, action = function(event)
			end}
		}

		local error_func = function()
			timer:add(nil)
		end

		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")

		timer = Timer{
			Event{time = 1, period = 2, priority = 0, action = function(event)
			end}
		}
		error_func = function()
			timer:add("ev")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Event or table, got string.")
	end,
	execute = function(unitTest)
		local timer = Timer{
			Event{time = 1, period = 2, priority = 0, action = function(event)
			end}
		}

		local error_func = function()
			timer:execute()
		end
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")

		timer = Timer{
			Event{time = 1, period = 2, priority = 0, action = function(event)
			end}
		}

		error_func = function()
			timer:execute("2")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected number, got string.")
	end
}

