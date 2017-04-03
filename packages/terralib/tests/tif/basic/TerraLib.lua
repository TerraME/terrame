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
	addGdalLayer = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib:createProject(proj, {})

		local layerName = "TifLayer"
		local layerFile = filePath("test/cbers_rgb342_crop1.tif", "terralib")
		TerraLib:addGdalLayer(proj, layerName, layerFile)

		local layerInfo = TerraLib:getLayerInfo(proj, layerName)

		unitTest:assertEquals(layerInfo.name, layerName)
		unitTest:assertEquals(layerInfo.file, tostring(layerFile))
		unitTest:assertEquals(layerInfo.type, "GDAL")
		unitTest:assertEquals(layerInfo.rep, "raster")
		unitTest:assertNotNil(layerInfo.sid)

		proj.file:delete()
	end,
	addShpCellSpaceLayer = function(unitTest) -- CREATE SHP CELLULAR SPACE FROM TIF
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib:createProject(proj, {})

		local layerName1 = "AmazoniaTif"
		local layerFile1 = filePath("amazonia-prodes.tif", "terralib")
		TerraLib:addGdalLayer(proj, layerName1, layerFile1)

		local clName = "Amazonia_Cells"
		local shp1 = File(clName..".shp")

		shp1:deleteIfExists()

		local resolution = 2e5
		local mask = false
		TerraLib:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp1, mask)

		local layerInfo = TerraLib:getLayerInfo(proj, clName)

		unitTest:assertEquals(layerInfo.name, clName)
		unitTest:assertEquals(layerInfo.file, tostring(shp1))
		unitTest:assertEquals(layerInfo.type, "OGR")
		unitTest:assertEquals(layerInfo.rep, "polygon")
		unitTest:assertNotNil(layerInfo.sid)

		shp1:deleteIfExists()

		proj.file:delete()
	end,
	-- addPgCellSpaceLayer = function(unitTest) -- CREATE POSTGIS CELLULAR SPACE FROM TIF
		-- #1152
		-- local tl = TerraLib{}
		-- local proj = {}
		-- proj.file = "myproject.tview"
		-- proj.title = "TerraLib Tests"
		-- proj.author = "Avancini Rodrigo"

		-- File(proj.file):deleteIfExists()

		-- TerraLib:createProject(proj, {})

		-- local layerName1 = "AmazoniaTif"
		-- local layerFile1 = filePath("amazonia-prodes.tif", "terralib")
		-- TerraLib:addGdalLayer(proj, layerName1, layerFile1)

		-- local host = "localhost"
		-- local port = "5432"
		-- local user = "postgres"
		-- local password = getConfig().password
		-- local database = "tif_pg_test"
		-- local encoding = "CP1252"
		-- local tableName = "sampa_cells"

		-- local pgData = {
			-- type = "POSTGIS",
			-- host = host,
			-- port = port,
			-- user = user,
			-- password = password,
			-- database = database,
			-- table = tableName,
			-- encoding = encoding
		-- }

		-- TerraLib:dropPgDatabase(pgData)

		-- local clName1 = "Amazonia_PG_Cells"
		-- local resolution = 2e5
		-- local mask = false
		-- TerraLib:addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)

		-- local layerInfo = TerraLib:getLayerInfo(proj, proj.layers[clName1])
		-- unitTest:assertEquals(layerInfo.name, clName1) -- SKIP
		-- unitTest:assertEquals(layerInfo.type, "POSTGIS") -- SKIP
		-- unitTest:assertEquals(layerInfo.rep, "polygon") -- SKIP
		-- unitTest:assertEquals(layerInfo.host, host) -- SKIP
		-- unitTest:assertEquals(layerInfo.port, port) -- SKIP
		-- unitTest:assertEquals(layerInfo.user, user) -- SKIP
		-- unitTest:assertEquals(layerInfo.password, password) -- SKIP
		-- unitTest:assertEquals(layerInfo.database, database) -- SKIP
		-- unitTest:assertEquals(layerInfo.table, tableName) -- SKIP
		-- unitTest:assertNotNil(layerInfo.sid) -- SKIP

		-- TerraLib:dropPgTable(pgData)
		-- TerraLib:dropPgDatabase(pgData)

		-- File(proj.file):delete()
	-- end,
	getGdalByFilePath = function(unitTest)
		local file = filePath("amazonia-prodes.tif", "terralib")

		local dSet = TerraLib:getGdalByFilePath(tostring(file))
		for i = 0, #dSet do
			for k, v in pairs(dSet[i]) do
				unitTest:assert(belong(k, {"xdim", "ydim", "name", "srid", "bands",
											"resolutionX", "resolutionY", "getValue"}))
				unitTest:assertNotNil(v)
			end
		end
	end,
	getNumOfBands = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib:createProject(proj, {})

		local layerName = "TifLayer"
		local layerFile = filePath("test/cbers_rgb342_crop1.tif", "terralib")
		TerraLib:addGdalLayer(proj, layerName, layerFile)

		local numBands = TerraLib:getNumOfBands(proj, layerName)
		unitTest:assertEquals(numBands, 3)

		proj.file:delete()
	end,
	getProjection = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib:createProject(proj, {})

		local layerName = "Prodes"
		local layerFile = filePath("amazonia-prodes.tif", "terralib")
		TerraLib:addGdalLayer(proj, layerName, layerFile, 100017)

		local prj = TerraLib:getProjection(proj.layers[layerName])

		unitTest:assertEquals(prj.SRID, 100017.0)
		unitTest:assertEquals(prj.NAME, "SAD69 / UTM zone 21S - old 29191")
		unitTest:assertEquals(prj.PROJ4, "+proj=utm +zone=21 +south +ellps=aust_SA +towgs84=-57,1,-41,0,0,0,0 +units=m +no_defs ")

		proj.file:delete()
	end,
	getPropertyNames = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib:createProject(proj, {})

		local layerName = "Prodes"
		local layerFile = filePath("amazonia-prodes.tif", "terralib")
		TerraLib:addGdalLayer(proj, layerName, layerFile)

		local propNames = TerraLib:getPropertyNames(proj, layerName)

		unitTest:assertEquals(getn(propNames), 1)
		unitTest:assertEquals(propNames[0], "raster")

		proj.file:delete()
	end,
	getPropertyInfos = function(unitTest)
		local proj = {}
		proj.file = "tlib_pg_bas.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib:createProject(proj, {})

		local layerName = "Prodes"
		local layerFile = filePath("amazonia-prodes.tif", "terralib")
		TerraLib:addGdalLayer(proj, layerName, layerFile)

		local propInfos = TerraLib:getPropertyInfos(proj, layerName)

		unitTest:assertEquals(getn(propInfos), 1)
		unitTest:assertEquals(propInfos[0].type, "raster")
		unitTest:assertEquals(propInfos[0].type, "raster")

		proj.file:delete()
	end,
	getDistance = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib:createProject(proj, {})

		local layerName1 = "AmazoniaTif"
		local layerFile1 = filePath("amazonia-prodes.tif", "terralib")
		TerraLib:addGdalLayer(proj, layerName1, layerFile1)

		local clName = "Amazonia_Cells"
		local shp1 = File(clName..".shp")

		shp1:deleteIfExists()

		local resolution = 2e5
		local mask = false
		TerraLib:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp1, mask)

		local dSet = TerraLib:getDataSet(proj, clName)
		local dist = TerraLib:getDistance(dSet[0].OGR_GEOMETRY, dSet[getn(dSet) - 1].OGR_GEOMETRY)

		unitTest:assertEquals(dist, 3883297.5677895, 1.0e-7) -- SKIP

		shp1:delete()

		proj.file:delete()
	end,
	getDummyValue = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib:createProject(proj, {})

		local layerName = "TifLayer"
		local layerFile = filePath("test/cbers_rgb342_crop1.tif", "terralib")
		TerraLib:addGdalLayer(proj, layerName, layerFile)

		local dummy = TerraLib:getDummyValue(proj, layerName, 0)
		unitTest:assertEquals(tostring(dummy), tostring(1.7976931348623e+308))

		dummy = TerraLib:getDummyValue(proj, layerName, 1)
		unitTest:assertEquals(tostring(dummy), tostring(1.7976931348623e+308))

		dummy = TerraLib:getDummyValue(proj, layerName, 2)
		unitTest:assertEquals(tostring(dummy), tostring(1.7976931348623e+308))

		local layerName2 = "ShapeLayer"
		local layerFile2 = filePath("test/sampa.shp", "terralib")
		TerraLib:addShpLayer(proj, layerName2, layerFile2)

		dummy = TerraLib:getDummyValue(proj, layerName2, 0)
		unitTest:assertNil(dummy)

		proj.file:delete()
	end,
	saveLayerAs = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib:createProject(proj, {})

		local layerName1 = "TifLayer"
		local layerFile1 = filePath("test/cbers_rgb342_crop1.tif", "terralib")
		TerraLib:addGdalLayer(proj, layerName1, layerFile1)

		local customWarningBkp = customWarning
		local currDir = currentDir()
		customWarning = function(msg)
			unitTest:assert((msg == "It was not possible to convert the data in layer 'TifLayer' to 'tif2nc.nc'.") or
							(msg == "Attempt to save data of the layer in '"..currDir.."/cbers_rgb342_crop1.tif'."))
		end

		-- NC (IT WAS ONLY TO COPY TIF TO A CURRENT DIR)
		local toData = {}
		toData.file = "tif2nc.nc"
		toData.type = "nc"

		local overwrite = true

		TerraLib:saveLayerAs(proj, layerName1, toData, overwrite)
		unitTest:assert(File("cbers_rgb342_crop1.tif"):exists())

		-- OVERWRITE
		TerraLib:saveLayerAs(proj, layerName1, toData, overwrite)
		unitTest:assert(File("cbers_rgb342_crop1.tif"):exists())

		File("cbers_rgb342_crop1.tif"):delete()
		proj.file:delete()

		customWarning = customWarningBkp
	end,
	getLayerSize = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		local file = File(proj.file)
		file:deleteIfExists()

		TerraLib:createProject(proj, {})

		local layerName = "TifLayer"
		local layerFile = filePath("test/cbers_rgb342_crop1.tif", "terralib")
		TerraLib:addGdalLayer(proj, layerName, layerFile)

		local size = TerraLib:getLayerSize(proj, layerName)

		unitTest:assertEquals(size, 882875.0)

		file:delete()
	end
}

