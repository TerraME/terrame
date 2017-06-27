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
	isDirectory = function(unitTest)
		local error_func = function()
			isDirectory(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
	end,
	isFile = function(unitTest)
		local error_func = function()
			isFile(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
	end,
	runCommand = function(unitTest)
		local error_func = function()
			runCommand(1)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
	end,
	sessionInfo = function(unitTest)
		local s = sessionInfo()

		local error_func = function()
			s.system = "mac"
		end

		unitTest:assertError(error_func, "Argument 'system' is an important information about the current execution and cannot be changed.")

		error_func = function()
			s.path = "/my/path/"
		end

		unitTest:assertError(error_func, "Argument 'path' is an important information about the current execution and cannot be changed.")

		error_func = function()
			s.initialDir = "/my/path/"
		end

		unitTest:assertError(error_func, "Argument 'initialDir' is an important information about the current execution and cannot be changed.")

		error_func = function()
			s.currentFile = "file.lua"
		end

		unitTest:assertError(error_func, "Argument 'currentFile' is an important information about the current execution and cannot be changed.")

		error_func = function()
			s.version = "5.0"
		end

		unitTest:assertError(error_func, "Argument 'version' is an important information about the current execution and cannot be changed.")

		error_func = function()
			s.mode = "void"
		end

		unitTest:assertError(error_func, "Argument 'mode' cannot be replaced by 'void'.")

		error_func = function()
			s.round = false
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("round", "number", false))

		error_func = function()
			s.autoclose = 2
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("autoclose", "boolean", 2))

		error_func = function()
			s.round = 1.1
		end

		unitTest:assertError(error_func, "Argument 'round' must be a number >= 0 and < 1, got '1.1'.")

		error_func = function()
			s.silent = 1
		end

		unitTest:assertError(error_func, "Argument 'silent' is an important information about the current execution and cannot be changed.")

		error_func = function()
			s.arg = 1
		end

		unitTest:assertError(error_func, "Argument 'arg' is not an information about the current execution.")

		error_func = function()
			s.time = 1
		end

		unitTest:assertError(error_func, "Argument 'time' is an important information about the current execution and cannot be changed.")
	end
}

