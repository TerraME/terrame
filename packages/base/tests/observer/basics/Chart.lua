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
	Chart = function(unitTest)
		local Tube = Model{
			init = function(model)
				model.v = 1

				model.c = Chart{
					target = model
				}

				model.t = Timer{Event{action = function(ev)
					model.v = model.v + 1
					model.c:update(ev)
				end}}

			end,
			finalTime = 10
		}

		local tube = Tube{}
		unitTest:assertType(tube.c, "Chart")

		tube:run(10)
		unitTest:assertSnapshot(tube.c, "chart-table-0.bmp", 0.02)

		local world = Agent{
			count = 0,
			m_count = function(self)
				return self.count + 1
			end
		}

		Chart{target = world}

		Chart{
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

		Chart{target = soc}

		soc = Society{
			instance = Agent{},
			quantity = 3,
			total = 10
		}

		Chart{target = soc}

		world = CellularSpace{
			xdim = 10,
			count = 0,
			mCount = function(self)
				return self.count + 1
			end
		}

		local c1 = Chart{target = world}
		c1:update(0)
		c1:update(1)
		unitTest:assertSnapshot(c1, "chart-table-base.bmp", 0.03)

		c1 = Chart{target = world, select = "mCount", xAxis = "count"}
		c1:update(0)
		world.count = world.count + 2
		c1:update(1)
		unitTest:assertSnapshot(c1, "chart-table-xaxis.bmp", 0.03)

		c1 = Chart{target = world, select = "count", xAxis = "mCount"}
		c1:update(0)
		world.count = world.count + 2
		c1:update(1)
		unitTest:assertSnapshot(c1, "chart-table-xaxis-func.bmp", 0.03)

		local t = DataFrame{
			value1 = {2, 2, 2},
			value2 = {5, 5, 5}
		}

		local c2 = Chart{
			target = t,
			select = "value1"
		}

		unitTest:assertSnapshot(c1, "chart-table-1.bmp", 0.03)
		unitTest:assertSnapshot(c2, "chart-table-2.bmp", 0.03)

		-- chart observing string values from sets
		local cell = Cell{
			state = "alive"
		}

		local cs = CellularSpace{
			xdim = 10,
			instance = cell
		}

		local map = Map{
			target = cs,
			select = "state",
			value = {"dead", "alive"},
			color = {"black", "blue"}
		}

		local chart = Chart{
			target = map
		}

		chart:update(1)
		for i = 2, 30 do
			cs:sample().state = "dead"
			chart:update(i)
		end

		unitTest:assertSnapshot(chart, "chart-function-cs.bmp", 0.1)

		local agent = Agent{
			state = "alive"
		}

		soc = Society{
			quantity = 50,
			instance = agent
		}

		chart = Chart{
			target = soc,
			select = "state",
			value = {"dead", "alive"},
			color = {"black", "blue"}
		}

		chart:update(1)
		for i = 2, 30 do
			soc:sample().state = "dead"
			chart:update(i)
		end

		unitTest:assertSnapshot(chart, "chart-function-soc.bmp", 0.1)

		-- chart using data
		local tab = DataFrame{
			first = 2000,
			step = 10,
			demand = {7, 8, 9, 10},
			limit = {0.1, 0.04, 0.3, 0.07}
		}

		c1 = Chart{
		    target = tab,
		    select = "limit",
		    xAxis = "demand",
		    color = "blue"
		}

		c2 = Chart{
		    target = tab,
		    select = "demand",
		    color = "green",
			pen = "dash"
		}

		local c3 = Chart{
			target = tab
		}

		unitTest:assertSnapshot(c1, "chart-data-1.bmp", 0.05)
		unitTest:assertSnapshot(c2, "chart-data-2.bmp", 0.05)
		unitTest:assertSnapshot(c3, "chart-data-3.bmp", 0.05)

		local init = function(model)
			local contacts = 6

			model.timer = Timer{
				Event{action = function()
					local proportion = model.susceptible /
						(model.susceptible + model.infected + model.recovered)

					local newInfected = model.infected * contacts * model.probability * proportion

					local newRecovered = model.infected / model.duration

					model.susceptible = model.susceptible - newInfected
					model.recovered = model.recovered + newRecovered
					model.infected = model.infected + newInfected - newRecovered
				end},
				Event{action = function()
					if model.infected >= model.maximum then
						contacts = contacts / 2
						return false
					end
				end}
			}
		end

		local SIR = Model{
			susceptible = 9998,
			infected = 2,
			recovered = 0,
			duration = 2,
			finalTime = 30,
			maximum = 1000,
			probability = 0.25,
			init = init
		}

		local e = Environment{
			max1000 = SIR{maximum = 1000},
			max2000 = SIR{maximum = 2000}
		}

		local c = Chart{
			target = e,
			select = "infected"
		}

		e:add(Event{action = c})
		e:run()

		unitTest:assertSnapshot(c, "chart-environment-scenarios.png", 0.05)

		e = Environment{
			SIR{maximum = 1000},
			SIR{maximum = 2000}
		}

		c = Chart{
			target = e,
			select = "infected"
		}

		e:add(Event{action = c})
		e:run()

		unitTest:assertSnapshot(c, "chart-environment-scenarios-2.png", 0.05)
	end,
	getData = function(unitTest)
		local tab = DataFrame{
			first = 2000,
			step = 10,
			demand = {7, 8, 9, 10},
			limit = {0.1, 0.04, 0.3, 0.07}
		}

		local c1 = Chart{
			target = tab,
			select = "limit",
			xAxis = "demand",
			color = "blue"
		}

		local data = c1:getData()
		unitTest:assertType(data, "DataFrame")
		unitTest:assertEquals(data[2000].limit, 0.1)
		unitTest:assertEquals(data[2010].limit, 0.04)
		unitTest:assertEquals(data[2020].limit, 0.3)
		unitTest:assertEquals(data[2030].limit, 0.07)

		local c2 = Chart{
			target = tab,
			select = "demand",
			color = "green",
			pen = "dash"
		}

		data = c2:getData()
		unitTest:assertType(data, "DataFrame")
		unitTest:assertEquals(data[2000].demand, 7)
		unitTest:assertEquals(data[2010].demand, 8)
		unitTest:assertEquals(data[2020].demand, 9)
		unitTest:assertEquals(data[2030].demand, 10)

		local world = CellularSpace{
			xdim = 10,
			count = 0,
			mCount = function(self)
				return self.count + 1
			end
		}

		c1 = Chart{target = world, select = "mCount", xAxis = "count"}

		c1:update(0)
		world.count = world.count + 2
		c1:update(1)
		c1:update(2)

		data = c1:getData()
		unitTest:assertType(data, "DataFrame")
		unitTest:assertEquals(data[0].count, 0)
		unitTest:assertEquals(data[0].mCount_, 1)

		unitTest:assertEquals(data[1].count, 2)
		unitTest:assertEquals(data[1].mCount_, 1)

		unitTest:assertEquals(data[2].count, 2)
		unitTest:assertEquals(data[2].mCount_, 3)
	end,
	update = function(unitTest)
		local world = Cell{
			water = 40,
			execute = function(world)
				world.water = world.water - 5
			end
		}

		local chart = Chart{
			target = world,
			yLabel = "Gallons"
		}

		local chart2 = Chart{
			target = world,
			yLabel = "Gallons"
		}

		local t = Timer{
			Event{action = world},
			Event{action = chart2},
			Event{action = chart}
		}

		t:run(10)

		unitTest:assertSnapshot(chart, "chart-update-two-actions.png", 0.05)
	end,
	save = function(unitTest)
		local c = Cell{value = 1}

		local ch = Chart{target = c}

		ch:update(1)
		ch:update(2)
		ch:update(3)

		unitTest:assertSnapshot(ch, "save_test.bmp", 0.05)
	end
}

