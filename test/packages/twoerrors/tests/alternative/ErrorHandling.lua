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
	customError2 = function(unitTest)
		local error_func = function()
			customError2(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	customWarning2 = function(unitTest)
		local error_func = function()
			customWarning2(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	defaultTableValue2 = function(unitTest)
		local t = {x = 5}
		local error_func = function()
			defaultTableValue2(t, "x", false)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("x", "boolean", 5))

		local error_func = function()
			defaultTableValue2(t, "x", 5)
		end
		unitTest:assertError(error_func, defaultValueMsg("x", 5))
	end,
	defaultValueWarning2 = function(unitTest)
		local error_func = function()
			defaultValueWarning2(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	deprecatedFunction2 = function(unitTest)
		local error_func = function()
			deprecatedFunction2(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))

		error_func = function()
			deprecatedFunction2("test.", -1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", -1))
	end,
	suggestion2 = function(unitTest)
		local t = {
			"aaaaa",
			"bbbbb",
			"ccccc"
		}

		local error_func = function()
			suggestion2()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		local error_func = function()
			suggestion2(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))

		local error_func = function()
			suggestion2("aaaab")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(2))

		local error_func = function()
			suggestion2("aaaab", 2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "table", 2))

		local error_func = function()
			suggestion2("aaaab", t)
		end
		unitTest:assertError(error_func, "All the indexes of second parameter should be string, got 'number'.")
	end,
	switchInvalidArgument2 = function(unitTest)
		local error_func = function()
			switchInvalidArgument2()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1, "string"))

		error_func = function()
			switchInvalidArgument2("abc")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(2, "string"))

		error_func = function()
			switchInvalidArgument2("abc", "def")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(3, "table"))
	end,
	switchInvalidArgumentMsg2 = function(unitTest)
		local error_func = function()
			switchInvalidArgumentMsg2()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1, "string"))

		error_func = function()
			switchInvalidArgumentMsg2("abc")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(2, "string"))

		error_func = function()
			switchInvalidArgumentMsg2("abc", "def")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(3, "table"))
	end,
	switchInvalidArgumentSuggestionMsg2 = function(unitTest)
		local error_func = function()
			switchInvalidArgumentSuggestionMsg2()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1, "string"))

		error_func = function()
			switchInvalidArgumentSuggestionMsg2("abc")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(2, "string"))

		error_func = function()
			switchInvalidArgumentSuggestionMsg2("abc", "def")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(3, "string"))
	end
}

