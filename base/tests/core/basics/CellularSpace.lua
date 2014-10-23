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

return{
	__len = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		unitTest:assert_equal(#cs, 100)
	end,
	add = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local c = Cell{x = 20, y = 20}

		cs:add(c)
		unitTest:assert_equal(#cs, 101)
		unitTest:assert_equal(cs.cells[101], c)
	end,
	CellularSpace = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		unitTest:assert_type(cs, "CellularSpace")
		unitTest:assert_equal(#cs, 100)
		unitTest:assert_equal(10, cs.xdim)
		unitTest:assert_equal(10, cs.ydim)
		unitTest:assert_type(cs:sample(), "Cell")
		unitTest:assert_type(cs.cells, "table")

		local cell = Cell{
			defor = 1,
			road = true,
			cover = "pasture"
		}

		local cs = CellularSpace{
			instance = cell,
			xdim = 10
		}

		unitTest:assert(cs:defor() == 100)

		unitTest:assert(cs:road() == 100)
		unitTest:assert(cs:cover().pasture == 100)

	end, 
	get = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local c = cs:get(2, 2)

		unitTest:assert_equal(2, c.x)
		unitTest:assert_equal(2, c.y)
	end,
	createNeighborhood = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		cs:createNeighborhood()

		-- Vector of size counters - Used to verify the size of the neighborhoods
		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood()
			unitTest:assert(not neighborhood:isNeighbor(cell))

			local neighborhoodSize = #neighborhood

			local sumWeight = 0

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(c, neigh, weight)
				unitTest:assert(neigh.x >= (c.x - 1))
				unitTest:assert(neigh.x <= (c.x + 1))
				unitTest:assert(neigh.y >= (c.y -1))
				unitTest:assert(neigh.y <= (c.y + 1))

				sumWeight = sumWeight + weight
			end)

			unitTest:assert_equal(1, sumWeight, 0.00001)
		end)

		unitTest:assert_equal(4, sizes[3])
		unitTest:assert_equal(32, sizes[5])
		unitTest:assert_equal(64, sizes[8])

		cs:createNeighborhood{name = "neigh2"}

		forEachNeighbor(cs:sample(), "neigh2", function(c, neigh, weight)
				unitTest:assert(c ~= neigh)

				unitTest:assert(neigh.x >= (c.x - 1))
				unitTest:assert(neigh.x <= (c.x + 1))
				unitTest:assert(neigh.y >= (c.y - 1))
				unitTest:assert(neigh.y <= (c.y + 1))
			end)

		cs:createNeighborhood{name = "my_neighborhood2", self = true}

		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood2")
			unitTest:assert(neighborhood:isNeighbor(cell))

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood2", function(c, neigh, weight)
				unitTest:assert(neigh.x >= c.x - 1)
				unitTest:assert(neigh.x <= c.x + 1)
				unitTest:assert(neigh.y >= c.y - 1)
				unitTest:assert(neigh.y <= c.y + 1)
			end)
		end)

		unitTest:assert_equal(4, sizes[4])
		unitTest:assert_equal(32, sizes[6])
		unitTest:assert_equal(64, sizes[9])

		local verifyWrapX = function(xCell, xNeigh)
			return xNeigh == (((xCell - 1) - cs.minCol) % (cs.maxCol - cs.minCol + 1) + cs.minCol)
			or xNeigh == ((xCell - cs.minCol) % (cs.maxCol - cs.minCol + 1) + cs.minCol)
			or xNeigh == (((xCell + 1) - cs.minCol) % (cs.maxCol - cs.minCol + 1) + cs.minCol)
		end

		local verifyWrapY = function(yCell, yNeigh)
			return yNeigh == (((yCell - 1) - cs.minRow) % (cs.maxRow - cs.minRow + 1) + cs.minRow)
			or yNeigh == ((yCell - cs.minRow) % (cs.maxRow - cs.minRow + 1) + cs.minRow)
			or yNeigh == (((yCell + 1) - cs.minRow) % (cs.maxRow - cs.minRow + 1) + cs.minRow)
		end

		cs:createNeighborhood{name = "my_neighborhood3", wrap = true}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood3")

			local neighborhoodSize = #neighborhood
			unitTest:assert_equal(8, neighborhoodSize)

			unitTest:assert(not neighborhood:isNeighbor(cell))
		end)

		cs:createNeighborhood{
			name = "my_neighborhood4",
			wrap = true,
			self = true
		}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood4")

			local neighborhoodSize = #neighborhood
			unitTest:assert_equal(9, neighborhoodSize)

			unitTest:assert(neighborhood:isNeighbor(cell))
		end)

		cs = CellularSpace{xdim = 10}

		cs:createNeighborhood{strategy = "vonneumann"}

		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("1")

			local neighborhoodSize = #neighborhood

			local sumWeight = 0

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(c, neigh, weight)
				unitTest:assert(neigh.x == c.x or neigh.y == c.y)

				sumWeight = sumWeight + weight
			end)

			unitTest:assert_equal(1, sumWeight, 0.00001)

			unitTest:assert(not neighborhood:isNeighbor(cell))
		end)

		unitTest:assert_equal(4, sizes[2])
		unitTest:assert_equal(32, sizes[3])
		unitTest:assert_equal(64, sizes[4])

		cs:createNeighborhood{ 
			strategy = "vonneumann",
			name = "my_neighborhood1",
			self = true
		}

		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood1")
			local neighborhoodSize = #neighborhood

			local sumWeight = 0

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood1", function(c, neigh, weight)
				unitTest:assert_equal((1/neighborhoodSize), weight, 0.00001)

				unitTest:assert(neigh.x == c.x or neigh.y == c.y)

				sumWeight = sumWeight + weight
			end)

			unitTest:assert(neighborhood:isNeighbor(cell))
		end)

		unitTest:assert_equal(4, sizes[3])
		unitTest:assert_equal(32, sizes[4])
		unitTest:assert_equal(64, sizes[5])

		cs:createNeighborhood{ 
			strategy = "vonneumann",
			name = "my_neighborhood2",
			wrap = true
		}

		local verifyWrapX = function(xCell, xNeigh)
			return (xNeigh == (((xCell -1) - cs.minCol) % (cs.maxCol - cs.minCol + 1) + cs.minCol)) or
			(xNeigh == ((xCell - cs.minCol) % (cs.maxCol - cs.minCol + 1) + cs.minCol)) or 
			(xNeigh == (((xCell + 1) - cs.minCol) % (cs.maxCol - cs.minCol + 1) + cs.minCol))
		end

		local verifyWrapY = function(yCell, yNeigh)
			return (yNeigh == (((yCell - 1) - cs.minRow) % (cs.maxRow - cs.minRow + 1) + cs.minRow)) or
			(yNeigh == ((yCell - cs.minRow) % (cs.maxRow - cs.minRow + 1) + cs.minRow)) or 
			(yNeigh == (((yCell + 1) - cs.minRow) % (cs.maxRow - cs.minRow + 1) + cs.minRow))
		end

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood2")

			local neighborhoodSize = #neighborhood
			unitTest:assert_equal(4, neighborhoodSize)

			local sumWeight = 0

			forEachNeighbor(cell, "my_neighborhood2", function(c, neigh, weight)
				unitTest:assert_equal((1/neighborhoodSize), weight, 0.00001)

				unitTest:assert(c ~= neigh)

				unitTest:assert(neigh.x == c.x or neigh.y == c.y)

				sumWeight = sumWeight + weight
			end)

			unitTest:assert_equal(1, sumWeight, 0.00001)

			unitTest:assert(not neighborhood:isNeighbor(cell))
		end)

		cs:createNeighborhood{
			strategy = "vonneumann",
			name = "my_neighborhood3",
			wrap = true,
			self = true
		}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood3")

			local neighborhoodSize = #neighborhood
			unitTest:assert_equal(5, neighborhoodSize)

			local sumWeight = 0

			forEachNeighbor(cell, "my_neighborhood3", function(c, neigh, weight)
				unitTest:assert_equal((1/neighborhoodSize), weight, 0.00001)

				unitTest:assert(neigh.x == c.x or neigh.y == c.y)
			end)

			unitTest:assert(neighborhood:isNeighbor(cell))
		end)

		local cs = CellularSpace{xdim = 10}

		cs:createNeighborhood{strategy = "3x3"}

		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood()
			unitTest:assert(neighborhood:isNeighbor(cell))

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(c, neigh, weight)
				unitTest:assert(neigh.x >= c.x - 1)
				unitTest:assert(neigh.x <= c.x + 1)
				unitTest:assert(neigh.y >= c.y - 1)
				unitTest:assert(neigh.y <= c.y + 1)

				unitTest:assert_equal(1, weight)
			end)
		end)

		unitTest:assert_equal(4, sizes[4])
		unitTest:assert_equal(32, sizes[6])
		unitTest:assert_equal(64, sizes[9])

		local filterFunction = function(cell, neighbor)
			return neighbor.y > cell.y
		end

		cs:createNeighborhood{
			strategy = "3x3",
			name = "my_neighborhood1",
			filter = filterFunction
		}

		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood1")

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood1", function(c, neigh, weight)
				unitTest:assert(neigh.x >= c.x - 1)
				unitTest:assert(neigh.x <= c.x + 1)
				unitTest:assert(neigh.y >= c.y - 1)
				unitTest:assert(neigh.y <= c.y + 1)

				unitTest:assert(filterFunction(c, neigh))
			end)
		end)

		unitTest:assert_equal(10, sizes[0])
		unitTest:assert_equal(18, sizes[2])
		unitTest:assert_equal(72, sizes[3])

		local weightFunction = function(cell, neighbor)
			return (neighbor.y - cell.y) / (neighbor.y + cell.y)
		end

		cs:createNeighborhood{
			strategy = "3x3",
			name = "my_neighborhood2",
			filter = filterFunction,
			weight = weightFunction
		}

		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood1")

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood2", function(c, neigh, weight)
				unitTest:assert(neigh.x >= c.x - 1)
				unitTest:assert(neigh.x <= c.x + 1)
				unitTest:assert(neigh.y >= c.y - 1)
				unitTest:assert(neigh.y <= c.y + 1)

				unitTest:assert(filterFunction(c, neigh))

				unitTest:assert_equal(((neigh.y - c.y) / (neigh.y + c.y)), weight, 0.00001)
			end)
		end)

		unitTest:assert_equal(10, sizes[0])
		unitTest:assert_equal(18, sizes[2])
		unitTest:assert_equal(72, sizes[3])

		-- mxn
		local cs = CellularSpace{xdim = 10}
		local cs2 = CellularSpace{xdim = 10}

		cs:createNeighborhood{
			strategy = "mxn",
			name = "my_neighborhood1",
			m = 5
		}

		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood1")
			unitTest:assert_not_nil(neighborhood)

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood1", function(c, neigh, weight)
				unitTest:assert(neigh.x >= c.x - 2)
				unitTest:assert(neigh.x <= c.x + 2)
				unitTest:assert(neigh.y >= c.y - 2)
				unitTest:assert(neigh.y <= c.y + 2)

				unitTest:assert_equal(1, weight)
			end)
		end)

		unitTest:assert_equal(36, sizes[25])
		unitTest:assert_equal(4,  sizes[9])
		unitTest:assert_equal(24, sizes[20])
		unitTest:assert_equal(4,  sizes[16])
		unitTest:assert_equal(8,  sizes[12])
		unitTest:assert_equal(24, sizes[15])

		cs:createNeighborhood{
			strategy = "mxn",
			name = "my_neighborhood2",
			m = 5,
		}

		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood2")

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood2", function(c, neigh, weight)
				unitTest:assert(neigh.x >= c.x - 2)
				unitTest:assert(neigh.x <= c.x + 2)
				unitTest:assert(neigh.y >= c.y - 2)
				unitTest:assert(neigh.y <= c.y + 2)

				unitTest:assert_equal(1, weight)
			end)
		end)

		unitTest:assert_equal(36, sizes[25])
		unitTest:assert_equal(4,  sizes[9])
		unitTest:assert_equal(24, sizes[20])
		unitTest:assert_equal(4,  sizes[16])
		unitTest:assert_equal(8,  sizes[12])
		unitTest:assert_equal(24, sizes[15])

		local filterFunction = function(cell, neighbor)
			return neighbor.y > cell.y
		end

		cs:createNeighborhood{
			strategy = "mxn",
			name = "my_neighborhood3",
			m = 3,
			n = 5,
			filter = filterFunction
		}

		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood3")

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood3", function(c, neigh, weight)
				unitTest:assert(neigh.x >= c.x - 1)
				unitTest:assert(neigh.x <= c.x + 1)
				unitTest:assert(neigh.y >= c.y - 2)
				unitTest:assert(neigh.y <= c.y + 2)
				unitTest:assert(neigh.y > c.y)

				unitTest:assert(filterFunction(c, neigh))

				unitTest:assert_equal(1, weight)
			end)
		end)

		unitTest:assert_equal(10, sizes[0])
		unitTest:assert_equal(2,  sizes[2])
		unitTest:assert_equal(8,  sizes[3])
		unitTest:assert_equal(16, sizes[4])
		unitTest:assert_equal(64, sizes[6])

		local weightFunction = function(cell, neighbor)
			return (neighbor.y - cell.y) / (neighbor.y + cell.y)
		end

		cs:createNeighborhood{
			strategy = "mxn",
			name = "my_neighborhood4",
			m = 5,
			filter = filterFunction,
			weight = weightFunction
		}

		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood4")

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood4", function(c, neigh, weight)
				unitTest:assert(neigh.x >= c.x - 2)
				unitTest:assert(neigh.x <= c.x + 2)
				unitTest:assert(neigh.y >= c.y - 2)
				unitTest:assert(neigh.y <= c.y + 2)
				unitTest:assert(neigh.y > c.y)

				unitTest:assert(filterFunction(c, neigh))

				unitTest:assert_equal(((neigh.y - c.y) / (neigh.y + c.y)), weight, 0.00001)
			end)
		end)

		unitTest:assert_equal(10, sizes[0])
		unitTest:assert_equal(2,  sizes[3])
		unitTest:assert_equal(2,  sizes[4])
		unitTest:assert_equal(6,  sizes[5])
		unitTest:assert_equal(16, sizes[6])
		unitTest:assert_equal(16, sizes[8])
		unitTest:assert_equal(48, sizes[10])

		cs:createNeighborhood{
			strategy = "mxn",
			name = "my_neighborhood5",
			m = 3,
			n = 5,
			filter = filterFunction,
			weight = weightFunction
		}

		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood5")

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood5", function(c, neigh, weight)
				unitTest:assert(neigh.x >= c.x - 1)
				unitTest:assert(neigh.x <= c.x + 1)
				unitTest:assert(neigh.y >= c.y - 2)
				unitTest:assert(neigh.y <= c.y + 2)
				unitTest:assert(neigh.y > c.y)

				unitTest:assert(filterFunction(c, neigh))

				unitTest:assert_equal(((neigh.y - c.y) / (neigh.y + c.y)), weight, 0.00001)
			end)
		end)

		unitTest:assert_equal(10, sizes[0])
		unitTest:assert_equal(2,  sizes[2])
		unitTest:assert_equal(8,  sizes[3])
		unitTest:assert_equal(16, sizes[4])
		unitTest:assert_equal(64, sizes[6])

		local weightFunction = function(cell, neighbor)
			if neighbor.x + cell.x == 0 then
				return 0
			else
				return (neighbor.x - cell.x) / (neighbor.x + cell.x)
			end
		end

		cs:createNeighborhood{
			strategy = "mxn",
			name = "my_neighborhood6",
			target = cs2,
			m = 5,
			filter = filterFunction,
			weight = weightFunction
		}

		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood6")

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood6", function(c, neigh, weight)
				unitTest:assert(neigh.y >= c.y)
				unitTest:assert(neigh.x >= c.x - 2)
				unitTest:assert(neigh.x <= c.x + 2)

				unitTest:assert(filterFunction(c, neigh))
				unitTest:assert_equal(weightFunction(c, neigh), weight, 0.00001)
			end)
		end)

		unitTest:assert_equal(10, sizes[0])
		unitTest:assert_equal(2,  sizes[3])
		unitTest:assert_equal(2,  sizes[4])
		unitTest:assert_equal(6,  sizes[5])
		unitTest:assert_equal(16, sizes[6])
		unitTest:assert_equal(16, sizes[8])
		unitTest:assert_equal(48, sizes[10])

		-- Tests the bilaterality (From cs2 to cs)
		local sizes = {}

		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood6")

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood6", function(c, neigh, weight)
				unitTest:assert(neigh.y > c.y)
				unitTest:assert(neigh.x >= c.x - 2)
				unitTest:assert(neigh.x <= c.x + 2)

				unitTest:assert(filterFunction(c, neigh))

				unitTest:assert_equal(weightFunction(c, neigh), weight, 0.00001)
			end)
		end)

		unitTest:assert_equal(10, sizes[0])
		unitTest:assert_equal(2,  sizes[3])
		unitTest:assert_equal(2,  sizes[4])
		unitTest:assert_equal(6,  sizes[5])
		unitTest:assert_equal(16, sizes[6])
		unitTest:assert_equal(16, sizes[8])
		unitTest:assert_equal(48, sizes[10])

		-- filter
		local cs = CellularSpace{xdim = 10}

		local filterFunction = function(cell, neighbor)
			return cell.x == neighbor.x and cell.y ~= neighbor.y
		end

		cs:createNeighborhood{
			strategy = "function",
			name = "my_neighborhood1",
			filter = filterFunction
		}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood1")

			local neighborhoodSize = #neighborhood
			unitTest:assert_equal(9, neighborhoodSize)

			forEachNeighbor(cell, "my_neighborhood1", function(c, neigh, weight)
				unitTest:assert_equal(neigh.x, cell.x)
				unitTest:assert(neigh.y ~= cell.y)

				unitTest:assert(filterFunction(c, neigh))

				unitTest:assert_equal(1, weight)
			end
			)
		end)

		local weightFunction = function(cell, neighbor)
			return math.abs(neighbor.y - cell.y)
		end

		cs:createNeighborhood{
			strategy = "function",
			name = "my_neighborhood2",
			filter = filterFunction,
			weight = weightFunction
		}

		local sumWeightVec = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood2")

			local neighborhoodSize = #neighborhood
			unitTest:assert_equal(9, neighborhoodSize)

			local sumWeight = 0

			forEachNeighbor(cell, "my_neighborhood2", function(c, neigh, weight)
				unitTest:assert_equal(neigh.x, cell.x)
				unitTest:assert(neigh.y ~= cell.y)

				unitTest:assert(filterFunction(c, neigh))

				unitTest:assert_equal(math.abs(neigh.y - c.y), weight)

				sumWeight = sumWeight + weight
			end)

			if sumWeightVec[sumWeight] == nil then sumWeightVec[sumWeight] = 0 end
			sumWeightVec[sumWeight] = sumWeightVec[sumWeight] + 1
		end)

		unitTest:assert_equal(20, sumWeightVec[25])
		unitTest:assert_equal(20, sumWeightVec[31])
		unitTest:assert_equal(20, sumWeightVec[45])
		unitTest:assert_equal(20, sumWeightVec[37])
		unitTest:assert_equal(20, sumWeightVec[27])

		--  coord
		local cs = CellularSpace{xdim = 10}
		local cs2 = CellularSpace{xdim = 10}
	
		cs:createNeighborhood{
			strategy = "coord",
			name = "my_neighborhood1",
			target = cs2
		}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood1")

			local neighborhoodSize = #neighborhood
			unitTest:assert_equal(1, neighborhoodSize)

			forEachNeighbor(cell, "my_neighborhood1", function(c, neigh, weight)
				unitTest:assert_equal(neigh.x, c.x)
				unitTest:assert_equal(neigh.y, c.y)
				unitTest:assert(neigh ~= c)

				unitTest:assert_equal(1, weight)
			end)
		end)
	
		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood1")

			local neighborhoodSize = #neighborhood
			unitTest:assert_equal(1, neighborhoodSize)

			forEachNeighbor(cell, "my_neighborhood1", function(c, neigh, weight)
				unitTest:assert_equal(neigh.x, c.x)
				unitTest:assert_equal(neigh.y, c.y)
				unitTest:assert(neigh ~= c)

				unitTest:assert_equal(1, weight)
			end)
		end)
	

		local cs = CellularSpace{xdim = 5}
		cs:createNeighborhood()

		forEachCell(cs, function(cell)
			unitTest:assert_type(cell:getNeighborhood(), "Neighborhood")
		end)

		-- on the fly
		local cs = CellularSpace{xdim = 10}

		cs:createNeighborhood{onthefly = true}

		unitTest:assert_type(cs.cells[1].neighborhoods["1"], "function")
		unitTest:assert_type(cs.cells[1]:getNeighborhood(), "Neighborhood")

		-- Vector of size counters - Used to verify the size of the neighborhoods
		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood()
			unitTest:assert(not neighborhood:isNeighbor(cell))

			local neighborhoodSize = #neighborhood

			local sumWeight = 0

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(c, neigh, weight)
				unitTest:assert(neigh.x >= (c.x - 1))
				unitTest:assert(neigh.x <= (c.x + 1))
				unitTest:assert(neigh.y >= (c.y -1))
				unitTest:assert(neigh.y <= (c.y + 1))

				sumWeight = sumWeight + weight
			end)

			unitTest:assert_equal(1, sumWeight, 0.00001)
		end)

		unitTest:assert_equal(4, sizes[3])
		unitTest:assert_equal(32, sizes[5])
		unitTest:assert_equal(64, sizes[8])

		cs = CellularSpace{xdim = 10}

		cs:createNeighborhood{strategy = "vonneumann", onthefly = true}

		unitTest:assert_type(cs.cells[1].neighborhoods["1"], "function")
		unitTest:assert_type(cs.cells[1]:getNeighborhood(), "Neighborhood")
		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("1")

			local neighborhoodSize = #neighborhood

			local sumWeight = 0

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(c, neigh, weight)
				unitTest:assert(neigh.x == c.x or neigh.y == c.y)

				sumWeight = sumWeight + weight
			end)

			unitTest:assert_equal(1, sumWeight, 0.00001)

			unitTest:assert(not neighborhood:isNeighbor(cell))
		end)

		unitTest:assert_equal(4, sizes[2])
		unitTest:assert_equal(32, sizes[3])
		unitTest:assert_equal(64, sizes[4])
	end,
	synchronize = function(unitTest)
		local cs = CellularSpace{xdim = 5}

		forEachCell(cs, function(cell) unitTest:assert_not_nil(cell) end)
		forEachCell(cs, function(cell) unitTest:assert_not_nil(cell.past) end)
		forEachCell(cs, function(cell) cell.cover = "forest" end)

		cs:synchronize()
		forEachCell(cs, function(cell) unitTest:assert_not_nil(cell.past.cover) end)
		forEachCell(cs, function(cell) unitTest:assert_equal("forest", cell.past.cover) end)

		forEachElement(cs.cells[1], function(el) unitTest:assert_not_nil(el) end)
		forEachElement(cs.cells[1].past, function(el) unitTest:assert_not_nil(el) end)
	end,
	sample = function(unitTest)
		local cs = CellularSpace{xdim = 3}

		unitTest:assert_type(cs:sample(), "Cell")
	end,
	split = function(unitTest)
		local cs = CellularSpace{xdim = 3}

		local counter = 0
		forEachCell(cs, function(cell)
			cell.height = 0.4
			if counter >= 3 then
				cell.cover = "forest"
			else
				cell.cover = "pasture"
			end
			counter = counter + 1
		end)

		local ts = cs:split("cover")
		local t1 = ts["pasture"]
		local t2 = ts["forest"]

		unitTest:assert_type(t1, "Trajectory")
		unitTest:assert_equal(#t1, 3)
		unitTest:assert_equal(#t2, 6)

		t2 = cs:split(function(cell)
			return "test"
		end)

		unitTest:assert_type(t2.test, "Trajectory")
		unitTest:assert_equal(#cs.cells, 9)
		unitTest:assert_equal(#cs.cells, #t2.test)
		unitTest:assert_type(cs:sample(), "Cell")

		local v = function(cell)
			if cell.x > 1 then
				return "test"
			else
				return nil
			end
		end
		
		t2 = cs:split(v)

		unitTest:assert_equal(#t2.test, 3)

		t2 = cs:split("terralab")
		unitTest:assert_equal(#t2, 0)
	end,
	__tostring = function(unitTest)
		local cs1 = CellularSpace{ 
			xdim = 10,
			ydim = 20,
			xyz = function() end,
			vvv = 333}
		unitTest:assert_equal(tostring(cs1), [[cells   table of size 200
cObj_   userdata
dbType  string [virtual]
load    function
maxCol  number [9]
maxRow  number [19]
minCol  number [0]
minRow  number [0]
vvv     number [333]
xdim    number [10]
xyz     function
ydim    number [20]
]])
	end
}

