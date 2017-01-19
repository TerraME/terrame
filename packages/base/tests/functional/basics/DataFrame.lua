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
		local df = DataFrame{}

		unitTest:assertEquals(#df, 0)

		df = DataFrame{
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
		unitTest:assertEquals(#df[1], 2)
		unitTest:assertEquals(df[1].x, 1)
		unitTest:assertEquals(df[3].y, 2)

		local tab = DataFrame{
			first = 2000,
			step = 10,
			demand = {7, 8, 9, 10},
			limit = {0.1, 0.04, 0.3, 0.07}
		}

		unitTest:assertType(tab, "DataFrame")
		unitTest:assertType(tab.demand, "table")
		unitTest:assertType(tab.limit, "table")
		unitTest:assertEquals(#tab, 4)
		unitTest:assertEquals(getn(tab.demand), 4)
		unitTest:assertEquals(getn(tab.limit), 4)

		unitTest:assertEquals(tab.demand[2010], 8)
		unitTest:assertEquals(tab.limit[2030], 0.07)

		local sumidx = 0
		local sumvalue = 0

		forEachElement(tab.demand, function(idx, value)
			sumidx = sumidx + idx
			sumvalue = sumvalue + value
		end)

		unitTest:assertEquals(sumidx, 2000 + 2010 + 2020 + 2030)
		unitTest:assertEquals(sumvalue, 7 + 8 + 9 + 10)

		tab = DataFrame{
			first = 2000,
			step = 10,
			last = 2030,
			demand = {7, 8, 9, 10},
			limit = {0.1, 0.04, 0.3, 0.07}
		}

		unitTest:assertType(tab, "DataFrame")
		unitTest:assertType(tab.demand, "table")
		unitTest:assertType(tab.limit, "table")
		unitTest:assertEquals(#tab, 4)
		unitTest:assertEquals(getn(tab.demand), 4)
		unitTest:assertEquals(getn(tab.limit), 4)

		sumidx = 0
		sumvalue = 0

		forEachElement(tab.limit, function(idx, value)
			sumidx = sumidx + idx
			sumvalue = sumvalue + value
		end)

		unitTest:assertEquals(sumidx, 2000 + 2010 + 2020 + 2030)
		unitTest:assertEquals(sumvalue, 0.1 + 0.04 + 0.3 + 0.07)

		local agent = Agent{}

		df = DataFrame{
			x = {1, 2, 3, 4, 5},
			y = {1, 1, 2, 2, 2},
			instance = agent
		}

		unitTest:assertType(df[1], "Agent")
	end,
	add = function(unitTest)
		local df = DataFrame{
			{x = 1, y = 1}
		}

		df:add{x = 5, y = 2}
		df:add{x = 4, y = 2}

		unitTest:assertEquals(#df, 3)
		unitTest:assertEquals(df[3].x, 4)
		unitTest:assertEquals(df.y[2], 2)

		df:add({x = 9, y = 9}, 4)

		unitTest:assertEquals(#df, 4)
		unitTest:assertEquals(df[4].x, 9)
		unitTest:assertEquals(df.y[4], 9)
	end,
	columns = function(unitTest)
		local df = DataFrame{
			{x = 1, y = 1},
			{x = 2, y = 1},
			{x = 3, y = 2},
			{x = 4, y = 2},
			{x = 5, y = 2}
		}

		local cols = df:columns()

		unitTest:assert(cols.x)
		unitTest:assert(cols.y)
		unitTest:assertEquals(getn(cols), 2)
	end,
	remove = function(unitTest)
		local df = DataFrame{
			{x = 1, y = 1},
			{x = 2, y = 1},
			{x = 3, y = 2},
			{x = 4, y = 2},
			{x = 5, y = 2}
		}

		unitTest:assertEquals(#df, 5)

		df:remove(3)
		unitTest:assertEquals(#df, 4)
		unitTest:assertEquals(df[3].x, 4)
	end,
	rows = function(unitTest)
		local df = DataFrame{
			{x = 1, y = 1},
			{x = 2, y = 1},
			{x = 3, y = 2},
			{x = 4, y = 2},
			{x = 5, y = 2}
		}

		local rows = df:rows()

		for i = 1, 5 do
			unitTest:assert(rows[i])
		end

		unitTest:assertEquals(#rows, 5)
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

		unitTest:assertNil(df[1].z)

		df[1].z = 2

		unitTest:assertEquals(df[1].z, 2)
		unitTest:assertEquals(df.z[1], 2)

		unitTest:assertEquals(df[3].y, 2)
		unitTest:assertEquals(df.y[3], 2)

		df[3].y = 7

		unitTest:assertEquals(df[3].y, 7)
		unitTest:assertEquals(df.y[3], 7)

		df.y[3] = 9

		unitTest:assertEquals(df[3].y, 9)
		unitTest:assertEquals(df.y[3], 9)

		-- cache
		df = DataFrame{
			x = {1, 2, 3},
			y = {4, 5, 6}
		}

		unitTest:assertEquals(getn(df.cache), 0)

		do
			local value = df[1]
			unitTest:assertEquals(value.y, 4)
			unitTest:assertEquals(getn(df.cache), 1)

			local values = {}

			for i = 1, 3 do
				values[i] = df[i]
				values[i].x = values[i].x + 1
			end

			collectgarbage()
			unitTest:assertEquals(getn(df.cache), 3)

			value = df[2]
			unitTest:assertEquals(value.x, 3)
		end

		collectgarbage()
		unitTest:assertEquals(getn(df.cache), 0)

		-- cache with instance
		df = DataFrame{
			x = {1, 2, 3},
			y = {4, 5, 6},
			instance = Agent{}
		}

		unitTest:assertEquals(getn(df.cache), 0)

		do
			local value = df[1]
			unitTest:assertType(value, "Agent")
			unitTest:assertEquals(value.y, 4)
			unitTest:assertEquals(getn(df.cache), 1)

			local values = {}

			for i = 1, 3 do
				values[i] = df[i]
				unitTest:assertType(values[i], "Agent")
				values[i].x = values[i].x + 1
			end

			collectgarbage()
			unitTest:assertEquals(getn(df.cache), 3)

			value = df[2]
			unitTest:assertEquals(value.x, 3)
		end

		collectgarbage()
		unitTest:assertEquals(getn(df.cache), 0)

	end,
	__newindex = function(unitTest)
		local df = DataFrame{
			{x = 1, y = 1},
			{x = 2, y = 1},
			{x = 3, y = 2},
			{x = 4, y = 2},
			{x = 5, y = 2}
		}

		df.z = {5, 4, 3, 2, 1}

		for i = 1, 5 do
			unitTest:assertEquals(df[i].z, 6 - i)
		end

		df[6] = {x = 9, y = 9, z = 9}

		unitTest:assertEquals(#df, 6)
		unitTest:assertEquals(df[6].x, 9)
		unitTest:assertEquals(df.y[6], 9)
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

		unitTest:assertEquals(tostring(df), [[	x	y
1	1	1
2	2	1
3	3	2
4	4	2
5	5	2]])

	unitTest:assertEquals(tostring(df[1]), [[{
    x = 1,
    y = 1
}]])

	end
}

