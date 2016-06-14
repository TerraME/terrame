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
	Map = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local m = Map{
			target = cs
		}

		unitTest:assertType(m, "Map")
		m:update()
		unitTest:assertSnapshot(m, "map_none.bmp")

		local r = Random()

		forEachCell(cs, function(cell)
			cell.value = r:number()
		end)

		m = Map{
			target = cs,
			select = "value",
			min = 0,
			max = 1,
			slices = 10,
			color = "Blues"
		}

		unitTest:assertType(m, "Map")

		local mi = Map{
			target = cs,
			select = "value",
			min = 0,
			max = 1,
			slices = 10,
			invert = true,
			color = "Blues"
		}

		unitTest:assertType(m, "Map")

		m:update()
		unitTest:assertSnapshot(m, "map_basic.bmp")
		unitTest:assertSnapshot(mi, "map_basic_invert.bmp")

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

		m:update()
		unitTest:assertSnapshot(m, "map_uniquevalue.bmp")

		m = Map{
			target = cs,
			color = "blue"
		}

		unitTest:assertType(m, "Map")

		m:update()
		unitTest:assertSnapshot(m, "map_background.bmp")

		cs = CellularSpace{
			xdim = 20
		}
		
		forEachCell(cs, function(cell)
			cell.w = cell.x
		end)

		m = Map{
			target = cs,
			select = "w",
			min = 0,
			max = 20,
			slices = 10,
			color = "RdYlGn"
		}

		unitTest:assertSnapshot(m, "map_rdylgn.bmp")

		r = Random{seed = 10}

		local c = Cell{
			mvalue = function()
				return r:number()
			end
		}

		cs = CellularSpace{
			xdim = 5,
			instance = c
		}

		m = Map{
			target = cs,
			select = "mvalue",
			min = 0,
			max = 1,
			slices = 10,
			color = "Blues"
		}

		m:update()
		unitTest:assertSnapshot(m, "map_function.bmp")

		c = Random{"low", "medium", "high"}
		cs = CellularSpace{xdim = 5}
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

		m:update()
		unitTest:assertSnapshot(m, "map_string.bmp")

		cs = CellularSpace{xdim = 10}

		r = Random()

		forEachCell(cs, function(cell)
			cell.value = r:number()
		end)

		m = Map{
			target = cs,
			select = "value",
			min = 0,
			max = 1,
			slices = 10,
			grouping = "quantil",
			color = "Blues"
		}

		mi = Map{
			target = cs,
			select = "value",
			min = 0,
			max = 1,
			slices = 10,
			grouping = "quantil",
			invert = true,
			color = "Blues"
		}

		unitTest:assertType(m, "Map")
		unitTest:assertSnapshot(m, "map_quantil.bmp")
		unitTest:assertSnapshot(mi, "map_quantil_invert.bmp")

		forEachCell(cs, function(cell)
			cell.w = cell.x
		end)

		m = Map{
			target = cs,
			select = "w",
			min = 0,
			max = 10,
			slices = 3,
			grouping = "quantil",
			color = "Blues"
		}

		unitTest:assertSnapshot(m, "map_quantil_3.bmp")

		m = Map{
			target = cs,
			select = "w",
			min = 0,
			max = 10,
			slices = 10,
			grouping = "quantil",
			color = "Blues"
		}

		unitTest:assertSnapshot(m, "map_quantil_10.bmp")

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

		cs = CellularSpace{xdim = 10}

		local env = Environment{cs, soc}
		env:createPlacement()

		m = Map{
			target = soc,
			font = "JLS Smiles Sampler",
			symbol = "smile",
			grid = true
		}

		m:update()
		unitTest:assertSnapshot(m, "map_society_background.bmp")

		m = Map{
			target = soc,
			background = "green",
			symbol = "turtle"
		}
		unitTest:assertSnapshot(m, "map_society_background2.bmp")

		m = Map{
			target = soc,
			select = "class",
			value = {"small", "large"},
			color = {"green", "red"}
		}

		unitTest:assertSnapshot(m, "map_society_uniquevalue.bmp")

		m = Map{
			target = soc,
			color = "white",
			background = "darkGreen",
			symbol = "beetle"
		}

		unitTest:assertSnapshot(m, "map_society_white.bmp")

		cs = CellularSpace{xdim = 10}

		r = Random()

		forEachCell(cs, function(cell)
			cell.value = r:number()
		end)

		m = Map{
			target = cs,
			select = "value",
			min = 0,
			max = 1,
			slices = 10,
			color = "Blues"
		}

		m:update()
		unitTest:assertType(m, "Map")
		unitTest:assertSnapshot(m, "map_save.bmp")

		local singleFooAgent = Agent{}
		cs = CellularSpace{xdim = 10}
		local e = Environment{cs, singleFooAgent}

		e:createPlacement()

		m = Map{
			target = singleFooAgent,
			symbol = "O",
			size = 30
		}

		unitTest:assertSnapshot(m, "map_single_agent_config.bmp")

		soc = Society{instance = Agent{}, quantity = 10}
		cs = CellularSpace{xdim = 10}
		e = Environment{cs, soc}

		Random():reSeed(123456789)
		e:createPlacement()

		forEachCell(cs, function(cell)
			if cell:isEmpty() then
				cell.state = "empty"
			else
				cell.state = "full"
			end
		end)

		m = Map{
			target = cs,
			select = "state",
			value = {"empty", "full"},
			color = {"white", "yellow"}
		}

		local m2 = Map{
			background = m,
			target = soc,
			color = "red"
		}

		unitTest:assertSnapshot(m2, "map_society_location.bmp")

		for _ = 1, 5 do
			soc:sample():die()
		end

		m2 = Map{
			background = "gray",
			target = soc,
			color = "red"
		}
		
		unitTest:assertSnapshot(m2, "map_society_five_left.bmp")
		
		local cell = Cell{
			init = function(self)
				self.state = "alive"
			end
		}

		cs = CellularSpace {
			xdim = 4,
			instance = cell
		}

		local map = Map{
			target = cs,
			select = "state",
			value = {"dead", "alive"},
			color = {"red", "yellow"}
		}		
		
		unitTest:assertSnapshot(map, "map_string_values.bmp")
		
		ag = Agent{}

		soc = Society{
			instance = ag,
			quantity = 40
		}

		cs = CellularSpace{xdim = 10}

		env = Environment{cs, soc}
		env:createPlacement{max = 5}

		map = Map{
			target = cs,
			grouping = "placement",
			min = 0,
			max = 5,
			slices = 6,
			color = "Reds"
		}

		unitTest:assertSnapshot(map, "map_placement.bmp")

		c = Cell{
			mvalue = function()
				return r:number()
			end
		}

		cs = CellularSpace{
			xdim = 5,
			instance = c
		}

		m = Map{
			target = cs,
			select = "mvalue",
			slices = 10,
			color = "Blues"
		}

		m:update()
		unitTest:assertSnapshot(m, "map_function_2.bmp")
	end,
	save = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local m = Map{
			target = cs
		}

		m:save("save_map.bmp")
		unitTest:assertFile("save_map.bmp")
	end,
	update = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local m = Map{
			target = cs,
			color = "black"
		}

		unitTest:assertType(m, "Map")
		m:update()
		unitTest:assertSnapshot(m, "map_none_black.bmp")
	end
}

