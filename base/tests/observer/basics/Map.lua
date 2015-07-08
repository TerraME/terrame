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
-------------------------------------------------------------------------------------------

return{
	Map = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local r = Random()

		forEachCell(cs, function(cell)
			cell.value = r:number()
		end)

		local m = Map{
			target = cs,
			select = "value",
			min = 0,
			max = 1,
			slices = 10,
			color = "Blues"
		}

		unitTest:assertType(m, "Map")

		cs:notify()
		unitTest:assertSnapshot(m, "map_basic.bmp")

		forEachCell(cs, function(cell)
			cell.value = r:integer(1, 3)
		end)

		m = Map{
			target = cs,
			select = "value",
			color = {"red", "green", "blue"},
			value = {1, 2, 3}
		}

		unitTest:assertType(m, "Map")

		cs:notify()
		unitTest:assertSnapshot(m, "map_uniquevalue.bmp")

		local m = Map{
			target = cs,
			color = "blue"
		}

		unitTest:assertType(m, "Map")

		cs:notify()
		unitTest:assertSnapshot(m, "map_background.bmp")

		local r = Random{seed = 10}

		local c = Cell{
			mvalue = function()
				return r:number()
			end
		}

		local cs = CellularSpace{
			xdim = 5,
			instance = c
		}

		local m = Map{
			target = cs,
			select = "mvalue",
			min = 0,
			max = 1,
			slices = 10,
			color = "Blues"
		}

		cs:notify()
		unitTest:assertSnapshot(m, "map_function.bmp")

		local c = Choice{"low", "medium", "high"}
		local cs = CellularSpace{xdim = 5}
		forEachCell(cs, function(cell)
			cell.level = c:sample()
		end)

		m = Map{
			target = cs,
			select = "level",
			color = {"blue", "green", "red"},
			value = {"low", "medium", "high"}
		}

		unitTest:assertType(m, "Map")

		cs:notify()
		unitTest:assertSnapshot(m, "map_string.bmp")

		local cs = CellularSpace{xdim = 10}

		local r = Random()

		forEachCell(cs, function(cell)
			cell.value = r:number()
		end)

		local m = Map{
			target = cs,
			select = "value",
			min = 0,
			max = 1,
			slices = 10,
			grouping = "quantil",
			color = "Blues"
		}

		unitTest:assertType(m, "Map")

		unitTest:assertSnapshot(m, "map_quantil.bmp")

		forEachCell(cs, function(cell)
			cell.w = cell.x
		end)

		local m = Map{
			target = cs,
			select = "w",
			min = 0,
			max = 10,
			slices = 3,
			grouping = "quantil",
			color = "Blues"
		}

		unitTest:assertSnapshot(m, "map_quantil_3.bmp")

		local m = Map{
			target = cs,
			select = "w",
			min = 0,
			max = 10,
			slices = 10,
			grouping = "quantil",
			color = "Blues"
		}

		unitTest:assertSnapshot(m, "map_quantil_10.bmp")
	end,
	save = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local r = Random()

		forEachCell(cs, function(cell)
			cell.value = r:number()
		end)

		local m = Map{
			target = cs,
			select = "value",
			min = 0,
			max = 1,
			slices = 10,
			color = "Blues"
		}

		unitTest:assertType(m, "Map")

		cs:notify()

		unitTest:assertSnapshot(m, "map_save.bmp")
	end
}

