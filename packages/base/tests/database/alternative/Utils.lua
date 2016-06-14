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
	CSVparseLine = function(unitTest)
		local error_func = function()
			CSVparseLine(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))

		error_func = function()
			CSVparseLine("abc", 2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))

		error_func = function()
			CSVparseLine("\"ab\"c", ",", "abc")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(3, "number", "abc"))

		error_func = function()
			CSVparseLine("\"ab\"c", ",")
		end
		unitTest:assertError(error_func, "Line 0 ('\"ab\"c') is invalid.")
	
		error_func = function()
			CSVparseLine("\"ab\"c", ",", 1)
		end
		unitTest:assertError(error_func, "Line 1 ('\"ab\"c') is invalid.")
	end,
	CSVread = function(unitTest)
		local error_func = function()
			csv = CSVread("asdfgh.csv")
		end

		unitTest:assertError(error_func, resourceNotFoundMsg(1, "asdfgh.csv"))

		error_func = function()
			CSVread(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))

		error_func = function()
			CSVread("abc", 2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))

		local s = sessionInfo().separator

		error_func = function()
			CSVread(filePath("error"..s.."csv-error.csv"))
		end
		unitTest:assertError(error_func, "Line 2 ('\"mary\",18,100,3,1') should contain 6 attributes but has 5.")
	end,
	CSVwrite = function(unitTest)
		local error_func = function()
			CSVwrite(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", 2))

		error_func = function()
			CSVwrite({}, 2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))

		error_func = function()
			CSVwrite({}, "aaa", 2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(3, "string", 2))

		local example = {
			{age = 1, wealth = 10, vision = 2, metabolism = 1, test = "Foo text"},
			{age = 3, wealth =  8, vision = 1, metabolism = 1, test = "Foo;text"},
			{age = 3, wealth = 13, vision = 1, metabolism = 1, test = "Foo.text"},
			w3c = {age = 1, wealth = 10, vision = 3, metabolism = 2, test = "Foo(text"}
		}

		local s = sessionInfo().separator
		local filename = tmpDir()..s.."csvwrite.csv"

		error_func = function()
			CSVwrite(example, filename)
		end
		unitTest:assertError(error_func, "#1 should be a vector.")

		example = {
			[2] = {age = 1, wealth = 10, vision = 2, metabolism = 1, test = "Foo text"},
			[3] = {age = 3, wealth =  8, vision = 1, metabolism = 1, test = "Foo;text"},
			[4] = {age = 3, wealth = 13, vision = 1, metabolism = 1, test = "Foo.text"},
			[5] = {age = 1, wealth = 10, vision = 3, metabolism = 2, test = "Foo(text"}
		}

		error_func = function()
			CSVwrite(example, filename)
		end
		unitTest:assertError(error_func, "#1 does not have position 1.")

		example = {
			{[1] = 1, wealth = 10, vision = 2, metabolism = 1, test = "Foo text"},
			{age = 3, wealth =  8, vision = 1, metabolism = 1, test = "Foo;text"},
			{age = 3, wealth = 13, vision = 1, metabolism = 1, test = "Foo.text"},
			{age = 1, wealth = 10, vision = 3, metabolism = 2, test = "Foo(text"}
		}

		error_func = function()
			CSVwrite(example, filename)
		end
		unitTest:assertError(error_func, "All attributes should be string, got number.")
	end
}

