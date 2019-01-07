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

return {
	TerraLib = function(unitTest)
		local t1 = TerraLib
		local t2 = TerraLib

		unitTest:assertEquals(t1, t2)
	end,
	getVersion = function(unitTest)
		unitTest:assertEquals(TerraLib().getVersion(), "5.4.1")
	end,
	createProject = function(unitTest)
		local happyPath = function()
			local title = "TerraLib Tests"
			local author = "Carneiro Heitor"
			local file = "myproject.tview"

			local proj = {
				file = file,
				title = title,
				author = author
			}

			File(proj.file):deleteIfExists()

			TerraLib().createProject(proj, {})

			unitTest:assert(proj.file:exists())
			unitTest:assertEquals(proj.file:name(), file)
			unitTest:assertEquals(proj.title, title)
			unitTest:assertEquals(proj.author, author)

			proj.file:delete()
		end

		unitTest:assert(happyPath)

		local version = ""
		local readQGisProject = function()
			-- shp
			local proj = {
				file = filePath("test/sampa"..version..".qgs", "gis")
			}

			TerraLib().createProject(proj)

			unitTest:assertEquals(proj.file:name(), "sampa"..version..".qgs")
			unitTest:assertEquals(proj.title, "Sampa QGis Project")
			unitTest:assertEquals(proj.author, "Sampa QGis Project")
			unitTest:assert(File("sampa"..version..".tview"):exists())
			unitTest:assertNotNil(proj.layers)

			local layerInfo = TerraLib().getLayerInfo(proj, "SP")

			unitTest:assertEquals(layerInfo.name, "SP")
			unitTest:assertEquals(layerInfo.rep, "polygon")
			unitTest:assertEquals(layerInfo.srid, 4019)
			unitTest:assertEquals(layerInfo.type, "OGR")
			unitTest:assertEquals(layerInfo.source, "shp")
			unitTest:assertEquals(layerInfo.encoding, "LATIN1")

			File("sampa"..version..".tview"):delete()

			-- three shps
			proj = {}
			proj.file = filePath("test/amazonia"..version..".qgs", "gis")

			TerraLib().createProject(proj)

			unitTest:assertEquals(proj.file:name(), "amazonia"..version..".qgs")
			unitTest:assertEquals(proj.title, "QGIS Project")
			unitTest:assertEquals(proj.author, "QGIS Project")
			unitTest:assert(File("amazonia"..version..".tview"):exists())
			unitTest:assertEquals(getn(proj.layers), 3)

			layerInfo = TerraLib().getLayerInfo(proj, "amazonia-limit")
			unitTest:assertEquals(layerInfo.name, "amazonia-limit")
			unitTest:assertEquals(layerInfo.rep, "polygon")
			unitTest:assertEquals(layerInfo.srid, 29191)
			unitTest:assertEquals(layerInfo.type, "OGR")
			unitTest:assertEquals(layerInfo.source, "shp")
			unitTest:assertEquals(layerInfo.encoding, "LATIN1")

			layerInfo = TerraLib().getLayerInfo(proj, "amazonia-prodes")
			unitTest:assertEquals(layerInfo.name, "amazonia-prodes")
			unitTest:assertEquals(layerInfo.rep, "raster")
			unitTest:assertEquals(layerInfo.srid, 29191)
			unitTest:assertEquals(layerInfo.type, "GDAL")
			unitTest:assertEquals(layerInfo.source, "tif")
			unitTest:assertEquals(layerInfo.encoding, "LATIN1")

			layerInfo = TerraLib().getLayerInfo(proj, "amazonia-roads")
			unitTest:assertEquals(layerInfo.name, "amazonia-roads")
			unitTest:assertEquals(layerInfo.rep, "line")
			unitTest:assertEquals(layerInfo.srid, 29191)
			unitTest:assertEquals(layerInfo.type, "OGR")
			unitTest:assertEquals(layerInfo.source, "shp")
			unitTest:assertEquals(layerInfo.encoding, "LATIN1")

			File("amazonia"..version..".tview"):delete()

			-- various types
			proj = {}
			proj.file = filePath("test/various"..version..".qgs", "gis")

			if _Gtme.sessionInfo().system == "windows" then
				TerraLib().createProject(proj)
			else
				local ncWarn = function()
					TerraLib().createProject(proj)
				end

				unitTest:assertWarning(ncWarn, "Layer QGIS ignored 'vegtype_2000'. Type 'nc' is not supported.") -- SKIP
			end

			layerInfo = TerraLib().getLayerInfo(proj, "sampa")
			unitTest:assertEquals(layerInfo.name, "sampa")
			unitTest:assertEquals(layerInfo.rep, "polygon")
			unitTest:assertEquals(layerInfo.srid, 4019)
			unitTest:assertEquals(layerInfo.type, "OGR")
			unitTest:assertEquals(layerInfo.source, "geojson")
			unitTest:assertEquals(layerInfo.encoding, "LATIN1")

			layerInfo = TerraLib().getLayerInfo(proj, "biomassa-manaus")
			unitTest:assertEquals(layerInfo.name, "biomassa-manaus")
			unitTest:assertEquals(layerInfo.rep, "raster")
			unitTest:assertEquals(layerInfo.srid, 4326)
			unitTest:assertEquals(layerInfo.type, "GDAL")
			unitTest:assertEquals(layerInfo.source, "asc")
			unitTest:assertEquals(layerInfo.encoding, "LATIN1")

			if _Gtme.sessionInfo().system == "windows" then
				layerInfo = TerraLib().getLayerInfo(proj, "vegtype_2000")
				unitTest:assertEquals(layerInfo.name, "vegtype_2000") -- SKIP
				unitTest:assertEquals(layerInfo.rep, "raster") -- SKIP
				unitTest:assertEquals(layerInfo.srid, 4326) -- SKIP
				unitTest:assertEquals(layerInfo.type, "GDAL") -- SKIP
				unitTest:assertEquals(layerInfo.source, "nc") -- SKIP
				unitTest:assertEquals(layerInfo.encoding, "LATIN1") -- SKIP
			end

			File("various"..version..".tview"):delete()

			-- web services
			local wmsDir = Directory("wms")
			if wmsDir:exists() then
				wmsDir:delete()
			end

			proj = {}
			proj.file = filePath("test/webservice"..version..".qgs", "gis")
			TerraLib().createProject(proj)

			layerInfo = TerraLib().getLayerInfo(proj, "LANDSAT2013")
			unitTest:assertEquals(layerInfo.name, "LANDSAT2013")
			unitTest:assertEquals(layerInfo.rep, "raster")
			unitTest:assertEquals(layerInfo.srid, 4326)
			unitTest:assertEquals(layerInfo.type, "WMS2")
			unitTest:assertEquals(layerInfo.source, "wms")
			unitTest:assertEquals(layerInfo.url, "http://terrabrasilis.info/geoserver/ows")
			unitTest:assertEquals(layerInfo.dataset, "Prodes_2013:LANDSAT2013")
			unitTest:assertEquals(layerInfo.encoding, "LATIN1")

			layerInfo = TerraLib().getLayerInfo(proj, "reddpac:LandCover2000")
			unitTest:assertEquals(layerInfo.name, "reddpac:LandCover2000")
			unitTest:assertEquals(layerInfo.rep, "surface")
			unitTest:assertEquals(layerInfo.srid, 4326)
			unitTest:assertEquals(layerInfo.type, "WFS")
			unitTest:assertEquals(layerInfo.source, "wfs")
			unitTest:assertEquals(layerInfo.url, "http://terrabrasilis.info/redd-pac/wfs")
			unitTest:assertEquals(layerInfo.dataset, "reddpac:LandCover2000")
			unitTest:assertEquals(layerInfo.encoding, "LATIN1")

			wmsDir:delete()
			File("webservice"..version..".tview"):delete()
		end

		local insertNewLayerQgis = function()
			local qgsfile = filePath("test/sampa_v3.qgs", "gis")
			local spfile = filePath("test/sampa.shp", "gis")

			qgsfile:copy(currentDir())
			spfile:copy(currentDir())

			local qgp = {
				file = File("sampa_v3.qgs")
			}

			TerraLib().createProject(qgp)

			local gjsp = filePath("test/sampa.geojson", "gis")
			gjsp:copy(currentDir())

			local layerName = "NewLayer"
			local layerFile = File("sampa.geojson")
			TerraLib().addGeoJSONLayer(qgp, layerName, layerFile)

			local qgp2 = {
				file = File("sampa_v3.qgs")
			}

			TerraLib().createProject(qgp2)

			local info = TerraLib().getLayerInfo(qgp2, layerName)

			unitTest:assertEquals(info.name, "NewLayer")
			unitTest:assertEquals(info.rep, "polygon")
			unitTest:assertEquals(info.srid, 4019)
			unitTest:assertEquals(File(info.file):name(), "sampa.geojson")
			unitTest:assertEquals(info.source, "geojson")
			unitTest:assertEquals(info.encoding, "LATIN1")

			qgp.file:delete()
			File("sampa_v3.tview"):delete()
			File("sampa.shp"):delete()
			layerFile:delete()
		end

		local createQGisProject = function()
			local spfile = filePath("test/sampa.shp", "gis")
			spfile:copy(currentDir())

			local qgp = {
				file = File("create_func_v3.qgs")
			}

			qgp.file:deleteIfExists()
			File("create_func_v3.tview"):deleteIfExists()

			TerraLib().createProject(qgp)

			local l1Name = "SP"
			local l1File = File("sampa.shp")
			TerraLib().addShpLayer(qgp, l1Name, l1File)

			local qgp2 = {
				file = qgp.file
			}

			TerraLib().createProject(qgp2)

			local info = TerraLib().getLayerInfo(qgp2, l1Name)

			unitTest:assertEquals(info.name, "SP")
			unitTest:assertEquals(info.rep, "polygon")
			unitTest:assertEquals(info.srid, 4019)
			unitTest:assertEquals(File(info.file):name(), "sampa.shp")
			unitTest:assertEquals(info.source, "shp")
			unitTest:assertEquals(info.encoding, "LATIN1")

			local gjsp = filePath("test/sampa.geojson", "gis")
			gjsp:copy(currentDir())

			local l2Name = "SPtoo"
			local l2File = File("sampa.geojson")
			TerraLib().addGeoJSONLayer(qgp2, l2Name, l2File)

			local info2 = TerraLib().getLayerInfo(qgp2, l2Name)
			unitTest:assertEquals(info2.name, "SPtoo")
			unitTest:assertEquals(info2.rep, "polygon")
			unitTest:assertEquals(info2.srid, 4019)
			unitTest:assertEquals(File(info2.file):name(), "sampa.geojson")
			unitTest:assertEquals(info2.source, "geojson")
			unitTest:assertEquals(info2.encoding, "LATIN1")

			local tif = filePath("test/prodes_polyc_10k.tif", "gis")
			tif:copy(currentDir())

			local l3Name = "Tif"
			local l3File = File("prodes_polyc_10k.tif")
			TerraLib().addGdalLayer(qgp2, l3Name, l3File, 4019)

			local info3 = TerraLib().getLayerInfo(qgp2, l3Name)
			unitTest:assertEquals(info3.name, "Tif")
			unitTest:assertEquals(info3.rep, "raster")
			unitTest:assertEquals(info3.srid, 4019)
			unitTest:assertEquals(File(info3.file):name(), "prodes_polyc_10k.tif")
			unitTest:assertEquals(info3.source, "tif")
			unitTest:assertEquals(info3.encoding, "LATIN1")

			qgp.file:delete()
			File("create_func_v3.tview"):delete()
			l1File:delete()
			l2File:delete()
			l3File:delete()
		end

		unitTest:assert(readQGisProject)
		version = "_v3"
		unitTest:assert(readQGisProject)
		unitTest:assert(insertNewLayerQgis)
		unitTest:assert(createQGisProject)
	end,
	openProject = function(unitTest)
		local proj = {
			file = "myproject.tview",
			title = "TerraLib Tests",
			author = "Avancini Rodrigo"
		}

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local proj2 = {}

		TerraLib().openProject(proj2, proj.file)

		unitTest:assertEquals(proj2.file, proj.file)
		unitTest:assertEquals(proj2.title, proj.title)
		unitTest:assertEquals(proj2.author, proj.author)

		proj.file:delete()
	end,
	checkName = function(unitTest)
		unitTest:assertEquals(TerraLib().checkName("count"), "Invalid name: using reserved word COUNT")
		unitTest:assertEquals(TerraLib().checkName("sum"), "Invalid name: using reserved word SUM")
		unitTest:assertEquals(TerraLib().checkName("file-name"), "Invalid character: mathematical symbol '-'")
		unitTest:assertEquals(TerraLib().checkName("$ymbol"), "Invalid symbol: '$'")
	end,
	getArea = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "PA"
		local layerFile1 = filePath("itaituba-localities.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local dSet = TerraLib().getDataSet{project = proj, layer = layerName1}

		local areaWarn = function()
			TerraLib().getArea(dSet[0].OGR_GEOMETRY)
		end
		unitTest:assertWarning(areaWarn, "Geometry should be a polygon to get the area.")

		proj.file:delete()
	end,
	getBoundingBox = function(unitTest)
		local proj = {}
		proj.file = "bbox.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "PA"
		local layerFile1 = filePath("itaituba-localities.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local bbox = TerraLib().getBoundingBox(proj.layers[layerName1])

		unitTest:assertEquals(bbox.xMin, 550450.93221054, 1.0e-8)
		unitTest:assertEquals(bbox.xMax, 693339.43694636, 1.0e-8)
		unitTest:assertEquals(bbox.yMin, 9487489.6139118, 1.0e-7)
		unitTest:assertEquals(bbox.yMax, 9583620.4323347, 1.0e-7)

		proj.file:delete()
	end,
	random = function(unitTest)
		-- Random tests is on functional/basic/Random.lua
		unitTest:assert(true)
	end,
	geometry = function(unitTest)
		-- Geometry tests is on functional/basic/Geometry.lua
		unitTest:assert(true)
	end,
	removeLayer = function(unitTest)
		local proj = {
			file = "removelayer_basic_func.tview",
			title = "TerraLib Tests",
			author = "Avancini Rodrigo"
		}

		File(proj.file):deleteIfExists()
		TerraLib().createProject(proj, {})

		local layerName = "inputLayer"
		local layerFile = filePath("itaituba-localities.shp", "gis")
		TerraLib().addShpLayer(proj, layerName, layerFile)

		local clName = "testLayer"
		local cellsShp = File("test.shp")
		local resolution = 30000
		local mask = true
		cellsShp:deleteIfExists()
		TerraLib().addShpCellSpaceLayer(proj, layerName, clName, resolution, cellsShp, mask)

		local info = TerraLib().getLayerInfo(proj, clName)
		unitTest:assertNotNil(proj.layers.testLayer)
		unitTest:assertEquals(info.name, clName)
		unitTest:assertEquals(tostring(info.file), tostring(cellsShp))

		TerraLib().removeLayer(proj, clName)

		unitTest:assertNil(proj.layers.testLayer)

		proj.file:delete()
	end
}

