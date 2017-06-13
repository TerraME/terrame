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
	assertEquals = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail
		local originalCustomWarning = customWarning

		unitTest:assertEquals(2, 3)
		unitTest:assertEquals(2, 3, 0.5)
		unitTest:assertEquals("2", "3")
		unitTest:assertEquals("2", 3)
		unitTest:assertEquals(true, false)

		local expected = [[string [biomassa-manaus.asc] ]]

		unitTest:assertEquals(expected, "bbb", 0, true)

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		-- THE TESTS BELOW SHOULD NOT FAIL
		unitTest:assertEquals(suc2, suc1)
		unitTest:assertEquals(test2, test1 + 6)
		unitTest:assertEquals(fail2, fail1 + 6)
		unitTest:assertEquals(originalCustomWarning, customWarning)
	end,
	assertError = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		local error_func = function() end

		unitTest:assertError(error_func, "abc")

		for i = 1, 5 do
			unitTest:assert(false)
		end

		local myError = function()
			customWarning("abc")
		end

		unitTest:assertError(myError, "abc")

		error_func = function()
			customError("abc")
		end

		unitTest:assertError(error_func, "def")

		error_func = function()
			customError("abc")
		end

		unitTest:assertError(error_func, "def", 2)

		-- these should be the last tests before checking the unitTest attributes
		for i = 1, 5 do
			unitTest:assert(false)
		end

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		-- THE TESTS BELOW SHOULD NOT FAIL
		unitTest:assertEquals(suc2, suc1)
		unitTest:assertEquals(test2, test1 + 14)
		unitTest:assertEquals(fail2, fail1 + 14)
	end,
	assertFile = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		if isFile("abc123.csv") then
			rmFile("abc123.csv")
		end

		unitTest:assertFile("abc123.csv") -- file does not exist

		local c = Cell{value = 2}
		Log{target = c, file = "mabc.csv"}

		c:notify()

		unitTest:assertFile("mabc.csv")

		c = Cell{value = 2}
		Log{target = c, file = "mabc.csv"}

		c:notify()

		unitTest:assertFile("mabc.csv") -- more than one assert

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		-- THE TESTS BELOW SHOULD NOT FAIL
		unitTest:assertEquals(suc2, suc1 + 1)
		unitTest:assertEquals(test2, test1 + 3)
		unitTest:assertEquals(fail2, fail1 + 2)
	end,
	assertNil = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		unitTest:assertNil(2)

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		-- THE TESTS BELOW SHOULD NOT FAIL
		unitTest:assertEquals(suc2, suc1)
		unitTest:assertEquals(test2, test1 + 1)
		unitTest:assertEquals(fail2, fail1 + 1)
	end,
	assertNotNil = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		unitTest:assertNotNil()

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		-- THE TESTS BELOW SHOULD NOT FAIL
		unitTest:assertEquals(suc2, suc1)
		unitTest:assertEquals(test2, test1 + 1)
		unitTest:assertEquals(fail2, fail1 + 1)
	end,
	assertSnapshot = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		local c = Cell{value = 1}
		local chart = Chart{target = c}

		chart:update(1)
		chart:update(2)
		chart:update(3)
		chart:update(4)

		unitTest:assertSnapshot(chart, "my-chart-1.png")
		unitTest:assertSnapshot(chart, "my-chart-2.png")

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		-- THE TESTS BELOW SHOULD NOT FAIL
		unitTest:assertEquals(suc2, suc1)
		unitTest:assertEquals(test2, test1 + 2)
		unitTest:assertEquals(fail2, fail1 + 2)
	end,

	assertType = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		unitTest:assertType(2, "string")

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		-- THE TESTS BELOW SHOULD NOT FAIL
		unitTest:assertEquals(suc2, suc1)
		unitTest:assertEquals(test2, test1 + 1)
		unitTest:assertEquals(fail2, fail1 + 1)
	end,
	assertWarning = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		local myWarning = function()
			customError("abc")
		end

		unitTest:assertWarning(myWarning, "abc")

		local myWarning = function()
			customWarning("abc1")
			customWarning("abc2")
			customWarning("abc3")
		end

		unitTest:assertWarning(myWarning, "abc")

		myWarning = function()
			customWarning("abc")
			customWarning("abc")
			customWarning("abc")
		end

		unitTest:assertWarning(myWarning, "abc")

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		-- THE TESTS BELOW SHOULD NOT FAIL
		unitTest:assertEquals(suc2, suc1)
		unitTest:assertEquals(test2, test1 + 3)
		unitTest:assertEquals(fail2, fail1 + 3)
	end
}

