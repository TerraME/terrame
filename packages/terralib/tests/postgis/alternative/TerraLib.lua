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
	addPgLayer = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		File(proj.file):deleteIfExists()
		
		tl:createProject(proj, {})	
	
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "post"
		local database = "terralib_pg_test"
		local encoding = "CP1252"
		local tableName = "sampa"
		
		local pgData = {
			type = "POSTGIS",
			host = host,
			port = port,
			user = user,
			password = password,
			database = database,
			table = tableName,
			encoding = encoding	
		}			
		
		local layerName = "Postgis"
		
		local passWrong = function()
			tl:addPgLayer(proj, layerName, pgData)
		end
		unitTest:assertError(passWrong, "It was not possible to create a connection to the given data source due to the following error: "
							.."FATAL:  password authentication failed for user \""..user.."\"\n.", 59) -- #1303

		File(proj.file):delete()
	end,
	saveLayerAs = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		File(proj.file):deleteIfExists()
		
		tl:createProject(proj, {})

		local layerName1 = "Setores"
		local layerFile1 = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)	
		
		-- POSTGIS
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = getConfig().password
		local database = "postgis_22_sample"
		local encoding = "CP1252"
		local tableName = "Setores_Censitarios_2000_pol"	

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
		
		local overwrite = true
		
		tl:saveLayerAs(proj, layerName1, pgData, overwrite)	
		local layerName2 = "PgLayer"
		tl:addPgLayer(proj, layerName2, pgData)
		
		-- TIF
		local toData = {}
		toData.file = "postgis2tif.tif"
		toData.type = "tif"		
		
		local postgis2tifError = function()
			tl:saveLayerAs(proj, layerName2, toData, overwrite)
		end
		unitTest:assertError(postgis2tifError, "It was not possible to convert the data in layer 'PgLayer' to 'postgis2tif.tif'.")	
		
		-- OVERWRITE
		overwrite = false
		
		-- SHP
		toData.file = "postgis2shp.shp"
		toData.type = "shp"		
		File(toData.file):deleteIfExists()
		
		tl:saveLayerAs(proj, layerName2, toData, overwrite)	
		
		local overwriteShpError = function()
			tl:saveLayerAs(proj, layerName2, toData, overwrite)
		end
		unitTest:assertError(overwriteShpError,  "The file 'postgis2shp.shp' already exists.")
		
		File(toData.file):delete()
		
		-- GEOJSON
		toData.file = "postgis2geojson.geojson"
		toData.type = "geojson"		
		File(toData.file):deleteIfExists()

		tl:saveLayerAs(proj, layerName2, toData, overwrite)		
		
		local overwriteGeojsonError = function()
			tl:saveLayerAs(proj, layerName2, toData, overwrite)
		end
		unitTest:assertError(overwriteGeojsonError,  "The file 'postgis2geojson.geojson' already exists.")

		File(toData.file):delete()
		
		tl:dropPgTable(pgData)
		File(proj.file):delete()		
	end	
}
