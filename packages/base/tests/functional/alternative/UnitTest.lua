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
	assert = function(unitTest)
		local u = UnitTest{unittest = true}

		local error_func = function()
			u:assert(2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "boolean", 2))

		for i = 1, 5 do

			error_func = function()
				u:assert(false)
			end

			if i == 1 then
				unitTest:assertError(error_func, "Test should be true, got false.")
			else
				error_func()
			end
		end

		error_func = function()
			u:assert(false)
		end

		unitTest:assertError(error_func, "[The error above occurs more 4 times.]")
	end,
	assertEquals = function(unitTest)
		local u = UnitTest{unittest = true}

		local error_func = function()
			u:assertEquals()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			u:assertEquals(1)
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			u:assertEquals(2, 2, "a")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(3, "number", "a"))

		error_func = function()
			u:assertEquals(false, true, 2)
		end

		unitTest:assertError(error_func, "#3 should be used only when comparing numbers or strings (#1 is boolean).")

		error_func = function()
			u:assertEquals(2, 3)
		end

		unitTest:assertError(error_func, "Values should be equal, but got '2' and '3'. The maximum difference is 0, but got 1.")

		error_func = function()
			u:assertEquals(2, 3, 0.5)
		end

		unitTest:assertError(error_func, "Values should be equal, but got '2' and '3'. The maximum difference is 0.5, but got 1.")

		error_func = function()
			u:assertEquals("2", "3")
		end

		unitTest:assertError(error_func, "Values should be equal, but got \n'2' and \n'3'. The maximum tolerance is 0, but got 1.")

		error_func = function()
			u:assertEquals("2", 3)
		end

		unitTest:assertError(error_func, "Values should be equal, but they have different types (string and number).")
	
		error_func = function()
			u:assertEquals(true, false)
		end

		unitTest:assertError(error_func, "Values have the same type (boolean) but different values.")

		local expected = [[string [biomassa-manaus.asc] ]]
		local actual = [[string [/home/jenkins/Documents/ba1c13592dcf65f3d0b2929f8eff266c4e622470/install/bin/packages/terralib/data/biomassa-manaus.asc] ]]

		error_func = function()
			u:assertEquals(expected, actual, 0, "")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(4, "boolean", actual))

		error_func = function()
			u:assertEquals(expected, "bbb", 0, true)
		end

		unitTest:assertError(error_func, "Values should be equal, but got \n'"..expected.."' and \n'".."bbb".."'. The maximum tolerance is 0, but got 28.")
	end,
	assertError = function(unitTest)
		local u = UnitTest{unittest = true}

		local error_func = function()
			u:assertError(2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "function", 2))

		error_func = function()
			u:assertError(function() end, 2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))

		error_func = function()
			u:assertError(function() end, "aaa", false)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(3, "number", false))
	end,
	assertFile = function(unitTest)
		local u = UnitTest{unittest = true}

		local error_func = function()
			u:assertFile(2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))

		error_func = function()
			u:assertFile("abcd1234.txt")
		end

		unitTest:assertError(error_func, resourceNotFoundMsg(1, "abcd1234.txt"))

		error_func = function()
			u:assertFile(tostring(sessionInfo().path))
		end

		unitTest:assertError(error_func, "It is not possible to use a directory as #1 for assertFile().")

		local c = Cell{value = 2}
		Log{target = c, file = "mabc.csv"}

		c:notify()
		unitTest:assertFile("mabc.csv")

		local str

		local oldPrint = unitTest.printError

		unitTest.printError = function(_, v)
			str = v
		end

		Log{target = c, file = "mabc.csv"}

		c:notify()
		unitTest:assertFile("mabc.csv")
		unitTest:assertEquals(str, "Log file 'mabc.csv' is used in more than one assert.")

		unitTest.fail = unitTest.fail - 1
		unitTest.success = unitTest.success + 1
		unitTest.printError = oldPrint

		u = UnitTest{}
		c = Cell{value = 2}
		Log{target = c, file = "abc.csv"}

		c:notify()

		error_func = function()
			u:assertFile("abc.csv")
		end

		u:assertError(error_func, "It is not possible to use assertFile without a 'log' directory.")

		unitTest:assert(not File("abc.csv"):exists())
	end,
	assertNil = function(unitTest)
		local u = UnitTest{unittest = true}

		local error_func = function()
			u:assertNil(2)
		end

		unitTest:assertError(error_func, "Test should be nil, got number.")
	end,
	assertNotNil = function(unitTest)
		local u = UnitTest{unittest = true}

		local error_func = function()
			u:assertNotNil()
		end

		unitTest:assertError(error_func, "Test should not be nil.")
	end,
	assertSnapshot = function(unitTest)
		local u = UnitTest{unittest = true}

		local error_func = function()
			u:assertSnapshot()
		end

		unitTest:assertError(error_func, "Argument #1 should be Chart, Map, TextScreen, Clock or VisualTable, got nil.")

		local ce = Cell{value = 5}
		local ch = Chart{target = ce}

		error_func = function()
			u:assertSnapshot(ch)
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			u:assertSnapshot(ch, "file.bmp", false)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(3, "number", false))
	
		error_func = function()
			u:assertSnapshot(ch, "file.bmp", 2)
		end

		unitTest:assertError(error_func, "Argument #3 should be between 0 and 1, got 2.")
	
		error_func = function()
			u:assertSnapshot(ch, "file.bmp", -1)
		end

		unitTest:assertError(error_func, "Argument #3 should be between 0 and 1, got -1.")
	
		error_func = function()
			u:assertSnapshot(ch, "file.bmp")
		end

		unitTest:assertError(error_func, "It is not possible to use assertSnapshot without a 'log' directory.")
	end,
	assertType = function(unitTest)
		local u = UnitTest{unittest = true}

		local error_func = function()
			u:assertType()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			u:assertType(2, 2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))

		error_func = function()
			u:assertType(2, "string")
		end

		unitTest:assertError(error_func, "Test should be string got number.")
	end
}

