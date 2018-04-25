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
	getLayerInfo = function(unitTest)
		-- see in other functions e.g. addPgLayer() --
		unitTest:assert(true)
	end,
	addPgLayer = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local fromData = {}
		fromData.project = proj
		fromData.layer = layerName1

		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = getConfig().password
		local database = "terralib_pg_test"
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

		TerraLib().saveDataAs(fromData, pgData, true)

		local layerName2 = "SampaPg"
		TerraLib().addPgLayer(proj, layerName2, pgData, nil, encoding)

		local layerInfo = TerraLib().getLayerInfo(proj, layerName2)

		unitTest:assertEquals(layerInfo.name, layerName2)
		unitTest:assertEquals(layerInfo.type, "POSTGIS")
		unitTest:assertEquals(layerInfo.rep, "polygon")
		unitTest:assertEquals(layerInfo.host, host)
		unitTest:assertEquals(layerInfo.port, port)
		unitTest:assertEquals(layerInfo.user, user)
		unitTest:assertEquals(layerInfo.password, password)
		unitTest:assertEquals(layerInfo.database, database)
		unitTest:assertEquals(layerInfo.table, tableName)

		-- CHANGE SRID
		local layerName3 = "SampaNewSrid"
		TerraLib().addPgLayer(proj, layerName3, pgData, 29901, encoding)

		local layerInfo3 = TerraLib().getLayerInfo(proj, layerName3)

		unitTest:assertEquals(layerInfo3.srid, 29901.0)
		unitTest:assert(layerInfo3.srid ~= layerInfo.srid)
		-- // CHANGE SRID

		proj.file:delete()
		TerraLib().dropPgTable(pgData)
		TerraLib().dropPgDatabase(pgData)
	end,
	dropPgTable = function(unitTest)
		-- see in addPgLayer() test --
		unitTest:assert(true)
	end,
	dropPgDatabase = function(unitTest)
		-- see in addPgLayer() test --
		unitTest:assert(true)
	end,
	addPgCellSpaceLayer = function(unitTest)
		local createProject = function()
			local proj = {
				file = "addpgcellspacelayer_pg_basic.tview",
				title = "TerraLib Tests",
				author = "Avancini Rodrigo"
			}
			File(proj.file):deleteIfExists()
			TerraLib().createProject(proj, {})
			return proj
		end

		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
		local database = "terralib_pg_test"
		local encoding = "CP1252"

		local creatingFromShape = function()
			local proj = createProject()
			local layerName1 = "SampaShp"
			local layerFile1 = filePath("test/sampa.shp", "gis")
			TerraLib().addShpLayer(proj, layerName1, layerFile1)
			local layerInfo1 = TerraLib().getLayerInfo(proj, layerName1)

			local tableName = "sampa_cells"

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

			TerraLib().dropPgDatabase(pgData)

			local clName1 = "SampaPgCells"
			local resolution = 1
			local mask = true
			TerraLib().addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)

			local layerInfo = TerraLib().getLayerInfo(proj, clName1)
			unitTest:assertEquals(layerInfo.name, clName1)
			unitTest:assertEquals(layerInfo.type, "POSTGIS")
			unitTest:assertEquals(layerInfo.rep, "polygon")
			unitTest:assertEquals(layerInfo.host, host)
			unitTest:assertEquals(layerInfo.port, port)
			unitTest:assertEquals(layerInfo.user, user)
			unitTest:assertEquals(layerInfo.password, password)
			unitTest:assertEquals(layerInfo.database, database)
			unitTest:assertEquals(layerInfo.table, tableName)
			unitTest:assertEquals(layerInfo.srid, layerInfo1.srid)

			-- NO MASK TEST
			local clSetSize = TerraLib().getLayerSize(proj, clName1)
			unitTest:assertEquals(clSetSize, 37)

			clName1 = clName1.."_NoMask"
			local pgData2 = pgData
			pgData2.tableName = clName1

			TerraLib().dropPgTable(pgData2)

			mask = false
			TerraLib().addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData2, mask)

			clSetSize = TerraLib().getLayerSize(proj, clName1)
			unitTest:assertEquals(clSetSize, 54)

			proj.file:delete()
			TerraLib().dropPgTable(pgData)
			TerraLib().dropPgTable(pgData2)
		end

		local creatingFromTif = function()
			local proj = createProject()

			local layerName1 = "AmazoniaTif"
			local layerFile1 = filePath("amazonia-prodes.tif", "gis")
			TerraLib().addGdalLayer(proj, layerName1, layerFile1, 29191)

			local tableName = "amzcs"

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

			TerraLib().dropPgDatabase(pgData)

			local clName1 = "Amazonia_PG_Cells"
			local resolution = 3e5
			local mask = true

			local maskNotWork = function()
				TerraLib().addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)
			end

			unitTest:assertWarning(maskNotWork, "The 'mask' not work to Raster, it was ignored.")

			local layerInfo = TerraLib().getLayerInfo(proj, clName1)
			unitTest:assertEquals(layerInfo.name, clName1)
			unitTest:assertEquals(layerInfo.type, "POSTGIS")
			unitTest:assertEquals(layerInfo.rep, "polygon")
			unitTest:assertEquals(layerInfo.host, host)
			unitTest:assertEquals(layerInfo.port, port)
			unitTest:assertEquals(layerInfo.user, user)
			unitTest:assertEquals(layerInfo.password, password)
			unitTest:assertEquals(layerInfo.database, database)
			unitTest:assertEquals(layerInfo.table, tableName)

			local clSetSize = TerraLib().getLayerSize(proj, clName1)
			unitTest:assertEquals(clSetSize, 108)

			TerraLib().dropPgTable(pgData)
			proj.file:delete()
		end

		unitTest:assert(creatingFromShape)
		unitTest:assert(creatingFromTif)

		local pgConnInfo = {
			host = host,
			port = port,
			user = user,
			password = password,
			database = database
		}

		TerraLib().dropPgDatabase(pgConnInfo)
	end,
	attributeFill = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()
		-- CREATE A PROJECT
		TerraLib().createProject(proj, {})

		-- CREATE A LAYER THAT WILL BE USED AS REFERENCE TO CREATE THE CELLULAR SPACE
		local layerName1 = "Para"
		local layerFile1 = filePath("test/limitePA_polyc_pol.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = getConfig().password
		local database = "postgis_22_sample" -- TODO: REVIEW TEST WITH NEW DATABASE (PROBLEM IN DROP)
		local encoding = "CP1252"
		local tableName = "para_cells"

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

		-- CREATE THE CELLULAR SPACE
		local clName = "Para_Cells"
		local resolution = 5e5
		local mask = true
		TerraLib().addPgCellSpaceLayer(proj, layerName1, clName, resolution, pgData, mask)

		local clSet = TerraLib().getDataSet{project = proj, layer = clName}

		unitTest:assertEquals(getn(clSet), 9)

		for k, v in pairs(clSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom"))
			unitTest:assertNotNil(v)
		end

		-- CREATE A LAYER WITH POLYGONS TO DO OPERATIONS
		local layerName2 = "Protection_Unit"
		local layerFile2 = filePath("test/BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "gis")
		TerraLib().addShpLayer(proj, layerName2, layerFile2)

		-- POSTGIS OUTPUT
		-- FILL CELLULAR SPACE WITH PRESENCE OPERATION
		local presLayerName = clName.."_"..layerName2.."_Presence"

		pgData.table = string.lower(presLayerName)
		TerraLib().dropPgTable(pgData)

		local operation = "presence"
		local attribute = "presence"
		local select = "FID"
		local area = nil
		local default = nil
		TerraLib().attributeFill(proj, layerName2, clName, presLayerName, attribute, operation, select, area, default)

		local presSet = TerraLib().getDataSet{project = proj, layer = presLayerName}

		unitTest:assertEquals(getn(presSet), 9)

		for k, v in pairs(presSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or (k == "presence"))
			unitTest:assertNotNil(v)
		end

		local presLayerInfo = TerraLib().getLayerInfo(proj, presLayerName)
		unitTest:assertEquals(presLayerInfo.name, presLayerName)
		unitTest:assertEquals(presLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(presLayerInfo.rep, "polygon")
		unitTest:assertEquals(presLayerInfo.host, host)
		unitTest:assertEquals(presLayerInfo.port, port)
		unitTest:assertEquals(presLayerInfo.user, user)
		unitTest:assertEquals(presLayerInfo.password, password)
		unitTest:assertEquals(presLayerInfo.database, database)
		unitTest:assertEquals(presLayerInfo.table, string.lower(presLayerName))

		-- FILL CELLULAR SPACE WITH PERCENTAGE TOTAL AREA OPERATION
		local areaLayerName = clName.."_"..layerName2.."_Area"

		pgData.table = string.lower(areaLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "area"
		attribute = "area_percent"
		select = "FID"
		area = nil
		default = 0
		TerraLib().attributeFill(proj, layerName2, presLayerName, areaLayerName, attribute, operation, select, area, default)

		local areaSet = TerraLib().getDataSet{project = proj, layer = areaLayerName}

		unitTest:assertEquals(getn(areaSet), 9)

		for k, v in pairs(areaSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") )
			unitTest:assertNotNil(v)
		end

		local areaLayerInfo = TerraLib().getLayerInfo(proj, areaLayerName)
		unitTest:assertEquals(areaLayerInfo.name, areaLayerName)
		unitTest:assertEquals(areaLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(areaLayerInfo.rep, "polygon")
		unitTest:assertEquals(areaLayerInfo.host, host)
		unitTest:assertEquals(areaLayerInfo.port, port)
		unitTest:assertEquals(areaLayerInfo.user, user)
		unitTest:assertEquals(areaLayerInfo.password, password)
		unitTest:assertEquals(areaLayerInfo.database, database)
		unitTest:assertEquals(areaLayerInfo.table, string.lower(areaLayerName))

		-- FILL CELLULAR SPACE WITH COUNT OPERATION
		local countLayerName = clName.."_"..layerName2.."_Count"

		pgData.table = string.lower(countLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "count"
		attribute = "count"
		select = "FID"
		area = nil
		default = 0
		TerraLib().attributeFill(proj, layerName2, areaLayerName, countLayerName, attribute, operation, select, area, default)

		local countSet = TerraLib().getDataSet{project = proj, layer = countLayerName}

		unitTest:assertEquals(getn(countSet), 9)

		for k, v in pairs(countSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count"))
			unitTest:assertNotNil(v)
		end

		local countLayerInfo = TerraLib().getLayerInfo(proj, countLayerName)
		unitTest:assertEquals(countLayerInfo.name, countLayerName)
		unitTest:assertEquals(countLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(countLayerInfo.rep, "polygon")
		unitTest:assertEquals(countLayerInfo.host, host)
		unitTest:assertEquals(countLayerInfo.port, port)
		unitTest:assertEquals(countLayerInfo.user, user)
		unitTest:assertEquals(countLayerInfo.password, password)
		unitTest:assertEquals(countLayerInfo.database, database)
		unitTest:assertEquals(countLayerInfo.table, string.lower(countLayerName))

		-- FILL CELLULAR SPACE WITH DISTANCE OPERATION
		local distLayerName = clName.."_"..layerName2.."_Distance"

		pgData.table = string.lower(distLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "distance"
		attribute = "distance"
		select = "FID"
		area = nil
		default = nil
		TerraLib().attributeFill(proj, layerName2, countLayerName, distLayerName, attribute, operation, select, area, default)

		local distSet = TerraLib().getDataSet{project = proj, layer = distLayerName}

		unitTest:assertEquals(getn(distSet), 9)

		for k, v in pairs(distSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance"))
			unitTest:assertNotNil(v)
		end

		local distLayerInfo = TerraLib().getLayerInfo(proj, distLayerName)
		unitTest:assertEquals(distLayerInfo.name, distLayerName)
		unitTest:assertEquals(distLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(distLayerInfo.rep, "polygon")
		unitTest:assertEquals(distLayerInfo.host, host)
		unitTest:assertEquals(distLayerInfo.port, port)
		unitTest:assertEquals(distLayerInfo.user, user)
		unitTest:assertEquals(distLayerInfo.password, password)
		unitTest:assertEquals(distLayerInfo.database, database)
		unitTest:assertEquals(distLayerInfo.table, string.lower(distLayerName))

		-- FILL CELLULAR SPACE WITH MINIMUM OPERATION
		local layerName3 = "Amazon_Munic"
		local layerFile3 = filePath("test/municipiosAML_ok.shp", "gis")
		TerraLib().addShpLayer(proj, layerName3, layerFile3)

		local minLayerName = clName.."_"..layerName3.."_Minimum"

		pgData.table = string.lower(minLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "minimum"
		attribute = "minimum"
		select = "POPULACAO_"
		area = nil
		default = nil
		TerraLib().attributeFill(proj, layerName3, distLayerName, minLayerName, attribute, operation, select, area, default)

		local minSet = TerraLib().getDataSet{project = proj, layer = minLayerName}

		unitTest:assertEquals(getn(minSet), 9)

		for k, v in pairs(minSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum"))
			unitTest:assertNotNil(v)
		end

		local minLayerInfo = TerraLib().getLayerInfo(proj, minLayerName)
		unitTest:assertEquals(minLayerInfo.name, minLayerName)
		unitTest:assertEquals(minLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(minLayerInfo.rep, "polygon")
		unitTest:assertEquals(minLayerInfo.host, host)
		unitTest:assertEquals(minLayerInfo.port, port)
		unitTest:assertEquals(minLayerInfo.user, user)
		unitTest:assertEquals(minLayerInfo.password, password)
		unitTest:assertEquals(minLayerInfo.database, database)
		unitTest:assertEquals(minLayerInfo.table, string.lower(minLayerName))

		-- FILL CELLULAR SPACE WITH MAXIMUM OPERATION
		local maxLayerName = clName.."_"..layerName3.."_Maximum"

		pgData.table = string.lower(maxLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "maximum"
		attribute = "maximum"
		select = "POPULACAO_"
		area = nil
		default = nil
		TerraLib().attributeFill(proj, layerName3, minLayerName, maxLayerName, attribute, operation, select, area, default)

		local maxSet = TerraLib().getDataSet{project = proj, layer = maxLayerName}

		unitTest:assertEquals(getn(maxSet), 9)

		for k, v in pairs(maxSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum"))
			unitTest:assertNotNil(v)
		end

		local maxLayerInfo = TerraLib().getLayerInfo(proj, maxLayerName)
		unitTest:assertEquals(maxLayerInfo.name, maxLayerName)
		unitTest:assertEquals(maxLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(maxLayerInfo.rep, "polygon")
		unitTest:assertEquals(maxLayerInfo.host, host)
		unitTest:assertEquals(maxLayerInfo.port, port)
		unitTest:assertEquals(maxLayerInfo.user, user)
		unitTest:assertEquals(maxLayerInfo.password, password)
		unitTest:assertEquals(maxLayerInfo.database, database)
		unitTest:assertEquals(maxLayerInfo.table, string.lower(maxLayerName))

		-- FILL CELLULAR SPACE WITH PERCENTAGE OPERATION
		local percLayerName = clName.."_"..layerName2.."_Percentage"

		pgData.table = string.lower(percLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "coverage"
		attribute = "perc"
		select = "ADMINISTRA"
		area = nil
		default = nil
		TerraLib().attributeFill(proj, layerName2, maxLayerName, percLayerName, attribute, operation, select, area, default)

		local percentSet = TerraLib().getDataSet{project = proj, layer = percLayerName, missing = -1}

		unitTest:assertEquals(getn(percentSet), 9)

		local missCount = 0

		for k, v in pairs(percentSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil))
			unitTest:assertNotNil(v)

			if string.match(k, "perc_") then
				missCount = missCount + 1
			end
		end

		unitTest:assertEquals(missCount, 2)

		local percLayerInfo = TerraLib().getLayerInfo(proj, percLayerName)
		unitTest:assertEquals(percLayerInfo.name, percLayerName)
		unitTest:assertEquals(percLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(percLayerInfo.rep, "polygon")
		unitTest:assertEquals(percLayerInfo.host, host)
		unitTest:assertEquals(percLayerInfo.port, port)
		unitTest:assertEquals(percLayerInfo.user, user)
		unitTest:assertEquals(percLayerInfo.password, password)
		unitTest:assertEquals(percLayerInfo.database, database)
		unitTest:assertEquals(percLayerInfo.table, string.lower(percLayerName))

		-- FILL CELLULAR SPACE WITH STANDART DERIVATION OPERATION
		local stdevLayerName = clName.."_"..layerName3.."_Stdev"

		pgData.table = string.lower(stdevLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "stdev"
		attribute = "stdev"
		select = "POPULACAO_"
		area = nil
		default = nil
		TerraLib().attributeFill(proj, layerName3, percLayerName, stdevLayerName, attribute, operation, select, area, default)

		local stdevSet = TerraLib().getDataSet{project = proj, layer = stdevLayerName, missing = 0}

		unitTest:assertEquals(getn(stdevSet), 9)

		for k, v in pairs(stdevSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev"))
			unitTest:assertNotNil(v)
		end

		local stdevLayerInfo = TerraLib().getLayerInfo(proj, stdevLayerName)
		unitTest:assertEquals(stdevLayerInfo.name, stdevLayerName)
		unitTest:assertEquals(stdevLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(stdevLayerInfo.rep, "polygon")
		unitTest:assertEquals(stdevLayerInfo.host, host)
		unitTest:assertEquals(stdevLayerInfo.port, port)
		unitTest:assertEquals(stdevLayerInfo.user, user)
		unitTest:assertEquals(stdevLayerInfo.password, password)
		unitTest:assertEquals(stdevLayerInfo.database, database)
		unitTest:assertEquals(stdevLayerInfo.table, string.lower(stdevLayerName))

		-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION
		local meanLayerName = clName.."_"..layerName3.."_AvrgMean"

		pgData.table = string.lower(meanLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "average"
		attribute = "mean"
		select = "POPULACAO_"
		area = false
		default = nil
		TerraLib().attributeFill(proj, layerName3, stdevLayerName, meanLayerName, attribute, operation, select, area, default)

		local meanSet = TerraLib().getDataSet{project = proj, layer = meanLayerName, missing = 0}

		unitTest:assertEquals(getn(meanSet), 9)

		for k, v in pairs(meanSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean"))
			unitTest:assertNotNil(v)
		end

		local meanLayerInfo = TerraLib().getLayerInfo(proj, meanLayerName)
		unitTest:assertEquals(meanLayerInfo.name, meanLayerName)
		unitTest:assertEquals(meanLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(meanLayerInfo.rep, "polygon")
		unitTest:assertEquals(meanLayerInfo.host, host)
		unitTest:assertEquals(meanLayerInfo.port, port)
		unitTest:assertEquals(meanLayerInfo.user, user)
		unitTest:assertEquals(meanLayerInfo.password, password)
		unitTest:assertEquals(meanLayerInfo.database, database)
		unitTest:assertEquals(meanLayerInfo.table, string.lower(meanLayerName))

		-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION
		local weighLayerName = clName.."_"..layerName3.."_AvrgWeighted"

		pgData.table = string.lower(weighLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "average"
		attribute = "weighted"
		select = "POPULACAO_"
		area = true
		default = nil
		TerraLib().attributeFill(proj, layerName3, meanLayerName, weighLayerName, attribute, operation, select, area, default)

		local weighSet = TerraLib().getDataSet{project = proj, layer = weighLayerName, missing = 0}

		unitTest:assertEquals(getn(weighSet), 9)

		for k, v in pairs(weighSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted"))
			unitTest:assertNotNil(v)
		end

		local weighLayerInfo = TerraLib().getLayerInfo(proj, weighLayerName)
		unitTest:assertEquals(weighLayerInfo.name, weighLayerName)
		unitTest:assertEquals(weighLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(weighLayerInfo.rep, "polygon")
		unitTest:assertEquals(weighLayerInfo.host, host)
		unitTest:assertEquals(weighLayerInfo.port, port)
		unitTest:assertEquals(weighLayerInfo.user, user)
		unitTest:assertEquals(weighLayerInfo.password, password)
		unitTest:assertEquals(weighLayerInfo.database, database)
		unitTest:assertEquals(weighLayerInfo.table, string.lower(weighLayerName))

		-- FILL CELLULAR SPACE WITH MAJORITY INTERSECTION OPERATION
		local interLayerName = clName.."_"..layerName3.."_Intersection"

		pgData.table = string.lower(interLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "mode"
		attribute = "mode_int"
		select = "POPULACAO_"
		area = true
		default = nil
		TerraLib().attributeFill(proj, layerName3, weighLayerName, interLayerName, attribute, operation, select, area, default)

		local interSet = TerraLib().getDataSet{project = proj, layer = interLayerName, missing = 0}

		unitTest:assertEquals(getn(interSet), 9)

		for k, v in pairs(interSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int"))
			unitTest:assertNotNil(v)
		end

		local interLayerInfo = TerraLib().getLayerInfo(proj, interLayerName)
		unitTest:assertEquals(interLayerInfo.name, interLayerName)
		unitTest:assertEquals(interLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(interLayerInfo.rep, "polygon")
		unitTest:assertEquals(interLayerInfo.host, host)
		unitTest:assertEquals(interLayerInfo.port, port)
		unitTest:assertEquals(interLayerInfo.user, user)
		unitTest:assertEquals(interLayerInfo.password, password)
		unitTest:assertEquals(interLayerInfo.database, database)
		unitTest:assertEquals(interLayerInfo.table, string.lower(interLayerName))

		-- FILL CELLULAR SPACE WITH MAJORITY OCCURRENCE OPERATION
		local occurLayerName = clName.."_"..layerName3.."_Occurence"

		pgData.table = string.lower(occurLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "mode"
		attribute = "mode_occur"
		select = "POPULACAO_"
		area = false
		default = nil
		TerraLib().attributeFill(proj, layerName3, interLayerName, occurLayerName, attribute, operation, select, area, default)

		local occurSet = TerraLib().getDataSet{project = proj, layer = occurLayerName, missing = 0}

		unitTest:assertEquals(getn(occurSet), 9)

		for k, v in pairs(occurSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur"))
			unitTest:assertNotNil(v)
		end

		local occurLayerInfo = TerraLib().getLayerInfo(proj, occurLayerName)
		unitTest:assertEquals(occurLayerInfo.name, occurLayerName)
		unitTest:assertEquals(occurLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(occurLayerInfo.rep, "polygon")
		unitTest:assertEquals(occurLayerInfo.host, host)
		unitTest:assertEquals(occurLayerInfo.port, port)
		unitTest:assertEquals(occurLayerInfo.user, user)
		unitTest:assertEquals(occurLayerInfo.password, password)
		unitTest:assertEquals(occurLayerInfo.database, database)
		unitTest:assertEquals(occurLayerInfo.table, string.lower(occurLayerName))

		-- FILL CELLULAR SPACE WITH SUM OPERATION
		local sumLayerName = clName.."_"..layerName3.."_Sum"

		pgData.table = string.lower(sumLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "sum"
		attribute = "sum"
		select = "POPULACAO_"
		area = false
		default = nil
		TerraLib().attributeFill(proj, layerName3, occurLayerName, sumLayerName, attribute, operation, select, area, default)

		local sumSet = TerraLib().getDataSet{project = proj, layer = sumLayerName, missing = 0}

		unitTest:assertEquals(getn(sumSet), 9)

		for k, v in pairs(sumSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur") or
							(k == "sum"))
			unitTest:assertNotNil(v)
		end

		local sumLayerInfo = TerraLib().getLayerInfo(proj, sumLayerName)
		unitTest:assertEquals(sumLayerInfo.name, sumLayerName)
		unitTest:assertEquals(sumLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(sumLayerInfo.rep, "polygon")
		unitTest:assertEquals(sumLayerInfo.host, host)
		unitTest:assertEquals(sumLayerInfo.port, port)
		unitTest:assertEquals(sumLayerInfo.user, user)
		unitTest:assertEquals(sumLayerInfo.password, password)
		unitTest:assertEquals(sumLayerInfo.database, database)
		unitTest:assertEquals(sumLayerInfo.table, string.lower(sumLayerName))

		-- FILL CELLULAR SPACE WITH WEIGHTED SUM OPERATION
		local wsumLayerName = clName.."_"..layerName3.."_Wsum"

		pgData.table = string.lower(wsumLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "sum"
		attribute = "wsum"
		select = "POPULACAO_"
		area = true
		default = nil
		TerraLib().attributeFill(proj, layerName3, sumLayerName, wsumLayerName, attribute, operation, select, area, default)

		local wsumSet = TerraLib().getDataSet{project = proj, layer = wsumLayerName, missing = 0}

		unitTest:assertEquals(getn(wsumSet), 9)

		for k, v in pairs(wsumSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur") or
							(k == "sum") or (k == "wsum"))
			unitTest:assertNotNil(v)
		end

		local wsumLayerInfo = TerraLib().getLayerInfo(proj, wsumLayerName)
		unitTest:assertEquals(wsumLayerInfo.name, wsumLayerName)
		unitTest:assertEquals(wsumLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(wsumLayerInfo.rep, "polygon")
		unitTest:assertEquals(wsumLayerInfo.host, host)
		unitTest:assertEquals(wsumLayerInfo.port, port)
		unitTest:assertEquals(wsumLayerInfo.user, user)
		unitTest:assertEquals(wsumLayerInfo.password, password)
		unitTest:assertEquals(wsumLayerInfo.database, database)
		unitTest:assertEquals(wsumLayerInfo.table, string.lower(wsumLayerName))

		-- RASTER TESTS WITH POSTGIS
		-- FILL CELLULAR SPACE WITH PERCENTAGE OPERATION USING TIF
		local layerName4 = "Prodes_PA"
		local layerFile4 = filePath("test/prodes_polyc_10k.tif", "gis")
		TerraLib().addGdalLayer(proj, layerName4, layerFile4, wsumLayerInfo.srid)

		local percTifLayerName = clName.."_"..layerName4.."_RPercentage"

		pgData.table = string.lower(percTifLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "coverage"
		attribute = "rperc"
		select = 0
		area = nil
		default = nil
		TerraLib().attributeFill(proj, layerName4, wsumLayerName, percTifLayerName, attribute, operation, select, area, default)

		percentSet = TerraLib().getDataSet{project = proj, layer = percTifLayerName, missing = 0}

		unitTest:assertEquals(getn(percentSet), 9)

		for k, v in pairs(percentSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur") or
							(k == "sum") or (k == "wsum") or (string.match(k, "rperc_") ~= nil))
			unitTest:assertNotNil(v)
		end

		local percTifLayerInfo = TerraLib().getLayerInfo(proj, percTifLayerName)
		unitTest:assertEquals(percTifLayerInfo.name, percTifLayerName)
		unitTest:assertEquals(percTifLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(percTifLayerInfo.rep, "polygon")
		unitTest:assertEquals(percTifLayerInfo.host, host)
		unitTest:assertEquals(percTifLayerInfo.port, port)
		unitTest:assertEquals(percTifLayerInfo.user, user)
		unitTest:assertEquals(percTifLayerInfo.password, password)
		unitTest:assertEquals(percTifLayerInfo.database, database)
		unitTest:assertEquals(percTifLayerInfo.table, string.lower(percTifLayerName))

		-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION FROM RASTER
		local rmeanLayerName = clName.."_"..layerName4.."_RMean"

		pgData.table = string.lower(rmeanLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "average"
		attribute = "rmean"
		select = 0
		area = nil
		default = nil
		TerraLib().attributeFill(proj, layerName4, percTifLayerName, rmeanLayerName, attribute, operation, select, area, default)

		local rmeanSet = TerraLib().getDataSet{project = proj, layer = rmeanLayerName, missing = 0}

		unitTest:assertEquals(getn(rmeanSet), 9)

		for k, v in pairs(rmeanSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur") or
							(k == "sum") or (k == "wsum") or (string.match(k, "rperc_") ~= nil) or
							(k == "rmean"))
			unitTest:assertNotNil(v)
		end

		local rmeanLayerInfo = TerraLib().getLayerInfo(proj, rmeanLayerName)
		unitTest:assertEquals(rmeanLayerInfo.name, rmeanLayerName)
		unitTest:assertEquals(rmeanLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(rmeanLayerInfo.rep, "polygon")
		unitTest:assertEquals(rmeanLayerInfo.host, host)
		unitTest:assertEquals(rmeanLayerInfo.port, port)
		unitTest:assertEquals(rmeanLayerInfo.user, user)
		unitTest:assertEquals(rmeanLayerInfo.password, password)
		unitTest:assertEquals(rmeanLayerInfo.database, database)
		unitTest:assertEquals(rmeanLayerInfo.table, string.lower(rmeanLayerName))

		-- FILL CELLULAR SPACE WITH MINIMUM OPERATION FROM RASTER
		local rminLayerName = clName.."_"..layerName4.."_RMinimum"

		pgData.table = string.lower(rminLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "minimum"
		attribute = "rmin"
		select = 0
		area = nil
		default = nil
		TerraLib().attributeFill(proj, layerName4, rmeanLayerName, rminLayerName, attribute, operation, select, area, default)

		local rminSet = TerraLib().getDataSet{project = proj, layer = rminLayerName, missing = 0}

		unitTest:assertEquals(getn(rminSet), 9)

		for k, v in pairs(rminSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur") or
							(k == "sum") or (k == "wsum") or (string.match(k, "rperc_") ~= nil) or
							(k == "rmean") or (k == "rmin"))
			unitTest:assertNotNil(v)
		end

		local rminLayerInfo = TerraLib().getLayerInfo(proj, rminLayerName)
		unitTest:assertEquals(rminLayerInfo.name, rminLayerName)
		unitTest:assertEquals(rminLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(rminLayerInfo.rep, "polygon")
		unitTest:assertEquals(rminLayerInfo.host, host)
		unitTest:assertEquals(rminLayerInfo.port, port)
		unitTest:assertEquals(rminLayerInfo.user, user)
		unitTest:assertEquals(rminLayerInfo.password, password)
		unitTest:assertEquals(rminLayerInfo.database, database)
		unitTest:assertEquals(rminLayerInfo.table, string.lower(rminLayerName))

		-- FILL CELLULAR SPACE WITH MAXIMUM OPERATION FROM RASTER
		local rmaxLayerName = clName.."_"..layerName4.."_RMaximum"

		pgData.table = string.lower(rmaxLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "maximum"
		attribute = "rmax"
		select = 0
		area = nil
		default = nil
		TerraLib().attributeFill(proj, layerName4, rminLayerName, rmaxLayerName, attribute, operation, select, area, default)

		local rmaxSet = TerraLib().getDataSet{project = proj, layer = rmaxLayerName, missing = 0}

		unitTest:assertEquals(getn(rmaxSet), 9)

		for k, v in pairs(rmaxSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur") or
							(k == "sum") or (k == "wsum") or (string.match(k, "rperc_") ~= nil) or
							(k == "rmean") or (k == "rmin") or (k == "rmax"))
			unitTest:assertNotNil(v)
		end

		local rmaxLayerInfo = TerraLib().getLayerInfo(proj, rmaxLayerName)
		unitTest:assertEquals(rmaxLayerInfo.name, rmaxLayerName)
		unitTest:assertEquals(rmaxLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(rmaxLayerInfo.rep, "polygon")
		unitTest:assertEquals(rmaxLayerInfo.host, host)
		unitTest:assertEquals(rmaxLayerInfo.port, port)
		unitTest:assertEquals(rmaxLayerInfo.user, user)
		unitTest:assertEquals(rmaxLayerInfo.password, password)
		unitTest:assertEquals(rmaxLayerInfo.database, database)
		unitTest:assertEquals(rmaxLayerInfo.table, string.lower(rmaxLayerName))

		-- FILL CELLULAR SPACE WITH STANDART DERIVATION OPERATION FROM RASTER
		local rstdevLayerName = clName.."_"..layerName4.."_RStdev"

		pgData.table = string.lower(rstdevLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "stdev"
		attribute = "rstdev"
		select = 0
		area = nil
		default = nil
		TerraLib().attributeFill(proj, layerName4, rmaxLayerName, rstdevLayerName, attribute, operation, select, area, default)

		local rstdevSet = TerraLib().getDataSet{project = proj, layer = rstdevLayerName, missing = 0}

		unitTest:assertEquals(getn(rstdevSet), 9)

		for k, v in pairs(rstdevSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur") or
							(k == "sum") or (k == "wsum") or (string.match(k, "rperc_") ~= nil) or
							(k == "rmean") or (k == "rmin") or (k == "rmax") or (k == "rstdev"))
			unitTest:assertNotNil(v)
		end

		local rstdevLayerInfo = TerraLib().getLayerInfo(proj, rstdevLayerName)
		unitTest:assertEquals(rstdevLayerInfo.name, rstdevLayerName)
		unitTest:assertEquals(rstdevLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(rstdevLayerInfo.rep, "polygon")
		unitTest:assertEquals(rstdevLayerInfo.host, host)
		unitTest:assertEquals(rstdevLayerInfo.port, port)
		unitTest:assertEquals(rstdevLayerInfo.user, user)
		unitTest:assertEquals(rstdevLayerInfo.password, password)
		unitTest:assertEquals(rstdevLayerInfo.database, database)
		unitTest:assertEquals(rstdevLayerInfo.table, string.lower(rstdevLayerName))

		-- FILL CELLULAR SPACE WITH SUM OPERATION FROM RASTER
		local rsumLayerName = clName.."_"..layerName4.."_RSum"

		pgData.table = string.lower(rsumLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "sum"
		attribute = "rsum"
		select = 0
		area = nil
		default = nil
		TerraLib().attributeFill(proj, layerName4, rstdevLayerName, rsumLayerName, attribute, operation, select, area, default)

		local rsumSet = TerraLib().getDataSet{project = proj, layer = rsumLayerName, missing = 0}

		unitTest:assertEquals(getn(rsumSet), 9)

		for k, v in pairs(rsumSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur") or
							(k == "sum") or (k == "wsum") or (string.match(k, "rperc_") ~= nil) or
							(k == "rmean") or (k == "rmin") or (k == "rmax") or (k == "rstdev") or
							(k == "rsum"))
			unitTest:assertNotNil(v)
		end

		local rsumLayerInfo = TerraLib().getLayerInfo(proj, rsumLayerName)
		unitTest:assertEquals(rsumLayerInfo.name, rsumLayerName)
		unitTest:assertEquals(rsumLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(rsumLayerInfo.rep, "polygon")
		unitTest:assertEquals(rsumLayerInfo.host, host)
		unitTest:assertEquals(rsumLayerInfo.port, port)
		unitTest:assertEquals(rsumLayerInfo.user, user)
		unitTest:assertEquals(rsumLayerInfo.password, password)
		unitTest:assertEquals(rsumLayerInfo.database, database)
		unitTest:assertEquals(rsumLayerInfo.table, string.lower(rsumLayerName))

		-- OVERWRITE OUTPUT
		operation = "sum"
		attribute = "rsum_over"
		select = 0
		area = nil
		default = 0
		TerraLib().attributeFill(proj, layerName4, rsumLayerName, nil, attribute, operation, select, area, default)

		local rsumOverSet = TerraLib().getDataSet{project = proj, layer = rsumLayerName, missing = 0}

		unitTest:assertEquals(getn(rsumOverSet), 9)

		for k, v in pairs(rsumOverSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur") or
							(k == "sum") or (k == "wsum") or (string.match(k, "rperc_") ~= nil) or
							(k == "rmean") or (k == "rmin") or (k == "rmax") or (k == "rstdev") or
							(k == "rsum") or (k == "rsum_over"))
			unitTest:assertNotNil(v)
		end

		local rsumOverLayerInfo = TerraLib().getLayerInfo(proj, rsumLayerName)
		unitTest:assertEquals(rsumOverLayerInfo.name, rsumLayerName)
		unitTest:assertEquals(rsumOverLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(rsumOverLayerInfo.rep, "polygon")
		unitTest:assertEquals(rsumOverLayerInfo.host, host)
		unitTest:assertEquals(rsumOverLayerInfo.port, port)
		unitTest:assertEquals(rsumOverLayerInfo.user, user)
		unitTest:assertEquals(rsumOverLayerInfo.password, password)
		unitTest:assertEquals(rsumOverLayerInfo.database, database)
		unitTest:assertEquals(rsumOverLayerInfo.table, string.lower(rsumLayerName))

		-- FILL CELLULAR SPACE WITH COUNT OPERATION FROM RASTER
		local rcountLayerName = clName.."_"..layerName4.."_RCount"

		pgData.table = string.lower(rcountLayerName)
		TerraLib().dropPgTable(pgData)

		operation = "count"
		attribute = "rcount"
		select = 0
		area = nil
		default = nil
		TerraLib().attributeFill(proj, layerName4, rsumLayerName, rcountLayerName, attribute, operation, select, area, default)

		local rcountSet = TerraLib().getDataSet{project = proj, layer = rcountLayerName, missing = 0}

		unitTest:assertEquals(getn(rcountSet), 9)

		for k, v in pairs(rcountSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur") or
							(k == "sum") or (k == "wsum") or (string.match(k, "rperc_") ~= nil) or
							(k == "rmean") or (k == "rmin") or (k == "rmax") or (k == "rstdev") or
							(k == "rsum") or (k == "rsum_over") or (k == "rcount"))
			unitTest:assertNotNil(v)
		end

		local rcountLayerInfo = TerraLib().getLayerInfo(proj, rcountLayerName)
		unitTest:assertEquals(rcountLayerInfo.name, rcountLayerName)
		unitTest:assertEquals(rcountLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(rcountLayerInfo.rep, "polygon")
		unitTest:assertEquals(rcountLayerInfo.host, host)
		unitTest:assertEquals(rcountLayerInfo.port, port)
		unitTest:assertEquals(rcountLayerInfo.user, user)
		unitTest:assertEquals(rcountLayerInfo.password, password)
		unitTest:assertEquals(rcountLayerInfo.database, database)
		unitTest:assertEquals(rcountLayerInfo.table, string.lower(rcountLayerName))

		-- END
		pgData.table = string.lower(clName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(presLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(areaLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(countLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(distLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(minLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(maxLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(percLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(stdevLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(meanLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(weighLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(interLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(occurLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(sumLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(wsumLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(percTifLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(rmeanLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(rminLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(rmaxLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(rstdevLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(rsumLayerName)
		TerraLib().dropPgTable(pgData)
		pgData.table = string.lower(rcountLayerName)
		TerraLib().dropPgTable(pgData)
		-- END POSTGIS TESTS

		proj.file:delete()
	end,
	getDataSet = function(unitTest)
		-- see in saveDataSet() test --
		unitTest:assert(true)
	end,
	saveDataSet = function(unitTest)
		local proj = {
			file = "myproject.tview",
			title = "TerraLib Tests",
			author = "Avancini Rodrigo"
		}

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		-- // create a database
		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
		local database = "terralib_save_test"
		local encoding = "CP1252"
		local tableName = "sampa_cells"

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

		TerraLib().dropPgDatabase(pgData)

		local clName1 = "SampaPgCells"
		local resolution = 1
		local mask = true
		TerraLib().addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)

		local dSet = TerraLib().getDataSet{project = proj, layer = clName1}

		unitTest:assertEquals(getn(dSet), 37)

		for i = 0, #dSet do
			for k, v in pairs(dSet[i]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom"))
				unitTest:assertNotNil(v)
			end
		end

		local attrNames = TerraLib().getPropertyNames(proj, clName1)
		unitTest:assertEquals("id", attrNames[0])
		unitTest:assertEquals("col", attrNames[1])
		unitTest:assertEquals("row", attrNames[2])

		local luaTable = {}

		for i = 0, #dSet do
			local data = dSet[i]
			data.attr1 = i
			data.attr2 = "test"..i
			data.attr3 = (i % 2) == 0
			table.insert(luaTable, dSet[i])
		end

		local newLayerName = "New_Layer"

		TerraLib().saveDataSet(proj, clName1, luaTable, newLayerName, {"attr1", "attr2", "attr3"})

		local newDSet = TerraLib().getDataSet{project = proj, layer = newLayerName}

		unitTest:assertEquals(getn(newDSet), 37)

		for i = 0, #newDSet do
			unitTest:assertEquals(newDSet[i].attr1, i)
			for k, v in pairs(newDSet[i]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
								(k == "attr1") or (k == "attr2") or (k == "attr3"))

				if k == "attr1" then
					unitTest:assertEquals(type(v), "number")
				elseif k == "attr2" then
					unitTest:assertEquals(type(v), "string")
				elseif k == "attr3" then
					unitTest:assertEquals(type(v), "boolean")
				end
			end
		end

		attrNames = TerraLib().getPropertyNames(proj, newLayerName)
		unitTest:assertEquals("id", attrNames[0])
		unitTest:assertEquals("col", attrNames[1])
		unitTest:assertEquals("row", attrNames[2])
		unitTest:assertEquals("geom", attrNames[3])	-- TODO(avancinirodrigo): why cell space does not return geom?
		unitTest:assertEquals("attr1", attrNames[4])
		unitTest:assertEquals("attr2", attrNames[5])
		unitTest:assertEquals("attr3", attrNames[6])

		TerraLib().saveDataSet(proj, clName1, luaTable, newLayerName, {"attr1"})
		newDSet = TerraLib().getDataSet{project = proj, layer = newLayerName}

		unitTest:assertEquals(getn(newDSet), 37)

		for i = 0, #newDSet do
			unitTest:assertEquals(newDSet[i].attr1, i)
			for k, v in pairs(newDSet[i]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
								(k == "attr1"))

				if k == "attr1" then
					unitTest:assertEquals(type(v), "number")
				end
			end
		end

		attrNames = TerraLib().getPropertyNames(proj, newLayerName)
		unitTest:assertEquals("id", attrNames[0])
		unitTest:assertEquals("col", attrNames[1])
		unitTest:assertEquals("row", attrNames[2])
		unitTest:assertEquals("geom", attrNames[3])
		unitTest:assertEquals("attr1", attrNames[4])

		-- SAVE POLYGONS, POINTS AND LINES THAT ARE NOT CELLSPACE SPACE
		-- POLYGONS
		local polName = "ES_Limit"
		local polFile = filePath("test/limite_es_poly_wgs84.shp", "gis")
		TerraLib().addShpLayer(proj, polName, polFile)

		local fromData = {}
		fromData.project = proj
		fromData.layer = polName

		pgData.srid = 4326
		local polTable = "limite_es_poly_wgs84"
		pgData.table = polTable

		TerraLib().saveDataAs(fromData, pgData, true)

		local polDset = TerraLib().getDataSet{project = proj, layer = polName}
		local polLuaTable = {}
		for i = 0, getn(polDset) - 1 do
			local data = polDset[i]
			data.attr1 = i
			table.insert(polLuaTable, polDset[i])
		end

		polName = "ES_Limit_Pg"
		TerraLib().addPgLayer(proj, polName, pgData, nil, encoding)

		attrNames = TerraLib().getPropertyNames(proj, polName)
		unitTest:assertEquals("fid", attrNames[0])
		unitTest:assertEquals("gm_layer", attrNames[1])
		unitTest:assertEquals("gm_type", attrNames[2])
		unitTest:assertEquals("layer", attrNames[3])
		unitTest:assertEquals("nm_estado", attrNames[4])
		unitTest:assertEquals("nm_regiao", attrNames[5])
		unitTest:assertEquals("cd_geocuf", attrNames[6])
		unitTest:assertEquals("nm_uf", attrNames[7])

		local newPolName = "ES_Limit_New"
		TerraLib().saveDataSet(proj, polName, polLuaTable, newPolName, {"attr1"})

		local newPolDsetSize = TerraLib().getLayerSize(proj, newPolName)
		unitTest:assertEquals(newPolDsetSize, 1)
		unitTest:assertEquals(newPolDsetSize, getn(polDset))

		attrNames = TerraLib().getPropertyNames(proj, newPolName)
		unitTest:assertEquals("fid", attrNames[0])
		unitTest:assertEquals("gm_layer", attrNames[1])
		unitTest:assertEquals("gm_type", attrNames[2])
		unitTest:assertEquals("layer", attrNames[3])
		unitTest:assertEquals("nm_estado", attrNames[4])
		unitTest:assertEquals("nm_regiao", attrNames[5])
		unitTest:assertEquals("cd_geocuf", attrNames[6])
		unitTest:assertEquals("nm_uf", attrNames[7])
		unitTest:assertEquals("attr1", attrNames[9])

		-- POINTS
		local ptName = "BR_Ports"
		local ptFile = filePath("test/ports.shp", "gis")
		TerraLib().addShpLayer(proj, ptName, ptFile)

		local ptTable = "ports"
		pgData.table = ptTable
		fromData.layer = ptName
		TerraLib().saveDataAs(fromData, pgData, true)

		local ptDset = TerraLib().getDataSet{project = proj, layer = ptName, missing = 0}
		local ptLuaTable = {}
		for i = 0, getn(ptDset) - 1 do
			local data = ptDset[i]
			data.attr1 = i
			table.insert(ptLuaTable, ptDset[i])
		end

		ptName = "BR_Ports_Pg"
		TerraLib().addPgLayer(proj, ptName, pgData, nil, encoding)

		attrNames = TerraLib().getPropertyNames(proj, ptName)
		unitTest:assertEquals("fid", attrNames[0])
		unitTest:assertEquals("tipo", attrNames[5])
		unitTest:assertEquals("gestao", attrNames[10])
		unitTest:assertEquals("pro_didade", attrNames[15])
		unitTest:assertEquals("cep", attrNames[20])
		unitTest:assertEquals("idr_rafica", attrNames[25])
		unitTest:assertEquals("observacao", attrNames[30])
		unitTest:assertEquals("cdc_troide", attrNames[32])

		local newPtName = "BR_Ports_New"
		TerraLib().saveDataSet(proj, ptName, ptLuaTable, newPtName, {"attr1"})

		local newPtDset = TerraLib().getDataSet{project = proj, layer = newPtName, missing = 0}
		unitTest:assertEquals(getn(newPtDset), 8)
		unitTest:assertEquals(getn(newPtDset), getn(ptDset))

		attrNames = TerraLib().getPropertyNames(proj, newPtName)
		unitTest:assertEquals("fid", attrNames[0])
		unitTest:assertEquals("tipo", attrNames[5])
		unitTest:assertEquals("gestao", attrNames[10])
		unitTest:assertEquals("pro_didade", attrNames[15])
		unitTest:assertEquals("cep", attrNames[20])
		unitTest:assertEquals("idr_rafica", attrNames[25])
		unitTest:assertEquals("observacao", attrNames[30])
		unitTest:assertEquals("cdc_troide", attrNames[32])
		unitTest:assertEquals("attr1", attrNames[34])

		-- CHANGING INTEGER DATA AND OVERWRITE LAYER
		local numSum1 = 0
		local newPtLuaTable = {}
		for i = 0, getn(newPtDset) - 1 do
			local data = newPtDset[i]
			numSum1 = numSum1 + data.numero
			data.numero = data.numero * 2
			table.insert(newPtLuaTable, newPtDset[i])
		end
		TerraLib().saveDataSet(proj, newPtName, newPtLuaTable, newPtName, {"numero"})

		newPtDset = TerraLib().getDataSet{project = proj, layer = newPtName, missing = 0}
		local numSum2 = 0
		for i = 0, getn(newPtDset) - 1 do
			local data = newPtDset[i]
			numSum2 = numSum2 + data.numero
		end

		unitTest:assertEquals(numSum2, 2 * numSum1)

		-- CHANGING INTEGER AND CREATE A NEW LAYER
		local newPtName2 = "BR_Ports_New2"
		newPtLuaTable = {}
		for i = 0, getn(newPtDset) - 1 do
			local data = newPtDset[i]
			data.numbkp = data.numero
			data.numero = data.numero * 2
			table.insert(newPtLuaTable, newPtDset[i])
		end
		TerraLib().saveDataSet(proj, newPtName, newPtLuaTable, newPtName2, {"numero", "numbkp"})

		local newPtDset2 = TerraLib().getDataSet{project = proj, layer = newPtName2, missing = 0}
		local numSum3 = 0
		local numBkpSum = 0
		for i = 0, getn(newPtDset2) - 1 do
			local data = newPtDset2[i]
			numSum3 = numSum3 + data.numero
			numBkpSum = numBkpSum + data.numbkp
		end

		unitTest:assertEquals(numSum3, 4 * numSum1)
		unitTest:assertEquals(numSum3, 2 * numBkpSum)

		-- LINES
		local lnName = "ES_Rails"
		local lnFile = filePath("test/rails.shp", "gis")
		TerraLib().addShpLayer(proj, lnName, lnFile)

		local lnTable = "rails"
		pgData.table = lnTable
		fromData.layer = lnName
		TerraLib().saveDataAs(fromData, pgData, true)

		local lnDset = TerraLib().getDataSet{project = proj, layer = lnName, missing = 0}
		local lnLuaTable = {}
		for i = 0, getn(lnDset) - 1 do
			local data = lnDset[i]
			data.attr1 = i
			table.insert(lnLuaTable, lnDset[i])
		end

		lnName = "ES_Rails_Pg"
		TerraLib().addPgLayer(proj, lnName, pgData, nil, encoding)

		attrNames = TerraLib().getPropertyNames(proj, lnName)
		unitTest:assertEquals("fid", attrNames[0])
		unitTest:assertEquals("observacao", attrNames[3])
		unitTest:assertEquals("produtos", attrNames[6])
		unitTest:assertEquals("operadora", attrNames[9])
		unitTest:assertEquals("bitola_ext", attrNames[12])
		unitTest:assertEquals("cod_pnv", attrNames[14])

		local newLnName = "ES_Rails_New"
		TerraLib().saveDataSet(proj, lnName, lnLuaTable, newLnName, {"attr1"})

		local newLnDsetSize = TerraLib().getLayerSize(proj, newLnName)
		unitTest:assertEquals(newLnDsetSize, 182)
		unitTest:assertEquals(newLnDsetSize, getn(lnDset))

		attrNames = TerraLib().getPropertyNames(proj, newLnName)
		unitTest:assertEquals("fid", attrNames[0])
		unitTest:assertEquals("observacao", attrNames[3])
		unitTest:assertEquals("produtos", attrNames[6])
		unitTest:assertEquals("operadora", attrNames[9])
		unitTest:assertEquals("bitola_ext", attrNames[12])
		unitTest:assertEquals("cod_pnv", attrNames[14])
		unitTest:assertEquals("attr1", attrNames[16])

		-- ADD NEW ATTRIBUTE AND UPDATE A OLD
		lnLuaTable = {}
		for i = 0, getn(lnDset) - 1 do
			local data = lnDset[i]
			data.attr1 = i + 1000
			data.attr2 = "test"..i
			data.attr3 = (i % 2) == 0
			table.insert(lnLuaTable, lnDset[i])
		end

		TerraLib().saveDataSet(proj, newLnName, lnLuaTable, newLnName, {"attr1", "attr2", "attr3"})
		attrNames = TerraLib().getPropertyNames(proj, newLnName)
		unitTest:assertEquals("fid", attrNames[0])
		unitTest:assertEquals("observacao", attrNames[3])
		unitTest:assertEquals("produtos", attrNames[6])
		unitTest:assertEquals("operadora", attrNames[9])
		unitTest:assertEquals("bitola_ext", attrNames[12])
		unitTest:assertEquals("cod_pnv", attrNames[14])
		unitTest:assertEquals("attr1", attrNames[16])
		unitTest:assertEquals("attr2", attrNames[17])
		unitTest:assertEquals("attr3", attrNames[18])

		-- ADD NEW ATTRIBUTE AND UPDATE THREE OLD
		lnLuaTable = {}
		for i = 0, getn(lnDset) - 1 do
			local data = lnDset[i]
			data.attr1 = i + 1000
			data.attr2 = "test"..i
			data.attr3 = (i % 2) == 0
			data.attr4 = data.attr1 * 2
			table.insert(lnLuaTable, lnDset[i])
		end

		TerraLib().saveDataSet(proj, newLnName, lnLuaTable, newLnName, {"attr1", "attr2", "attr3", "attr4"})
		attrNames = TerraLib().getPropertyNames(proj, newLnName)
		unitTest:assertEquals("fid", attrNames[0])
		unitTest:assertEquals("observacao", attrNames[3])
		unitTest:assertEquals("produtos", attrNames[6])
		unitTest:assertEquals("operadora", attrNames[9])
		unitTest:assertEquals("bitola_ext", attrNames[12])
		unitTest:assertEquals("cod_pnv", attrNames[14])
		unitTest:assertEquals("attr1", attrNames[16])
		unitTest:assertEquals("attr2", attrNames[17])
		unitTest:assertEquals("attr3", attrNames[18])
		unitTest:assertEquals("attr4", attrNames[19])

		-- ONLY UPDATE SOME ATTRIBUTE
		lnLuaTable = {}
		for i = 0, getn(lnDset) - 1 do
			local data = lnDset[i]
			data.attr1 = i - 1000
			table.insert(lnLuaTable, lnDset[i])
		end

		TerraLib().saveDataSet(proj, newLnName, lnLuaTable, newLnName, {"attr1"})
		attrNames = TerraLib().getPropertyNames(proj, newLnName)
		unitTest:assertEquals("fid", attrNames[0])
		unitTest:assertEquals("observacao", attrNames[3])
		unitTest:assertEquals("produtos", attrNames[6])
		unitTest:assertEquals("operadora", attrNames[9])
		unitTest:assertEquals("bitola_ext", attrNames[12])
		unitTest:assertEquals("cod_pnv", attrNames[14])
		unitTest:assertEquals("attr1", attrNames[16])
		unitTest:assertEquals("attr2", attrNames[17])
		unitTest:assertEquals("attr3", attrNames[18])

		-- UPDATE MORE ATTRIBUTES
		lnLuaTable = {}
		for i = 0, getn(lnDset) - 1 do
			local data = lnDset[i]
			data.attr1 = i + 5000
			data.attr2 = i.."data.attr2"
			data.attr3 = ((i % 2) == 0) and data.attr3
			table.insert(lnLuaTable, lnDset[i])
		end

		TerraLib().saveDataSet(proj, newLnName, lnLuaTable, newLnName, {"attr1", "attr2", "attr3"})
		attrNames = TerraLib().getPropertyNames(proj, newLnName)
		unitTest:assertEquals("fid", attrNames[0])
		unitTest:assertEquals("observacao", attrNames[3])
		unitTest:assertEquals("produtos", attrNames[6])
		unitTest:assertEquals("operadora", attrNames[9])
		unitTest:assertEquals("bitola_ext", attrNames[12])
		unitTest:assertEquals("cod_pnv", attrNames[14])
		unitTest:assertEquals("attr1", attrNames[16])
		unitTest:assertEquals("attr2", attrNames[17])
		unitTest:assertEquals("attr3", attrNames[18])
		unitTest:assertEquals("attr4", attrNames[19])

		proj.file:delete()
		TerraLib().dropPgDatabase(pgData)
	end,
	getArea = function(unitTest)
		local proj = {
			file = "myproject.tview",
			title = "TerraLib Tests",
			author = "Avancini Rodrigo"
		}

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = getConfig().password
		local database = "terralib_save_test"
		local encoding = "CP1252"
		local tableName = "sampa_cells"

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

		TerraLib().dropPgDatabase(pgData)

		local clName1 = "SampaPgCells"
		local resolution = 1
		local mask = true
		TerraLib().addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)

		local dSet = TerraLib().getDataSet{project = proj, layer = clName1}
		local area = TerraLib().getArea(dSet[0].geom)
		unitTest:assertEquals(type(area), "number")
		unitTest:assertEquals(area, 1, 0.001)

		for i = 1, #dSet do
			for k, v in pairs(dSet[i]) do
				if k == "geom" then
					unitTest:assertEquals(area, TerraLib().getArea(v), 0.001)
				end
			end
		end

		proj.file:delete()
		TerraLib().dropPgDatabase(pgData)
	end,
	getProjection = function(unitTest)
		local proj = {
			file = "myproject.tview",
			title = "TerraLib Tests",
			author = "Avancini Rodrigo"
		}

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "SetoresShp"
		local layerFile1 = filePath("itaituba-census.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
		local database = "terralib_projection_test"
		local encoding = "CP1252"
		local tableName = "setores_cells"

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

		TerraLib().dropPgDatabase(pgData)

		local clName1 = "SetoresPgCells"
		local resolution = 5e3
		local mask = true
		TerraLib().addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)

		local prj = TerraLib().getProjection(proj.layers[clName1])

		unitTest:assertEquals(prj.SRID, 29191.0)
		unitTest:assertEquals(prj.NAME, "SAD69 / UTM zone 21S")
		unitTest:assertEquals(prj.PROJ4, "+proj=utm +zone=21 +south +ellps=aust_SA +towgs84=-66.87,4.37,-38.52,0,0,0,0 +units=m +no_defs ")

		proj.file:delete()
		TerraLib().dropPgTable(pgData)
		TerraLib().dropPgDatabase(pgData)
	end,
	getPropertyNames = function(unitTest)
		local proj = {
			file = "myproject.tview",
			title = "TerraLib Tests",
			author = "Avancini Rodrigo"
		}

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "SetoresShp"
		local layerFile1 = filePath("itaituba-census.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
		local database = "terralib_projection_test"
		local encoding = "CP1252"
		local tableName = "setores_cells"

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

		TerraLib().dropPgDatabase(pgData)

		local clName1 = "SetoresPgCells"
		local resolution = 5e3
		local mask = true
		TerraLib().addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)

		local propNames = TerraLib().getPropertyNames(proj, clName1)

		for i = 0, #propNames do
			unitTest:assert((propNames[i] == "id") or (propNames[i] == "geom") or
						(propNames[i] == "col") or (propNames[i] == "row"))
		end

		proj.file:delete()
		TerraLib().dropPgTable(pgData)
		TerraLib().dropPgDatabase(pgData)
	end,
	getPropertyInfos = function(unitTest)
		local proj = {
			file = "tlib_pg_bas.tview",
			title = "TerraLib Tests",
			author = "Avancini Rodrigo"
		}

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "SetoresShp"
		local layerFile1 = filePath("itaituba-census.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local fromData = {}
		fromData.project = proj
		fromData.layer = layerName1

		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
		local database = "postgis_22_sample"
		local encoding = "CP1252"
		local tableName = "setores_cells"

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

		TerraLib().saveDataAs(fromData, pgData, true)
		local layerName2 = "PgLayer"
		TerraLib().addPgLayer(proj, layerName2, pgData, nil, encoding)

		local propInfos = TerraLib().getPropertyInfos(proj, layerName2)

		unitTest:assertEquals(getn(propInfos), 4)
		unitTest:assertEquals(propInfos[0].name, "fid")
		unitTest:assertEquals(propInfos[0].type, "integer 32")
		unitTest:assertEquals(propInfos[1].name, "population")
		unitTest:assertEquals(propInfos[1].type, "double")
		unitTest:assertEquals(propInfos[2].name, "dens_pop")
		unitTest:assertEquals(propInfos[2].type, "double")
		unitTest:assertEquals(propInfos[3].name, "ogr_geometry")
		unitTest:assertEquals(propInfos[3].type, "geometry")

		proj.file:delete()
		TerraLib().dropPgTable(pgData)
	end,
	getDistance = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		-- // create a database
		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
		local database = "terralib_distance_test"
		local encoding = "CP1252"
		local tableName = "sampa_cells"

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

		TerraLib().dropPgDatabase(pgData)

		local clName1 = "SampaPgCells"
		local resolution = 1
		local mask = true
		TerraLib().addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)

		local dSet = TerraLib().getDataSet{project = proj, layer = clName1}
		local dist = TerraLib().getDistance(dSet[0].geom, dSet[getn(dSet) - 1].geom)

		unitTest:assertEquals(dist, 4.1231056256177, 1.0e-13)

		proj.file:delete()
		TerraLib().dropPgTable(pgData)
		TerraLib().dropPgDatabase(pgData)
	end,
	saveDataAs = function(unitTest)
		local sampaLayerName = "SampaShp"
		local createProjectWithSampaLayer = function()
			local proj = {
				file = "saveDataAs_postgis_basic.tview",
				title = "TerraLib Tests",
				author = "Avancini Rodrigo"
			}
			File(proj.file):deleteIfExists()
			TerraLib().createProject(proj, {})
			TerraLib().addShpLayer(proj, sampaLayerName, filePath("test/sampa.shp", "gis"))
			return proj
		end

		-- POSTGIS
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = getConfig().password
		local database = "postgis_22_sample"
		local encoding = "CP1252"
		local tableName = "sampa"
		local srid = 4019

		local spPgData = {
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

		local exportToPostgis = function()
			local proj = createProjectWithSampaLayer()
			local fromData = {project = proj, layer = sampaLayerName}
			local overwrite = true
			TerraLib().saveDataAs(fromData, spPgData, overwrite)
		end

		exportToPostgis()

		local spPgLayerName = "SampaPg"
		local createPgProject = function()
			local proj = createProjectWithSampaLayer()
			TerraLib().addPgLayer(proj, spPgLayerName, spPgData, nil, encoding)
			return proj
		end

		local overwritePostgisFromShpAndChangeItsSrid = function()
			local proj = createPgProject()
			local fromData = {project = proj, layer = spPgLayerName}
			local info2 = TerraLib().getLayerInfo(proj, spPgLayerName)
			unitTest:assertEquals(info2.srid, 4019.0)

			local sridBkp = spPgData.srid
			spPgData.srid = 4326

			fromData.layer = sampaLayerName
			local overwrite = true
			TerraLib().saveDataAs(fromData, spPgData, overwrite)
			info2 = TerraLib().getLayerInfo(proj, spPgLayerName)
			unitTest:assertEquals(info2.srid, 4326.0)

			proj.file:delete()
			TerraLib().dropPgTable(spPgData)
			spPgData.srid = sridBkp
			exportToPostgis()
		end

		local postgisToShp = function()
			local proj = createPgProject()
			local fromData = {project = proj, layer = spPgLayerName}
			local toData = {file = File("postgis2shp.shp"), type = "shp"}

			local overwrite = true
			TerraLib().saveDataAs(fromData, toData, overwrite)
			unitTest:assert(toData.file:exists())

			-- OVERWRITE AND CHANGE SRID
			toData.srid = 4326
			TerraLib().saveDataAs(fromData, toData, overwrite)
			local layerName3 = "PG2SHP"
			TerraLib().addShpLayer(proj, layerName3, toData.file)
			local info3 = TerraLib().getLayerInfo(proj, layerName3)
			unitTest:assertEquals(info3.srid, toData.srid)

			proj.file:delete()
			toData.file:delete()
		end

		local postgisToGeoJson = function()
			local proj = createPgProject()
			local fromData = {project = proj, layer = spPgLayerName}
			local toData = {file = File("postgis2geojson.geojson"), type = "geojson"}
			local overwrite = true

			TerraLib().saveDataAs(fromData, toData, overwrite)
			unitTest:assert(toData.file:exists())

			-- OVERWRITE AND CHANGE SRID
			toData.srid = 4326
			TerraLib().saveDataAs(fromData, toData, overwrite)
			local layerName4 = "PG2GJ"
			TerraLib().addGeoJSONLayer(proj, layerName4, toData.file)
			local info4 = TerraLib().getLayerInfo(proj, layerName4)
			unitTest:assertEquals(info4.srid, toData.srid)

			proj.file:delete()
			toData.file:delete()
		end

		local overwritePostgisFromGeoJsonAndChangeItsSrid = function()
			local proj = createPgProject()
			local gjLayerName = "SampaGj"
			TerraLib().addGeoJSONLayer(proj, gjLayerName, filePath("test/sampa.geojson", "gis"))
			local fromData = {project = proj, layer = gjLayerName}

			local tableBkp = spPgData.table
			spPgData.table = "sampagj"
			local sridBkp = spPgData.srid

			local overwrite = true
			TerraLib().saveDataAs(fromData, spPgData, overwrite)

			local layerName5 = "PgLayerGJ"
			TerraLib().addPgLayer(proj, layerName5, spPgData, nil, encoding)
			local info5 = TerraLib().getLayerInfo(proj, layerName5)
			unitTest:assertEquals(info5.srid, 4019.0)

			spPgData.srid = 2309
			TerraLib().saveDataAs(fromData, spPgData, overwrite)
			info5 = TerraLib().getLayerInfo(proj, layerName5)
			unitTest:assertEquals(info5.srid, 2309.0)

			proj.file:delete()
			TerraLib().dropPgTable(spPgData)
			spPgData.table = tableBkp
			spPgData.srid = sridBkp
			exportToPostgis()
		end

		local saveJustOnePropertyFromShp = function()
			local proj = createPgProject()
			local fromData = {project = proj, layer = sampaLayerName}

			local tableBkp = spPgData.table
			spPgData.table = "shp2postgis"

			local overwrite = true
			TerraLib().saveDataAs(fromData, spPgData, overwrite, {"nm_micro"})

			local layerName6 = "SHP2PG"
			TerraLib().addPgLayer(proj, layerName6, spPgData, nil, encoding)
			local dset6 = TerraLib().getDataSet{project = proj, layer = layerName6}

			unitTest:assertEquals(getn(dset6), 63)

			for k, v in pairs(dset6[0]) do
				unitTest:assert(((k == "fid") and (v == 0)) or ((k == "ogr_geometry") and (v ~= nil) ) or
								((k == "nm_micro") and (v == "VOTUPORANGA")))
			end

			proj.file:delete()
			TerraLib().dropPgTable(spPgData)
			spPgData.table = tableBkp
		end

		local saveTwoPropertiesFromGeoJson = function()
			local proj = createPgProject()
			local gjLayerName = "SampaGj"
			TerraLib().addGeoJSONLayer(proj, gjLayerName, filePath("test/sampa.geojson", "gis"))
			local fromData = {project = proj, layer = gjLayerName}

			local tableBkp = spPgData.table
			spPgData.table = "geojson2postgis"

			local overwrite = true
			TerraLib().saveDataAs(fromData, spPgData, overwrite, {"nm_micro", "id"})

			local layerName7 = "GJ2PG"
			TerraLib().addPgLayer(proj, layerName7, spPgData, nil, encoding)
			local dset7 = TerraLib().getDataSet{project = proj, layer = layerName7}

			unitTest:assertEquals(getn(dset7), 63)

			for k, v in pairs(dset7[0]) do
				unitTest:assert(((k == "fid") and (v == 2)) or ((k == "ogr_geometry") and (v ~= nil) ) or
								((k == "nm_micro") and (v == "VOTUPORANGA")) or ((k == "id") and (v == 2)))
			end

			proj.file:delete()
			TerraLib().dropPgTable(spPgData)
			spPgData.table = tableBkp
		end

		-- SAVE DATA SUBSET TESTS
		local createSubsetTable = function()
			local proj = createPgProject()
			local dset2 = TerraLib().getDataSet{project = proj, layer = spPgLayerName}
			local sjc
			for i = 0, getn(dset2) - 1 do
				if dset2[i].id == 27 then
					sjc = dset2[i]
				end
			end

			local touches = {}
			local j = 1
			for i = 0, getn(dset2) - 1 do
				if sjc.ogr_geometry:touches(dset2[i].ogr_geometry) then
					touches[j] = dset2[i]
					j = j + 1
				end
			end

			proj.file:delete()

			return touches
		end

		local subset = createSubsetTable()

		local saveLayerSubset = function()
			local proj = createPgProject()
			local fromData = {project = proj, layer = spPgLayerName}

			local tableBkp = spPgData.table
			spPgData.table = "touches_sjc"

			local overwrite = true
			TerraLib().saveDataAs(fromData, spPgData, overwrite, {"nm_micro", "id"}, subset)

			local layerName8 = "SJC"
			TerraLib().addPgLayer(proj, layerName8, spPgData, nil, encoding)
			local tchsSjc = TerraLib().getDataSet{project = proj, layer = layerName8}

			unitTest:assertEquals(getn(tchsSjc), 2)
			unitTest:assertEquals(tchsSjc[0].id, 55)
			unitTest:assertEquals(tchsSjc[1].id, 109)

			proj.file:delete()
			TerraLib().dropPgTable(spPgData)
			spPgData.table = tableBkp
		end

		local saveSubsetWithoutLayer = function()
			local fromData = {file = filePath("test/sampa.shp", "gis")}

			local tableBkp = spPgData.table
			spPgData.table = "touches_sjc"

			for i = 1, #subset do
				subset[i].FID = subset[i].fid
			end

			local overwrite = true
			TerraLib().saveDataAs(fromData, spPgData, overwrite, {"NM_MICRO", "ID"}, subset)

			local proj = createPgProject()
			local layerName9 = "SJC2"
			TerraLib().addPgLayer(proj, layerName9, spPgData, nil, encoding)
			local tchsSjc2 = TerraLib().getDataSet{project = proj, layer = layerName9}

			unitTest:assertEquals(getn(tchsSjc2), 2)
			unitTest:assertEquals(tchsSjc2[0].id, 55)
			unitTest:assertEquals(tchsSjc2[1].id, 109)

			proj.file:delete()
			TerraLib().dropPgTable(spPgData)
			spPgData.table = tableBkp
		end

		unitTest:assert(overwritePostgisFromShpAndChangeItsSrid)
		unitTest:assert(postgisToShp)
		unitTest:assert(postgisToGeoJson)
		unitTest:assert(overwritePostgisFromGeoJsonAndChangeItsSrid)
		unitTest:assert(saveJustOnePropertyFromShp)
		unitTest:assert(saveTwoPropertiesFromGeoJson)
		unitTest:assert(saveLayerSubset)
		unitTest:assert(saveSubsetWithoutLayer)

		TerraLib().dropPgTable(spPgData)
	end,
	getLayerSize = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		local file = File(proj.file)
		file:deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "Sampa"
		local layerFile1 = filePath("test/sampa.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local fromData = {}
		fromData.project = proj
		fromData.layer = layerName1

		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = getConfig().password
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
			table = tableName, -- it is used only to drop
			encoding = encoding
		}

		local overwrite = true

		TerraLib().saveDataAs(fromData, pgData, overwrite)
		local layerName2 = "PgLayer"
		TerraLib().addPgLayer(proj, layerName2, pgData, nil, encoding)

		local size = TerraLib().getLayerSize(proj, layerName2)

		unitTest:assertEquals(size, 63.0)

		TerraLib().dropPgTable(pgData)

		unitTest:assert(true)
		file:delete()
	end,
	douglasPeucker = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		local file = File(proj.file)
		file:deleteIfExists()

		TerraLib().createProject(proj, {})

		local lnName = "ES_Rails"
		local lnFile = filePath("test/rails.shp", "gis")
		TerraLib().addShpLayer(proj, lnName, lnFile, nil, 29101)

		local fromData = {}
		fromData.project = proj
		fromData.layer = lnName

		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = getConfig().password
		local database = "postgis_22_sample"
		local encoding = "CP1252"
		local tableName = "rails"

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
		TerraLib().saveDataAs(fromData, pgData, overwrite)

		local layerName2 = "ES_Rails_Pg"
		TerraLib().addPgLayer(proj, layerName2, pgData, nil, encoding)

		local dpLayerName = "ES_Rails_Peucker"
		TerraLib().douglasPeucker(proj, layerName2, dpLayerName, 500)

		pgData.table = string.lower(dpLayerName)
		TerraLib().addPgLayer(proj, dpLayerName, pgData, nil, encoding)

		local dpSet = TerraLib().getDataSet{project = proj, layer = dpLayerName, missing = -1}
		unitTest:assertEquals(getn(dpSet), 182)

		local missingCount = 0
		for i = 0, getn(dpSet) - 1 do
			if dpSet[i].pnvcoin == -1 then
				missingCount = missingCount + 1
			end
		end

		unitTest:assertEquals(missingCount, 177)

		local attrNames = TerraLib().getPropertyNames(proj, dpLayerName)
		unitTest:assertEquals("fid", attrNames[0])
		unitTest:assertEquals("observacao", attrNames[3])
		unitTest:assertEquals("produtos", attrNames[6])
		unitTest:assertEquals("operadora", attrNames[9])
		unitTest:assertEquals("bitola_ext", attrNames[12])
		unitTest:assertEquals("cod_pnv", attrNames[14])

		TerraLib().dropPgTable(pgData)
		pgData.table = tableName
		TerraLib().dropPgTable(pgData)
		proj.file:delete()
	end,
	polygonize = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName = "TifLayer"
		local layerFile = filePath("emas-accumulation.tif", "gis")
		TerraLib().addGdalLayer(proj, layerName, layerFile, 29192)

		local inInfo = {
			project = proj,
			layer = layerName,
			band = 0,
		}

		local outInfo = {
			type = "postgis",
			host = "localhost",
			port = "5432",
			user = "postgres",
			password = "postgres",
			database = "postgis_22_sample",
			table = "polygonized",
			encoding = "LATIN1"
		}

		TerraLib().dropPgTable(outInfo)

		TerraLib().polygonize(inInfo, outInfo)

		local polyName = "Polygonized"
		TerraLib().addPgLayer(proj, polyName, outInfo, nil, outInfo.encoding)
		local dsetSize = TerraLib().getLayerSize(proj, polyName)

		unitTest:assertEquals(dsetSize, 381)

		local attrNames = TerraLib().getPropertyNames(proj, polyName)
		unitTest:assertEquals("id", attrNames[0])
		unitTest:assertEquals("value", attrNames[1])
		unitTest:assertEquals("geom", attrNames[2])

		proj.file:delete()
		TerraLib().dropPgTable(outInfo)
	end
}
