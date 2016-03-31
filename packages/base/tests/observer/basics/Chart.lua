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
	Chart = function(unitTest)
		local Tube = Model{
			init = function(model)
				model.t = Timer{Event{action = function(ev)
					model.v = model.v + 1
					model:notify(ev)
				end}}
				model.v = 1
			end,
			finalTime = 10
		}

		local tube = Tube{}

		local c = Chart{
			target = tube
		}

		unitTest:assertType(c, "Chart")

		tube:run(10)
		unitTest:assertSnapshot(c, "chart-table-0.bmp", 0.02)

		local world = Agent{
			count = 0,
			m_count = function(self)
				return self.count + 1
			end
		}

		local c1 = Chart{target = world}

		local c1 = Chart{
			target = world,
			select = {"m_count"},
			color = "green",
			size = 5,
			pen = "solid",
			symbol = "square",
			width = 3,
			style = "lines"
		}

		local soc = Society{
			instance = world,
			quantity = 3
		}

		local c1 = Chart{target = soc}

		local soc = Society{
			instance = Agent{},
			quantity = 3,
			total = 10
		}

		local c1 = Chart{target = soc}

		local world = CellularSpace{
			xdim = 10,
			count = 0,
			mCount = function(self)
				return self.count + 1
			end
		}

		local c1 = Chart{target = world}
		world:notify()
		world:notify()
		unitTest:assertSnapshot(c1, "chart-table-base.bmp", 0.02)

		local c1 = Chart{target = world, select = "mCount", xAxis = "count"}
		world:notify()
		world.count = world.count + 2
		world:notify()
		unitTest:assertSnapshot(c1, "chart-table-xaxis.bmp", 0.02)

		local t = {
			value1 = 2,
			value2 = 5
		}

		local c1 = Chart{
			target = t
		}

		t:notify()
	
		local c2 = Chart{
			target = t,
			select = "value1"
		}

		t:notify()
		t:notify()
		t:notify()

		unitTest:assertSnapshot(c1, "chart-table-1.bmp", 0.01)
		unitTest:assertSnapshot(c2, "chart-table-2.bmp", 0.01)

		-- chart using data
		local tab = makeDataTable{
			first = 2000,
			step = 10,
			demand = {7, 8, 9, 10},
			limit = {0.1, 0.04, 0.3, 0.07}
		}

		c1 = Chart{
		    data = tab,
		    select = "limit",
		    xAxis = "demand",
		    color = "blue"
		}
	
		c2 = Chart{
		    data = tab,
		    select = "demand",
		    color = "green",
			pen = "dash"
		}
		
		unitTest:assertSnapshot(c1, "chart-data-1.bmp", 0.01)
		unitTest:assertSnapshot(c2, "chart-data-2.bmp", 0.01)
	end,
	save = function(unitTest)
		local c = Cell{value = 1}

		local ch = Chart{target = c}

		c:notify(1)
		c:notify(2)
		c:notify(3)

		local file = "save_test.bmp"

		ch:save(file)

		unitTest:assertFile(file)
	end
}

