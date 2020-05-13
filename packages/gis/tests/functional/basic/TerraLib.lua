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
		unitTest:assertEquals(TerraLib().getVersion(), "5.5.0")
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
			local spQgs = filePath("test/sampa"..version..".qgs", "gis")
			local amzQgs = filePath("test/amazonia"..version..".qgs", "gis")
			local variousQgs = filePath("test/various"..version..".qgs", "gis")
			local webQgs = filePath("test/webservice"..version..".qgs", "gis")

			local spQgsCd = File("sampa"..version..".qgs"):deleteIfExists()
			local variousQgsCd = File("various"..version..".qgs"):deleteIfExists()
			local webQgsCd = File("webservice"..version..".qgs"):deleteIfExists()

			spQgs:copy(currentDir())
			variousQgs:copy(currentDir())
			webQgs:copy(currentDir())

			local amzdir = Directory(currentDir().."/amztest/")
			if amzdir:exists() then amzdir:delete() end
			amzdir:create()
			amzQgs:copy(amzdir)
			local amzQgsCd = File("amztest/amazonia"..version..".qgs")

			local shpFile = filePath("test/sampa.shp", "gis")
			local gjFile = filePath("test/sampa.geojson", "gis")
			local ascFile = filePath("test/biomassa-manaus.asc", "gis")
			local ncFile = filePath("test/vegtype_2000.nc", "gis")
			File("sampa.shp"):deleteIfExists()
			File("sampa.geojson"):deleteIfExists()
			File("biomassa-manaus.asc"):deleteIfExists()
			File("vegtype_2000.nc"):deleteIfExists()
			shpFile:copy(currentDir())
			gjFile:copy(currentDir())
			ascFile:copy(currentDir())
			ncFile:copy(currentDir())

			local amzFile = filePath("amazonia-limit.shp", "gis")
			local prodesFile = filePath("amazonia-prodes.tif", "gis")
			local roadsFile = filePath("amazonia-roads.shp", "gis")
			File("amazonia-limit.shp"):deleteIfExists()
			File("amazonia-prodes.tif"):deleteIfExists()
			File("amazonia-roads.shp"):deleteIfExists()
			amzFile:copy(currentDir())
			prodesFile:copy(currentDir())
			roadsFile:copy(currentDir())

			-- shp
			local proj = {
				file = spQgsCd
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

			spQgsCd:delete()
			File("sampa.shp"):delete()

			-- three shps
			proj = {}
			proj.file = amzQgsCd

			TerraLib().createProject(proj)

			unitTest:assertEquals(proj.file:name(), "amazonia"..version..".qgs")
			unitTest:assertEquals(proj.title, "QGIS Project")
			unitTest:assertEquals(proj.author, "QGIS Project")
			unitTest:assert(File("amztest/amazonia"..version..".tview"):exists())
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

			amzQgsCd:delete()
			File("amazonia-limit.shp"):delete()
			File("amazonia-prodes.tif"):delete()
			File("amazonia-roads.shp"):delete()
			amzdir:delete()

			-- various types
			proj = {}
			proj.file = variousQgsCd

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

			variousQgsCd:delete()
			File("sampa.geojson"):delete()
			File("biomassa-manaus.asc"):delete()
			File("vegtype_2000.nc"):delete()

			-- web services
			local wmsDir = Directory("wms")
			if wmsDir:exists() then
				wmsDir:delete()
			end

			proj = {}
			proj.file = webQgsCd
			TerraLib().createProject(proj)

			layerInfo = TerraLib().getLayerInfo(proj, "Cerrado States")
			unitTest:assertEquals(layerInfo.name, "Cerrado States")
			unitTest:assertEquals(layerInfo.rep, "raster")
			unitTest:assertEquals(layerInfo.srid, 4326)
			unitTest:assertEquals(layerInfo.type, "WMS2")
			unitTest:assertEquals(layerInfo.source, "wms")
			unitTest:assertEquals(layerInfo.url, "http://terrabrasilis.dpi.inpe.br/geoserver/ows")
			unitTest:assertEquals(layerInfo.dataset, "prodes-cerrado:estados")
			unitTest:assertEquals(layerInfo.encoding, "LATIN1")

			layerInfo = TerraLib().getLayerInfo(proj, "prodes-legal-amz:brazilian_legal_amazon")
			unitTest:assertEquals(layerInfo.name, "prodes-legal-amz:brazilian_legal_amazon")
			unitTest:assertEquals(layerInfo.rep, "polygon")
			unitTest:assertEquals(layerInfo.srid, 4674)
			unitTest:assertEquals(layerInfo.type, "WFS")
			unitTest:assertEquals(layerInfo.source, "wfs")
			unitTest:assertEquals(layerInfo.url, "http://terrabrasilis.dpi.inpe.br/geoserver/ows?version=2.0.0&", 1)
			unitTest:assertEquals(layerInfo.dataset, "prodes-legal-amz:brazilian_legal_amazon")
			unitTest:assertEquals(layerInfo.encoding, "LATIN1")

			wmsDir:delete()
			webQgsCd:delete()
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
			if _Gtme.sessionInfo().system == "windows" then
				unitTest:assertEquals(info.srid, 4019) --SKIP
			else
				unitTest:assertEquals(info.srid, 4674) --SKIP
			end
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
		local openTviewProject = function()
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
		end

		local openQGisProject = function()
			local spQgs = filePath("test/sampa_v3.qgs", "gis")
			local spQgsCd = File("sampa_v3.qgs"):deleteIfExists()
			spQgs:copy(currentDir())

			local spFile = filePath("test/sampa.shp", "gis")
			File("sampa.shp"):deleteIfExists()
			spFile:copy(currentDir())

			local proj = {
				file = spQgsCd
			}

			TerraLib().openProject(proj, proj.file)

			unitTest:assertEquals(proj.file:name(), "sampa_v3.qgs")
			unitTest:assertEquals(proj.title, "Sampa QGis Project")
			unitTest:assertEquals(proj.author, "Sampa QGis Project")
			unitTest:assert(File("sampa_v3.tview"):exists())

			proj.file:delete()
			File("sampa.shp"):delete()
		end

		unitTest:assert(openTviewProject)
		unitTest:assert(openQGisProject)
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
		local layerInfo = TerraLib().getLayerInfo(proj, layerName1)
		local geomAttrName = layerInfo.geometry

		local areaWarn = function()
			TerraLib().getArea(dSet[0][geomAttrName])
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
		TerraLib().setProgressVisible(false)

		local removeInTview = function()
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

		local removeInQgs = function()
			local proj = {
				file = "removelayer_basic_func.qgs",
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

		unitTest:assert(removeInTview)
		unitTest:assert(removeInQgs)
	end,
	setProgressVisible = function(unitTest)
		unitTest:assert(true)
	end
}
