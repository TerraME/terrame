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
-- indirect, special, incidental, or caonsequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Pedro R. Andrade
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

return{
	UnitTest = function(unitTest)
		local u = UnitTest{sleep = 0.1, source = "Test"}

		unitTest:assertType(u, "UnitTest")
		unitTest:assertEquals(u.success, 0)
		unitTest:assertEquals(u.fail, 0)
		unitTest:assertEquals(u.test, 0)
		unitTest:assertEquals(u.last_error, "")
		unitTest:assertEquals(u.count_last, 0)
		unitTest:assertEquals(u.sleep, 0.1)
		unitTest:assertEquals(u.source, "test")
	end,
	assert = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		unitTest:assert(true)

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

		unitTest:assertEquals(0, 0)
		unitTest:assertEquals(math.huge, math.huge)

		unitTest:assertEquals(currentDir(), currentDir())
		unitTest:assertEquals(File("abc.txt"), File("abc.txt"))

		unitTest:assertEquals(1, 1.1, 0.15)
		unitTest:assertEquals("abc", "abd", 1)

		local actual = "string [/home/jenkins/Documents/ba1c13592dcf65f3d0b2929f8eff266c4e622470/install/bin/packages/gis/data/biomassa-manaus.asc]"
		local expected = "string [biomassa-manaus.asc]"
		unitTest:assertEquals(actual, expected, 0, true)

		actual = "string [C:/home/jenkins/Documents/ba1c13592dcf65f3d0b2929f8eff266c4e622470/install/bin/packages/gis/data/biomassa-manaus.asc]"
		expected = "string [biomassa-manaus.asc]"
		unitTest:assertEquals(actual, expected, 0, true)

		actual = "string [C:/biomassa-manaus.asc]"
		expected = "string [biomassa-manaus.asc]"
		unitTest:assertEquals(actual, expected, 0, true)

		actual = [[file     string [packages\gis\data\Setores_Censitarios_2000_pol.shp]
name     string [Setores_2000]
project  Project
rep      string [geometry]
sid      string [055e2e78-18d7-4246-9e03-dbe2277a7e77]
source   string [shp]
]]
		expected = [[file     string [packagesSetores_Censitarios_2000_pol.shp]
name     string [Setores_2000]
project  Project
rep      string [geometry]
sid      string [055e2e78-18d7-4246-9e03-dbe2277a7e77]
source   string [shp]
]]
		unitTest:assertEquals(actual, expected, 0, true)

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		unitTest:assertEquals(suc2, suc1 + 10)
		unitTest:assertEquals(test2, test1 + 10)
		unitTest:assertEquals(fail2, fail1)
	end,
	assertError = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		local error_func = function()
			CellularSpace{xdim = "a"}
		end

		unitTest:assertError(error_func, "Incompatible types. Argument 'xdim' expected number, got string.")

		error_func = function()
			CellularSpace{xdim = "a"}
		end

		unitTest:assertError(error_func, "Incompatible types. Argument 'xdim' expected number, got   string.", 3)

		error_func = function()
			customError("File '/a/b/c/d/e' should not be shown.")
		end

		unitTest:assertError(error_func, "File 'e' should not be shown.", 0, true)

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		unitTest:assertEquals(suc2, suc1 + 3)
		unitTest:assertEquals(test2, test1 + 3)
		unitTest:assertEquals(fail2, fail1)
	end,
	assertFile = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		local c = Cell{value = 2}
		Log{target = c, file = "abc.csv"}
		c:notify()

		unitTest:assertFile("abc.csv")

		c = Cell{value = 2}
		Log{target = c, file = "assertFile.csv"}
		c:notify()

		unitTest:assertFile(File("assertFile.csv"))

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		unitTest:assertEquals(suc2, suc1 + 2)
		unitTest:assertEquals(test2, test1 + 2)
		unitTest:assertEquals(fail2, fail1)
	end,
	assertNil = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		unitTest:assertNil()

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		unitTest:assertEquals(suc2, suc1 + 1)
		unitTest:assertEquals(test2, test1 + 1)
		unitTest:assertEquals(fail2, fail1)
	end,
	assertNotNil = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		unitTest:assertNotNil(true)

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		unitTest:assertEquals(suc2, suc1 + 1)
		unitTest:assertEquals(test2, test1 + 1)
		unitTest:assertEquals(fail2, fail1)
	end,
	assertType = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		unitTest:assertType(2, "number")

		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		unitTest:assertEquals(suc2, suc1 + 1)
		unitTest:assertEquals(test2, test1 + 1)
		unitTest:assertEquals(fail2, fail1)
	end,
	assertWarning = function(unitTest)
		local suc1 = unitTest.success
		local test1 = unitTest.test
		local fail1 = unitTest.fail

		local warning_func = function()
			customWarning("abc")
		end

		unitTest:assertWarning(warning_func, "abc")

		warning_func = function()
			customWarning("abc")
		end

		unitTest:assertWarning(warning_func, "abc2", 1)


		local suc2 = unitTest.success
		local test2 = unitTest.test
		local fail2 = unitTest.fail

		unitTest:assertEquals(suc2, suc1 + 2)
		unitTest:assertEquals(test2, test1 + 2)
		unitTest:assertEquals(fail2, fail1)
	end,
	printError = function(unitTest)
		unitTest:assert(true)
	end
}

