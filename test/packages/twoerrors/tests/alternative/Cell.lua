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
	Cell = function(unitTest)
		local world = Cell{
			count = 0,
			value = function(self)
				return self.count + 2
			end,
			sum = function(self)
				return self.count + 4
			end
		}

		local c1 = Chart{target = world}
		unitTest:assertType(c1, "Chart")

		local c2 = Chart{target = world, select = {"count", "value", "sum"}}
		unitTest:assertType(c2, "Map")
		
		if false then
			unitTest:assertType(c2, "Map")
		end

		world:notify()

		local t = Timer{
			Event{action = function()
				world.count = world.count + 1
				world:notify()
			end}
		}

		t:execute(30)
		local s = sessionInfo().separator

		unitTest:assertSnapshot(c1, "chart_cell.bmp")
		unitTest:assertSnapshot(c2, "chart_cell_select.bmp")

		local c = abc + def
	end
}

