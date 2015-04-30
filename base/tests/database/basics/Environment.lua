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
-- Authors: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--          Pedro R. Andrade
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

return{
	loadNeighborhood = function(unitTest)
		local config = getConfig()
		local mdbType = config.dbType
		local mhost = config.host
		local muser = config.user
		local mpassword = config.password
		local mport = config.port
		local mdatabase

		if mdbType == "ado" then
			mdatabase = data("emas.mdb", "base")
		else
			mdatabase = "emas"
		end

		local cs = CellularSpace{
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "River"
		}

		local cs2 = CellularSpace{
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "cells1000x1000"
		}

		unitTest:assert(true)

		local cs3 = CellularSpace{
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "Limit"
		}

		unitTest:assertEquals(208, #cs)
		unitTest:assertEquals(1435, #cs2)
		unitTest:assertEquals(1, #cs3)

		local env = Environment{cs, cs2, cs3}

		local countTest = 1

		-- .gpm Regular CS x Irregular CS - without weights
		env:loadNeighborhood{
			source = file("gpmlinesDbEmas.gpm", "base"),
			name = "my_neighborhood"..countTest
		}

		local sizes = {}

		local minSize = math.huge
		local maxSize = -math.huge
		local sumWeight = 0

		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assert_not_nil(neighborhood)

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 0)
			unitTest:assert(neighborhoodSize <= 9)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			if(sizes[neighborhoodSize] == nil)then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertEquals(1, weight)
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(623, sumWeight)
		unitTest:assertEquals(0, minSize)
		unitTest:assertEquals(9, maxSize)

		unitTest:assertEquals(242, sizes[1])
		unitTest:assertEquals(28, sizes[2])
		unitTest:assertEquals(60, sizes[3])
		unitTest:assertEquals(11, sizes[4])
		unitTest:assertEquals(8, sizes[5])
		unitTest:assertEquals(4, sizes[6])
		unitTest:assertEquals(4, sizes[7])
		unitTest:assertEquals(1, sizes[9])
		unitTest:assertEquals(1077, sizes[0])

		-- .gpm Regular CS x Irregular CS - file with weight
		countTest = countTest + 1

		env:loadNeighborhood{
			source = file("gpmAreaCellsPols.gpm", "base"),
			name = "my_neighborhood"..countTest
		}

		local minWeight = math.huge
		local maxWeight = -math.huge
		sumWeight = 0

		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assert_not_nil(neighborhood)

			local neighborhoodSize = #neighborhood

			unitTest:assertEquals(1, neighborhoodSize)

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assert(weight <= 1000000)
				unitTest:assert(weight >= 304.628)

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)

				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(1326705357.3888, sumWeight, 0.00001)
		unitTest:assertEquals(304.628, minWeight, 0.00001)
		unitTest:assertEquals(1000000, maxWeight)

		-- .gpm Regular CS x Irregular CS - using 'bidirect' = false
		countTest = countTest + 1

		env:loadNeighborhood{
			source = file("gpmAreaCellsPols.gpm", "base"),
			name = "my_neighborhood"..countTest
		}

		minWeight = math.huge
		maxWeight = -math.huge
		sumWeight = 0

		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)

			local neighborhoodSize = #neighborhood
			unitTest:assertEquals(1, neighborhoodSize)

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assert(weight <= 1000000)
				unitTest:assert(weight >= 304.628)

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)

				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(1326705357.3888, sumWeight, 0.00001)
		unitTest:assertEquals(304.628, minWeight, 0.00001)
		unitTest:assertEquals(1000000, maxWeight)

		-- .gpm Reg CS x Irreg CS - using 'bidirect' = true
		countTest = countTest + 1

		env:loadNeighborhood{
			source = file("gpmAreaCellsPols.gpm", "base"),
			name = "my_neighborhood"..countTest,
			bidirect = true
		}

		minWeight = math.huge
		maxWeight = -math.huge
		sumWeight = 0

		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assert_not_nil(neighborhood)

			local neighborhoodSize = #neighborhood
			unitTest:assertEquals(1, neighborhoodSize)

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assert(weight <= 1000000)
				unitTest:assert(weight >= 304.628)

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)

				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(1326705357.3888, sumWeight, 0.00001)
		unitTest:assertEquals(304.628, minWeight, 0.00001)
		unitTest:assertEquals(1000000, maxWeight)

		-- Verifying the other side
		minWeight = math.huge
		maxWeight = -math.huge
		sumWeight = 0

		forEachCell(cs3, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assert_not_nil(neighborhood)

			local neighborhoodSize = #neighborhood
			unitTest:assertEquals(1435, neighborhoodSize)

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assert(1000000 >= weight)
				unitTest:assert(304.628 <= weight)

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)

				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(1326705357.3888, sumWeight, 0.00001)
		unitTest:assertEquals(304.628, minWeight, 0.00001)
		unitTest:assertEquals(1000000, maxWeight)

		-- .gpm Irregular CS x Irregular CS - using bidirect = false
		countTest = countTest + 1

		env:loadNeighborhood{
			source = file("emas-pollin.gpm", "base"),
			name = "my_neighborhood"..countTest
		}

		sumWeight = 0

		forEachCell(cs3, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assert_not_nil(neighborhood)

			local neighborhoodSize = #neighborhood

			unitTest:assertEquals(207, neighborhoodSize)

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertEquals(weight, 1)

				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(207, sumWeight)

		-- .gpm Irregular CS x Irregular CS - using bidirect = true
		countTest = countTest + 1

		env:loadNeighborhood{
			source = file("emas-pollin.gpm", "base"),
			name = "my_neighborhood"..countTest,
			bidirect = true
		}

		sumWeight = 0

		forEachCell(cs3, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assert_not_nil(neighborhood)

			local neighborhoodSize = #neighborhood
			unitTest:assertEquals(207, neighborhoodSize)

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertEquals(weight, 1)
				unitTest:assert(neigh:getNeighborhood("my_neighborhood"..countTest):isNeighbor(c))

				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(207, sumWeight)

		-- the other side
		sizes = {}
		sumWeight = 0

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assert_not_nil(neighborhood)

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertEquals(weight, 1)
				unitTest:assert(neigh:getNeighborhood("my_neighborhood"..countTest):isNeighbor(c))

				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(207, sumWeight)
		unitTest:assertEquals(1, sizes[0])
		unitTest:assertEquals(207, sizes[1])
	end
}

