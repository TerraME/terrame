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
	Society = function(unitTest)
		local ag = Agent{
			height = 1,
			grow = function(self)
				self.height = self.height + 1
			end
		}

		local soc = Society{
			instance = ag,
			quantity = 10,
			value = 5
		}

		local c1 = Chart{target = soc, select = "#"}
		unitTest:assertType(c1, "Chart")

		local c2 = Chart{target = soc, select = {"value", "height"}}
		unitTest:assertType(c2, "Chart")

		soc:notify()

		local t = Timer{
			Event{action = function(e)
				for i = 1, e:getTime() do
					soc:grow()
					soc:add()
					soc.value = soc.value + 1
				end
				soc:notify(e)
			end}
		}

		TextScreen{target = soc}
		LogFile{target = soc}
		VisualTable{target = soc}
		t:execute(30)
		unitTest:assertSnapshot(c1, "chart_society.bmp")
		unitTest:assertSnapshot(c2, "chart_society_select.bmp")

--[[
		local cs = CellularSpace{
			xdim = 10
		}

		local env = Environment{cs, soc}
		env:createPlacement()

		local m = Map{
			target = soc -- white background
		}

		unitTest:assertSnapshot(m, "map_society_background.bmp")

		local m = Map{
			target = soc,
			background = "green"
		}
		unitTest:assertSnapshot(m, "map_society_background2.bmp")

		forEachCell(cs, function(cell)
			cell.value = Random():number()
		end)

		local m1 = Map{
			target = cs,
			min = 0,
			max = 1,
			colors = "Blues",
			slices = 10
		}

		m = Map{
			target = soc,
			background = m1,
			size = 2, -- size = {1, 10} to work in the same way of value
			symbol = "smile"
		}

		unitTest:assertSnapshot(m, "map_society_symbol.bmp")
--]]
	end
}

