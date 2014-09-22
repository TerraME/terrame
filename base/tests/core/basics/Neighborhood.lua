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
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

return{
	Neighborhood = function(unitTest)
		local neigh = Neighborhood{}
		unitTest:assert_type(neigh, "Neighborhood")

		local neigh = Neighborhood()
		unitTest:assert_type(neigh, "Neighborhood")
	end,
	add = function(unitTest)
		local neigh = Neighborhood{}
		local cell1 = Cell{}
		local cell2 = Cell{x = 1, y = 1}

		neigh:add(cell1)
		unitTest:assert(neigh:isNeighbor(cell1))
		unitTest:assert_equal(neigh:getWeight(cell1), 1)
		unitTest:assert_equal(#neigh, 1)

		neigh:add(cell2, 0.5)
		unitTest:assert(neigh:isNeighbor(cell1))
		unitTest:assert_equal(neigh:getWeight(cell1), 1)
		unitTest:assert(neigh:isNeighbor(cell2))
		unitTest:assert_equal(neigh:getWeight(cell2), 0.5)
		unitTest:assert_equal(#neigh, 2)
	end,
	clear = function(unitTest)
		local neigh = Neighborhood{}
		local cell1 = Cell{}
		local cell2 = Cell{x = 0, y = 1}
		local cell3 = Cell{x = 1, y = 1}

		neigh:add(cell1)
		neigh:add(cell2)
		neigh:add(cell3)

		neigh:clear()

		unitTest:assert(neigh:isEmpty())
	end,
	getParent = function(unitTest)
		local neigh = Neighborhood{}
		local cell1 = Cell{}
		local cell2 = Cell{x = 0, y = 1}

		neigh:add(cell1, 0.5)
		cell2:addNeighborhood(neigh)
		unitTest:assert_equal(cell2, neigh:getParent())
	end,	
	getWeight = function(unitTest)
		local neigh = Neighborhood{}
		local cell1 = Cell{}
		local cell2 = Cell{x = 0, y = 1}
		local cell3 = Cell{x = 1, y = 1}

		neigh:add(cell1, 0.5)
		neigh:add(cell2, 0.3)
		neigh:add(cell3, 0.2)

		unitTest:assert_equal(0.5, neigh:getWeight(cell1))
		unitTest:assert_equal(0.3, neigh:getWeight(cell2))
		unitTest:assert_equal(0.2, neigh:getWeight(cell3))
	end,
	isNeighbor = function(unitTest)
		local neigh = Neighborhood{}
		local cell1 = Cell{}
		local cell2 = Cell{x = 0, y = 1}
		local cell3 = Cell{x = 1, y = 1}

		neigh:add(cell1)
		neigh:add(cell2)

		unitTest:assert(neigh:isNeighbor(cell1))
		unitTest:assert(neigh:isNeighbor(cell2))
		unitTest:assert(not neigh:isNeighbor(cell3))
	end,
	isEmpty = function(unitTest)
		local neigh = Neighborhood{}
		local cell1 = Cell{}

		unitTest:assert(neigh:isEmpty())
		neigh:add(cell1)
		unitTest:assert(not neigh:isEmpty())

		neigh:remove(cell1)
		unitTest:assert(neigh:isEmpty())
	end,
	remove = function(unitTest)
		local neigh = Neighborhood{}
		local cell1 = Cell{}
		local cell2 = Cell{x = 0, y = 1}
		local cell3 = Cell{x = 1, y = 1}

		neigh:add(cell1)
		neigh:add(cell2)
		neigh:add(cell3)

		neigh:remove(cell1)
		unitTest:assert(#neigh, 2)
		unitTest:assert(not neigh:isNeighbor(cell1))

		neigh:remove(cell2)
		unitTest:assert(#neigh, 1)
		unitTest:assert(not neigh:isNeighbor(cell2))

		neigh:remove(cell3)
		unitTest:assert(#neigh, 0)
		unitTest:assert(not neigh:isNeighbor(cell3))
	end,
	sample = function(unitTest)
		local randomObj = Random{seed = 12345}
		local neigh = Neighborhood{}
		local cell1 = Cell{}
		local cell2 = Cell{x = 0, y = 1}
		local cell3 = Cell{x = 1, y = 1}

		neigh:add(cell1)
		unitTest:assert_equal(type(neigh:sample()), type(cell1))

		neigh:add(cell2)
		unitTest:assert_equal(type(neigh:sample()), type(cell2))

		neigh:add(cell3)
		unitTest:assert_equal(type(neigh:sample()), type(cell1))
	end,
	setWeight = function(unitTest)
		local neigh = Neighborhood{}
		local cell1 = Cell{}
		local cell2 = Cell{x = 0, y = 1}
		local cell3 = Cell{x = 1, y = 1}

		neigh:add(cell1, 0.5)
		neigh:add(cell2, 0.3)
		neigh:add(cell3, 0.2)

		neigh:setWeight(cell1, 0.0)
		neigh:setWeight(cell2, 0.1)
		neigh:setWeight(cell3, 0.9)

		unitTest:assert_equal(0.0, neigh:getWeight(cell1))
		unitTest:assert_equal(0.1, neigh:getWeight(cell2))
		unitTest:assert_equal(0.9, neigh:getWeight(cell3))
	end,
	__len = function(unitTest)
		local neigh = Neighborhood{}
		local cell1 = Cell{}

		unitTest:assert_equal(#neigh, 0)
		neigh:add(cell1)
		unitTest:assert_equal(#neigh, 1)

		neigh:remove(cell1)
		unitTest:assert_equal(#neigh, 0)
	end,
	__tostring = function(unitTest)
		local neigh = Neighborhood{}

		unitTest:assert_equal(tostring(neigh),[[cObj_  userdata
]])
	end
}

