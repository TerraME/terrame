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
-------------------------------------------------------------------------------------------

return{
	DataFrame = function(unitTest)
		local df = DataFrame{
			x = {1, 2, 3, 4, 5},
			y = {1, 1, 2, 2, 2}
		}

		unitTest:assertType(df, "DataFrame")
		unitTest:assertEquals(#df, 5)

		df = DataFrame{
			{x = 1, y = 1},
			{x = 2, y = 1},
			{x = 3, y = 2},
			{x = 4, y = 2},
			{x = 5, y = 2}
		}

		unitTest:assertType(df, "DataFrame")
		unitTest:assertEquals(#df, 5)
		unitTest:assertEquals(#df.x, 5)
		unitTest:assertEquals(#df.y, 5)
		unitTest:assertEquals(getn(df[1]), 2)
		unitTest:assertEquals(df[1].x, 1)
		unitTest:assertEquals(df[3].y, 2)
	end,
	__index = function(unitTest)
		local df = DataFrame{
			{x = 1, y = 1},
			{x = 2, y = 1},
			{x = 3, y = 2},
			{x = 4, y = 2},
			{x = 5, y = 2}
		}

		unitTest:assertEquals(df[3].y, 2)
	end,
	__newindex = function(unitTest)
		local df = DataFrame{
			{x = 1, y = 1},
			{x = 2, y = 1},
			{x = 3, y = 2},
			{x = 4, y = 2},
			{x = 5, y = 2}
		}

		unitTest:assertEquals(df[3].y, 2)
		unitTest:assertEquals(df.y[3], 2)

		df[3].y = 7

		unitTest:assertEquals(df[3].y, 7)
		unitTest:assertEquals(df.y[3], 7)

		df.y[3] = 9

		unitTest:assertEquals(df[3].y, 9)
		unitTest:assertEquals(df.y[3], 9)
	end,
	__len = function(unitTest)
		local df = DataFrame{
			{x = 1, y = 1},
			{x = 2, y = 1},
			{x = 3, y = 2},
			{x = 4, y = 2},
			{x = 5, y = 2}
		}

		unitTest:assertEquals(#df, 5)
	end,
	__tostring = function(unitTest)
		local df = DataFrame{
			{x = 1, y = 1},
			{x = 2, y = 1},
			{x = 3, y = 2},
			{x = 4, y = 2},
			{x = 5, y = 2}
		}

		unitTest:assertEquals(tostring(df), [[x	y
1	1
2	1
3	2
4	2
5	2]])
	end
}

