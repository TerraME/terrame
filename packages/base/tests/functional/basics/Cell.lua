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
	Cell = function(unitTest)
		local cell = Cell{
			cover = "forest",
			soilWater = 0,
			sum = function() return 2 end
		}

		unitTest:assertType(cell, "Cell")
		unitTest:assertType(cell.sum, "function")
		unitTest:assertEquals(cell.soilWater, 0)
		unitTest:assertEquals(cell.cover, "forest")
		unitTest:assertEquals(#cell, 0)
	end,
	__len = function(unitTest)
		local c1 = Cell{}

		unitTest:assertEquals(0, #c1)
	end,
	__tostring = function(unitTest)
		local c1 = Cell{w = 3, t = 4, s = "alguem", twr = false, dfg = Cell()}

		unitTest:assertEquals(tostring(c1), [[cObj_  userdata
dfg    Cell
past   vector of size 0
s      string [alguem]
t      number [4]
twr    boolean [false]
w      number [3]
x      number [0]
y      number [0]
]])

		local ag = Agent{}
		local s = Society{instance = ag, quantity = 2}

		local ag1 = s.agents[1]

		local cs = CellularSpace{xdim = 3}

		local myEnv = Environment{cs, ag1}
		myEnv:createPlacement{strategy = "void"}
		myEnv:createPlacement{strategy = "void", name = "friends"}

		local c = cs.cells[1]

		unitTest:assertEquals(tostring(c), [[agents     vector of size 0
cObj_      userdata
friends    Group
parent     CellularSpace
past       vector of size 0
placement  Group
x          number [0]
y          number [0]
]])

		c:synchronize()
		
		unitTest:assertEquals(tostring(c), [[agents     vector of size 0
cObj_      userdata
friends    Group
parent     CellularSpace
past       named table of size 4
placement  Group
x          number [0]
y          number [0]
]])
	end,
	addNeighborhood = function(unitTest)
		local c1 = Cell{}
		local c2 = Cell{}
		local c3 = Cell{}

		local n = Neighborhood()
		n:add(c2)
		n:add(c3)

		unitTest:assertEquals(0, #c1)
		c1:addNeighborhood(n)
		unitTest:assertEquals(1, #c1)
		
		unitTest:assertType(c1:getNeighborhood(), "Neighborhood")
	end,
	distance = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		unitTest:assertEquals(cs.cells[1]:distance(cs.cells[10]), 9)
		unitTest:assertEquals(cs.cells[1]:distance(cs.cells[91]), 9)
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
		unitTest:assertEquals(c:getAgent(), ag1)
		unitTest:assertEquals(c:getAgent("friends"), ag1)
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
		unitTest:assertType(c:getAgents(), "table")
		unitTest:assertEquals(#c:getAgents(), 1)

		c = cs.cells[2]
		unitTest:assertEquals(#c:getAgents(), 0)
		unitTest:assertEquals(#c:getAgents("friends"), 0)
	end,
	getId = function(unitTest)
		local c = Cell{id = "a"}

		unitTest:assertEquals(c:getId(), "a")
	end,
	getNeighborhood = function(unitTest)
		local cell = Cell{x = 1, y = 1}
		local cell2 = Cell{x = 1, y = 1}
		local n = Neighborhood()

		unitTest:assertNil(cell:getNeighborhood())

		cell:addNeighborhood(n)

		local ng = cell:getNeighborhood()
		unitTest:assertType(ng, "Neighborhood")
		unitTest:assertEquals(0, #ng)

		cell:addNeighborhood(n, "neigh2")
		ng = cell:getNeighborhood("neigh2")

		n:add(cell2)
		unitTest:assertEquals(1, #ng)
		unitTest:assertNil(cell:getNeighborhood("wrong_name"))

		local cs = CellularSpace{xdim = 10}

		local filterFunction = function(cell, neighbor)
			return cell.x == neighbor.x and cell.y ~= neighbor.y
		end

		cs:createNeighborhood{
			inmemory = false
		}

		unitTest:assertType(cs:sample():getNeighborhood(), "Neighborhood")
	end,
	init = function(unitTest)
		local c = Cell{
			init = function(self)
				self.value = 2
			end
		}

		unitTest:assertNil(c.value)
		c:init()
		unitTest:assertEquals(2, c.value)
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

		unitTest:assertType(c:sample(), "Cell")
	end,
	setId = function(unitTest)
		local c = Cell{id = "a"}

		c:setId("b")

		unitTest:assertEquals(c:getId(), "b")
	end,
	synchronize = function(unitTest)
		local cell = Cell{
			cover = "forest",
			soilWater = 0,
			geom = {0, 0}
		}

		unitTest:assertNotNil(cell.past)
		unitTest:assertNil(cell.past.cover)

		cell:synchronize()

		unitTest:assertNotNil(cell.past)
		unitTest:assertNil(cell.past.geom)
		unitTest:assertNil(cell.past.x)
		unitTest:assertNil(cell.past.y)
		unitTest:assertNil(cell.past.past)
		unitTest:assertNil(cell.past.cObj_)
		unitTest:assertEquals(cell.cover,"forest")
		unitTest:assertEquals(cell.cover, cell.past.cover)
		unitTest:assertNil(cell.past.past)
	end
}

