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
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		local error_func = function()
			Profiler():start()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))
		error_func = function()
			Profiler():start(1)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
		error_func = function()
			Profiler():start("test")
			Profiler():start("test")
			Profiler():stop("test")
		end

		unitTest:assertWarning(error_func, "Block 'test' has already been started. Please, stop the block before re-start it.")
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	count = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		local error_func = function()
			Profiler():count(1)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
		error_func = function()
			Profiler():count("test")
		end

		unitTest:assertError(error_func, "Block 'test' was not found.")
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	uptime = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		local error_func = function()
			Profiler():uptime(1)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
		error_func = function()
			Profiler():uptime("test")
		end

		unitTest:assertError(error_func, "Block 'test' was not found.")
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	stop = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		local error_func = function()
			Profiler():stop(1)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
		error_func = function()
			Profiler():stop("main")
		end

		unitTest:assertWarning(error_func, "The block 'main' cannot be stopped.")
		error_func = function()
			Profiler():stop()
		end

		unitTest:assertWarning(error_func, "The block 'main' cannot be stopped.")
		error_func = function()
			Profiler():stop("test")
		end

		unitTest:assertError(error_func, "Block 'test' was not found.")
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	steps = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		local error_func = function()
			Profiler():steps()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))
		error_func = function()
			Profiler():steps(1, 1)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
		error_func = function()
			Profiler():steps("block")
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(2))
		error_func = function()
			Profiler():steps("block", -1)
		end

		unitTest:assertError(error_func, positiveArgumentMsg(2, -1))
		error_func = function()
			Profiler():steps("block", 0)
		end

		unitTest:assertError(error_func, positiveArgumentMsg(2, 0))
		error_func = function()
			Profiler():steps("block", 1.1)
		end

		unitTest:assertError(error_func, integerArgumentMsg (2, 1.1))
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	eta = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		local error_func = function()
			Profiler():eta(1)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
		error_func = function()
			Profiler():eta("block")
		end

		unitTest:assertError(error_func, "Block 'block' was not found.")
		error_func = function()
			Profiler():eta("test")
		end
		Profiler():start("test")
		unitTest:assertError(error_func, "'Profiler():steps(\"test\")' must be set before calling 'Profiler():eta(\"test\")'.")
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end
}
