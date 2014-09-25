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
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--          Pedro R. Andrade (pedro.andrade@inpe.br)
-------------------------------------------------------------------------------------------

return {
	__len = function(unitTest)
		local c1 = Cell{}

		unitTest:assert_equal(0, #c1)
	end,
	Cell = function(unitTest)
		local cell = Cell{
			cover = "forest",
			soilWater = 0,
			sum = function() return 2 end
		}

		unitTest:assert_type(cell, "Cell")
		unitTest:assert_type(cell.sum, "function")
		unitTest:assert_equal(cell.soilWater, 0)
		unitTest:assert_equal(cell.cover, "forest")
		unitTest:assert_equal(#cell, 0)
	end,
	addNeighborhood = function(unitTest)
		local c1 = Cell{}
		local c2 = Cell{}
		local c3 = Cell{}

		local n = Neighborhood()
		n:add(c2)
		n:add(c3)

		unitTest:assert_equal(0, #c1)
		c1:addNeighborhood(n)
		unitTest:assert_equal(1, #c1)
		
		unitTest:assert_type(c1:getNeighborhood(), "Neighborhood")
	end,
	getAgent = function(unitTest)
		local ag = Agent{}
		local s = Society{instance = ag, quantity = 2}

		local ag1 = s.agents[1]

		local cs = CellularSpace{xdim = 3}

		local myEnv = Environment{cs, ag1}
		myEnv:createPlacement{strategy = "void"}
		myEnv:createPlacement{strategy = "void", name = "friends"}

		local c = cs.cells[1]
		ag1:enter(c)
		ag1:enter(c, "friends")
		unitTest:assert_equal(c:getAgent(), ag1)
		unitTest:assert_equal(c:getAgent("friends"), ag1)
	end,
	getAgents = function(unitTest)
		local ag = Agent{}
		local s = Society{instance = ag, quantity = 2}

		local ag1 = s.agents[1]

		local cs = CellularSpace{xdim = 3}

		local myEnv = Environment{cs, ag1}
		myEnv:createPlacement{strategy = "void"}
		myEnv:createPlacement{strategy = "void", name = "friends"}

		local c = cs.cells[1]
		ag1:enter(c)
		unitTest:assert_type(c:getAgents(), "table")
		unitTest:assert_equal(#c:getAgents(), 1)

		c = cs.cells[2]
		unitTest:assert_equal(#c:getAgents(), 0)
		unitTest:assert_equal(#c:getAgents("friends"), 0)
	end,
	getNeighborhood = function(unitTest)
		local cell = Cell{x = 1, y = 1}
		local cell2 = Cell{x = 1, y = 1}
		local n = Neighborhood()

		unitTest:assert_nil(cell:getNeighborhood())

		cell:addNeighborhood(n)

		local ng = cell:getNeighborhood()
		unitTest:assert_type(ng, "Neighborhood")
		unitTest:assert_equal(0, #ng)

		cell:addNeighborhood(n, "neigh2")
		ng = cell:getNeighborhood("neigh2")

		n:add(cell2)
		unitTest:assert_equal(1, #ng)
		unitTest:assert_nil(cell:getNeighborhood("wrong_name"))
	end,
	init = function(unitTest)
		local c = Cell{
			init = function(self)
				self.value = 2
			end
		}

		unitTest:assert_nil(c.value)
		c:init()
		unitTest:assert_equal(2, c.value)
	end,
	distance = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		unitTest:assert_equal(cs.cells[1]:distance(cs.cells[10]), 9) 
		unitTest:assert_equal(cs.cells[1]:distance(cs.cells[91]), 9)
	end,
	isEmpty = function(unitTest)
		local ag = Agent{}
		local s = Society{instance = ag, quantity = 2}
		local ag1 = s.agents[1]
		local cs = CellularSpace{xdim = 3}
		local c = cs.cells[1]
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void"}
		myEnv:createPlacement{strategy = "void", name = "friends"}

		ag1:enter(c)
		unitTest:assert(not c:isEmpty())

		c = cs.cells[2]
		unitTest:assert(c:isEmpty())
		unitTest:assert(c:isEmpty("friends"))
	end,
	sample = function(unitTest)
		local cs = CellularSpace{xdim = 3}
		local c = cs.cells[1]

		cs:createNeighborhood()

		unitTest:assert_type(c:sample(), "Cell")
	end,
	synchronize = function(unitTest)
		local cell = Cell{
			cover = "forest",
			soilWater = 0
		}

		unitTest:assert_not_nil(cell.past)
		unitTest:assert_nil(cell.past.cover)

		cell:synchronize()

		unitTest:assert_not_nil(cell.past)
		unitTest:assert_equal(cell.cover,"forest")
		unitTest:assert_equal(cell.cover, cell.past.cover)
		unitTest:assert_nil(cell.past.past)
	end,
	__tostring = function(unitTest)
		local c1 = Cell{w = 3, t = 4, s = "alguem", twr = false, dfg = Cell()}

		unitTest:assert_equal(tostring(c1), [[cObj_  userdata
dfg    Cell
past   table of size 0
s      string [alguem]
t      number [4]
twr    boolean [false]
w      number [3]
x      number [0]
y      number [0]
]])
	end
}

