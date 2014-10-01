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
	checkUnnecessaryParameters = function(unitTest)
		local error_func = function(unitTest)
			checkUnnecessaryParameters({aaa = "aaa"}, {"abc", "acd", "aab"})
		end
		unitTest:assert_error(error_func, "Error: Parameter 'aaa' is unnecessary.")
	end,
	customError = function(unitTest)
		local error_func = function()
			customError("test.")
		end
		unitTest:assert_error(error_func, "Error: test.")
	end,
	customWarning = function(unitTest)
		local error_func = function()
			customWarning("test.")
		end
		unitTest:assert_error(error_func, "Error: test.")
	end,
	defaultValueWarning = function(unitTest)
		local error_func = function()
			defaultValueWarning(2)
		end
		unitTest:assert_error(error_func, "Error: #1 should be a string.")
	end,
	deprecatedFunctionWarning = function(unitTest)
		local error_func = function()
			deprecatedFunctionWarning("abc", "def")
		end
		unitTest:assert_error(error_func, "Error: Function 'abc' is deprecated. Use 'def' instead.")
	end,
	incompatibleFileExtensionError = function(unitTest)
		local error_func = function()
			incompatibleFileExtensionError("file", ".txt")
		end
		unitTest:assert_error(error_func, "Error: Parameter 'file' does not support '.txt'.")
	end,
	incompatibleTypeError = function(unitTest)
		local error_func = function()
			incompatibleTypeError("cell", "Cell", Agent{})
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'cell' expected Cell, got Agent.")
	end,
	incompatibleValueError = function(unitTest)
		local error_func = function()
			incompatibleValueError("position", "1, 2, or 3", "4")
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'position' expected 1, 2, or 3, got '4'.")
	end,
	resourceNotFoundError = function(unitTest)
		local error_func = function()
			resourceNotFoundError("file", "/usr/local/file.txt")
		end
		unitTest:assert_error(error_func, "Error: Resource '/usr/local/file.txt' not found for parameter 'file'.")
	end,
	mandatoryArgumentError = function(unitTest)
		local error_func = function()
			mandatoryArgumentError("neighborhood")
		end
		unitTest:assert_error(error_func, "Error: Parameter 'neighborhood' is mandatory.")
	end,
	namedParametersError = function(unitTest)
		local error_func = function()
			namedParametersError("CellularSpace")
		end
		unitTest:assert_error(error_func, "Error: Parameters for 'CellularSpace' must be named.")
	end,
	suggest = function(unitTest)
		unitTest:assert(true)
	end,
	switch = function(unitTest)
		unitTest:assert(true)
	end,
	tableParameterError = function(unitTest)
		local error_func = function()
			tableParameterError("CellularSpace")
		end
		unitTest:assert_error(error_func, "Error: Parameter for 'CellularSpace' must be a table.")
	end,
	valueNotFoundError = function(unitTest)
		local error_func = function()
			valueNotFoundError("1", "neighborhood")
		end
		unitTest:assert_error(error_func, "Error: Value 'neighborhood' not found for parameter '1'.")
	end,
	verify = function(unitTest)
		local error_func = function(unitTest)
			verify(false, "error")
		end
		unitTest:assert_error(error_func, "Error: error")
	end
}

