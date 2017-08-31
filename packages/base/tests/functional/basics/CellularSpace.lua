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
			water = Random{1, 2, 3},
			set = function() end
		}

		local replaceWarn = function()
			cs = CellularSpace{
				instance = cell,
				xdim = 10,
				set = 5
			}
		end
		unitTest:assertWarning(replaceWarn, "Attribute 'set' will not be replaced by a summary function.")
		unitTest:assertEquals(cs:defor(), 100)
		unitTest:assertEquals(cs:road(), 100)
		unitTest:assertEquals(cs:cover().pasture, 100)
		unitTest:assertEquals(cs:water(), 194)

		unitTest:assert(cs:deforest())
		unitTest:assertEquals(cs:sample().defor, 2)

		cell = Cell{
			defor = 1,
			deforest = function(self)
				if self.x > 4 then
					return false
				end

				self.defor = self.defor + 1
			end,
			init = function(self)
				self.status = "forest"
			end,
			value = 4
		}

		replaceWarn = function()
			cs = CellularSpace{
				instance = cell,
				xdim = 10,
				status = 5
			}
		end
		unitTest:assertWarning(replaceWarn, "Attribute 'status' will not be replaced by a summary function.")
		unitTest:assertEquals(cs:defor(), 100)
		unitTest:assert(not cs:deforest())
		unitTest:assertEquals(cs:defor(), 150)


		cell = Cell{
			defor = 1,
			deforest = function(self)
				if self.x > 4 then
					return false
				end

				self.defor = self.defor + 1
			end,
			value = 4
		}

		replaceWarn = function()
			cs = CellularSpace{
				instance = cell,
				xdim = 10,
				value = 5
			}
		end
		unitTest:assertWarning(replaceWarn, "Attribute 'value' will not be replaced by a summary function.")
		unitTest:assertEquals(cs:defor(), 100)
		unitTest:assert(not cs:deforest())
		unitTest:assertEquals(cs:defor(), 150)

		cell = Cell{
			defor = 1,
			deforest = function(self)
				if self.x > 4 then
					return false
				end

				self.defor = self.defor + 1
			end,
			alive = true
		}

		replaceWarn = function()
			cs = CellularSpace{
				instance = cell,
				xdim = 10,
				alive = 5
			}
		end
		unitTest:assertWarning(replaceWarn, "Attribute 'alive' will not be replaced by a summary function.")
		unitTest:assertEquals(cs:defor(), 100)
		unitTest:assert(not cs:deforest())
		unitTest:assertEquals(cs:defor(), 150)

		cell = Cell{
			defor = 1,
			deforest = function(self)
				if self.x > 4 then
					return false
				end

				self.defor = self.defor + 1
			end,
			status = "forest"
		}

		replaceWarn = function()
			cs = CellularSpace{
				instance = cell,
				xdim = 10,
				status = 5
			}
		end
		unitTest:assertWarning(replaceWarn, "Attribute 'status' will not be replaced by a summary function.")
		unitTest:assertEquals(cs:defor(), 100)
		unitTest:assert(not cs:deforest())
		unitTest:assertEquals(cs:defor(), 150)

		cell = Cell{
			getNeighborhood = function()
				return "neighbor"
			end
		}

		replaceWarn = function()
			cs = CellularSpace{
				instance = cell,
				xdim = 10
			}
		end
		unitTest:assertWarning(replaceWarn, "Function 'getNeighborhood()' from Cell is replaced in the instance.")
		unitTest:assertEquals(cs:sample():getNeighborhood(), "neighbor")

		-- Shapefile
		local projName = "cellspace.tview"
		local author = "Avancini"
		local title = "Cellular Space"

		local gis = getPackage("gis")

		local proj = gis.Project{
			file = projName,
			clean = true,
			author = author,
			title = title
		}

		local layerName1 = "Sampa"

		gis.Layer{
			project = proj,
			name = layerName1,
			file = filePath("test/sampa.shp", "gis"),
		}

		local testDir = currentDir()
		local shp1 = "sampa_cells.shp"
		local filePath1 = testDir..shp1
		local fn1 = File(filePath1):name()
		fn1 = testDir..fn1

		File(fn1):deleteIfExists()

		local clName1 = "Sampa_Cells"
		local layer = gis.Layer{
			project = proj,
			clean = true,
			input = layerName1,
			name = clName1,
			resolution = 1,
			file = filePath1
		}

		local geometryDefaultValue = function()
			cs = CellularSpace{
				project = projName,
				layer = clName1,
				geometry = true
			}
		end
		unitTest:assertWarning(geometryDefaultValue, defaultValueMsg("geometry", true))

		unitTest:assertEquals(File(projName), cs.project.file)
		unitTest:assertType(cs.layer, "Layer")

		unitTest:assertEquals(proj.title, title)
		unitTest:assertEquals(proj.author, author)

		unitTest:assertEquals(layer.source, "shp")
		unitTest:assertEquals(layer.file, filePath1)

		cs = CellularSpace{
			file = filePath1
		}

		unitTest:assert(#cs.cells > 0)

		forEachCell(cs, function(c)
			unitTest:assertNotNil(c.x)
			unitTest:assertNotNil(c.y)
		end)

		cs = CellularSpace{
			project = projName,
			layer = clName1,
			geometry = false
		}

		forEachCell(cs, function(c)
			unitTest:assertNil(c.geom)
			unitTest:assertNil(c.OGR_GEOMETRY)
		end)

		cs = CellularSpace{
			project = projName,
			layer = clName1
		}

		forEachCell(cs, function(c)
			unitTest:assertNil(c.geom)
			unitTest:assertNil(c.OGR_GEOMETRY)
		end)

		File(projName):deleteIfExists()
		File(fn1):deleteIfExists()

		-- GeoJSON
		author = "Carneiro Heitor"

		projName = "geojson_cellspace.tview"
		title = "GeoJSON Cellular Space"

		proj = gis.Project{
			file = projName,
			clean = true,
			author = author,
			title = title
		}

		layerName1 = "GeoJSON_Sampa"

		gis.Layer{
			project = proj,
			name = layerName1,
			file = filePath("test/sampa.geojson", "gis")
		}

		cs = CellularSpace{
			project = projName,
			layer = layerName1
		}

		forEachCell(cs, function(c)
			unitTest:assertEquals(c.CD_GEOCODU, "35")
			unitTest:assertNotNil(c.NM_MICRO)
		end)

		local geojson1 = "geojson_sampa_cells.geojson"
		filePath1 = testDir..geojson1

		File(filePath1):deleteIfExists()

		clName1 = "GeoJSON_Sampa_Cells"
		layer = gis.Layer{
			project = proj,
			input = layerName1,
			name = clName1,
			resolution = 1,
			file = filePath1
		}

		cs = CellularSpace{
			project = projName,
			layer = clName1
		}

		unitTest:assertEquals(projName, cs.project.file:name())
		unitTest:assertType(cs.layer, "Layer")

		unitTest:assertEquals(proj.title, title)
		unitTest:assertEquals(proj.author, author)

		unitTest:assertEquals(layer.source, "geojson")
		unitTest:assertEquals(layer.file, filePath1)
		unitTest:assert(#cs.cells > 0)

		cs = CellularSpace{
			file = filePath1
		}

		unitTest:assert(#cs.cells > 0)

		forEachCell(cs, function(c)
			unitTest:assertNotNil(c.x)
			unitTest:assertNotNil(c.y)
		end)

		cs = CellularSpace{
			project = projName,
			layer = clName1
		}

		forEachCell(cs, function(c)
			unitTest:assertNotNil(c.geom)
			unitTest:assertNil(c.OGR_GEOMETRY)
		end)

		cs = CellularSpace{
			project = projName,
			layer = clName1
		}

		forEachCell(cs, function(c)
			unitTest:assertNil(c.geom)
			unitTest:assertNil(c.OGR_GEOMETRY)
		end)

		File(projName):deleteIfExists()
		File(geojson1):deleteIfExists()

		if _Gtme.sessionInfo().system == "windows" then
			-- Tif
			projName = "tif_four_cellspace.tview"
			title = "Tif Cellular Space"

			proj = gis.Project{
				file = projName,
				clean = true,
				author = author,
				title = title
			}

			layerName1 = "tif_one_Layer"
			filePath1 = filePath("itaituba-elevation.tif", "gis")

			layer = gis.Layer{
				project = proj,
				name = layerName1,
				file = filePath1
			}

			cs = CellularSpace{
				project = projName,
				layer = layerName1
			}

			unitTest:assertEquals(projName, cs.project.file:name()) -- SKIP
			unitTest:assertType(cs.layer, "Layer") -- SKIP

			unitTest:assertEquals(proj.title, title) -- SKIP
			unitTest:assertEquals(proj.author, author) -- SKIP

			unitTest:assertEquals(layer.source, "tif") -- SKIP
			unitTest:assertEquals(layer.file, tostring(filePath1)) -- SKIP
			unitTest:assertEquals(#cs, 17928) -- SKIP

			cs = CellularSpace{
				file = filePath1
			}

			unitTest:assertEquals(#cs, 17928) -- SKIP
			File(projName):deleteIfExists()

			-- NetCDF
			projName = "nc_cellspace.tview"
			title = "NC Cellular Space"

			proj = gis.Project{
				file = projName,
				clean = true,
				author = author,
				title = title
			}

			layerName1 = "NC_vegtype2000"
			filePath1 = filePath("test/vegtype_2000.nc", "gis")

			layer = gis.Layer{
				project = proj,
				name = layerName1,
				file = filePath1,
				epsg = 4326
			}

			cs = CellularSpace{
				project = projName,
				layer = layerName1
			}

			unitTest:assertEquals(projName, cs.project.file:name()) -- SKIP
			unitTest:assertType(cs.layer, "Layer") -- SKIP

			unitTest:assertEquals(proj.title, title) -- SKIP
			unitTest:assertEquals(proj.author, author) -- SKIP

			unitTest:assertEquals(layer.source, "nc") -- SKIP
			unitTest:assertEquals(layer.file, tostring(filePath1)) -- SKIP
			unitTest:assertEquals(#cs.cells, 8904) -- SKIP

			cs = CellularSpace{
				file = filePath1
			}

			unitTest:assertEquals(#cs.cells, 8904) -- SKIP
			File(projName):deleteIfExists()

			-- ASC
			projName = "asc_cellspace.tview"
			title = "Asc Cellular Space"

			proj = gis.Project{
				file = projName,
				clean = true,
				author = author,
				title = title
			}

			layerName1 = "ASC_biomassa-manaus"
			filePath1 = filePath("test/biomassa-manaus.asc", "gis")

			layer = gis.Layer{
				project = proj,
				name = layerName1,
				file = filePath1
			}

			cs = CellularSpace{
				project = projName,
				layer = layerName1
			}

			unitTest:assertEquals(projName, cs.project.file:name()) -- SKIP
			unitTest:assertType(cs.layer, "Layer") -- SKIP

			unitTest:assertEquals(proj.title, title) -- SKIP
			unitTest:assertEquals(proj.author, author) -- SKIP

			unitTest:assertEquals(layer.source, "asc") -- SKIP
			unitTest:assertEquals(layer.file, tostring(filePath1)) -- SKIP
			unitTest:assertEquals(#cs.cells, 9964) -- SKIP

			cs = CellularSpace{
				file = filePath1
			}

			unitTest:assertEquals(#cs.cells, 9964) -- SKIP
			File(projName):deleteIfExists()
		end
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
		unitTest:assertEquals(tostring(cs1), [[cObj_   userdata
cells   vector of size 200
load    function
source  string [virtual]
vvv     number [333]
xMax    number [9]
xMin    number [0]
xdim    number [10]
xyz     function
yMax    number [19]
yMin    number [0]
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
		local icell = Cell{}
		local cs = CellularSpace{xdim = 5, instance = icell}

		local unnecessaryArgument = function()
			cs:createNeighborhood{namen = "abc"}
		end
		unitTest:assertWarning(unnecessaryArgument, unnecessaryArgumentMsg("namen", "name"))

		-- Vector of size counters - Used to verify the size of the neighborhoods
		local sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood()
			unitTest:assert(not neighborhood:isNeighbor(cell))

			local neighborhoodSize = #neighborhood

			local sumWeight = 0

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(neigh, weight)
				unitTest:assert(neigh.x >= (cell.x - 1))
				unitTest:assert(neigh.x <= (cell.x + 1))
				unitTest:assert(neigh.y >= (cell.y -1))
				unitTest:assert(neigh.y <= (cell.y + 1))

				sumWeight = sumWeight + weight
			end)

			unitTest:assertEquals(1, sumWeight, 0.00001)
		end)

		unitTest:assertEquals(4, sizes[3])
		unitTest:assertEquals(12, sizes[5])
		unitTest:assertEquals(9, sizes[8])

		cs:createNeighborhood{name = "neigh2"}

		local sample = cs:sample()

		forEachNeighbor(sample, "neigh2", function(neigh)
				unitTest:assert(sample ~= neigh)

				unitTest:assert(neigh.x >= (sample.x - 1))
				unitTest:assert(neigh.x <= (sample.x + 1))
				unitTest:assert(neigh.y >= (sample.y - 1))
				unitTest:assert(neigh.y <= (sample.y + 1))
			end)

		cs:createNeighborhood{name = "my_neighborhood2", self = true}

		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood2")
			unitTest:assert(neighborhood:isNeighbor(cell))

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood2", function(neigh)
				unitTest:assert(neigh.x >= cell.x - 1)
				unitTest:assert(neigh.x <= cell.x + 1)
				unitTest:assert(neigh.y >= cell.y - 1)
				unitTest:assert(neigh.y <= cell.y + 1)
			end)
		end)

		unitTest:assertEquals(4, sizes[4])
		unitTest:assertEquals(12, sizes[6])
		unitTest:assertEquals(9, sizes[9])

		local verifyWrapX = function(cs1, cell, neigh)
			return neigh.x == ((cell.x - 1) - cs1.xMin) % (cs1.xMax - cs1.xMin + 1) + cs1.xMin
			or     neigh.x == cell.x
			or     neigh.x == ((cell.x + 1) - cs1.xMin) % (cs1.xMax - cs1.xMin + 1) + cs1.xMin
		end

		local verifyWrapY = function(cs1, cell, neigh)
			return neigh.y == (((cell.y - 1) - cs1.yMin) % (cs1.yMax - cs1.yMin + 1) + cs1.yMin)
			or     neigh.y == cell.y
			or     neigh.y == (((cell.y + 1) - cs1.yMin) % (cs1.yMax - cs1.yMin + 1) + cs1.yMin)
		end

		cs:createNeighborhood{name = "my_neighborhood3", wrap = true}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood3")

			local neighborhoodSize = #neighborhood
			unitTest:assertEquals(8, neighborhoodSize)

			unitTest:assert(not neighborhood:isNeighbor(cell))

			forEachNeighbor(cell, function(neigh)
				unitTest:assert(verifyWrapX(cs, cell, neigh))
				unitTest:assert(verifyWrapY(cs, cell, neigh))
			end)
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

			forEachNeighbor(cell, function(neigh)
				unitTest:assert(verifyWrapX(cs, cell, neigh))
				unitTest:assert(verifyWrapY(cs, cell, neigh))
			end)
		end)

		cs = CellularSpace{xdim = 5}

		cs:createNeighborhood{strategy = "vonneumann"}

		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("1")

			local neighborhoodSize = #neighborhood

			local sumWeight = 0

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(neigh, weight)
				unitTest:assert(neigh.x == cell.x or neigh.y == cell.y)

				sumWeight = sumWeight + weight
			end)

			unitTest:assertEquals(1, sumWeight, 0.00001)

			unitTest:assert(not neighborhood:isNeighbor(cell))
		end)

		unitTest:assertEquals(4, sizes[2])
		unitTest:assertEquals(12, sizes[3])
		unitTest:assertEquals(9, sizes[4])

		cs:createNeighborhood{
			strategy = "vonneumann",
			name = "my_neighborhood1",
			self = true
		}

		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood1")
			local neighborhoodSize = #neighborhood

			local sumWeight = 0

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood1", function(neigh, weight)
				unitTest:assertEquals(1 / neighborhoodSize, weight, 0.00001)

				unitTest:assert(neigh.x == cell.x or neigh.y == cell.y)

				sumWeight = sumWeight + weight
			end)

			unitTest:assert(neighborhood:isNeighbor(cell))
		end)

		unitTest:assertEquals(4, sizes[3])
		unitTest:assertEquals(12, sizes[4])
		unitTest:assertEquals(9, sizes[5])

		cs:createNeighborhood{
			strategy = "vonneumann",
			name = "my_neighborhood2",
			wrap = true
		}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood2")

			local neighborhoodSize = #neighborhood
			unitTest:assertEquals(4, neighborhoodSize)

			local sumWeight = 0

			forEachNeighbor(cell, "my_neighborhood2", function(neigh, weight)
				unitTest:assertEquals(1 / neighborhoodSize, weight, 0.00001)

				unitTest:assert(cell ~= neigh)

				unitTest:assert(neigh.x == cell.x or neigh.y == cell.y)

				sumWeight = sumWeight + weight
			end)

			unitTest:assertEquals(1, sumWeight, 0.00001)

			unitTest:assert(not neighborhood:isNeighbor(cell))

			forEachNeighbor(cell, function(neigh)
				unitTest:assert(verifyWrapX(cs, cell, neigh))
				unitTest:assert(verifyWrapY(cs, cell, neigh))
			end)
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

			forEachNeighbor(cell, "my_neighborhood3", function(neigh, weight)
				unitTest:assertEquals(1 / neighborhoodSize, weight, 0.00001)

				unitTest:assert(neigh.x == cell.x or neigh.y == cell.y)
				unitTest:assert(verifyWrapX(cs, cell, neigh))
				unitTest:assert(verifyWrapY(cs, cell, neigh))
			end)

			unitTest:assert(neighborhood:isNeighbor(cell))
		end)

		cs = CellularSpace{xdim = 5}

		cs:createNeighborhood{strategy = "diagonal"}

		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("1")

			local neighborhoodSize = #neighborhood

			local sumWeight = 0

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(neigh, weight)
				unitTest:assert(neigh.x ~= cell.x and neigh.y ~= cell.y)

				sumWeight = sumWeight + weight
			end)

			unitTest:assertEquals(1, sumWeight, 0.00001)

			unitTest:assert(not neighborhood:isNeighbor(cell))
		end)

		unitTest:assertEquals(4, sizes[1])
		unitTest:assertEquals(12, sizes[2])
		unitTest:assertEquals(9, sizes[4])

		cs = CellularSpace{xdim = 5}

		cs:createNeighborhood{
			strategy = "diagonal",
			wrap = true
		}

		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("1")

			local neighborhoodSize = #neighborhood

			local sumWeight = 0

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(neigh, weight)
				unitTest:assert(neigh.x ~= cell.x and neigh.y ~= cell.y)

				sumWeight = sumWeight + weight

				unitTest:assert(verifyWrapX(cs, cell, neigh))
				unitTest:assert(verifyWrapY(cs, cell, neigh))
			end)

			unitTest:assertEquals(1, sumWeight, 0.00001)

			unitTest:assert(not neighborhood:isNeighbor(cell))
		end)

		unitTest:assertEquals(25, sizes[4])

		cs = CellularSpace{xdim = 5}

		cs:createNeighborhood{
			strategy = "diagonal",
			self = true,
			wrap = true
		}

		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("1")

			local neighborhoodSize = #neighborhood

			local sumWeight = 0

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(neigh, weight)
				unitTest:assert((neigh.x ~= cell.x and neigh.y ~= cell.y) or (cell == neigh))

				sumWeight = sumWeight + weight
				unitTest:assert(verifyWrapX(cs, cell, neigh))
				unitTest:assert(verifyWrapY(cs, cell, neigh))
			end)

			unitTest:assertEquals(1, sumWeight, 0.00001)

		end)

		unitTest:assertEquals(25, sizes[5])

		-- mxn
		cs = CellularSpace{xdim = 10}

		cs:createNeighborhood{strategy = "mxn"}

		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood()
			unitTest:assert(neighborhood:isNeighbor(cell))

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(neigh, weight)
				unitTest:assert(neigh.x >= cell.x - 1)
				unitTest:assert(neigh.x <= cell.x + 1)
				unitTest:assert(neigh.y >= cell.y - 1)
				unitTest:assert(neigh.y <= cell.y + 1)

				unitTest:assertEquals(1, weight)
			end)
		end)

		unitTest:assertEquals(4, sizes[4])
		unitTest:assertEquals(32, sizes[6])
		unitTest:assertEquals(64, sizes[9])

		cs:createNeighborhood{
			strategy = "mxn",
			m = 5,
			wrap = true,
			name = "mxnwrap"
		}

		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("mxnwrap")
			unitTest:assert(neighborhood:isNeighbor(cell))
			unitTest:assertEquals(#neighborhood, 25)

			forEachNeighbor(cell, function(neigh)
				unitTest:assert(verifyWrapX(cs, cell, neigh))
				unitTest:assert(verifyWrapY(cs, cell, neigh))
			end)
		end)

		local filterFunction = function(cell, neighbor)
			return neighbor.y > cell.y
		end

		cs:createNeighborhood{
			strategy = "mxn",
			name = "my_neighborhood1",
			filter = filterFunction
		}

		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood1")

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood1", function(neigh)
				unitTest:assert(neigh.x >= cell.x - 1)
				unitTest:assert(neigh.x <= cell.x + 1)
				unitTest:assert(neigh.y >= cell.y - 1)
				unitTest:assert(neigh.y <= cell.y + 1)

				unitTest:assert(filterFunction(cell, neigh))
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

		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood1")

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood2", function(neigh, weight)
				unitTest:assert(neigh.x >= cell.x - 1)
				unitTest:assert(neigh.x <= cell.x + 1)
				unitTest:assert(neigh.y >= cell.y - 1)
				unitTest:assert(neigh.y <= cell.y + 1)
				unitTest:assert(filterFunction(cell, neigh))

				unitTest:assertEquals(((neigh.y - cell.y) / (neigh.y + cell.y)), weight, 0.00001)
			end)
		end)

		unitTest:assertEquals(10, sizes[0])
		unitTest:assertEquals(18, sizes[2])
		unitTest:assertEquals(72, sizes[3])

		cs = CellularSpace{xdim = 10}
		local cs2 = CellularSpace{xdim = 10}

		cs:createNeighborhood{
			strategy = "mxn",
			name = "my_neighborhood1",
			m = 5
		}

		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood1")
			unitTest:assertNotNil(neighborhood)

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood1", function(neigh, weight)
				unitTest:assert(neigh.x >= cell.x - 2)
				unitTest:assert(neigh.x <= cell.x + 2)
				unitTest:assert(neigh.y >= cell.y - 2)
				unitTest:assert(neigh.y <= cell.y + 2)

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

		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood2")

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood2", function(neigh, weight)
				unitTest:assert(neigh.x >= cell.x - 2)
				unitTest:assert(neigh.x <= cell.x + 2)
				unitTest:assert(neigh.y >= cell.y - 2)
				unitTest:assert(neigh.y <= cell.y + 2)

				unitTest:assertEquals(1, weight)
			end)
		end)

		unitTest:assertEquals(36, sizes[25])
		unitTest:assertEquals(4,  sizes[9])
		unitTest:assertEquals(24, sizes[20])
		unitTest:assertEquals(4,  sizes[16])
		unitTest:assertEquals(8,  sizes[12])
		unitTest:assertEquals(24, sizes[15])

		filterFunction = function(cell, neighbor)
			return neighbor.y > cell.y
		end

		cs:createNeighborhood{
			strategy = "mxn",
			name = "my_neighborhood3",
			n = 5,
			filter = filterFunction
		}

		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood3")

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood3", function(neigh, weight)
				unitTest:assert(neigh.x >= cell.x - 1)
				unitTest:assert(neigh.x <= cell.x + 1)
				unitTest:assert(neigh.y >= cell.y - 2)
				unitTest:assert(neigh.y <= cell.y + 2)
				unitTest:assert(neigh.y > cell.y)

				unitTest:assert(filterFunction(cell, neigh))

				unitTest:assertEquals(1, weight)
			end)
		end)

		unitTest:assertEquals(10, sizes[0])
		unitTest:assertEquals(2,  sizes[2])
		unitTest:assertEquals(8,  sizes[3])
		unitTest:assertEquals(16, sizes[4])
		unitTest:assertEquals(64, sizes[6])

		weightFunction = function(cell, neighbor)
			return (neighbor.y - cell.y) / (neighbor.y + cell.y)
		end

		cs:createNeighborhood{
			strategy = "mxn",
			name = "my_neighborhood4",
			m = 5,
			filter = filterFunction,
			weight = weightFunction
		}

		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood4")

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood4", function(neigh, weight)
				unitTest:assert(neigh.x >= cell.x - 2)
				unitTest:assert(neigh.x <= cell.x + 2)
				unitTest:assert(neigh.y >= cell.y - 2)
				unitTest:assert(neigh.y <= cell.y + 2)
				unitTest:assert(neigh.y > cell.y)

				unitTest:assert(filterFunction(cell, neigh))

				unitTest:assertEquals(((neigh.y - cell.y) / (neigh.y + cell.y)), weight, 0.00001)
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

		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood5")

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood5", function(neigh, weight)
				unitTest:assert(neigh.x >= cell.x - 1)
				unitTest:assert(neigh.x <= cell.x + 1)
				unitTest:assert(neigh.y >= cell.y - 2)
				unitTest:assert(neigh.y <= cell.y + 2)
				unitTest:assert(neigh.y > cell.y)

				unitTest:assert(filterFunction(cell, neigh))

				unitTest:assertEquals(((neigh.y - cell.y) / (neigh.y + cell.y)), weight, 0.00001)
			end)
		end)

		unitTest:assertEquals(10, sizes[0])
		unitTest:assertEquals(2,  sizes[2])
		unitTest:assertEquals(8,  sizes[3])
		unitTest:assertEquals(16, sizes[4])
		unitTest:assertEquals(64, sizes[6])

		weightFunction = function(cell, neighbor)
			if neighbor.x + cell.x == 0 then
				return 0
			else
				return (neighbor.x - cell.x) / (neighbor.x + cell.x)
			end
		end

		local defaultValue = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood6",
				target = cs2,
				m = 5,
				n = 5,
				filter = filterFunction,
				weight = weightFunction
			}
		end
		unitTest:assertWarning(defaultValue, defaultValueMsg("n", 5))

		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood6")

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood6", function(neigh, weight)
				unitTest:assert(neigh.y >= cell.y)
				unitTest:assert(neigh.x >= cell.x - 2)
				unitTest:assert(neigh.x <= cell.x + 2)

				unitTest:assert(filterFunction(cell, neigh))
				unitTest:assertEquals(weightFunction(cell, neigh), weight, 0.00001)
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
		sizes = {}

		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood6")

			local neighborhoodSize = #neighborhood

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, "my_neighborhood6", function(neigh, weight)
				unitTest:assert(neigh.y > cell.y)
				unitTest:assert(neigh.x >= cell.x - 2)
				unitTest:assert(neigh.x <= cell.x + 2)

				unitTest:assert(filterFunction(cell, neigh))

				unitTest:assertEquals(weightFunction(cell, neigh), weight, 0.00001)
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
		cs = CellularSpace{xdim = 5}

		filterFunction = function(cell, neighbor)
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
			unitTest:assertEquals(4, neighborhoodSize)

			forEachNeighbor(cell, "my_neighborhood1", function(neigh, weight)
				unitTest:assertEquals(neigh.x, cell.x)
				unitTest:assert(neigh.y ~= cell.y)

				unitTest:assert(filterFunction(cell, neigh))

				unitTest:assertEquals(1, weight)
			end)
		end)

		weightFunction = function(cell, neighbor)
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
			unitTest:assertEquals(4, neighborhoodSize)

			local sumWeight = 0

			forEachNeighbor(cell, "my_neighborhood2", function(neigh, weight)
				unitTest:assertEquals(neigh.x, cell.x)
				unitTest:assert(neigh.y ~= cell.y)

				unitTest:assert(filterFunction(cell, neigh))

				unitTest:assertEquals(math.abs(neigh.y - cell.y), weight)

				sumWeight = sumWeight + weight
			end)

			if sumWeightVec[sumWeight] == nil then sumWeightVec[sumWeight] = 0 end
			sumWeightVec[sumWeight] = sumWeightVec[sumWeight] + 1
		end)

		unitTest:assertEquals(5, sumWeightVec[6])
		unitTest:assertEquals(10, sumWeightVec[7])
		unitTest:assertEquals(10, sumWeightVec[10])

		--  coord
		cs = CellularSpace{xdim = 5}
		cs2 = CellularSpace{xdim = 5}

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

			forEachNeighbor(cell, "my_neighborhood1", function(neigh, weight)
				unitTest:assertEquals(neigh.x, cell.x)
				unitTest:assertEquals(neigh.y, cell.y)
				unitTest:assert(neigh ~= cell)

				unitTest:assertEquals(1, weight)
			end)
		end)

		forEachCell(cs2, function(cell)
			local neighborhood = cell:getNeighborhood("my_neighborhood1")

			local neighborhoodSize = #neighborhood
			unitTest:assertEquals(1, neighborhoodSize)

			forEachNeighbor(cell, "my_neighborhood1", function(neigh, weight)
				unitTest:assertEquals(neigh.x, cell.x)
				unitTest:assertEquals(neigh.y, cell.y)
				unitTest:assert(neigh ~= cell)

				unitTest:assertEquals(1, weight)
			end)
		end)

		-- on the fly
		cs = CellularSpace{xdim = 5}

		cs:createNeighborhood{inmemory = false}

		unitTest:assertType(cs.cells[1].neighborhoods["1"], "function")
		unitTest:assertType(cs.cells[1]:getNeighborhood(), "Neighborhood")

		-- Vector of size counters - Used to verify the size of the neighborhoods
		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood()
			unitTest:assert(not neighborhood:isNeighbor(cell))

			local neighborhoodSize = #neighborhood

			local sumWeight = 0

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(neigh, weight)
				unitTest:assert(neigh.x >= (cell.x - 1))
				unitTest:assert(neigh.x <= (cell.x + 1))
				unitTest:assert(neigh.y >= (cell.y -1))
				unitTest:assert(neigh.y <= (cell.y + 1))

				sumWeight = sumWeight + weight
			end)

			unitTest:assertEquals(1, sumWeight, 0.00001)
		end)

		unitTest:assertEquals(4, sizes[3])
		unitTest:assertEquals(12, sizes[5])
		unitTest:assertEquals(9, sizes[8])

		cs = CellularSpace{xdim = 5}

		cs:createNeighborhood{strategy = "vonneumann", inmemory = false}

		unitTest:assertType(cs.cells[1].neighborhoods["1"], "function")
		unitTest:assertType(cs.cells[1]:getNeighborhood(), "Neighborhood")
		sizes = {}

		forEachCell(cs, function(cell)
			local neighborhood = cell:getNeighborhood("1")

			local neighborhoodSize = #neighborhood

			local sumWeight = 0

			if sizes[neighborhoodSize] == nil then sizes[neighborhoodSize] = 0 end
			sizes[neighborhoodSize] = sizes[neighborhoodSize] + 1

			forEachNeighbor(cell, function(neigh, weight)
				unitTest:assert(neigh.x == cell.x or neigh.y == cell.y)

				sumWeight = sumWeight + weight
			end)

			unitTest:assertEquals(1, sumWeight, 0.00001)

			unitTest:assert(not neighborhood:isNeighbor(cell))
		end)

		unitTest:assertEquals(4, sizes[2])
		unitTest:assertEquals(12, sizes[3])
		unitTest:assertEquals(9, sizes[4])

		-- small cellular spaces
		cs = CellularSpace{xdim = 2}

		cs:createNeighborhood{
		    strategy = "vonneumann",
		    wrap = true
		}

		cs:createNeighborhood{
		    wrap = true,
			name = "2"
		}

		cs:createNeighborhood{
		    wrap = true,
			strategy = "mxn",
			m = 5,
			name = "3"
		}
	end,
	cut = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local region = cs:cut()
		unitTest:assertEquals(#region, #cs)

		region = cs:cut{xmin = 3, xmax = 7}
		unitTest:assertEquals(#region, 50)

		region = cs:cut{xmin = 5}
		unitTest:assertEquals(#region, 50)

		local unnecessaryArgument = function()
			region = cs:cut{xmin = 1, xmax = 5, ymin = 3, ymax = 7, xmox = 5}
		end
		unitTest:assertWarning(unnecessaryArgument, unnecessaryArgumentMsg("xmox", "xmax"))
		unitTest:assertEquals(#region, 25)

		local defaultValue = function()
			region = cs:cut{xmin = 0}
		end
		unitTest:assertWarning(defaultValue, defaultValueMsg("xmin", 0))
		unitTest:assertEquals(#region, #cs)
	end,
	get = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		local c = cs:get(2, 2)

		unitTest:assertEquals(2, c.x)
		unitTest:assertEquals(2, c.y)

		local d = cs:get(c:getId())

		unitTest:assertEquals(c, d)

		c = cs:get(100, 100)
		unitTest:assertNil(c)

		local warningFunc = function()
			c = cs:get("4", 2.3)
		end
		unitTest:assertWarning(warningFunc, "As #1 is string, #2 should be nil, but got number.")
		unitTest:assertEquals(c.x, 0)
		unitTest:assertEquals(c.y, 3)
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
	save = function(unitTest)
        local gis = getPackage("gis")

		local projName = "cellspace_save_basic.tview"

		File(projName):deleteIfExists()

		local proj = gis.Project{
			file = projName,
			clean = true,
			author = "Avancini",
			title = "Sampa"
		}

		local layerName1 = "Sampa"
		gis.Layer{
			project = proj,
			name = layerName1,
			file = filePath("test/sampa.shp", "gis")
		}

		local testDir = currentDir()
		local shp1 = "sampa_cells.shp"
		local filePath1 = testDir..shp1
		local fn1 = File(filePath1):name()
		fn1 = testDir..fn1

		File(fn1):deleteIfExists()

		local clName1 = "Sampa_Cells"
		gis.Layer{
			project = proj,
			clean = true,
			input = layerName1,
			name = clName1,
			resolution = 0.7,
			file = filePath1
		}

		local cs = CellularSpace{
			project = proj,
			layer = clName1
		}

		forEachCell(cs, function(cell)
			cell.t0 = 1000
		end)

		local cellSpaceLayerNameT0 = clName1.."_CellSpace_T0"

		local shp2 = cellSpaceLayerNameT0..".shp"
		local filePath2 = testDir..shp2
		local fn2 = File(filePath2):name()
		fn2 = testDir..fn2

		File(fn2):deleteIfExists()

		cs:save(cellSpaceLayerNameT0, "t0")

		local layer = gis.Layer{
			project = proj,
			name = cellSpaceLayerNameT0,
		}

		unitTest:assertEquals(layer.source, "shp")
		unitTest:assertEquals(layer.file, filePath2)

		cs = CellularSpace{
			project = projName,
			layer = cellSpaceLayerNameT0
		}

		forEachCell(cs, function(cell)
			unitTest:assertEquals(cell.t0, 1000)
			cell.t0 = cell.t0 + 1000
		end)

		cs:save(cellSpaceLayerNameT0, "t0")

		cs = CellularSpace{
			project = projName,
			layer = cellSpaceLayerNameT0
		}

		forEachCell(cs, function(cell)
			unitTest:assertEquals(cell.t0, 2000)
		end)

		cs = CellularSpace{
			project = projName,
			layer = cellSpaceLayerNameT0
		}

		local cellSpaceLayerNameGeom = clName1.."_CellSpace_Geom"

		local shp3 = cellSpaceLayerNameGeom..".shp"
		local filePath3 = testDir..shp3
		local fn3 = File(filePath3):name()
		fn3 = testDir..fn3

		File(fn3):deleteIfExists()

		cs:save(cellSpaceLayerNameGeom)

		cs = CellularSpace{
			project = projName,
			layer = cellSpaceLayerNameGeom
		}

		forEachCell(cs, function(cell)
			unitTest:assertNotNil(cell.geom)
		end)

		local cellSpaceLayerNameGeom2 = clName1.."_CellSpace_Geom2"

		local shp4 = cellSpaceLayerNameGeom2..".shp"
		local filePath4 = testDir..shp4
		local fn4 = File(filePath4):name()
		fn4 = testDir..fn4

		File(fn4):deleteIfExists()

		cs:save(cellSpaceLayerNameGeom2)

		cs = CellularSpace{
			project = projName,
			layer = cellSpaceLayerNameGeom2
		}

		forEachCell(cs, function(cell)
			unitTest:assertNotNil(cell.geom)
		end)

		File(projName):deleteIfExists()

		File(fn1):deleteIfExists()
		File(fn2):deleteIfExists()
		File(fn3):deleteIfExists()
		File(fn4):deleteIfExists()
	end,
	split = function(unitTest)
		local cs = CellularSpace{xdim = 3}

		local counter = 0
		forEachCell(cs, function(cell)
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

		t2 = cs:split(function()
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

		local cell = Cell{
			cover = Random{"pasture", "forest"},
		}

		cs = CellularSpace{
			xdim = 5,
			instance = cell
		}

		ts = cs:split("cover")
		unitTest:assertEquals(getn(ts), 2)
		unitTest:assertEquals(#ts.forest, 14)
		unitTest:assertEquals(#ts.pasture, 11)

		forEachCell(cs, function(mcell)
			mcell.cover = "pasture"
		end)

		ts.forest:filter()
		ts.pasture:rebuild()

		unitTest:assertEquals(#ts.forest, 0)
		unitTest:assertEquals(#ts.pasture, 25)
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

		local c = Cell{
			value = 3,
			on_synchronize = function(self)
				self.value = 0
			end
		}

		cs = CellularSpace{
			instance = c,
			xdim = 3
		}

		cs:synchronize()

		forEachCell(cs, function(cell) unitTest:assertEquals(3, cell.past.value) end)
		forEachCell(cs, function(cell) unitTest:assertEquals(0, cell.value) end)
	end
}

