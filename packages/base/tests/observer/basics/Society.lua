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
			value = 5,
			total = function(self) return self.value + 5000 end
		}

		local c1 = Chart{target = soc, select = "#"}
		unitTest:assertType(c1, "Chart")

		local c2 = Chart{target = soc, select = {"value", "height", "total"}}
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

		local ts = TextScreen{target = soc}
		LogFile{target = soc, file = "society.csv"}
		local vt = VisualTable{target = soc}

		t:run(15)

		unitTest:assertFile("society.csv")

		unitTest:assertSnapshot(c1, "chart_society.bmp", 0.02)
		unitTest:assertSnapshot(c2, "chart_society_select.bmp", 0.03)
		unitTest:assertSnapshot(ts, "textscreen_society_grow.bmp")
		unitTest:assertSnapshot(vt, "society_visualtable.bmp", 0.059)

		local singleFooAgent = Agent{}
		local cs = CellularSpace{xdim = 10}
		local e = Environment{cs,singleFooAgent}

		e:createPlacement()

		local m = Map{
			target = singleFooAgent
		}

		unitTest:assertSnapshot(m, "map_single_agent.bmp")

		local ag = Agent{
			init = function(self)
				if Random():number() > 0.8 then
					self.class = "large"
				else
					self.class = "small"
				end
			end,
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

		local cs = CellularSpace{xdim = 10}

		local env = Environment{cs, soc}
		env:createPlacement()

		local m = Map{
			target = soc,
			symbol = "beetle",
			color = "green"
		}

		cs:notify()
		soc:sample():reproduce()
		cs:notify()
		cs:notify()
		cs:notify()
		unitTest:assertSnapshot(m, "map_society_reproduce.bmp")
	end
}

