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
-- Author: Pedro R. Andrade (pedro.andrade@inpe.br)
-------------------------------------------------------------------------------------------

return{
	Choice = function(unitTest)
		local c = Choice{1, 2, 3}

		unitTest:assertType(c, "Choice")
		unitTest:assertEquals(#c.values, 3)

		c = Choice{min = 2, max = 3, step = 0.1}
		unitTest:assertType(c, "Choice")
		unitTest:assertEquals(c.min, 2)
		unitTest:assertEquals(c.max, 3)
		unitTest:assertEquals(c.default, 2)
		unitTest:assertEquals(c.step, 0.1)

		c = Choice{min = 5, default = 7}
		unitTest:assertType(c, "Choice")
		unitTest:assertEquals(c.min, 5)
		unitTest:assertEquals(c.default, 7)

		c = Choice{min = 5}
		unitTest:assertType(c, "Choice")
		unitTest:assertEquals(c.default, 5)

		c = Choice{max = 5, default = 3}
		unitTest:assertType(c, "Choice")
		unitTest:assertEquals(c.max, 5)
		unitTest:assertEquals(c.default, 3)

		c = Choice{max = 5}
		unitTest:assertType(c, "Choice")
		unitTest:assertEquals(c.default, 5)

		c = Choice{1, 2, 3, 4, default = 3}
		unitTest:assertEquals(#c.values, 4)
		unitTest:assertEquals(c.default, 3)

		c = Choice{min = 0.1, max = 0.7, step = 0.05}
		unitTest:assertEquals(c.default, 0.1)

		c = Choice{min = 1, max = 5, slices = 10}
		unitTest:assertEquals(c.slices, 10)
		unitTest:assertEquals(#c.values, c.slices)

		c = Choice{min = 2, max = 20, slices = 4}
		unitTest:assertEquals(c.step, 6)
		unitTest:assertEquals(c.slices, 4)
		unitTest:assertEquals(#c.values, c.slices)

		c = Choice{min = 1, max = 5, slices = 5}
		unitTest:assertType(c, "Choice")
		unitTest:assertEquals(c.min, 1)
		unitTest:assertEquals(c.max, 5)
		unitTest:assertEquals(c.default, 1)
		unitTest:assertEquals(c.step, 1)
		unitTest:assertEquals(c.slices, 5)
		unitTest:assertEquals(#c.values, c.slices)

		local expectedvalues = {1.0, 2.0, 3.0, 4.0, 5.0}
		for i, value in ipairs(c.values) do
			unitTest:assertEquals(value, expectedvalues[i])
		end

		local func1 = function() return 1 end
		local func2 = function() return 2 end

		c = Choice{a = func1, b = func2}

		unitTest:assertEquals(#c.values, 0)
		unitTest:assertEquals(getn(c.values), 2)
		unitTest:assertEquals(c.default, "a")

		c = Choice{a = func1, b = func2, default = "b"}

		unitTest:assertEquals(#c.values, 0)
		unitTest:assertEquals(getn(c.values), 2)
		unitTest:assertEquals(c.default, "b")
	end,
	sample = function(unitTest)
		local c = Choice{1, 2, 3}

		unitTest:assertEquals(c:sample(), 2)
		unitTest:assertEquals(c:sample(), 3)
		unitTest:assertEquals(c:sample(), 1)
		unitTest:assertEquals(c:sample(), 1)

		c = Choice{min = 2, max = 3, step = 0.1}

		unitTest:assertEquals(c:sample(), 2.1)
		unitTest:assertEquals(c:sample(), 3)
		unitTest:assertEquals(c:sample(), 2.9)

		c = Choice{min = 1, max = 3}

		unitTest:assertEquals(c:sample(), 1.975266, 0.01)
		unitTest:assertEquals(c:sample(), 1.776360, 0.01)
		unitTest:assertEquals(c:sample(), 2.180204, 0.01)

		c = Choice{min = 1}

		unitTest:assertEquals(c:sample(), 4.2864135353406e+15, 100)
		unitTest:assertEquals(c:sample(), 9.3113723735736e+14, 100)
		unitTest:assertEquals(c:sample(), 1.2947668784705e+15, 100)

		c = Choice{max = 1}

		unitTest:assertEquals(c:sample(), -9.498361830102e+14, 100)
		unitTest:assertEquals(c:sample(), -3.6382329589713e+15, 100)
		unitTest:assertEquals(c:sample(), -1.7993591879204e+15, 100)
	end,
	__tostring = function(unitTest)
		local c = Choice{min = 2, max = 3, step = 0.1}

		unitTest:assertEquals(tostring(c), [[default  number [2]
max      number [3]
min      number [2]
step     number [0.1]
]])

		c = Choice{1, 2, 4, 5}

		unitTest:assertEquals(tostring(c), [[default  number [1]
values   vector of size 4
]])
	end
}

