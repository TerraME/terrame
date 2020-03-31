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
			host = host,
			port = port,
			user = user,
			password = password,
			database = database,
			table = tableName
		}

		local layerName = "Postgis"

		local passWrong = function()
			TerraLib().addPgLayer(proj, layerName, pgData, nil, encoding)
		end

		unitTest:assertError(passWrong, "Connection failed due to invalid username or password.")

		proj.file:delete()
	end,
	saveDataAs = function(unitTest)
		TerraLib().setProgressVisible(false)

		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "ES-Limit"
		local layerFile1 = filePath("test/limite_es_poly_wgs84.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local fromData = {}
		fromData.project = proj
		fromData.layer = layerName1

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

		TerraLib().saveDataAs(fromData, pgData, overwrite)
		local layerName2 = "PgLayer"
		TerraLib().addPgLayer(proj, layerName2, pgData, nil, encoding)

		-- TIF
		local toData = {}
		toData.file = File("postgis2tif.tif")
		toData.type = "tif"
		fromData.layer = layerName2

		local postgis2tifWarn = function()
			TerraLib().saveDataAs(fromData, toData, overwrite)
		end
		unitTest:assertError(postgis2tifWarn, "Vector data 'PgLayer' cannot be saved as raster.")

		-- OVERWRITE
		overwrite = false

		-- SHP
		toData.file = File("postgis2shp.shp")
		toData.type = "shp"
		toData.file:deleteIfExists()

		TerraLib().saveDataAs(fromData, toData, overwrite)

		local overwriteShpError = function()
			TerraLib().saveDataAs(fromData, toData, overwrite)
		end
		unitTest:assertError(overwriteShpError, "File 'postgis2shp.shp' already exists.")

		toData.file:delete()

		-- TODO(#2328)
		-- -- GEOJSON
		-- toData.file = File("postgis2geojson.geojson")
		-- toData.type = "geojson"
		-- toData.file:deleteIfExists()

		-- TerraLib().saveDataAs(fromData, toData, overwrite)

		-- local overwriteGeojsonError = function()
			-- TerraLib().saveDataAs(fromData, toData, overwrite)
		-- end
		-- unitTest:assertError(overwriteGeojsonError, "File 'postgis2geojson.geojson' already exists.")

		-- fromData.layer = layerName1

		-- local overwritePgError = function()
			-- TerraLib().saveDataAs(fromData, pgData, overwrite)
		-- end
		-- unitTest:assertError(overwritePgError, "Table 'limite_es_poly_wgs84' already exists in postgis database 'postgis_22_sample'.")

		-- toData.file:delete()

		TerraLib().dropPgTable(pgData)
		proj.file:delete()
	end,
	addPgCellSpaceLayer = function(unitTest)
		local proj = {
			file = "myproject.tview",
			title = "TerraLib Tests",
			author = "Avancini Rodrigo"
		}
		File(proj.file):deleteIfExists()
		TerraLib().createProject(proj, {})


		local layerName1 = "AmazoniaTif"
		local layerFile1 = filePath("test/amazonia-prodes-noepsg.tif", "gis")
		TerraLib().addGdalLayer(proj, layerName1, layerFile1)

		local tableName = "amzcs"
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
			table = tableName,
			encoding = encoding
		}

		TerraLib().dropPgTable(pgData)

		local clName1 = "Amazonia_PG_Cells"
		local resolution = 3e5
		local mask = false
		TerraLib().dropPgTable(pgData)

		local projectionError = function()
			TerraLib().addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)
		end

		unitTest:assertError(projectionError, "Layer 'AmazoniaTif' has a invalid EPSG. Please, set a valid projection, if it still doesn't work, reproject the layer data.")

		proj.file:delete()
		TerraLib().dropPgTable(pgData)
	end
}
