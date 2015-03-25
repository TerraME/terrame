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
	assert = function(unitTest)
		local u = UnitTest{}

		u:assert(true)

		unitTest:assert_equal(u.success, 1)
	end,
	assert_equal = function(unitTest)
		local u = UnitTest{}
		u:assert_equal(true, true)

		unitTest:assert_equal(u.success, 1)
	end,
	assert_error = function(unitTest)
		local u = UnitTest{}

		local error_func = function() CellularSpace{xdim = "a"} end
		u:assert_error(error_func, "Incompatible types. Argument 'xdim' expected number, got string.")

		local error_func = function() CellularSpace{xdim = "a"} end
		u:assert_error(error_func, "Incompatible types. Argument 'xdim' expected number, got   string.", 3)

		unitTest:assert_equal(u.success, 2)
	end,
	assert_nil = function(unitTest)
		local u = UnitTest{}
		u:assert_nil()

		unitTest:assert_equal(u.success, 1)
	end,
	assert_not_nil = function(unitTest)
		local u = UnitTest{}
		u:assert_not_nil(true)

		unitTest:assert_equal(u.success, 1)
	end,
	assert_type = function(unitTest)
		local u = UnitTest{}

		u:assert_type(2, "number")

		unitTest:assert_equal(u.success, 1)
	end,
	delay = function(unitTest)
		local u = UnitTest{sleep = 1}
		unitTest:assert(true)
	end,
	print_error = function(unitTest)
		unitTest:assert(true)
	end,
	tmpFolder = function(unitTest)
		local u = UnitTest{}

		local f = u:tmpFolder()
		local g = u:tmpFolder()

		unitTest:assert_equal(f, g)
		unitTest:assert_type(f, "string")
		os.execute("rm -rf "..f)
	end,
	UnitTest = function(unitTest)
		local u = UnitTest{sleep = 0.1, dbType = "Test"}

		unitTest:assert_type(u, "UnitTest")
		unitTest:assert_equal(u.success, 0)
		unitTest:assert_equal(u.fail, 0)
		unitTest:assert_equal(u.test, 0)
		unitTest:assert_equal(u.last_error, "")
		unitTest:assert_equal(u.count_last, 0)
		unitTest:assert_equal(u.sleep, 0.1)
		unitTest:assert_equal(u.dbType, "test")

		u:delay()
	end
}

