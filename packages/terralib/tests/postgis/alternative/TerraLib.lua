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
	addPgLayer = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

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
			TerraLib().addPgLayer(proj, layerName, pgData)
		end

		if sessionInfo().system == "linux" then
			unitTest:assertError(passWrong, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"FATAL:  password authentication failed for user \"postgres\"\n"..
				"FATAL:  password authentication failed for user \"postgres\"\n.")
		elseif sessionInfo().system == "mac" then
			unitTest:assertError(passWrong, "Is not possible add the Layer. Table 'sampa' does not exist.") -- SKIP
		else -- windows
			unitTest:assertError(passWrong, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"FATAL:  password authentication failed for user \"postgres\"\n.")
		end

		proj.file:delete()
	end,
	saveLayerAs = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "ES-Limit"
		local layerFile1 = filePath("test/limite_es_poly_wgs84.shp", "terralib")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		-- POSTGIS
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = getConfig().password
		local database = "postgis_22_sample"
		local encoding = "CP1252"
		local tableName = "limite_es_poly_wgs84"
		local srid = 4326

		local pgData = {
			type = "postgis",
			host = host,
			port = port,
			user = user,
			password = password,
			database = database,
			table = tableName, -- it is used only to drop
			encoding = encoding,
			srid = srid
		}

		local overwrite = true

		TerraLib().saveLayerAs(proj, layerName1, pgData, overwrite)
		local layerName2 = "PgLayer"
		TerraLib().addPgLayer(proj, layerName2, pgData)

		-- TIF
		local toData = {}
		toData.file = "postgis2tif.tif"
		toData.type = "tif"

		local postgis2tifError = function()
			TerraLib().saveLayerAs(proj, layerName2, toData, overwrite)
		end
		unitTest:assertError(postgis2tifError, "It was not possible to convert the data in layer 'PgLayer' to 'postgis2tif.tif'.")

		-- OVERWRITE
		overwrite = false

		-- SHP
		toData.file = "postgis2shp.shp"
		toData.type = "shp"
		File(toData.file):deleteIfExists()

		TerraLib().saveLayerAs(proj, layerName2, toData, overwrite)

		local overwriteShpError = function()
			TerraLib().saveLayerAs(proj, layerName2, toData, overwrite)
		end
		unitTest:assertError(overwriteShpError, "File 'postgis2shp.shp' already exists.")

		File(toData.file):delete()

		-- GEOJSON
		toData.file = "postgis2geojson.geojson"
		toData.type = "geojson"
		File(toData.file):deleteIfExists()

		TerraLib().saveLayerAs(proj, layerName2, toData, overwrite)

		local overwriteGeojsonError = function()
			TerraLib().saveLayerAs(proj, layerName2, toData, overwrite)
		end
		unitTest:assertError(overwriteGeojsonError, "File 'postgis2geojson.geojson' already exists.")

		local overwritePgError = function()
			TerraLib().saveLayerAs(proj, layerName1, pgData, overwrite)
		end
		unitTest:assertError(overwritePgError, "Table 'limite_es_poly_wgs84' already exists in postgis database 'postgis_22_sample'.")

		File(toData.file):delete()

		TerraLib().dropPgTable(pgData)
		proj.file:delete()
	end
}
