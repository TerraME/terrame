-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.

-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this software and its documentation.
--
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
		unitTest:assertType(c2, "Chart")

		local c3 = Chart{
			target = world,
			style = "steps",
			pen = "dashdot",
			width = 2
		}
		unitTest:assertType(c3, "Chart")

		local c4 = Chart{
			target = world,
			select = "sum",
			style = "sticks",
			pen = "dashdotdot",
			width = 2
		}
		unitTest:assertType(c4, "Chart")

		local c5 = Chart{
			target = world,
			select = {"value", "sum"},
			color = {"green", "yellow"},
			size = 10,
			pen = "dot",
			symbol = "diamond"
		}
		unitTest:assertType(c5, "Chart")

		local t = Timer{
			Event{action = function()
				world.count = world.count + 1
			end},
			Event{action = c1},
			Event{action = c2},
			Event{action = c3},
			Event{action = c4},
			Event{action = c5}
		}

		local ts = TextScreen{target = world}
		LogFile{target = world, file = "cell.csv"}
		local vt = VisualTable{target = world}

		t:run(15)

		unitTest:assertFile("cell.csv")

		unitTest:assertSnapshot(c1, "chart_cell.bmp", 0.03)
		unitTest:assertSnapshot(c2, "chart_cell_select.bmp", 0.04)
		unitTest:assertSnapshot(c3, "chart_cell_style.bmp", 0.03)
		unitTest:assertSnapshot(c4, "chart_cell_select_pen.bmp", 0.04)
		unitTest:assertSnapshot(c5, "chart_cell_select_color.bmp", 0.04)
		unitTest:assertSnapshot(ts, "textscreen_cell.bmp", 0.06)
		unitTest:assertSnapshot(vt, "cell_visualtable.bmp", 0.015)

		world:notify(Event{start = 31, action = function() end})

		-- the call to notify() above creates the file again.
		-- remove the line below after refactoring observer.
		if isFile("cell.csv") then rmFile("cell.csv") end

-- FIXME: bug below
--[[
		world = Cell{value = 3, value2 = 5}

		unitTest:clear()
		c = InternetSender{
			target = world,
			select = {"value", "value2"},
			protocol = "udp",
			port = 11111
		}
		unitTest:assertType(c, "number") -- SKIP
		world:notify(1)
		world:notify(2)
--]]
	end
}

