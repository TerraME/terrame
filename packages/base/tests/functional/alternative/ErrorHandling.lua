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
	customError = function(unitTest)
		local error_func = function()
			customError(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	customWarning = function(unitTest)
		local error_func = function()
			customWarning(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	defaultTableValue = function(unitTest)
		local t = {x = 5}
		local error_func = function()
			defaultTableValue(t, "x", false)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("x", "boolean", 5))

		error_func = function()
			defaultTableValue(t, "x", 5)
		end
		unitTest:assertError(error_func, defaultValueMsg("x", 5))
	end,
	defaultValueWarning = function(unitTest)
		local error_func = function()
			defaultValueWarning(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	deprecatedFunction = function(unitTest)
		local error_func = function()
			deprecatedFunction(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))

		error_func = function()
			deprecatedFunction("test.", -1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", -1))
	end,
	integerArgument = function(unitTest)
		local error_func = function()
			integerArgument(1, "value")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "number", "value"))
	end,
	integerTableArgument = function(unitTest)
		local error_func = function()
			integerTableArgument({}, "value")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("value", "number", nil))
	end,
	mandatoryTableArgument = function(unitTest)
		local tab = {value = 5}
		local error_func = function()
			mandatoryTableArgument(tab, "value", 2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(3, "string or table", 2))
	end,
	positiveTableArgument = function(unitTest)
		local error_func = function()
			positiveTableArgument({}, "value")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("value", "number", nil))
	end,
	suggestion = function(unitTest)
		local error_func = function()
			suggestion()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			suggestion(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))

		error_func = function()
			suggestion("aaaab")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			suggestion("aaaab", 2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "table", 2))

		local t = {2, 3, 4}

		error_func = function()
			suggestion("aaaab", t)
		end
		unitTest:assertError(error_func, "All the names of argument #2 should be string, got 'number'.")
	end,
	switchInvalidArgument = function(unitTest)
		local error_func = function()
			switchInvalidArgument()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1, "string"))

		error_func = function()
			switchInvalidArgument("abc")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(2, "string"))

		error_func = function()
			switchInvalidArgument("abc", "def")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(3, "table"))
	end,
	switchInvalidArgumentMsg = function(unitTest)
		local error_func = function()
			switchInvalidArgumentMsg()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1, "string"))

		error_func = function()
			switchInvalidArgumentMsg("abc")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(2, "string"))

		error_func = function()
			switchInvalidArgumentMsg("abc", "def")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(3, "table"))
	end,
	switchInvalidArgumentSuggestionMsg = function(unitTest)
		local error_func = function()
			switchInvalidArgumentSuggestionMsg()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1, "string"))

		error_func = function()
			switchInvalidArgumentSuggestionMsg("abc")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(2, "string"))

		error_func = function()
			switchInvalidArgumentSuggestionMsg("abc", "def")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(3, "string"))
	end
}

