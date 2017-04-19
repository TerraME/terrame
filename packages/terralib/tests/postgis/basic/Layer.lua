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
	Layer = function(unitTest)
		local projName = "layer_postgis_basic.tview" -- TODO: (#1442)

		if File(projName):exists() then
			File(projName):delete()
		end

		local proj1 = Project{
			file = projName,
			clean = true
		}

		local layerName1 = "Sampa"

		local layer1 = Layer{
			project = proj1,
			name = layerName1,
			file = filePath("test/sampa.shp", "terralib")
		}

		unitTest:assertEquals(layer1.name, layerName1)

		local host
		local port
		local password = getConfig().password
		local database = "postgis_22_sample"
		local encoding
		local tableName = "sampa"

		local pgData = {
			source = "postgis",
			--host = host,
			--port = port,
			password = password,
			database = database,
			overwrite = true
		}

		layer1:export(pgData, true)

		local layerName2 = "SampaDB"

		local layer2 = Layer{
			project = proj1,
			source = "postgis",
			name = layerName2,
			-- host = host,
			-- port = port,
			password = password,
			database = database,
			table = tableName
		}

		unitTest:assertEquals(layer2.name, layerName2)

		local layerName3 = "Another_SampaDB"

		local layer3 = Layer{
			project = proj1,
			source = "postgis",
			name = layerName3,
			-- host = host,
			-- port = port,
			password = password,
			database = database,
			table = tableName
		}

		unitTest:assert(layer3.name ~= layer2.name)
		unitTest:assertEquals(layer3.sid, layer2.sid)

		File(projName):deleteIfExists()

		projName = "cells_setores_2000.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		layerName1 = "Sampa"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath("test/sampa.shp", "terralib")
		}

		local clName1 = "Sampa_Cells"
		local tName1 = "add_cellslayer_basic"

		host = "localhost"
		port = "5432"
		password = "postgres"
		database = "postgis_22_sample"
		encoding = "CP1252"

		pgData = {
			type = "POSTGIS",
			host = host,
			port = port,
			password = password,
			database = database,
			table = tName1,
			user = "postgres",
			encoding = encoding
		}

		local l1 = Layer{
			project = proj,
			source = "postgis",
			clean = true,
			input = layerName1,
			name = clName1,
			resolution = 0.7,
			password = password,
			database = database,
			table = tName1
		}

		unitTest:assertEquals(l1.name, clName1)

		local clName2 = "Another_Sampa_Cells"
		local tName2 = "add_cellslayer_basic_another"

		pgData.table = tName2

		local l2 = Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			clean = true,
			name = clName2,
			resolution = 0.7,
			password = password,
			database = database,
			table = tName2
		}

		unitTest:assertEquals(l2.name, clName2)

		local clName3 = "Other_Sampa_Cells"
		local tName3 = "add_cellslayer_basic_from_db"

		pgData.table = tName3

		local l3 = Layer{
			project = proj,
			source = "postgis",
			input = clName2,
			name = clName3,
			clean = true,
			resolution = 0.7,
			password = password,
			database = database,
			table = tName3
		}

		unitTest:assertEquals(l3.name, clName3)

		local newDbName = "new_pg_db_30032017"
		pgData.database = newDbName
		TerraLib().dropPgDatabase(pgData)
		pgData.database = database

		local clName4 = "New_Sampa_Cells"

		local layer4 = Layer{
			project = proj,
			source = "postgis",
			input = clName2,
			name = clName4,
			resolution = 0.7,
			password = password,
			database = newDbName
		}

		unitTest:assertEquals(layer4.source, "postgis")
		unitTest:assertEquals(layer4.host, host)
		unitTest:assertEquals(layer4.port, port)
		unitTest:assertEquals(layer4.user, "postgres")
		unitTest:assertEquals(layer4.password, password)
		unitTest:assertEquals(layer4.database, newDbName)
		unitTest:assertEquals(layer4.table, string.lower(clName4))

		-- BOX TEST
		local clSet = TerraLib().getDataSet(proj, clName1)
		unitTest:assertEquals(getn(clSet), 68)

		clName1 = clName1.."_Box"
		local tName4 = string.lower(clName1)
		pgData.table = tName4

		Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			clean = true,
			name = clName1,
			resolution = 0.7,
			box = true,
			password = password,
			database = database
		}

		clSet = TerraLib().getDataSet(proj, clName1)
		unitTest:assertEquals(getn(clSet), 104)

		-- CHANGE EPSG
		local layerName5 = "SampaDBNewSrid"

		local layer5 = Layer{
			project = proj,
			source = "postgis",
			name = layerName5,
			-- host = host,
			-- port = port,
			password = password,
			database = database,
			table = tName1,
			epsg = 29901
		}

		unitTest:assertEquals(layer5.epsg, 29901.0)
		unitTest:assert(layer5.epsg ~= layer4.epsg)
		-- // CHANGE EPSG

		-- #1152
		-- local host = "localhost"
		-- local port = "5432"
		-- local password = "postgres"
		-- local database = "postgis_22_sample"
		-- local encoding = "CP1252"
		-- local tableName = "prodes_pg_cells"

		-- local pgData = {
			-- type = "POSTGIS",
			-- host = host,
			-- port = port,
			-- password = password,
			-- database = database,
			-- table = tableName,
			-- user = "postgis",
			-- encoding = encoding

		-- }

		-- local clName2 = "ProdesPg"

		-- local layer2 = Layer{
			-- project = proj,
			-- source = "postgis",
			-- clean = true,
			-- input = layerName1
			-- name = clName2,
			-- resolution = 60e3,
			-- password = password,
			-- database = database,
			-- table = tableName
		-- }

		-- END
		-- TerraLib().dropPgTable(pgData)

		File(projName):deleteIfExists()

		pgData.table = tName1
		TerraLib().dropPgTable(pgData)
		pgData.table = tName2
		TerraLib().dropPgTable(pgData)
		pgData.table = tName3
		TerraLib().dropPgTable(pgData)
		pgData.table = tName4
		TerraLib().dropPgTable(pgData)
		pgData.database = newDbName
		TerraLib().dropPgDatabase(pgData)
	end,
	projection = function(unitTest)
		local projName = "layer_basic.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local layerName1 = "Setores"

		local layer1 = Layer{
			project = proj,
			name = layerName1,
			file = filePath("itaituba-census.shp", "terralib")
		}

		unitTest:assertEquals(layer1.name, layerName1)

		local host = "localhost"
		local port = "5432"
		local password = "postgres"
		local database = "postgis_22_sample"
		local encoding = "CP1252"
		local tableName = "setores_cells"

		local clName1 = "Setores_Cells"
		local layer = Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			name = clName1,
			resolution = 5e3,
			clean = true,
			password = password,
			database = database
		}

		unitTest:assertEquals(layer:projection(), "'SAD69 / UTM zone 21S', with EPSG: 29191 (PROJ4: '+proj=utm +zone=21 +south +ellps=aust_SA +towgs84=-66.87,4.37,-38.52,0,0,0,0 +units=m +no_defs ')")

		proj.file:delete()
		TerraLib().dropPgTable(pgData)
	end,
	attributes = function(unitTest)
		local projName = "layer_basic.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local layerName1 = "Setores"

		local layer1 = Layer{
			project = proj,
			name = layerName1,
			file = filePath("itaituba-census.shp", "terralib")
		}

		unitTest:assertEquals(layer1.name, layerName1)

		local host = "localhost"
		local port = "5432"
		local password = "postgres"
		local database = "postgis_22_sample"
		local encoding = "CP1252"
		local tableName = "setores_cells"

		local pgData = {
			type = "POSTGIS",
			host = host,
			port = port,
			password = password,
			database = database,
			table = tableName,
			encoding = encoding
		}

		local clName1 = "Setores_Cells"
		local layer = Layer{
			project = proj,
			input = layerName1,
			name = clName1,
			resolution = 5e3,
			clean = true,
			password = password,
			database = database
		}

		local propInfos = layer:attributes()

		unitTest:assertEquals(#propInfos, 3)
		unitTest:assertEquals(propInfos[1].name, "id")
		unitTest:assertEquals(propInfos[1].type, "string")
		unitTest:assertEquals(propInfos[2].name, "col")
		unitTest:assertEquals(propInfos[2].type, "integer 32")
		unitTest:assertEquals(propInfos[3].name, "row")
		unitTest:assertEquals(propInfos[3].type, "integer 32")

		proj.file:delete()
		TerraLib().dropPgTable(pgData)
	end,
	export = function(unitTest)
		local projName = "layer_postgis_basic.tview"

		if File(projName):exists() then -- TODO: (#1442)
			File(projName):delete()
		end

		local proj = Project {
			file = projName,
			clean = true
		}

		local filePath1 = filePath("test/MG_cities.shp", "terralib")

		local layerName1 = "mg"
		local layer1 = Layer{
			project = proj,
			name = layerName1,
			file = filePath1
		}

		local overwrite = true

		local password = getConfig().password
		local database = "postgis_22_sample"
		local tableName = "mg"

		local pgData = {
			source = "postgis",
			password = password,
			database = database,
			overwrite = overwrite,
			epsg = 4036
		}

		layer1:export(pgData)

		local layerName2 = "mgpg"
		local layer2 = Layer{
			project = proj,
			source = "postgis",
			name = layerName2,
			password = password,
			database = database,
			table = tableName
		}

		local geojson = "mg.geojson"
		local data1 = {
			file = geojson,
			overwrite = overwrite
		}

		layer2:export(data1)
		unitTest:assert(File(geojson):exists())

		-- OVERWRITE AND CHANGE EPSG
		data1.epsg = 4326
		layer2:export(data1)

		local layerName3 = "GJ"
		local layer3 = Layer{
			project = proj,
			name = layerName3,
			file = geojson
		}

		unitTest:assertEquals(layer3.epsg, data1.epsg)
		unitTest:assert(layer2.epsg ~= data1.epsg)

		local shp = "mg.shp"
		local data2 = {
			file = shp,
			overwrite = overwrite
		}

		layer2:export(data2)
		unitTest:assert(File(shp):exists())

		-- OVERWRITE AND CHANGE EPSG
		data2.epsg = 4326
		layer2:export(data2)

		local layerName4 = "SHP"
		local layer4 = Layer{
			project = proj,
			name = layerName4,
			file = shp
		}

		unitTest:assertEquals(layer4.epsg, data2.epsg)
		unitTest:assert(layer2.epsg ~= data2.epsg)

		-- SELECT ONE ATTRIBUTE TO GEOJSON
		data1.select = {"populaca"}
		layer2:export(data1)
		local attrs1 = layer3:attributes()

		unitTest:assertEquals(attrs1[1].name, "FID")
		unitTest:assertEquals(attrs1[2].name, "populaca")
		unitTest:assertNil(attrs1[3])

		-- SELECT TWO ATTRIBUTES TO SHAPE
		data2.select = {"populaca", "nomemeso"}
		layer2:export(data2)
		local attrs2 = layer4:attributes()

		unitTest:assertEquals(attrs2[1].name, "FID")
		unitTest:assertEquals(attrs2[2].name, "populaca")
		unitTest:assertEquals(attrs2[3].name, "nomemeso")
		unitTest:assertNil(attrs2[4])

		File(geojson):delete()
		File(shp):delete()
		proj.file:delete()

		pgData.table = tableName
		TerraLib().dropPgTable(pgData)
	end,
	simplify = function(unitTest)
		local projName = "layer_postgis_basic.tview"

		if File(projName):exists() then -- TODO: (#1442)
			File(projName):delete()
		end

		local proj = Project {
			file = projName,
			clean = true
		}

		local filePath1 = filePath("test/rails.shp", "terralib")

		local layerName1 = "ES_Rails"
		local layer1 = Layer{
			project = proj,
			name = layerName1,
			file = filePath1
		}

		local password = getConfig().password
		local database = "postgis_22_sample"
		local tableName = string.lower(layerName1)

		local pgData = {
			source = "postgis",
			password = password,
			database = database,
			overwrite = true,
			epsg = 4036
		}

		layer1:export(pgData)

		local layerName2 = "ES_Rails_Pg"
		local layer2 = Layer{
			project = proj,
			source = "postgis",
			name = layerName2,
			password = password,
			database = database,
			table = tableName
		}

		local outputName = "spl_"..tableName
		local data = {
			output = outputName,
			tolerance = 500
		}

		layer2:simplify(data)

		local layerName3 = "ES_Rails_Spl"
		local layer3 = Layer{
			project = proj,
			source = "postgis",
			name = layerName3,
			password = password,
			database = database,
			table = outputName
		}

		local attrs = layer3:attributes()
		unitTest:assertEquals("fid", attrs[1].name)
		unitTest:assertEquals("observacao", attrs[4].name)
		unitTest:assertEquals("produtos", attrs[7].name)
		unitTest:assertEquals("operadora", attrs[10].name)
		unitTest:assertEquals("bitola_ext", attrs[13].name)
		unitTest:assertEquals("cod_pnv", attrs[15].name)

		pgData.table = tableName
		TerraLib().dropPgTable(pgData)
		pgData.table = outputName
		TerraLib().dropPgTable(pgData)
		proj.file:delete()
	end
}

