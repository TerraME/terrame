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

return{
	start = function(unitTest)
		local error_func = function()
			Profiler():start()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("name"))
		error_func = function()
			Profiler():start(1)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("name", "string", 1))
		error_func = function()
			Profiler():start("test")
			Profiler():start("test")
			Profiler():stop("test")
			Profiler().blocks["test"] = nil
		end

		unitTest:assertWarning(error_func, "Block 'test' has already been started.")
	end,
	count = function(unitTest)
		local error_func = function()
			Profiler():count(1)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("name", "string", 1))
		error_func = function()
			Profiler():count("test")
		end

		unitTest:assertError(error_func, "Block 'test' not found.")
	end,
	uptime = function(unitTest)
		local error_func = function()
			Profiler():uptime(1)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("name", "string", 1))
		error_func = function()
			Profiler():uptime("test")
			Profiler():start("test")
		end

		unitTest:assertError(error_func, "Block 'test' not found.")
		Profiler().blocks["test"] = nil
	end,
	stop = function(unitTest)
		local error_func = function()
			Profiler():stop(1)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("name", "string", 1))
		error_func = function()
			Profiler():stop("main")
		end

		unitTest:assertWarning(error_func, "The block 'main' cannot be stopped.")

		error_func = function()
			Profiler():stop("test")
		end

		unitTest:assertError(error_func, "Block 'test' not found.")
	end
}
