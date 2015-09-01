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
	CellularSpace = function(unitTest)
		local config = getConfig()
		local mdbType = config.dbType
		local mhost = config.host
		local muser = config.user
		local mpassword = config.password
		local mport = config.port
		local mdatabase

		if mdbType == "ado" then
			mdatabase = file("cabecadeboi.mdb", "base")
		else
			mdatabase = "cabecadeboi"
		end

		local cs = CellularSpace{
			dbType = mdbType,
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "cells90x90"
		}

		unitTest:assertEquals("cells90x90", cs.layer)
		unitTest:assertEquals(10201, #cs.cells)

		cs:createNeighborhood{name = "moore1"}
		cs:createNeighborhood{name = "moore2", inmemory = false}

		local countNeigh = 0
		local sumWeight  = 0

		forEachCell(cs, function(cell)
			unitTest:assertType(cell.object_id0, "string")
			unitTest:assertType(cell.x, "number")
			unitTest:assertType(cell.y, "number")
			unitTest:assertNotNil(cell.height_)
			unitTest:assertNotNil(cell.soilWater)

			forEachNeighbor(cell, "moore1", function(cell, neigh, weight)
				countNeigh = countNeigh + 1
				sumWeight = sumWeight + weight
			end)						

			forEachNeighbor(cell, "moore2", function(cell, neigh, weight)
				countNeigh = countNeigh + 1
				sumWeight = sumWeight + weight
			end)						
		end)

		unitTest:assertEquals(160800, countNeigh)
		unitTest:assertEquals(20402, sumWeight, 0.00001)

		local cell = cs:get(0, 0)
		unitTest:assertEquals(0, cell.x)
		unitTest:assertEquals(0, cell.y)
		
		cell = cs.cells[1]
		unitTest:assertEquals(0, cell.x)
		unitTest:assertEquals(0, cell.y)

		cell = cs:get(0, 1)
		unitTest:assertEquals(0, cell.x)
		unitTest:assertEquals(1, cell.y)
		
		cell = cs.cells[2]
		unitTest:assertEquals(0, cell.x)
		unitTest:assertEquals(1, cell.y)

		cell = cs:get(0, 99)
		unitTest:assertEquals(0, cell.x)
		unitTest:assertEquals(99, cell.y)
		
		cell = cs.cells[100]
		unitTest:assertEquals(0, cell.x)
		unitTest:assertEquals(99, cell.y)

		cell = cs:get(0, 100)
		unitTest:assertEquals(0, cell.x)
		unitTest:assertEquals(100, cell.y)
		
		cell = cs.cells[101]
		unitTest:assertEquals(0, cell.x)
		unitTest:assertEquals(100, cell.y)

		-- no dbType
		cs = CellularSpace{
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "cells90x90"
		}
		unitTest:assertEquals(mdbType, cs.dbType)

		-- no port
		cs = CellularSpace{
			host = mhost,
			user = muser,
			password = mpassword,
			database = mdatabase,
			theme = "cells90x90",
			autoload = false
		}
		unitTest:assertEquals(3306, cs.port)

		-- no user
		cs = CellularSpace{
			host = mhost,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "cells90x90",
			autoload = false
		}
		unitTest:assertEquals("root", cs.user)

		-- with select
		cs = CellularSpace{
			dbType = mdbType,
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "cells90x90",
			select = {"height_", "soilWater"}
		}

		forEachCell(cs, function(cell) 
			unitTest:assertType(cell.objectId_, "string")
			unitTest:assertType(cell.x, "number")
			unitTest:assertType(cell.y, "number")
			unitTest:assertNotNil(cell.height_)
			unitTest:assertNotNil(cell.soilWater)
			unitTest:assertNil(cell.umatributoquenaofoiselecionado)
		end)
		unitTest:assertEquals(10201, #cs)

		-- with where
		cs = CellularSpace{
			dbType = mdbType,
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "cells90x90",
			select = {"height_", "soilWater"},
			where = "height_ > 100"
		}

		forEachCell(cs, function(cell) 
			unitTest:assertType(cell.objectId_, "string")
			unitTest:assertType(cell.x, "number")
			unitTest:assertType(cell.y, "number")
			unitTest:assert(cell.height_ > 100)		
			unitTest:assertNotNil(cell.soilWater)
		end)

		unitTest:assertEquals(5673, #cs)

		-- csv file
		cs = CellularSpace{database = file("simple-cs.csv", "base"), dbType = "csv", sep = ";"}
		cs = CellularSpace{database = file("simple-cs.csv", "base"), sep = ";"}

		unitTest:assertType(cs, "CellularSpace")
		unitTest:assertEquals(2500, #cs)

		forEachCell(cs, function(cell)
			unitTest:assertType(cell.maxSugar, "number")
		end)

		-- shp file
		cs = CellularSpace{database = file("brazilstates.shp", "base")}

		unitTest:assertNotNil(cs.cells[1])
		unitTest:assertEquals(#cs.cells, 27)
		unitTest:assertType(cs.cells[1], "Cell")

		unitTest:assertEquals(cs.minRow, 0)
		unitTest:assertEquals(cs.maxRow, 5256115)

		unitTest:assertEquals(cs.minCol, 0)
		unitTest:assertEquals(cs.maxCol, 5380443)

		local valuesDefault = {
			  500000,  2300000, 1300000,  300000,  2300000,
			 1900000,  9600000,  300000, 4800000,  8700000,
			 1000000,  1700000, 4300000, 5400000, 33700000,
			16500000, 13300000, 2700000, 5200000,  2800000,
			 6700000, 12600000, 7400000, 1600000,  3300000,
			 2700000,  2600000
		}

		for i = 1, 27 do
			unitTest:assertEquals(valuesDefault[i], cs.cells[i].POPUL)
		end

		-- late load
		cs = CellularSpace{
			dbType = mdbType,
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "cells90x90",
			autoload = false
		}
		
		unitTest:assertNil(cs.cells[1])
		unitTest:assertEquals(#cs.cells, 0)

		cs:load()
		unitTest:assertNotNil(cs.cells[1])
		unitTest:assertEquals(#cs.cells, 10201)
		unitTest:assertType(cs.cells[1], "Cell")

		cs = CellularSpace{database = file("brazilstates.shp", "base"), autoload = false}
		unitTest:assertNil(cs.cells[1])
		unitTest:assertEquals(#cs.cells, 0)

		cs:load()
		unitTest:assertNotNil(cs.cells[1])
		unitTest:assertEquals(#cs.cells, 27)
		unitTest:assertType(cs.cells[1], "Cell")

		cs = CellularSpace{database = file("simple-cs.csv", "base"), sep = ";", autoload = false}
		unitTest:assertType(cs, "CellularSpace")
		unitTest:assertEquals(0, #cs)

		cs:load()
		unitTest:assertEquals(2500, #cs)

		cs = CellularSpace{
			database = file("simple.map", "base")
		}

		unitTest:assertEquals(#cs, 100)
	end,
	createNeighborhood = function(unitTest)
		debug.sethook()
		local config = getConfig()
		local mdbType = config.dbType
		local mhost = config.host
		local muser = config.user
		local mpassword = config.password
		local mport = config.port
		local mdatabase

		if mdbType == "ado" then
			mdatabase = file("cabecadeboi.mdb", "base")
		else
			mdatabase = "cabecadeboi"
		end

		-- neighborhood between two cellular spaces
		local cs = CellularSpace{
			dbType = mdbType,
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "cells90x90"
		}

		local cs2 = CellularSpace{
			dbType = mdbType,
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "cells900x900"
		}

		cs:createNeighborhood{
			strategy = "mxn",
			target = cs2,
			filter = function(cell,neigh) 
				return not ((cell.x == neigh.x) and (cell.y == neigh.y))
			end,
			weight = function(cell, neigh) return 1/9 end,
			name = "spatialCoupling",
		}

		local countNeigh = 0
		local sumWeight  = 0

		forEachCell(cs, function(cell)
			forEachNeighbor(cell, "spatialCoupling", function(cell, neigh, weight)
				countNeigh = countNeigh + 1
				sumWeight = sumWeight + weight
			end)
		end)
		unitTest:assertEquals(903, countNeigh) -- SKIP
		unitTest:assertEquals(100.33333, sumWeight, 0.00001) -- SKIP

		countNeigh = 0
		sumWeight  = 0

		forEachCell(cs2, function(cell)
			forEachNeighbor(cell, "spatialCoupling", function(cell, neigh, weight)
				countNeigh = countNeigh + 1
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(10201, #cs) -- SKIP
		unitTest:assertEquals(903, countNeigh) -- SKIP
		unitTest:assertEquals(100.33333, sumWeight, 0.00001) -- SKIP

		-- where plus createNeighborhood
		cs = CellularSpace{
			dbType = mdbType,
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "cells90x90",
			select = {"height_", "soilWater"},
			where = "height_ > 100"
		}

		cs:createNeighborhood{name = "first", self = true}

		cs:createNeighborhood{
			strategy = "mxn",
			filter = function(c, n) return n.height_ < c.height_ end,
			weight = function(c, n) return (c.height_ - n.height_ ) / (c.height_ + n.height_) end,
			name = "second"
		}

		countNeigh = 0
		sumWeight  = 0
		forEachCell(cs, function(cell)
			forEachNeighbor(cell, "first", function(cell, neigh, weight)
				countNeigh = countNeigh + 1
				sumWeight = sumWeight + weight
			end)
		end)
		unitTest:assertEquals(49385, countNeigh) -- SKIP
		unitTest:assertEquals(5673, sumWeight, 0.00001) -- SKIP

		countNeigh = 0
		sumWeight  = 0

		forEachCell(cs, function(cell)
			forEachNeighbor(cell, "second", function(cell, neigh, weight)
				countNeigh = countNeigh + 1
				sumWeight = sumWeight + weight
			end)
		end)
		unitTest:assertEquals(18582, countNeigh) -- SKIP
		unitTest:assertEquals(451.98359156683, sumWeight, 0.00001) -- SKIP
	end,
	loadNeighborhood = function(unitTest)
	
		if _Gtme.isWindowsOS() then
			unitTest:assert(true) -- SKIP
			return
		end
		debug.sethook()
		local config = getConfig()
		local mdbType = config.dbType
		local mhost = config.host
		local muser = config.user
		local mpassword = config.password
		local mport = config.port

		local mdatabase1, mdatabase2, mdatabase3

		if mdbType == "ado" then
			mdatabase1 = file("cabecadeboi.mdb", "base")
			mdatabase2 = file("emas.mdb", "base")
			mdatabase3 = file("emas.mdb", "base")
		else
			mdatabase1 = "cabecadeboi"
			mdatabase2 = "emas"
			mdatabase3 = "emas"
		end

		local cs = CellularSpace{
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase1,
			theme = "cells90x90"
		}

		-- #197
		--[[
		cs:loadNeighborhood{source = "GPM_NAME"}

		local countNeigh = 0
		local sumWeight  = 0
		forEachCell(cs, function(cell)
			forEachNeighbor(cell, function(cell, neigh, weight)
				unitTest:assertNotNil(neigh) -- SKIP
				unitTest:assertNotNil(weight) -- SKIP
				countNeigh = countNeigh + 1
				sumWeight = sumWeight + weight
			end)
		end)
		unitTest:assertEquals(80400, countNeigh) -- SKIP
		unitTest:assertEquals(10201.00000602, sumWeight, 0.00001) -- SKIP
		--]]

		local cs1 = CellularSpace{
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase1,
			theme = "cells900x900"
		}

		local cs2 = CellularSpace{
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase2,
			theme = "River"
		}

		local cs3 = CellularSpace{
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase3,
			theme = "cells1000x1000"
		}

		unitTest:assertType(cs1, "CellularSpace") -- SKIP
		unitTest:assertEquals(121, #cs1) -- SKIP

		local countTest = 1

		cs1:loadNeighborhood{source = file("cabecadeboi-neigh.gpm", "base")}

		local sizes = {}
		local minSize  = math.huge
		local maxSize  = -math.huge
		local minWeight = math.huge
		local maxWeight = -math.huge
		local sumWeight = 0

		forEachCell(cs1, function(cell)
			local neighborhood = cell:getNeighborhood()
			unitTest:assertNotNil(neighborhood) -- SKIP

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 5) -- SKIP
			unitTest:assert(neighborhoodSize <= 12) -- SKIP

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(c, neigh, weight)
				unitTest:assertNotNil(c) -- SKIP
				unitTest:assertNotNil(neigh) -- SKIP

				unitTest:assert(weight >= 900) -- SKIP
				unitTest:assert(weight <= 1800) -- SKIP

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)

				unitTest:assertEquals(weight, neighborhood:getWeight(neigh)) -- SKIP
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(5, minSize) -- SKIP
		unitTest:assertEquals(12, maxSize) -- SKIP
		unitTest:assertEquals(900, minWeight) -- SKIP
		unitTest:assertEquals(1800, maxWeight) -- SKIP
		unitTest:assertEquals(1617916.8, sumWeight, 0.00001) -- SKIP

		unitTest:assertEquals(28, sizes[11]) -- SKIP
		unitTest:assertEquals(8,  sizes[7]) -- SKIP
		unitTest:assertEquals(28, sizes[8]) -- SKIP
		unitTest:assertEquals(4,  sizes[10]) -- SKIP
		unitTest:assertEquals(49, sizes[12]) -- SKIP
		unitTest:assertEquals(4,  sizes[5]) -- SKIP

		countTest = countTest + 1

		cs1:loadNeighborhood{
			source = file("cabecadeboi-neigh.gpm", "base"),
			name = "my_neighborhood"..countTest
		}

		local sizes = {}

		local minSize   = math.huge
		local maxSize   = -math.huge
		local minWeight = math.huge
		local maxWeight = -math.huge
		local sumWeight = 0

		forEachCell(cs1, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood) -- SKIP

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 5) -- SKIP
			unitTest:assert(neighborhoodSize <= 12) -- SKIP

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertNotNil(c) -- SKIP
				unitTest:assertNotNil(neigh) -- SKIP

				unitTest:assert(weight >= 900) -- SKIP
				unitTest:assert(weight <= 1800) -- SKIP

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)

				unitTest:assertEquals(weight, neighborhood:getWeight(neigh)) -- SKIP
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(5, minSize) -- SKIP
		unitTest:assertEquals(12, maxSize) -- SKIP
		unitTest:assertEquals(900, minWeight) -- SKIP
		unitTest:assertEquals(1800, maxWeight) -- SKIP
		unitTest:assertEquals(1617916.8, sumWeight, 0.00001) -- SKIP

		unitTest:assertEquals(28, sizes[11]) -- SKIP
		unitTest:assertEquals(8, sizes[7]) -- SKIP
		unitTest:assertEquals(28, sizes[8]) -- SKIP
		unitTest:assertEquals(4, sizes[10]) -- SKIP
		unitTest:assertEquals(49, sizes[12]) -- SKIP
		unitTest:assertEquals(4, sizes[5]) -- SKIP

		countTest = countTest + 1

		cs3:loadNeighborhood{
			source = file("gpmdistanceDbEmasCells.gpm", "base"),
			name = "my_neighborhood"..countTest
		}

		local sizes = {}

		local minSize = math.huge
		local maxSize = -math.huge
		local sumWeight = 0

		forEachCell(cs3, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood) -- SKIP

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 3) -- SKIP
			unitTest:assert(neighborhoodSize <= 8) -- SKIP

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertNotNil(c) -- SKIP
				unitTest:assertNotNil(neigh) -- SKIP

				unitTest:assertEquals(weight, 1) -- SKIP

				unitTest:assertEquals(weight, neighborhood:getWeight(neigh)) -- SKIP
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(3, minSize) -- SKIP
		unitTest:assertEquals(8, maxSize) -- SKIP
		unitTest:assertEquals(10992, sumWeight) -- SKIP

		unitTest:assertEquals(4, sizes[3]) -- SKIP
		unitTest:assertEquals(34, sizes[4]) -- SKIP
		unitTest:assertEquals(72, sizes[5]) -- SKIP
		unitTest:assertEquals(34, sizes[6]) -- SKIP
		unitTest:assertEquals(48, sizes[7]) -- SKIP
		unitTest:assertEquals(1243, sizes[8]) -- SKIP

		countTest = countTest + 1

		cs2:loadNeighborhood{
			source = file("emas-distance.gpm", "base"),
			name = "my_neighborhood"..countTest
		}

		local minSize   = math.huge
		local maxSize   = -math.huge
		local minWeight = math.huge
		local maxWeight = -math.huge

		local sumWeight = 0

		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood) -- SKIP

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 5) -- SKIP
			unitTest:assert(neighborhoodSize <= 120) -- SKIP

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertNotNil(c) -- SKIP
				unitTest:assertNotNil(neigh) -- SKIP

				unitTest:assert(weight >= 70.8015) -- SKIP
				unitTest:assert(weight <= 9999.513) -- SKIP

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(5, minSize) -- SKIP
		unitTest:assertEquals(120, maxSize) -- SKIP
		unitTest:assertEquals(70.8015, minWeight, 0.00001) -- SKIP
		unitTest:assertEquals(9999.513, maxWeight, 0.00001) -- SKIP
		unitTest:assertEquals(84604261.93974, sumWeight, 0.00001) -- SKIP

		-- .GAL Regular CS
		countTest = countTest + 1
 
		cs1:loadNeighborhood{
			source = file("cabecadeboi-neigh.gal", "base"),
			name = "my_neighborhood"..countTest
		}

		sizes = {}

		minSize   = math.huge
		maxSize   = -math.huge
		sumWeight = 0

		forEachCell(cs1, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood) -- SKIP

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 5) -- SKIP
			unitTest:assert(neighborhoodSize <= 12) -- SKIP

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertNotNil(c) -- SKIP
				unitTest:assertNotNil(neigh) -- SKIP

				unitTest:assertEquals(1, weight) -- SKIP
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(1236, sumWeight) -- SKIP
		unitTest:assertEquals(5,    minSize) -- SKIP
		unitTest:assertEquals(12,   maxSize) -- SKIP

		unitTest:assertEquals(28, sizes[11]) -- SKIP
		unitTest:assertEquals(8,  sizes[7]) -- SKIP
		unitTest:assertEquals(28, sizes[8]) -- SKIP
		unitTest:assertEquals(4,  sizes[10]) -- SKIP
		unitTest:assertEquals(49, sizes[12]) -- SKIP
		unitTest:assertEquals(4,  sizes[5]) -- SKIP

		-- .GAL Irregular CS
		countTest = countTest + 1

		cs2:loadNeighborhood{
			source = file("emas-distance.gal", "base"),
			name = "my_neighborhood"..countTest
		}

		minSize   = math.huge
		maxSize   = -math.huge
		sumWeight = 0

		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood) -- SKIP

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 5) -- SKIP
			unitTest:assert(neighborhoodSize <= 120) -- SKIP

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertNotNil(c) -- SKIP
				unitTest:assertNotNil(neigh) -- SKIP

				unitTest:assertEquals(1, weight) -- SKIP
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(14688, sumWeight) -- SKIP
		unitTest:assertEquals(5,     minSize) -- SKIP
		unitTest:assertEquals(120,   maxSize) -- SKIP

		-- .GWT Regular CS
		countTest = countTest + 1

		cs1:loadNeighborhood{
			source = file("cabecadeboi-neigh.gwt", "base"),
			name = "my_neighborhood"..countTest
		}

		sizes = {}

		minSize   = math.huge
		maxSize   = -math.huge
		minWeight = math.huge
		maxWeight = -math.huge
		sumWeight = 0

		forEachCell(cs1, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood) -- SKIP

			local neighborhoodSize = #neighborhood
			unitTest:assertType(neighborhoodSize, "number") -- SKIP

			unitTest:assert(neighborhoodSize >= 5) -- SKIP
			unitTest:assert(neighborhoodSize <= 12) -- SKIP

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertNotNil(c) -- SKIP
				unitTest:assertNotNil(neigh) -- SKIP

				unitTest:assert(weight >= 900) -- SKIP
				unitTest:assert(weight <= 1800) -- SKIP

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(1800, maxWeight) -- SKIP
		unitTest:assertEquals(900, minWeight) -- SKIP
		unitTest:assertEquals(1617916.8, sumWeight, 0.00001) -- SKIP

		unitTest:assertEquals(28, sizes[11]) -- SKIP
		unitTest:assertEquals(8,  sizes[7]) -- SKIP
		unitTest:assertEquals(28, sizes[8]) -- SKIP
		unitTest:assertEquals(4,  sizes[10]) -- SKIP
		unitTest:assertEquals(49, sizes[12]) -- SKIP
		unitTest:assertEquals(4,  sizes[5]) -- SKIP

		-- .GWT Irregular CS
		countTest = countTest + 1

		cs2:loadNeighborhood{
			source = file("emas-distance.gwt", "base"),
			name = "my_neighborhood"..countTest
		}

		minSize   = math.huge
		maxSize   = -math.huge
		minWeight = math.huge
		maxWeight = -math.huge
		sumWeight = 0

		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood) -- SKIP

			local neighborhoodSize = #neighborhood
			unitTest:assertType(neighborhoodSize, "number") -- SKIP

			unitTest:assert(neighborhoodSize >= 5) -- SKIP
			unitTest:assert(neighborhoodSize <= 120) -- SKIP

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertNotNil(c) -- SKIP
				unitTest:assertNotNil(neigh) -- SKIP
				unitTest:assertType(weight, "number") -- SKIP

				unitTest:assert(weight >= 70.8015) -- SKIP
				unitTest:assert(weight <= 9999.513) -- SKIP

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(9999.513, maxWeight) -- SKIP
		unitTest:assertEquals(70.8015, minWeight) -- SKIP
		unitTest:assertEquals(5, minSize) -- SKIP
		unitTest:assertEquals(120, maxSize) -- SKIP
		unitTest:assertEquals(84604261.93974, sumWeight, 0.00001) -- SKIP

		-- GAL from shapefile
		local cs = CellularSpace{database = file("brazilstates.shp", "base")}

		cs:loadNeighborhood{
			source = file("brazil.gal", "base"),
			check = false
		}

		local count = 0
		forEachCell(cs, function(cell)
			count = count + #cell:getNeighborhood()
		end)

		unitTest:assertEquals(count, 7) -- SKIP
	end,
	save = function(unitTest)
		local config = getConfig()
		local mdbType = config.dbType
		local mhost = config.host
		local muser = config.user
		local mpassword = config.password
		local mport = config.port
		local mdatabase

		if mdbType == "ado" then
			mdatabase = file("cabecadeboi.mdb", "base")
		else
			mdatabase = "cabecadeboi"
		end

		local cs = CellularSpace{
			dbType = mdbType,
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "cells90x90"
		}

		for t = 1, 2 do
			forEachCell(cs, function(cell)
				cell.height_ = t
			end)

			cs:save(t, "themeName", "height_")
		end

		local ev = Event{start = 10, action = function() end}
		cs:save(ev, "themeName", "height_")
		unitTest:assert(true)
	end
}

