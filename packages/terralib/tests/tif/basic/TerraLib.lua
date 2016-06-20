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

return {
	addTifLayer = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		if isFile(proj.file) then
			rmFile(proj.file)
		end
		
		tl:createProject(proj, {})
		
		local layerName = "TifLayer"
		local layerFile = filePath("cbers_rgb342_crop1.tif", "terralib")
		tl:addTifLayer(proj, layerName, layerFile)
		
		local layerInfo = tl:getLayerInfo(proj, proj.layers[layerName])
		
		unitTest:assertEquals(layerInfo.name, layerName)
		unitTest:assertEquals(layerInfo.file, layerFile)
		unitTest:assertEquals(layerInfo.type, "GDAL")
		unitTest:assertEquals(layerInfo.rep, "raster")
		unitTest:assertNotNil(layerInfo.sid)
		
		rmFile(proj.file)
	end,
	addShpCellSpaceLayer = function(unitTest) -- CREATE SHP CELLULAR SPACE FROM TIF
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		if isFile(proj.file) then
			rmFile(proj.file)
		end	
		
		tl:createProject(proj, {})
		
		local layerName1 = "AmazoniaTif"
		local layerFile1 = filePath("PRODES_5KM.tif", "terralib")
		tl:addTifLayer(proj, layerName1, layerFile1)

		local clName = "Amazonia_Cells"
		local shp1 = clName..".shp"

		if isFile(shp1) then
			rmFile(shp1)
		end	
		
		local resolution = 60e3
		local mask = false
		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp1, mask)
		
		local layerInfo = tl:getLayerInfo(proj, proj.layers[clName])
		
		unitTest:assertEquals(layerInfo.name, clName)
		unitTest:assertEquals(layerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp1)
		unitTest:assertEquals(layerInfo.type, "OGR")
		unitTest:assertEquals(layerInfo.rep, "polygon")
		unitTest:assertNotNil(layerInfo.sid)				

		-- END
		if isFile(shp1) then
			rmFile(shp1)
		end			
		
		rmFile(proj.file)		
	end,
	-- addPgCellSpaceLayer = function(unitTest) -- CREATE POSTGIS CELLULAR SPACE FROM TIF
		-- #1152
		-- local tl = TerraLib{}
		-- local proj = {}
		-- proj.file = "myproject.tview"
		-- proj.title = "TerraLib Tests"
		-- proj.author = "Avancini Rodrigo"
		
		-- if isFile(proj.file) then
			-- rmFile(proj.file)
		-- end	
		
		-- tl:createProject(proj, {})
		
		-- local layerName1 = "AmazoniaTif"
		-- local layerFile1 = filePath("PRODES_5KM.tif", "terralib")
		-- tl:addTifLayer(proj, layerName1, layerFile1)
	
		-- local host = "localhost"
		-- local port = "5432"
		-- local user = "postgres"
		-- local password = "postgres"
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

		-- tl:dropPgDatabase(pgData)
		
		-- local clName1 = "Amazonia_PG_Cells"
		-- local resolution = 60e3
		-- local mask = false
		-- tl:addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)		
		
		-- local layerInfo = tl:getLayerInfo(proj, proj.layers[clName1])
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
	
		-- tl:dropPgTable(pgData)
		-- tl:dropPgDatabase(pgData)		
		
		-- rmFile(proj.file)	
	-- end,
	getNumOfBands = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		if isFile(proj.file) then
			rmFile(proj.file)
		end
		
		tl:createProject(proj, {})
		
		local layerName = "TifLayer"
		local layerFile = filePath("cbers_rgb342_crop1.tif", "terralib")
		tl:addTifLayer(proj, layerName, layerFile)
		
		local numBands = tl:getNumOfBands(proj, layerName)
		unitTest:assertEquals(numBands, 3)
		
		rmFile(proj.file)
	end,
	getProjection = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		if isFile(proj.file) then
			rmFile(proj.file)
		end
		
		tl:createProject(proj, {})
		
		local layerName = "Prodes"
		local layerFile = filePath("PRODES_5KM.tif", "terralib")
		tl:addTifLayer(proj, layerName, layerFile)
		
		local prj = tl:getProjection(proj.layers[layerName])
		
		unitTest:assertEquals(prj.SRID, 100017.0)
		unitTest:assertEquals(prj.NAME, "SAD69 / UTM zone 21S - old 29191")		
		unitTest:assertEquals(prj.PROJ4, "+proj=utm +zone=21 +south +ellps=aust_SA +towgs84=-57,1,-41,0,0,0,0 +units=m +no_defs ")
		
		rmFile(proj.file)		
	end
}

