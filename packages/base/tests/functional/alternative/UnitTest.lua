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
	assert = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		local error_func = function()
			unitTest:assert(2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "boolean", 2))

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		unitTest:assertEquals(suc2, suc1 + 1)
		unitTest:assertEquals(test2, test1 + 1)
		unitTest:assertEquals(fail2, fail1)
	end,
	assertEquals = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		local error_func = function()
			unitTest:assertEquals()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			unitTest:assertEquals(1)
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			unitTest:assertEquals(2, 2, "a")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(3, "number", "a"))

		error_func = function()
			unitTest:assertEquals(false, true, 2)
		end

		unitTest:assertError(error_func, "#3 should be used only when comparing numbers or strings (#1 is boolean).")

		local expected = [[string [biomassa-manaus.asc] ]]
		local actual = [[string [/home/jenkins/Documents/ba1c13592dcf65f3d0b2929f8eff266c4e622470/install/bin/packages/terralib/data/biomassa-manaus.asc] ]]

		error_func = function()
			unitTest:assertEquals(expected, actual, 0, "")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(4, "boolean", actual))

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		unitTest:assertEquals(suc2, suc1 + 5)
		unitTest:assertEquals(test2, test1 + 5)
		unitTest:assertEquals(fail2, fail1)
	end,
	assertError = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		local error_func = function()
			unitTest:assertError(2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "function", 2))

		error_func = function()
			unitTest:assertError(function() end, 2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))

		error_func = function()
			unitTest:assertError(function() end, "aaa", false)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(3, "number", false))

		error_func = function()
			unitTest:assertError(function() end, "aaa", 2, 2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(4, "boolean", 2))

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		unitTest:assertEquals(suc2, suc1 + 4)
		unitTest:assertEquals(test2, test1 + 4)
		unitTest:assertEquals(fail2, fail1)
	end,
	assertFile = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		local error_func = function()
			unitTest:assertFile(2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "File", 2))

		error_func = function()
			unitTest:assertFile(tostring(sessionInfo().path))
		end

		unitTest:assertError(error_func, "'/MacOS' is a directory, and not a file.", 10, true)

		local c = Cell{value = 2}
		Log{target = c, file = "mabc.csv"}

		c:notify()

		error_func = function()
			unitTest:assertFile("mabc.csv", 2)
		end

		unitTest:assertError(error_func, "#2 should be between [0, 1], got 2.")

		unitTest:assertFile("mabc.csv")

		error_func = function()
			c = Cell{value = 2}
			Log{target = c, file = "abc.csv"}

			c:notify()
			local u = UnitTest{}
			u:assertFile("abc.csv")
		end

		unitTest:assertError(error_func, "It is not possible to use assertFile without a 'log' directory.")

		unitTest:assert(not File("abc.csv"):exists())

		error_func = function()
			unitTest:assertFile(tostring(packageInfo().data)) -- not possible to use directory
		end

		unitTest:assertError(error_func, "'data' is a directory, and not a file.", 0, true)

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		unitTest:assertEquals(suc2, suc1 + 7)
		unitTest:assertEquals(test2, test1 + 7)
		unitTest:assertEquals(fail2, fail1)
	end,
	assertSnapshot = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		local error_func = function()
			unitTest:assertSnapshot()
		end

		unitTest:assertError(error_func, "Argument #1 should be Chart, Map, TextScreen, Clock or VisualTable, got nil.")

		local ce = Cell{value = 5}
		local ch = Chart{target = ce}

		error_func = function()
			unitTest:assertSnapshot(ch)
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			unitTest:assertSnapshot(ch, "file.bmp", false)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(3, "number", false))

		error_func = function()
			unitTest:assertSnapshot(ch, "file.bmp", 2)
		end

		unitTest:assertError(error_func, "Argument #3 should be between 0 and 1, got 2.")

		error_func = function()
			unitTest:assertSnapshot(ch, "file.bmp", -1)
		end

		unitTest:assertError(error_func, "Argument #3 should be between 0 and 1, got -1.")

		error_func = function()
			local u = UnitTest{}
			u:assertSnapshot(ch, "file.bmp")
		end

		unitTest:assertError(error_func, "It is not possible to use assertSnapshot without a 'log' directory.")

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		unitTest:assertEquals(suc2, suc1 + 6)
		unitTest:assertEquals(test2, test1 + 6)
		unitTest:assertEquals(fail2, fail1)
	end,
	assertType = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		local error_func = function()
			unitTest:assertType()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			unitTest:assertType(2, 2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		unitTest:assertEquals(suc2, suc1 + 2)
		unitTest:assertEquals(test2, test1 + 2)
		unitTest:assertEquals(fail2, fail1)
	end,
	assertWarning = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		local error_func = function()
			unitTest:assertWarning(2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "function", 2))

		error_func = function()
			unitTest:assertWarning(function() end, 2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))

		error_func = function()
			unitTest:assertWarning(function() end, "aaa", false)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(3, "number", false))

		error_func = function()
			unitTest:assertWarning(function() end, "aaa", 2, 2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(4, "boolean", 2))

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		unitTest:assertEquals(suc2, suc1 + 4)
		unitTest:assertEquals(test2, test1 + 4)
		unitTest:assertEquals(fail2, fail1)
	end
}

