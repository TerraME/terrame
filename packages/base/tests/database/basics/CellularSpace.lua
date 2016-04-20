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
	CellularSpace = function(unitTest)
		local cs = CellularSpace{
			file = filePath("cabecadeboi.shp")
		}

		unitTest:assertEquals("cabecadeboi.shp", cs.layer)
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
		
		-- in TerraLib 5 we have 
		-- [11] (0, 10)
		-- [12] (0, 100) -- this line was not here in TerraLib 4
		-- [13] (0, 11)

		cell = cs.cells[100]
		unitTest:assertEquals(0, cell.x)
		unitTest:assertEquals(98, cell.y)

		cell = cs:get(0, 100)
		unitTest:assertEquals(0, cell.x)
		unitTest:assertEquals(100, cell.y)
		
		cell = cs.cells[101]
		unitTest:assertEquals(0, cell.x)
		unitTest:assertEquals(99, cell.y)

		--[[
		-- TODO: test the lines below using postgis
		-- no dbType
		cs = CellularSpace{
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "cells90x90"
		}
		unitTest:assertEquals(mdbType, cs.dbType) -- SKIP

		-- no port
		cs = CellularSpace{
			host = mhost,
			user = muser,
			password = mpassword,
			database = mdatabase,
			theme = "cells90x90",
			autoload = false
		}
		unitTest:assertEquals(3306, cs.port) -- SKIP

		-- no user
		cs = CellularSpace{
			host = mhost,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "cells90x90",
			autoload = false
		}
		unitTest:assertEquals("root", cs.user) -- SKIP

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
			unitTest:assertType(cell.objectId_, "string") -- SKIP
			unitTest:assertType(cell.x, "number") -- SKIP
			unitTest:assertType(cell.y, "number") -- SKIP
			unitTest:assertNotNil(cell.height_) -- SKIP
			unitTest:assertNotNil(cell.soilWater) -- SKIP
			unitTest:assertNil(cell.umatributoquenaofoiselecionado) -- SKIP
		end)
		unitTest:assertEquals(10201, #cs) -- SKIP

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
			unitTest:assertType(cell.objectId_, "string") -- SKIP
			unitTest:assertType(cell.x, "number") -- SKIP
			unitTest:assertType(cell.y, "number") -- SKIP
			unitTest:assert(cell.height_ > 100)		 -- SKIP
			unitTest:assertNotNil(cell.soilWater) -- SKIP
		end)

		unitTest:assertEquals(5673, #cs) -- SKIP
		--]]
		-- shp file
		cs = CellularSpace{file = filePath("brazilstates.shp", "base")}

		unitTest:assertNotNil(cs.cells[1])
		unitTest:assertEquals(#cs.cells, 27)
		unitTest:assertType(cs.cells[1], "Cell")

		unitTest:assertEquals(cs.yMin, 0)
		unitTest:assertEquals(cs.yMax, 0)

		unitTest:assertEquals(cs.xMin, 0)
		unitTest:assertEquals(cs.yMax, 0)

		local valuesDefault = {
			2300000,  12600000, 2700000,  6700000,  5200000,
			16500000,  1900000,  5400000, 7400000,  3300000,
			8700000,  13300000, 2600000, 1300000, 300000,
			9600000, 4800000, 1600000, 33700000,  1000000,
			2700000, 2800000, 300000, 500000,  1700000,
			4300000,  2300000
		}

		for i = 1, 27 do
			unitTest:assertEquals(valuesDefault[i], cs.cells[i].POPUL)
		end

		-- project
		local terralib = getPackage("terralib")
		local projName = "cellspace_basic.tview"
		local author = "Avancini"
		local title = "Cellular Space"

		local proj = terralib.Project{
			file = projName,
			clean = true,
			author = author,
			title = title
		}

		local layerName1 = "Sampa"

		terralib.Layer{
			project = proj,
			name = layerName1,
			file = filePath("sampa.shp", "terralib")
		}

		local clName1 = "Sampa_Cells_DB"
		local tName1 = "sampa_cells"
		
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
		local database = "postgis_22_sample"
		local encoding = "CP1252"

		local pgData = {
			type = "POSTGIS",
			host = host,
			port = port,
			user = user,
			password = password,
			database = database,
			table = tName1,
			encoding = encoding
		}

		local tl = terralib.TerraLib{}
		tl:dropPgTable(pgData)

		terralib.Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			name = clName1,
			resolution = 0.3,
			user = user,
			password = password,
			database = database,
			table = tName1
		}

		local cs = CellularSpace{
			project = projName,
			layer = clName1,
			geometry = true
		}

		forEachCell(cs, function(cell)
			unitTest:assertNotNil(cell.geom)
			unitTest:assertNil(cell.OGR_GEOMETRY)
		end)

		local cs = CellularSpace{
			project = "cellspace_basic",
			layer = clName1
		}

		forEachCell(cs, function(cell)
			unitTest:assertNil(cell.geom)
			unitTest:assertNil(cell.OGR_GEOMETRY)
		end)

		unitTest:assertEquals(303, #cs.cells)		
		unitTest:assertFile(projName)

		pgData.table = string.lower(tName1)
		tl:dropPgTable(pgData)
		
		-- map file
		local cs = CellularSpace{
			file = filePath("simple.map", "base")
		}

		unitTest:assertEquals(#cs, 100)
		
		-- csv file
		cs = CellularSpace{file = filePath("simple-cs.csv", "base"), sep = ";"}

		unitTest:assertType(cs, "CellularSpace")
		unitTest:assertEquals(2500, #cs)

		forEachCell(cs, function(cell)
			unitTest:assertType(cell.maxSugar, "number")
		end)	
	end,
	createNeighborhood = function(unitTest)
		-- neighborhood between two cellular spaces
		local cs = CellularSpace{
			file = filePath("cabecadeboi.shp", "base"),
		}

		local cs2 = CellularSpace{
			file = filePath("cabecadeboi900.shp", "base"),
		}

		cs:createNeighborhood{
			strategy = "mxn",
			target = cs2,
			filter = function(cell,neigh) 
				return not ((cell.x == neigh.x) and (cell.y == neigh.y))
			end,
			weight = function(cell, neigh) return 1 / 9 end,
			name = "spatialCoupling"
		}

		local countNeigh = 0
		local sumWeight  = 0

		forEachCell(cs, function(cell)
			forEachNeighbor(cell, "spatialCoupling", function(cell, neigh, weight)
				countNeigh = countNeigh + 1
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(903, countNeigh)
		unitTest:assertEquals(100.33333, sumWeight, 0.00001)

		countNeigh = 0
		sumWeight  = 0

		forEachCell(cs2, function(cell)
			forEachNeighbor(cell, "spatialCoupling", function(cell, neigh, weight)
				countNeigh = countNeigh + 1
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(10201, #cs)
		unitTest:assertEquals(903, countNeigh)
		unitTest:assertEquals(100.33333, sumWeight, 0.00001)

--[[
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
		--]]
	end,
	loadNeighborhood = function(unitTest)
		local cs = CellularSpace{
			file = filePath("cabecadeboi.shp", "base")
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
			file = filePath("cabecadeboi900.shp", "base")	
		}

		local cs2 = CellularSpace{
			file = filePath("River_lin.shp", "base")
		}

		local cs3 = CellularSpace{
			file = filePath("emas.shp", "base")
		}

		unitTest:assertType(cs1, "CellularSpace")
		unitTest:assertEquals(121, #cs1)

		local countTest = 1

		cs1:loadNeighborhood{source = filePath("cabecadeboi-neigh.gpm", "base")}

		local sizes = {}
		local minSize = math.huge
		local maxSize = -math.huge
		local minWeight = math.huge
		local maxWeight = -math.huge
		local sumWeight = 0

		forEachCell(cs1, function(cell)
			local neighborhood = cell:getNeighborhood()
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 5)
			unitTest:assert(neighborhoodSize <= 12)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(c, neigh, weight)
				unitTest:assertNotNil(c)
				unitTest:assertNotNil(neigh)

				unitTest:assert(weight >= 900)
				unitTest:assert(weight <= 1800)

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)

				unitTest:assertEquals(weight, neighborhood:getWeight(neigh))
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(5, minSize)
		unitTest:assertEquals(12, maxSize)
		unitTest:assertEquals(900, minWeight)
		unitTest:assertEquals(1800, maxWeight)
		unitTest:assertEquals(1617916.8, sumWeight, 0.00001)

		unitTest:assertEquals(28, sizes[11])
		unitTest:assertEquals(8,  sizes[7])
		unitTest:assertEquals(28, sizes[8])
		unitTest:assertEquals(4,  sizes[10])
		unitTest:assertEquals(49, sizes[12])
		unitTest:assertEquals(4,  sizes[5])

		countTest = countTest + 1

		cs1:loadNeighborhood{
			source = filePath("cabecadeboi-neigh.gpm", "base"),
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
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 5)
			unitTest:assert(neighborhoodSize <= 12)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertNotNil(c)
				unitTest:assertNotNil(neigh)

				unitTest:assert(weight >= 900)
				unitTest:assert(weight <= 1800)

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)

				unitTest:assertEquals(weight, neighborhood:getWeight(neigh))
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(5, minSize)
		unitTest:assertEquals(12, maxSize)
		unitTest:assertEquals(900, minWeight)
		unitTest:assertEquals(1800, maxWeight)
		unitTest:assertEquals(1617916.8, sumWeight, 0.00001)

		unitTest:assertEquals(28, sizes[11])
		unitTest:assertEquals(8, sizes[7])
		unitTest:assertEquals(28, sizes[8])
		unitTest:assertEquals(4, sizes[10])
		unitTest:assertEquals(49, sizes[12])
		unitTest:assertEquals(4, sizes[5])

		countTest = countTest + 1

		cs3:loadNeighborhood{
			source = filePath("gpmdistanceDbEmasCells.gpm", "base"),
			name = "my_neighborhood"..countTest
		}

		local sizes = {}

		local minSize = math.huge
		local maxSize = -math.huge
		local sumWeight = 0

		forEachCell(cs3, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 3)
			unitTest:assert(neighborhoodSize <= 8)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertNotNil(c)
				unitTest:assertNotNil(neigh)

				unitTest:assertEquals(weight, 1)

				unitTest:assertEquals(weight, neighborhood:getWeight(neigh))
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(3, minSize)
		unitTest:assertEquals(8, maxSize)
		unitTest:assertEquals(10992, sumWeight)

		unitTest:assertEquals(4, sizes[3])
		unitTest:assertEquals(34, sizes[4])
		unitTest:assertEquals(72, sizes[5])
		unitTest:assertEquals(34, sizes[6])
		unitTest:assertEquals(48, sizes[7])
		unitTest:assertEquals(1243, sizes[8])

		countTest = countTest + 1

		cs2:loadNeighborhood{
			source = filePath("emas-distance.gpm", "base"),
			name = "my_neighborhood"..countTest
		}

		local minSize   = math.huge
		local maxSize   = -math.huge
		local minWeight = math.huge
		local maxWeight = -math.huge

		local sumWeight = 0

		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 5)
			unitTest:assert(neighborhoodSize <= 120)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertNotNil(c)
				unitTest:assertNotNil(neigh)

				unitTest:assert(weight >= 70.8015)
				unitTest:assert(weight <= 9999.513)

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(5, minSize)
		unitTest:assertEquals(120, maxSize)
		unitTest:assertEquals(142.7061, minWeight, 0.00001) -- it was 70.8015
		unitTest:assertEquals(9993.341, maxWeight, 0.00001) -- it was 9999.513
		unitTest:assertEquals(108624082.31201, sumWeight, 0.00001) -- it was 84604261.92974

		-- .GAL Regular CS
		countTest = countTest + 1
 
		cs1:loadNeighborhood{
			source = filePath("cabecadeboi-neigh.gal", "base"),
			name = "my_neighborhood"..countTest
		}

		sizes = {}

		minSize   = math.huge
		maxSize   = -math.huge
		sumWeight = 0

		forEachCell(cs1, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 5)
			unitTest:assert(neighborhoodSize <= 12)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertNotNil(c)
				unitTest:assertNotNil(neigh)

				unitTest:assertEquals(1, weight)
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(1236, sumWeight)
		unitTest:assertEquals(5,    minSize)
		unitTest:assertEquals(12,   maxSize)

		unitTest:assertEquals(28, sizes[11])
		unitTest:assertEquals(8,  sizes[7])
		unitTest:assertEquals(28, sizes[8])
		unitTest:assertEquals(4,  sizes[10])
		unitTest:assertEquals(49, sizes[12])
		unitTest:assertEquals(4,  sizes[5])

		-- .GAL Irregular CS
		countTest = countTest + 1

		cs2:loadNeighborhood{
			source = filePath("emas-distance.gal", "base"),
			name = "my_neighborhood"..countTest
		}

		minSize   = math.huge
		maxSize   = -math.huge
		sumWeight = 0

		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood

			unitTest:assert(neighborhoodSize >= 5)
			unitTest:assert(neighborhoodSize <= 120)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertNotNil(c)
				unitTest:assertNotNil(neigh)
				unitTest:assertEquals(1, weight)
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(14688, sumWeight)
		unitTest:assertEquals(5,     minSize)
		unitTest:assertEquals(120,   maxSize)

		-- .GWT Regular CS
		countTest = countTest + 1

		cs1:loadNeighborhood{
			source = filePath("cabecadeboi-neigh.gwt", "base"),
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
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood
			unitTest:assertType(neighborhoodSize, "number")

			unitTest:assert(neighborhoodSize >= 5)
			unitTest:assert(neighborhoodSize <= 12)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertNotNil(c)
				unitTest:assertNotNil(neigh)

				unitTest:assert(weight >= 900)
				unitTest:assert(weight <= 1800)

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(1800, maxWeight)
		unitTest:assertEquals(900, minWeight)
		unitTest:assertEquals(1617916.8, sumWeight, 0.00001)

		unitTest:assertEquals(28, sizes[11])
		unitTest:assertEquals(8,  sizes[7])
		unitTest:assertEquals(28, sizes[8])
		unitTest:assertEquals(4,  sizes[10])
		unitTest:assertEquals(49, sizes[12])
		unitTest:assertEquals(4,  sizes[5])

		-- .GWT Irregular CS
		countTest = countTest + 1

		cs2:loadNeighborhood{
			source = filePath("emas-distance.gwt", "base"),
			name = "my_neighborhood"..countTest
		}

		minSize   = math.huge
		maxSize   = -math.huge
		minWeight = math.huge
		maxWeight = -math.huge
		sumWeight = 0

		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood"..countTest)
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood
			unitTest:assertType(neighborhoodSize, "number")

			unitTest:assert(neighborhoodSize >= 5)
			unitTest:assert(neighborhoodSize <= 120)

			minSize = math.min(neighborhoodSize, minSize)
			maxSize = math.max(neighborhoodSize, maxSize)

			forEachNeighbor(cell, "my_neighborhood"..countTest, function(c, neigh, weight)
				unitTest:assertNotNil(c)
				unitTest:assertNotNil(neigh)
				unitTest:assertType(weight, "number")

				unitTest:assert(weight >= 70.8015)
				unitTest:assert(weight <= 9999.513)

				minWeight = math.min(weight, minWeight)
				maxWeight = math.max(weight, maxWeight)
				sumWeight = sumWeight + weight
			end)
		end)

		unitTest:assertEquals(9993.341, maxWeight) -- it was 9999.513
		unitTest:assertEquals(142.7061, minWeight) -- it was 70.8015
		unitTest:assertEquals(5, minSize)
		unitTest:assertEquals(120, maxSize)
		unitTest:assertEquals(108624082.31201, sumWeight, 0.00001) -- it was 84604261

		-- GAL from shapefile
		local cs = CellularSpace{
			file = filePath("brazilstates.shp", "base")
		}

		cs:loadNeighborhood{
			source = filePath("brazil.gal", "base"),
			check = false
		}

		local count = 0
		forEachCell(cs, function(cell)
			count = count + #cell:getNeighborhood()
		end)

		unitTest:assertEquals(count, 7) 	
	end,
	save = function(unitTest)
		local terralib = getPackage("terralib")
		local projName = "cellspace_save_basic.tview"
		local author = "Avancini"
		local title = "Cellular Space"

		local proj = terralib.Project{
			file = projName,
			clean = true,
			author = author,
			title = title
		}

		local layerName1 = "Sampa"
		terralib.Layer{
			project = proj,
			name = layerName1,
			file = filePath("sampa.shp", "terralib")
		}

		local clName1 = "Sampa_Cells_DB"
		local tName1 = "sampa_cells"

		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
		local database = "postgis_22_sample"
		local encoding = "CP1252"

		local pgData = {
			type = "POSTGIS",
			host = host,
			port = port,
			user = user,
			password = password,
			database = database,
			table = tName1,
			encoding = encoding
		}

		local tl = terralib.TerraLib{}
		tl:dropPgTable(pgData)

		local layer = terralib.Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			name = clName1,
			resolution = 0.3,
			user = user,
			password = password,
			database = database,
			table = tName1
		}

		local cs = CellularSpace{
			project = proj,
			layer = clName1
		}

		forEachCell(cs, function(cell)
			cell.t0 = 1000
		end)

		local cellSpaceLayerNameT0 = clName1.."_CellSpace_T0"

		cs:save(cellSpaceLayerNameT0, "t0")

		layer = terralib.Layer{
			project = proj,
			name = cellSpaceLayerNameT0
		}

		unitTest:assertEquals(layer.source, "postgis")
		unitTest:assertEquals(layer.host, host)
		unitTest:assertEquals(layer.port, port)
		unitTest:assertEquals(layer.user, user)
		unitTest:assertEquals(layer.password, password)
		unitTest:assertEquals(layer.database, database)
		unitTest:assertEquals(layer.table, cellSpaceLayerNameT0)	-- TODO: VERIFY LOWER CASE IF CHANGED

		local cellSpaceLayerName = clName1.."_CellSpace"

		cs:save(cellSpaceLayerName)

		local layer = terralib.Layer{
			project = proj,
			name = cellSpaceLayerName
		}

		unitTest:assertEquals(layer.source, "postgis")
		unitTest:assertEquals(layer.host, host)
		unitTest:assertEquals(layer.port, port)
		unitTest:assertEquals(layer.user, user)
		unitTest:assertEquals(layer.password, password)
		unitTest:assertEquals(layer.database, database)
		unitTest:assertEquals(layer.table, cellSpaceLayerName)	-- TODO: VERIFY LOWER CASE IF CHANGED

		local cs = CellularSpace{
			project = proj,
			layer = cellSpaceLayerNameT0
		}

		forEachCell(cs, function(cell)
			unitTest:assertEquals(cell.t0, 1000)
			cell.t0 = cell.t0 + 1000
		end)

		cs:save(cellSpaceLayerNameT0)

		local cs = CellularSpace{
			project = proj,
			layer = cellSpaceLayerNameT0
		}

		forEachCell(cs, function(cell)
			unitTest:assertEquals(cell.t0, 2000)
		end)

		-- DOUBLE PRECISION TEST
		local num = 0.123456789012345

		forEachCell(cs, function(cell)
			cell.number = num
		end)

		cs:save(cellSpaceLayerNameT0, "number")

		local cs = CellularSpace{
			project = proj,
			layer = cellSpaceLayerNameT0
		}

		forEachCell(cs, function(cell)
			unitTest:assertEquals(cell.number, num)
		end)

		local cs = CellularSpace{
			project = projName,
			layer = cellSpaceLayerNameT0
		}

		local cellSpaceLayerNameGeom = clName1.."_CellSpace_Geom"
		cs:save(cellSpaceLayerNameGeom)
		
		local cs = CellularSpace{
			project = projName,
			layer = cellSpaceLayerNameGeom,
			geometry = true
		}

		forEachCell(cs, function(cell)
			unitTest:assertNotNil(cell.geom)
		end)

		local cellSpaceLayerNameGeom2 = clName1.."_CellSpace_Geom2"
		cs:save(cellSpaceLayerNameGeom2)

		local cs = CellularSpace{
			project = projName,
			layer = cellSpaceLayerNameGeom2,
			geometry = true
		}

		forEachCell(cs, function(cell)
			unitTest:assertNotNil(cell.geom)
		end)
		
		if isFile(projName) then
			rmFile(projName)
		end

		pgData.table = string.lower(tName1)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(cellSpaceLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(cellSpaceLayerNameT0)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(cellSpaceLayerNameGeom)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(cellSpaceLayerNameGeom2)
		tl:dropPgTable(pgData)

		tl:finalize()
	end,
	synchronize = function(unitTest)
		local terralib = getPackage("terralib")
		local projName = "cellspace_basic.tview"
		local author = "Avancini"
		local title = "Cellular Space"

		local proj = terralib.Project {
			file = projName,
			clean = true,
			author = author,
			title = title
		}

		local layerName1 = "Sampa"
		terralib.Layer{
			project = proj,
			name = layerName1,
			file = filePath("sampa.shp", "terralib")
		}

		local cs = CellularSpace{
			project = proj,
			layer = layerName1,
			geometry = true
		}

		cs:synchronize()

		unitTest:assertNil(cs:sample().past.geom)

		if isFile(projName) then
			rmFile(projName)
		end
	end
}

