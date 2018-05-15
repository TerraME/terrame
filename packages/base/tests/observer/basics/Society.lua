-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

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
				for _ = 1, e:getTime() do
					soc:grow()
					soc:add()
					soc.value = soc.value + 1
				end
				soc:notify(e)
			end}
		}

		local ts = TextScreen{target = soc}
		Log{target = soc, file = "society.csv"}
		local vt = VisualTable{target = soc}

		t:run(15)

		unitTest:assertFile("society.csv")

		unitTest:assertSnapshot(c1, "chart_society.bmp", 0.03)
		unitTest:assertSnapshot(c2, "chart_society_select.bmp", 0.05)
		unitTest:assertSnapshot(ts, "textscreen_society_grow.bmp", 0.05)
		unitTest:assertSnapshot(vt, "society_visualtable.bmp", 0.2)

		local singleFooAgent = Agent{}
		local cs = CellularSpace{xdim = 10}
		local e = Environment{cs,singleFooAgent}

		e:createPlacement()

		local m = Map{
			target = singleFooAgent
		}

		unitTest:assertSnapshot(m, "map_single_agent.bmp", 0.03)

		ag = Agent{
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

		soc = Society{
			instance = ag,
			quantity = 10,
			value = 5
		}

		cs = CellularSpace{xdim = 10}

		local env = Environment{cs, soc}
		env:createPlacement()

		m = Map{
			target = soc,
			symbol = "beetle",
			color = "green"
		}

		cs:notify()
		soc:sample():reproduce()
		cs:notify()
		cs:notify()
		cs:notify()
		unitTest:assertSnapshot(m, "map_society_reproduce.bmp", 0.09)

		local killingAgents = function()
			singleFooAgent = Agent{
				execute = function(self)
					if Random{p = 0.05}:sample() then
						self:reproduce()
						self:die()
					end
				end
			}

			soc = Society{
				instance = singleFooAgent,
				quantity = 100
			}

			cs = CellularSpace{
				xdim = 20
			}

			e = Environment{cs, soc}

			e:createPlacement{max = 5}

			m = Map{target = soc}

			t = Timer{
				Event{action = soc},
				Event{action = m}
			}

			t:run(100)

			unitTest:assertEquals(#soc, 100)
			unitTest:assertSnapshot(m, "map_society_die.png")
		end

		unitTest:assert(killingAgents)
	end
}

