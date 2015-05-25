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
		cs:notify()
		cs:notify()
		cs:notify()
		unitTest:assertSnapshot(m, "map_uniquevalue.bmp")

		local m = Map{
			target = cs,
			color = "blue"
		}

		unitTest:assertType(m, "Map")

		cs:notify()
		cs:notify()
		cs:notify()
		cs:notify()
		unitTest:assertSnapshot(m, "map_background.bmp")
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

