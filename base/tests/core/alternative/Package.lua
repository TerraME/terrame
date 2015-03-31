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
	customError = function(unitTest)
		local error_func = function()
			customError(2)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	customWarning = function(unitTest)
		local error_func = function()
			customWarning(2)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	defaultTableValue = function(unitTest)
		local t = {x = 5}
		local error_func = function()
			defaultTableValue(t, "x", false)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("x", "boolean", 5))

		local error_func = function()
			defaultTableValue(t, "x", 5)
		end
		unitTest:assert_error(error_func, defaultValueMsg("x", 5))
	end,
	defaultValueWarning = function(unitTest)
		local error_func = function()
			defaultValueWarning(2)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	deprecatedFunction = function(unitTest)
		local error_func = function()
			deprecatedFunction(2)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "string", 2))

		error_func = function()
			deprecatedFunction("test.", -1)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "string", -1))
	end,
	require = function(unitTest)
		local error_func = function()
			require("asdfgh")
		end
		unitTest:assert_error(error_func, "Package 'asdfgh' is not installed.")

		local error_func = function()
			require("base")
		end
		unitTest:assert_error(error_func, "Package 'base' is already loaded.")
	end,
	packageInfo = function(unitTest)
		local error_func = function()
        	local r = packageInfo("asdfgh")
		end
		unitTest:assert_error(error_func, "Package 'asdfgh' is not installed.")
	end,
    suggestion = function(unitTest)
        local t = {
            "aaaaa",
            "bbbbb",
            "ccccc"
        }

		local error_func = function()
        	suggestion()
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg(1))

		local error_func = function()
        	suggestion(2)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "string", 2))

		local error_func = function()
        	suggestion("aaaab")
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg(2))

		local error_func = function()
        	suggestion("aaaab", 2)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "table", 2))

		local error_func = function()
        	suggestion("aaaab", t)
		end
		unitTest:assert_error(error_func, "All the indexes in #2 should be string, got 'number'.")

    end,
	switch = function(unitTest)
		local error_func = function()
        	switch("aaaab")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "table", "aaaab"))

		local error_func = function()
        	switch({}, 2)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "string", 2))
	
		local error_func = function()
			local data = {att = "abd"}
			switch(data, "att"):caseof{
				abc = function() end
			}
		end
		unitTest:assert_error(error_func, switchInvalidArgumentSuggestionMsg("abd", "att", "abc"))
	end
}

