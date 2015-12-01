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
	CellularSpace = function(unitTest)
		Random{seed = 12345}
		local cs = CellularSpace{xdim = 10}

		unitTest:assertType(cs, "CellularSpace")
		unitTest:assertEquals(#cs, 100)
		unitTest:assertEquals(10, cs.xdim)
		unitTest:assertEquals(10, cs.ydim)
		unitTest:assertType(cs:sample(), "Cell")
		unitTest:assertType(cs.cells, "table")

		local cell = Cell{
			defor = 1,
			road = true,
			cover = "pasture",
			deforest = function(self) self.defor = self.defor + 1 end,
			water = Random{1, 2, 3}
		}

		local cs = CellularSpace{
			instance = cell,
			xdim = 10
		}

		unitTest:assertEquals(cs:defor(), 100)
		unitTest:assertEquals(cs:road(), 100)
		unitTest:assertEquals(cs:cover().pasture, 100)
		unitTest:assertEquals(cs:water(), 194)

		unitTest:assert(cs:deforest())
		unitTest:assertEquals(cs:sample().defor, 2)

		local cell = Cell{
			defor = 1,
			deforest = function(self)
				if self.x > 4 then
					return false
				end

				self.defor = self.defor + 1
			end
		}

		local cs = CellularSpace{
			instance = cell,
			xdim = 10
		}

		unitTest:assertEquals(cs:defor(), 100)
		unitTest:assert(not cs:deforest())
		unitTest:assertEquals(cs:defor(), 150)
	end, 
	__len = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		unitTest:assertEquals(#cs, 100)
	end,
	__tostring = function(unitTest)
		local cs1 = CellularSpace{ 
			xdim = 10,
			ydim = 20,
			xyz = function() end,
			vvv = 333}
		unitTest:assertEquals(tostring(cs1), [[cells   table of size 200
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
	end,
	add = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local c = Cell{x = 20, y = 20}

		cs:add(c)
		unitTest:assertEquals(#cs, 101)
		unitTest:assertEquals(cs.cells[101], c)
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

			unitTest:assertEquals(1, sumWeight, 0.00001)
		end)

		unitTest:assertEquals(4, sizes[3])
		unitTest:assertEquals(32, sizes[5])
		unitTest:assertEquals(64, sizes[8])

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

		unitTest:assertEquals(4, sizes[4])
		unitTest:assertEquals(32, sizes[6])
		unitTest:assertEquals(64, sizes[9])

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
			unitTest:assertEquals(8, neighborhoodSize)

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
			unitTest:assertEquals(9, neighborhoodSize)

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

			unitTest:assertEquals(1, sumWeight, 0.00001)

			unitTest:assert(not neighborhood:isNeighbor(cell))
		end)

		unitTest:assertEquals(4, sizes[2])
		unitTest:assertEquals(32, sizes[3])
		unitTest:assertEquals(64, sizes[4])

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
				unitTest:assertEquals((1/neighborhoodSize), weight, 0.00001)

				unitTest:assert(neigh.x == c.x or neigh.y == c.y)

				sumWeight = sumWeight + weight
			end)

			unitTest:assert(neighborhood:isNeighbor(cell))
		end)

		unitTest:assertEquals(4, sizes[3])
		unitTest:assertEquals(32, sizes[4])
		unitTest:assertEquals(64, sizes[5])

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
			unitTest:assertEquals(4, neighborhoodSize)

			local sumWeight = 0

			forEachNeighbor(cell, "my_neighborhood2", function(c, neigh, weight)
				unitTest:assertEquals((1/neighborhoodSize), weight, 0.00001)

				unitTest:assert(c ~= neigh)

				unitTest:assert(neigh.x == c.x or neigh.y == c.y)

				sumWeight = sumWeight + weight
			end)

			unitTest:assertEquals(1, sumWeight, 0.00001)

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
			unitTest:assertEquals(5, neighborhoodSize)

			local sumWeight = 0

			forEachNeighbor(cell, "my_neighborhood3", function(c, neigh, weight)
				unitTest:assertEquals((1/neighborhoodSize), weight, 0.00001)

				unitTest:assert(neigh.x == c.x or neigh.y == c.y)
			end)

			unitTest:assert(neighborhood:isNeighbor(cell))
		end)

		cs = CellularSpace{xdim = 10}

		cs:createNeighborhood{strategy = "diagonal"}

		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("1")

			local neighborhoodSize = #neighborhood

			local sumWeight = 0

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(c, neigh, weight)
				unitTest:assert(neigh.x ~= c.x and neigh.y ~= c.y)

				sumWeight = sumWeight + weight
			end)

			unitTest:assertEquals(1, sumWeight, 0.00001)

			unitTest:assert(not neighborhood:isNeighbor(cell))
		end)

		unitTest:assertEquals(4, sizes[1])
		unitTest:assertEquals(32, sizes[2])
		unitTest:assertEquals(64, sizes[4])

		cs = CellularSpace{xdim = 10}

		cs:createNeighborhood{
			strategy = "diagonal",
			wrap = true
		}

		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("1")

			local neighborhoodSize = #neighborhood

			local sumWeight = 0

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(c, neigh, weight)
				unitTest:assert(neigh.x ~= c.x and neigh.y ~= c.y)

				sumWeight = sumWeight + weight
			end)

			unitTest:assertEquals(1, sumWeight, 0.00001)

			unitTest:assert(not neighborhood:isNeighbor(cell))
		end)

		unitTest:assertEquals(100, sizes[4])

		cs = CellularSpace{xdim = 10}

		cs:createNeighborhood{
			strategy = "diagonal",
			self = true,
			wrap = true
		}

		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("1")

			local neighborhoodSize = #neighborhood

			local sumWeight = 0

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(c, neigh, weight)
				unitTest:assert((neigh.x ~= c.x and neigh.y ~= c.y) or (c == neigh))

				sumWeight = sumWeight + weight
			end)

			unitTest:assertEquals(1, sumWeight, 0.00001)

		end)

		unitTest:assertEquals(100, sizes[5])

		-- mxn
		local cs = CellularSpace{xdim = 10}

		cs:createNeighborhood{strategy = "mxn"}

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

				unitTest:assertEquals(1, weight)
			end)
		end)

		unitTest:assertEquals(4, sizes[4])
		unitTest:assertEquals(32, sizes[6])
		unitTest:assertEquals(64, sizes[9])

		local filterFunction = function(cell, neighbor)
			return neighbor.y > cell.y
		end

		cs:createNeighborhood{
			strategy = "mxn",
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

		unitTest:assertEquals(10, sizes[0])
		unitTest:assertEquals(18, sizes[2])
		unitTest:assertEquals(72, sizes[3])

		local weightFunction = function(cell, neighbor)
			return (neighbor.y - cell.y) / (neighbor.y + cell.y)
		end

		cs:createNeighborhood{
			strategy = "mxn",
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

				unitTest:assertEquals(((neigh.y - c.y) / (neigh.y + c.y)), weight, 0.00001)
			end)
		end)

		unitTest:assertEquals(10, sizes[0])
		unitTest:assertEquals(18, sizes[2])
		unitTest:assertEquals(72, sizes[3])

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
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood1", function(c, neigh, weight)
				unitTest:assert(neigh.x >= c.x - 2)
				unitTest:assert(neigh.x <= c.x + 2)
				unitTest:assert(neigh.y >= c.y - 2)
				unitTest:assert(neigh.y <= c.y + 2)

				unitTest:assertEquals(1, weight)
			end)
		end)

		unitTest:assertEquals(36, sizes[25])
		unitTest:assertEquals(4,  sizes[9])
		unitTest:assertEquals(24, sizes[20])
		unitTest:assertEquals(4,  sizes[16])
		unitTest:assertEquals(8,  sizes[12])
		unitTest:assertEquals(24, sizes[15])

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

				unitTest:assertEquals(1, weight)
			end)
		end)

		unitTest:assertEquals(36, sizes[25])
		unitTest:assertEquals(4,  sizes[9])
		unitTest:assertEquals(24, sizes[20])
		unitTest:assertEquals(4,  sizes[16])
		unitTest:assertEquals(8,  sizes[12])
		unitTest:assertEquals(24, sizes[15])

		local filterFunction = function(cell, neighbor)
			return neighbor.y > cell.y
		end

		cs:createNeighborhood{
			strategy = "mxn",
			name = "my_neighborhood3",
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

				unitTest:assertEquals(1, weight)
			end)
		end)

		unitTest:assertEquals(10, sizes[0])
		unitTest:assertEquals(2,  sizes[2])
		unitTest:assertEquals(8,  sizes[3])
		unitTest:assertEquals(16, sizes[4])
		unitTest:assertEquals(64, sizes[6])

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

				unitTest:assertEquals(((neigh.y - c.y) / (neigh.y + c.y)), weight, 0.00001)
			end)
		end)

		unitTest:assertEquals(10, sizes[0])
		unitTest:assertEquals(2,  sizes[3])
		unitTest:assertEquals(2,  sizes[4])
		unitTest:assertEquals(6,  sizes[5])
		unitTest:assertEquals(16, sizes[6])
		unitTest:assertEquals(16, sizes[8])
		unitTest:assertEquals(48, sizes[10])

		cs:createNeighborhood{
			strategy = "mxn",
			name = "my_neighborhood5",
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

				unitTest:assertEquals(((neigh.y - c.y) / (neigh.y + c.y)), weight, 0.00001)
			end)
		end)

		unitTest:assertEquals(10, sizes[0])
		unitTest:assertEquals(2,  sizes[2])
		unitTest:assertEquals(8,  sizes[3])
		unitTest:assertEquals(16, sizes[4])
		unitTest:assertEquals(64, sizes[6])

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
				unitTest:assertEquals(weightFunction(c, neigh), weight, 0.00001)
			end)
		end)

		unitTest:assertEquals(10, sizes[0])
		unitTest:assertEquals(2,  sizes[3])
		unitTest:assertEquals(2,  sizes[4])
		unitTest:assertEquals(6,  sizes[5])
		unitTest:assertEquals(16, sizes[6])
		unitTest:assertEquals(16, sizes[8])
		unitTest:assertEquals(48, sizes[10])

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

				unitTest:assertEquals(weightFunction(c, neigh), weight, 0.00001)
			end)
		end)

		unitTest:assertEquals(10, sizes[0])
		unitTest:assertEquals(2,  sizes[3])
		unitTest:assertEquals(2,  sizes[4])
		unitTest:assertEquals(6,  sizes[5])
		unitTest:assertEquals(16, sizes[6])
		unitTest:assertEquals(16, sizes[8])
		unitTest:assertEquals(48, sizes[10])

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
			unitTest:assertEquals(9, neighborhoodSize)

			forEachNeighbor(cell, "my_neighborhood1", function(c, neigh, weight)
				unitTest:assertEquals(neigh.x, cell.x)
				unitTest:assert(neigh.y ~= cell.y)

				unitTest:assert(filterFunction(c, neigh))

				unitTest:assertEquals(1, weight)
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
			unitTest:assertEquals(9, neighborhoodSize)

			local sumWeight = 0

			forEachNeighbor(cell, "my_neighborhood2", function(c, neigh, weight)
				unitTest:assertEquals(neigh.x, cell.x)
				unitTest:assert(neigh.y ~= cell.y)

				unitTest:assert(filterFunction(c, neigh))

				unitTest:assertEquals(math.abs(neigh.y - c.y), weight)

				sumWeight = sumWeight + weight
			end)

			if sumWeightVec[sumWeight] == nil then sumWeightVec[sumWeight] = 0 end
			sumWeightVec[sumWeight] = sumWeightVec[sumWeight] + 1
		end)

		unitTest:assertEquals(20, sumWeightVec[25])
		unitTest:assertEquals(20, sumWeightVec[31])
		unitTest:assertEquals(20, sumWeightVec[45])
		unitTest:assertEquals(20, sumWeightVec[37])
		unitTest:assertEquals(20, sumWeightVec[27])

		--  coord
		local cs = CellularSpace{xdim = 10}
		local cs2 = CellularSpace{xdim = 10}
	
		cs:createNeighborhood{
			strategy = "coord",
			name = "my_neighborhood1",
			inmemory = false,
			target = cs2
		}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood1")

			local neighborhoodSize = #neighborhood
			unitTest:assertEquals(1, neighborhoodSize)

			forEachNeighbor(cell, "my_neighborhood1", function(c, neigh, weight)
				unitTest:assertEquals(neigh.x, c.x)
				unitTest:assertEquals(neigh.y, c.y)
				unitTest:assert(neigh ~= c)

				unitTest:assertEquals(1, weight)
			end)
		end)
	
		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood1")

			local neighborhoodSize = #neighborhood
			unitTest:assertEquals(1, neighborhoodSize)

			forEachNeighbor(cell, "my_neighborhood1", function(c, neigh, weight)
				unitTest:assertEquals(neigh.x, c.x)
				unitTest:assertEquals(neigh.y, c.y)
				unitTest:assert(neigh ~= c)

				unitTest:assertEquals(1, weight)
			end)
		end)
	

		local cs = CellularSpace{xdim = 5}
		cs:createNeighborhood()

		forEachCell(cs, function(cell)
			unitTest:assertType(cell:getNeighborhood(), "Neighborhood")
		end)

		-- on the fly
		local cs = CellularSpace{xdim = 10}

		cs:createNeighborhood{inmemory = false}

		unitTest:assertType(cs.cells[1].neighborhoods["1"], "function")
		unitTest:assertType(cs.cells[1]:getNeighborhood(), "Neighborhood")

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

			unitTest:assertEquals(1, sumWeight, 0.00001)
		end)

		unitTest:assertEquals(4, sizes[3])
		unitTest:assertEquals(32, sizes[5])
		unitTest:assertEquals(64, sizes[8])

		cs = CellularSpace{xdim = 10}

		cs:createNeighborhood{strategy = "vonneumann", inmemory = false}

		unitTest:assertType(cs.cells[1].neighborhoods["1"], "function")
		unitTest:assertType(cs.cells[1]:getNeighborhood(), "Neighborhood")
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

			unitTest:assertEquals(1, sumWeight, 0.00001)

			unitTest:assert(not neighborhood:isNeighbor(cell))
		end)

		unitTest:assertEquals(4, sizes[2])
		unitTest:assertEquals(32, sizes[3])
		unitTest:assertEquals(64, sizes[4])
	end,
	cut = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local region = cs:cut()
		unitTest:assertEquals(#region, #cs)

		region = cs:cut{xmin = 3, xmax = 7}
		unitTest:assertEquals(#region, 50)

		region = cs:cut{xmin = 5}
		unitTest:assertEquals(#region, 50)

		region = cs:cut{xmin = 1, xmax = 5, ymin = 3, ymax = 7}
		unitTest:assertEquals(#region, 25)
	end,
	get = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local c = cs:get(2, 2)

		unitTest:assertEquals(2, c.x)
		unitTest:assertEquals(2, c.y)

		local d = cs:get(c:getId())

		unitTest:assertEquals(c, d)

		local c = cs:get(100, 100)
		unitTest:assertNil(c)
	end,
	load = function(unitTest)
		local cs = CellularSpace{xdim = 5}

		forEachCell(cs, function(cell)
			cell.w = 3
		end)

		cs:load()

		unitTest:assertNil(cs:sample().w)
	end,
	sample = function(unitTest)
		local cs = CellularSpace{xdim = 3}

		unitTest:assertType(cs:sample(), "Cell")
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

		unitTest:assertType(t1, "Trajectory")
		unitTest:assertEquals(#t1, 3)
		unitTest:assertEquals(#t2, 6)

		t2 = cs:split(function(cell)
			return "test"
		end)

		unitTest:assertType(t2.test, "Trajectory")
		unitTest:assertEquals(#cs.cells, 9)
		unitTest:assertEquals(#cs.cells, #t2.test)
		unitTest:assertType(cs:sample(), "Cell")

		local v = function(cell)
			if cell.x > 1 then
				return "test"
			else
				return nil
			end
		end
		
		t2 = cs:split(v)

		unitTest:assertEquals(#t2.test, 3)
	end,
	synchronize = function(unitTest)
		local cs = CellularSpace{xdim = 5}

		forEachCell(cs, function(cell) unitTest:assertNotNil(cell) end)
		forEachCell(cs, function(cell) unitTest:assertNotNil(cell.past) end)
		forEachCell(cs, function(cell) cell.cover = "forest" end)

		cs:synchronize()
		forEachCell(cs, function(cell) unitTest:assertNotNil(cell.past.cover) end)
		forEachCell(cs, function(cell) unitTest:assertEquals("forest", cell.past.cover) end)

		forEachElement(cs.cells[1], function(el) unitTest:assertNotNil(el) end)
		forEachElement(cs.cells[1].past, function(el) unitTest:assertNotNil(el) end)
	end
}

