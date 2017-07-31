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
		unitTest:assertEquals(TerraLib().getVersion(), "5.2.1")
	end,
	createProject = function(unitTest)
		-- QGIS PROJECT
		-- shp
		local proj = {
			file = filePath("test/sampa.qgs", "gis")
		}

		TerraLib().createProject(proj)

		unitTest:assertEquals(proj.file:name(), "sampa.qgs")
		unitTest:assertEquals(proj.title, "Sampa QGis Project")
		unitTest:assertEquals(proj.author, "Sampa QGis Project")
		unitTest:assert(File("sampa.tview"):exists())
		unitTest:assertNotNil(proj.layers)

		local layerInfo = TerraLib().getLayerInfo(proj, "SP")

		unitTest:assertEquals(layerInfo.name, "SP")
		unitTest:assertEquals(layerInfo.rep, "polygon")
		unitTest:assertEquals(layerInfo.srid, 4019)
		unitTest:assertEquals(layerInfo.type, "OGR")
		unitTest:assertEquals(layerInfo.source, "shp")
		unitTest:assertEquals(layerInfo.encoding, "LATIN1")

		-- postgis
		local fromData = {}
		fromData.project = proj
		fromData.layer = "SP"

		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
		local database = "postgis_22_sample"
		local encoding = "CP1252"
		local tableName = "sampa"

		local pgData = {
			type = "postgis",
			host = host,
			port = port,
			user = user,
			password = password,
			database = database,
			table = tableName,
			encoding = encoding
		}

		TerraLib().saveLayerAs(fromData, pgData, true)

		local projPg = {}
		projPg.file = filePath("test/sampapg.qgs", "gis")
		project = TerraLib().createProject(projPg)

		unitTest:assertEquals(projPg.file:name(), "sampapg.qgs")
		unitTest:assertEquals(projPg.title, "QGis Project")
		unitTest:assertEquals(projPg.author, "QGis Project")
		unitTest:assert(File("sampapg.tview"):exists())
		unitTest:assertEquals(getn(proj.layers), 1)

		layerInfo = TerraLib().getLayerInfo(projPg, "SP")
		unitTest:assertEquals(layerInfo.name, "SP")
		unitTest:assertEquals(layerInfo.rep, "polygon")
		unitTest:assertEquals(layerInfo.srid, 4019)
		unitTest:assertEquals(layerInfo.type, "POSTGIS")
		unitTest:assertEquals(layerInfo.source, "postgis")
		unitTest:assertEquals(layerInfo.encoding, "LATIN1")
		unitTest:assertEquals(layerInfo.database, database)
		unitTest:assertEquals(layerInfo.password, password)
		unitTest:assertEquals(layerInfo.host, host)
		unitTest:assertEquals(layerInfo.user, user)
		unitTest:assertEquals(layerInfo.port, port)
		unitTest:assertEquals(layerInfo.table, tableName)

		TerraLib().dropPgTable(pgData)
		File("sampa.tview"):delete()
		File("sampapg.tview"):delete()

		-- three shps
		proj = {}
		proj.file = filePath("test/amazonia.qgs", "gis")

		TerraLib().createProject(proj)

		unitTest:assertEquals(proj.file:name(), "amazonia.qgs")
		unitTest:assertEquals(proj.title, "QGis Project")
		unitTest:assertEquals(proj.author, "QGis Project")
		unitTest:assert(File("amazonia.tview"):exists())
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
		unitTest:assertNil(layerInfo.encoding)

		layerInfo = TerraLib().getLayerInfo(proj, "amazonia-roads")
		unitTest:assertEquals(layerInfo.name, "amazonia-roads")
		unitTest:assertEquals(layerInfo.rep, "line")
		unitTest:assertEquals(layerInfo.srid, 29191)
		unitTest:assertEquals(layerInfo.type, "OGR")
		unitTest:assertEquals(layerInfo.source, "shp")
		unitTest:assertEquals(layerInfo.encoding, "LATIN1")

		File("amazonia.tview"):delete()

		-- various types
		proj = {}
		proj.file = filePath("test/various.qgs", "gis")

		if _Gtme.sessionInfo().system == "windows" then
			TerraLib().createProject(proj)
		else
			local ncWarn = function()
				TerraLib().createProject(proj)
			end
			unitTest:assertWarning(ncWarn, "Layer QGis ignored 'vegtype_2000'. Type 'nc' is not supported.")
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
		unitTest:assertNil(layerInfo.encoding)

		if _Gtme.sessionInfo().system == "windows" then
			layerInfo = TerraLib().getLayerInfo(proj, "vegtype_2000")
			unitTest:assertEquals(layerInfo.name, "vegtype_2000") -- SKIP
			unitTest:assertEquals(layerInfo.rep, "raster") -- SKIP
			unitTest:assertEquals(layerInfo.srid, 4326) -- SKIP
			unitTest:assertEquals(layerInfo.type, "GDAL") -- SKIP
			unitTest:assertEquals(layerInfo.source, "nc") -- SKIP
			unitTest:assertNil(layerInfo.encoding) -- SKIP
		end

		File("various.tview"):delete()

		-- web services
		proj = {}
		proj.file = filePath("test/webservice.qgs", "gis")
		TerraLib().createProject(proj)

		layerInfo = TerraLib().getLayerInfo(proj, "IMG_02082016_321077D")
		unitTest:assertEquals(layerInfo.name, "IMG_02082016_321077D")
		unitTest:assertEquals(layerInfo.rep, "raster")
		unitTest:assertEquals(layerInfo.srid, 4326)
		unitTest:assertEquals(layerInfo.type, "WMS2")
		unitTest:assertEquals(layerInfo.source, "wms")
		unitTest:assertEquals(layerInfo.url, "http://terrabrasilis.info/terraamazon/ows")
		unitTest:assertEquals(layerInfo.dataset, "inpe:02082016_321077D")
		unitTest:assertNil(layerInfo.encoding)

		layerInfo = TerraLib().getLayerInfo(proj, "reddpac:LandCover2000")
		unitTest:assertEquals(layerInfo.name, "reddpac:LandCover2000")
		unitTest:assertEquals(layerInfo.rep, "surface")
		unitTest:assertEquals(layerInfo.srid, 4326)
		unitTest:assertEquals(layerInfo.type, "WFS")
		unitTest:assertEquals(layerInfo.source, "wfs")
		unitTest:assertEquals(layerInfo.url, "http://terrabrasilis.info/redd-pac/wfs")
		unitTest:assertEquals(layerInfo.dataset, "reddpac:LandCover2000")
		unitTest:assertEquals(layerInfo.encoding, "LATIN1")

		File("webservice.tview"):delete()
		-- // QGIS PROJECT
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

		local dSet = TerraLib().getDataSet(proj, layerName1)

		local areaWarn = function()
			TerraLib().getArea(dSet[0].OGR_GEOMETRY)
		end
		unitTest:assertWarning(areaWarn, "Geometry should be a polygon to get the area.")

		proj.file:delete()
	end,
}

