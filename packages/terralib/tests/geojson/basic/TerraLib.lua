-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.3 of the License, or (at your option) any later version.

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
	createProject = function(unitTest)
		local tl = TerraLib{}
		local title = "TerraLib Tests"
		local author = "Carneiro Heitor"
		local file = "mygeojsonproject.tview"
		local proj = {}
		proj.file = file
		proj.title = title
		proj.author = author

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})
		unitTest:assert(proj.file:exists())
		unitTest:assertEquals(proj.file:name(), file)
		unitTest:assertEquals(proj.title, title)
		unitTest:assertEquals(proj.author, author)

		-- allow overwrite
		tl:createProject(proj, {})
		unitTest:assert(proj.file:exists())

		proj.file:delete()
	end,
	addGeoJSONLayer = function(unitTest)
		local tl = TerraLib {}
		local title = "TerraLib Tests"
		local author = "Carneiro Heitor"
		local file = "mygeojsonproject.tview"
		local proj = {}
		proj.file = file
		proj.title = title
		proj.author = author

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		local layerName = "GeoJSONLayer"
		local layerFile = filePath("test/Setores_Censitarios_2000_pol.geojson", "terralib")

		tl:addGeoJSONLayer(proj, layerName, layerFile)

		local layerInfo = tl:getLayerInfo(proj, proj.layers[layerName])

		unitTest:assertEquals(layerInfo.name, layerName)
		unitTest:assertEquals(layerInfo.file, tostring(layerFile))
		unitTest:assertEquals(layerInfo.type, "OGR")
		unitTest:assertEquals(layerInfo.rep, "geometry")
		unitTest:assertNotNil(layerInfo.sid)

		proj.file:deleteIfExists()
	end,
	addGeoJSONCellSpaceLayer = function(unitTest)
		local tl = TerraLib{}
		local title = "TerraLib Tests"
		local author = "Carneiro Heitor"
		local file = "mygeojsonproject.tview"
		local proj = {}
		proj.file = file
		proj.title = title
		proj.author = author

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		local layerName = "GeoJSONLayer"
		local layerFile = filePath("test/Setores_Censitarios_2000_pol.geojson", "terralib")

		tl:addGeoJSONLayer(proj, layerName, layerFile)

		local clName = "GeoJSON_Cells"
		local geojson1 = clName..".geojson"

		File(geojson1):deleteIfExists()

		local resolution = 10000
		local mask = true
		tl:addGeoJSONCellSpaceLayer(proj, layerName, clName, resolution, geojson1, mask)

		local layerInfo = tl:getLayerInfo(proj, proj.layers[clName])

		unitTest:assertEquals(layerInfo.name, clName)
		unitTest:assertEquals(layerInfo.file, geojson1)
		unitTest:assertEquals(layerInfo.type, "OGR")
		unitTest:assertEquals(layerInfo.rep, "polygon")
		unitTest:assertNotNil(layerInfo.sid)

		-- NO MASK TEST
		local clSet = tl:getDataSet(proj, clName)
		unitTest:assertEquals(getn(clSet), 160)

		clName = clName.."_NoMask"
		local geojson2 = clName..".geojson"

		File(geojson2):deleteIfExists()

		mask = false
		tl:addGeoJSONCellSpaceLayer(proj, layerName, clName, resolution, geojson2, mask)

		clSet = tl:getDataSet(proj, clName)
		unitTest:assertEquals(getn(clSet), 160)
		-- // NO MASK TEST

		unitTest:assertFile(geojson1)
		unitTest:assertFile(geojson2)
		proj.file:delete()
	end,
	getOGRByFilePath = function(unitTest)
		local tl = TerraLib{}
		local shpPath = filePath("test/sampa.geojson", "terralib")
		local dSet = tl:getOGRByFilePath(tostring(shpPath))
		
		unitTest:assertEquals(getn(dSet), 63)

		for i = 0, #dSet do
			unitTest:assertEquals(dSet[i].FID, i)

			for k, v in pairs(dSet[i]) do
				unitTest:assert((k == "FID") or (k == "ID") or (k == "NM_MICRO") or 
								(k == "CD_GEOCODU") or (k == "OGR_GEOMETRY"))
				unitTest:assertNotNil(v)
			end
		end		
	end,	
	saveLayerAs = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		File(proj.file):deleteIfExists()
		
		tl:createProject(proj, {})

		local layerName1 = "SampaGeoJson"
		local layerFile1 = filePath("test/sampa.geojson", "terralib")
		tl:addGeoJSONLayer(proj, layerName1, layerFile1)	

		-- SHP
		local toData = {}
		toData.file = "geojson2shp.shp"
		toData.type = "shp"		
		File(toData.file):deleteIfExists()
		
		local overwrite = true
		
		tl:saveLayerAs(proj, layerName1, toData, overwrite)		
		unitTest:assert(File(toData.file):exists())

		-- OVERWRITE
		tl:saveLayerAs(proj, layerName1, toData, overwrite)
		unitTest:assert(File(toData.file):exists())

		-- POSTGIS
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = getConfig().password
		local database = "postgis_22_sample"
		local encoding = "CP1252"
		local tableName = "ogrgeojson"	-- #1243

		local pgData = {
			type = "postgis",
			host = host,
			port = port,
			user = user,
			password = password,
			database = database,
			table = tableName, -- it is used only to drop
			encoding = encoding	
		}		
		
		tl:saveLayerAs(proj, layerName1, pgData, overwrite)
		
		-- OVERWRITE
		tl:saveLayerAs(proj, layerName1, pgData, overwrite)
		
		tl:dropPgTable(pgData)		

		File(toData.file):delete()
		proj.file:delete()
	end,
	getLayerSize = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		local file = File(proj.file)
		file:deleteIfExists()

		tl:createProject(proj, {})

		local layerName1 = "SampaGeoJson"
		local layerFile1 = filePath("test/sampa.geojson", "terralib")
		tl:addGeoJSONLayer(proj, layerName1, layerFile1)

		local size = tl:getLayerSize(proj, layerName1)

		unitTest:assertEquals(size, 63.0)

		file:delete()
	end
}
