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
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)

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

		tl:saveLayerAs(proj, layerName1, pgData, true)

		local layerName2 = "SampaPg"
		tl:addPgLayer(proj, layerName2, pgData)

		local layerInfo = tl:getLayerInfo(proj, proj.layers[layerName2])

		unitTest:assertEquals(layerInfo.name, layerName2)
		unitTest:assertEquals(layerInfo.type, "POSTGIS")
		unitTest:assertEquals(layerInfo.rep, "polygon")
		unitTest:assertEquals(layerInfo.host, host)
		unitTest:assertEquals(layerInfo.port, port)
		unitTest:assertEquals(layerInfo.user, user)
		unitTest:assertEquals(layerInfo.password, password)
		unitTest:assertEquals(layerInfo.database, database)
		unitTest:assertEquals(layerInfo.table, tableName)
		unitTest:assertNotNil(layerInfo.sid)

		-- CHANGE SRID
		local layerName3 = "SampaNewSrid"
		tl:addPgLayer(proj, layerName3, pgData, 29901)

		local layerInfo3 = tl:getLayerInfo(proj, proj.layers[layerName3])

		unitTest:assertEquals(layerInfo3.srid, 29901.0)
		unitTest:assert(layerInfo3.srid ~= layerInfo.srid)
		-- // CHANGE SRID

		proj.file:delete()
		tl:dropPgTable(pgData)
		tl:dropPgDatabase(pgData)
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
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		-- // create a database
		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)

		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = getConfig().password
		local database = "terralib_pg_test"
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

		tl:dropPgDatabase(pgData)

		local clName1 = "SampaPgCells"
		local resolution = 1
		local mask = true
		tl:addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)

		local layerInfo = tl:getLayerInfo(proj, proj.layers[clName1])
		unitTest:assertEquals(layerInfo.name, clName1)
		unitTest:assertEquals(layerInfo.type, "POSTGIS")
		unitTest:assertEquals(layerInfo.rep, "polygon")
		unitTest:assertEquals(layerInfo.host, host)
		unitTest:assertEquals(layerInfo.port, port)
		unitTest:assertEquals(layerInfo.user, user)
		unitTest:assertEquals(layerInfo.password, password)
		unitTest:assertEquals(layerInfo.database, database)
		unitTest:assertEquals(layerInfo.table, tableName)
		unitTest:assertNotNil(layerInfo.sid)

		-- NO MASK TEST
		local clSet = tl:getDataSet(proj, clName1)
		unitTest:assertEquals(getn(clSet), 37)

		clName1 = clName1.."_NoMask"
		local pgData2 = pgData
		pgData2.tableName = clName1

		tl:dropPgTable(pgData2)

		mask = false
		tl:addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData2, mask)

		clSet = tl:getDataSet(proj, clName1)
		unitTest:assertEquals(getn(clSet), 54)

		proj.file:delete()
		tl:dropPgTable(pgData)
		tl:dropPgTable(pgData2)
		tl:dropPgDatabase(pgData)
	end,
	attributeFill = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()
		-- CREATE A PROJECT
		tl:createProject(proj, {})

		local customWarningBkp = customWarning
		customWarning = function(msg)
			return msg
		end

		-- CREATE A LAYER THAT WILL BE USED AS REFERENCE TO CREATE THE CELLULAR SPACE
		local layerName1 = "Para"
		local layerFile1 = filePath("test/limitePA_polyc_pol.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)

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

		tl:dropPgTable(pgData)

		-- CREATE THE CELLULAR SPACE
		local clName = "Para_Cells"
		local resolution = 5e5
		local mask = true
		tl:addPgCellSpaceLayer(proj, layerName1, clName, resolution, pgData, mask)

		local clSet = tl:getDataSet(proj, clName)

		unitTest:assertEquals(getn(clSet), 9)

		for k, v in pairs(clSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom"))
			unitTest:assertNotNil(v)
		end

		-- CREATE A LAYER WITH POLYGONS TO DO OPERATIONS
		local layerName2 = "Protection_Unit"
		local layerFile2 = filePath("test/BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "terralib")
		tl:addShpLayer(proj, layerName2, layerFile2)

		-- POSTGIS OUTPUT
		-- FILL CELLULAR SPACE WITH PRESENCE OPERATION
		local presLayerName = clName.."_"..layerName2.."_Presence"

		pgData.table = string.lower(presLayerName)
		tl:dropPgTable(pgData)

		local operation = "presence"
		local attribute = "presence"
		local select = "FID"
		local area = nil
		local default = nil
		tl:attributeFill(proj, layerName2, clName, presLayerName, attribute, operation, select, area, default)

		local presSet = tl:getDataSet(proj, presLayerName)

		unitTest:assertEquals(getn(presSet), 9)

		for k, v in pairs(presSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or (k == "presence"))
			unitTest:assertNotNil(v)
		end

		local presLayerInfo = tl:getLayerInfo(proj, proj.layers[presLayerName])
		unitTest:assertEquals(presLayerInfo.name, presLayerName)
		unitTest:assertEquals(presLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(presLayerInfo.rep, "polygon")
		unitTest:assertEquals(presLayerInfo.host, host)
		unitTest:assertEquals(presLayerInfo.port, port)
		unitTest:assertEquals(presLayerInfo.user, user)
		unitTest:assertEquals(presLayerInfo.password, password)
		unitTest:assertEquals(presLayerInfo.database, database)
		unitTest:assertEquals(presLayerInfo.table, string.lower(presLayerName))
		unitTest:assertNotNil(presLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH PERCENTAGE TOTAL AREA OPERATION
		local areaLayerName = clName.."_"..layerName2.."_Area"

		pgData.table = string.lower(areaLayerName)
		tl:dropPgTable(pgData)

		operation = "area"
		attribute = "area_percent"
		select = "FID"
		area = nil
		default = 0
		tl:attributeFill(proj, layerName2, presLayerName, areaLayerName, attribute, operation, select, area, default)

		local areaSet = tl:getDataSet(proj, areaLayerName)

		unitTest:assertEquals(getn(areaSet), 9)

		for k, v in pairs(areaSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") )
			unitTest:assertNotNil(v)
		end

		local areaLayerInfo = tl:getLayerInfo(proj, proj.layers[areaLayerName])
		unitTest:assertEquals(areaLayerInfo.name, areaLayerName)
		unitTest:assertEquals(areaLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(areaLayerInfo.rep, "polygon")
		unitTest:assertEquals(areaLayerInfo.host, host)
		unitTest:assertEquals(areaLayerInfo.port, port)
		unitTest:assertEquals(areaLayerInfo.user, user)
		unitTest:assertEquals(areaLayerInfo.password, password)
		unitTest:assertEquals(areaLayerInfo.database, database)
		unitTest:assertEquals(areaLayerInfo.table, string.lower(areaLayerName))
		unitTest:assertNotNil(areaLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH COUNT OPERATION
		local countLayerName = clName.."_"..layerName2.."_Count"

		pgData.table = string.lower(countLayerName)
		tl:dropPgTable(pgData)

		operation = "count"
		attribute = "count"
		select = "FID"
		area = nil
		default = 0
		tl:attributeFill(proj, layerName2, areaLayerName, countLayerName, attribute, operation, select, area, default)

		local countSet = tl:getDataSet(proj, countLayerName)

		unitTest:assertEquals(getn(countSet), 9)

		for k, v in pairs(countSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count"))
			unitTest:assertNotNil(v)
		end

		local countLayerInfo = tl:getLayerInfo(proj, proj.layers[countLayerName])
		unitTest:assertEquals(countLayerInfo.name, countLayerName)
		unitTest:assertEquals(countLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(countLayerInfo.rep, "polygon")
		unitTest:assertEquals(countLayerInfo.host, host)
		unitTest:assertEquals(countLayerInfo.port, port)
		unitTest:assertEquals(countLayerInfo.user, user)
		unitTest:assertEquals(countLayerInfo.password, password)
		unitTest:assertEquals(countLayerInfo.database, database)
		unitTest:assertEquals(countLayerInfo.table, string.lower(countLayerName))
		unitTest:assertNotNil(countLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH DISTANCE OPERATION
		local distLayerName = clName.."_"..layerName2.."_Distance"

		pgData.table = string.lower(distLayerName)
		tl:dropPgTable(pgData)

		operation = "distance"
		attribute = "distance"
		select = "FID"
		area = nil
		default = nil
		tl:attributeFill(proj, layerName2, countLayerName, distLayerName, attribute, operation, select, area, default)

		local distSet = tl:getDataSet(proj, distLayerName)

		unitTest:assertEquals(getn(distSet), 9)

		for k, v in pairs(distSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance"))
			unitTest:assertNotNil(v)
		end

		local distLayerInfo = tl:getLayerInfo(proj, proj.layers[distLayerName])
		unitTest:assertEquals(distLayerInfo.name, distLayerName)
		unitTest:assertEquals(distLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(distLayerInfo.rep, "polygon")
		unitTest:assertEquals(distLayerInfo.host, host)
		unitTest:assertEquals(distLayerInfo.port, port)
		unitTest:assertEquals(distLayerInfo.user, user)
		unitTest:assertEquals(distLayerInfo.password, password)
		unitTest:assertEquals(distLayerInfo.database, database)
		unitTest:assertEquals(distLayerInfo.table, string.lower(distLayerName))
		unitTest:assertNotNil(distLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH MINIMUM OPERATION
		local layerName3 = "Amazon_Munic"
		local layerFile3 = filePath("test/municipiosAML_ok.shp", "terralib")
		tl:addShpLayer(proj, layerName3, layerFile3)

		local minLayerName = clName.."_"..layerName3.."_Minimum"

		pgData.table = string.lower(minLayerName)
		tl:dropPgTable(pgData)

		operation = "minimum"
		attribute = "minimum"
		select = "POPULACAO_"
		area = nil
		default = nil
		tl:attributeFill(proj, layerName3, distLayerName, minLayerName, attribute, operation, select, area, default)

		local minSet = tl:getDataSet(proj, minLayerName)

		unitTest:assertEquals(getn(minSet), 9)

		for k, v in pairs(minSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum"))
			unitTest:assertNotNil(v)
		end

		local minLayerInfo = tl:getLayerInfo(proj, proj.layers[minLayerName])
		unitTest:assertEquals(minLayerInfo.name, minLayerName)
		unitTest:assertEquals(minLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(minLayerInfo.rep, "polygon")
		unitTest:assertEquals(minLayerInfo.host, host)
		unitTest:assertEquals(minLayerInfo.port, port)
		unitTest:assertEquals(minLayerInfo.user, user)
		unitTest:assertEquals(minLayerInfo.password, password)
		unitTest:assertEquals(minLayerInfo.database, database)
		unitTest:assertEquals(minLayerInfo.table, string.lower(minLayerName))
		unitTest:assertNotNil(minLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH MAXIMUM OPERATION
		local maxLayerName = clName.."_"..layerName3.."_Maximum"

		pgData.table = string.lower(maxLayerName)
		tl:dropPgTable(pgData)

		operation = "maximum"
		attribute = "maximum"
		select = "POPULACAO_"
		area = nil
		default = nil
		tl:attributeFill(proj, layerName3, minLayerName, maxLayerName, attribute, operation, select, area, default)

		local maxSet = tl:getDataSet(proj, maxLayerName)

		unitTest:assertEquals(getn(maxSet), 9)

		for k, v in pairs(maxSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum"))
			unitTest:assertNotNil(v)
		end

		local maxLayerInfo = tl:getLayerInfo(proj, proj.layers[maxLayerName])
		unitTest:assertEquals(maxLayerInfo.name, maxLayerName)
		unitTest:assertEquals(maxLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(maxLayerInfo.rep, "polygon")
		unitTest:assertEquals(maxLayerInfo.host, host)
		unitTest:assertEquals(maxLayerInfo.port, port)
		unitTest:assertEquals(maxLayerInfo.user, user)
		unitTest:assertEquals(maxLayerInfo.password, password)
		unitTest:assertEquals(maxLayerInfo.database, database)
		unitTest:assertEquals(maxLayerInfo.table, string.lower(maxLayerName))
		unitTest:assertNotNil(maxLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH PERCENTAGE OPERATION
		local percLayerName = clName.."_"..layerName2.."_Percentage"

		pgData.table = string.lower(percLayerName)
		tl:dropPgTable(pgData)

		operation = "coverage"
		attribute = "perc"
		select = "ADMINISTRA"
		area = nil
		default = nil
		tl:attributeFill(proj, layerName2, maxLayerName, percLayerName, attribute, operation, select, area, default)

		local percentSet = tl:getDataSet(proj, percLayerName)

		unitTest:assertEquals(getn(percentSet), 9)

		for k, v in pairs(percentSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil))
			unitTest:assertNotNil(v)
		end

		local percLayerInfo = tl:getLayerInfo(proj, proj.layers[percLayerName])
		unitTest:assertEquals(percLayerInfo.name, percLayerName)
		unitTest:assertEquals(percLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(percLayerInfo.rep, "polygon")
		unitTest:assertEquals(percLayerInfo.host, host)
		unitTest:assertEquals(percLayerInfo.port, port)
		unitTest:assertEquals(percLayerInfo.user, user)
		unitTest:assertEquals(percLayerInfo.password, password)
		unitTest:assertEquals(percLayerInfo.database, database)
		unitTest:assertEquals(percLayerInfo.table, string.lower(percLayerName))
		unitTest:assertNotNil(percLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH STANDART DERIVATION OPERATION
		local stdevLayerName = clName.."_"..layerName3.."_Stdev"

		pgData.table = string.lower(stdevLayerName)
		tl:dropPgTable(pgData)

		operation = "stdev"
		attribute = "stdev"
		select = "POPULACAO_"
		area = nil
		default = nil
		tl:attributeFill(proj, layerName3, percLayerName, stdevLayerName, attribute, operation, select, area, default)

		local stdevSet = tl:getDataSet(proj, stdevLayerName)

		unitTest:assertEquals(getn(stdevSet), 9)

		for k, v in pairs(stdevSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev"))
			unitTest:assertNotNil(v)
		end

		local stdevLayerInfo = tl:getLayerInfo(proj, proj.layers[stdevLayerName])
		unitTest:assertEquals(stdevLayerInfo.name, stdevLayerName)
		unitTest:assertEquals(stdevLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(stdevLayerInfo.rep, "polygon")
		unitTest:assertEquals(stdevLayerInfo.host, host)
		unitTest:assertEquals(stdevLayerInfo.port, port)
		unitTest:assertEquals(stdevLayerInfo.user, user)
		unitTest:assertEquals(stdevLayerInfo.password, password)
		unitTest:assertEquals(stdevLayerInfo.database, database)
		unitTest:assertEquals(stdevLayerInfo.table, string.lower(stdevLayerName))
		unitTest:assertNotNil(stdevLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION
		local meanLayerName = clName.."_"..layerName3.."_AvrgMean"

		pgData.table = string.lower(meanLayerName)
		tl:dropPgTable(pgData)

		operation = "average"
		attribute = "mean"
		select = "POPULACAO_"
		area = false
		default = nil
		tl:attributeFill(proj, layerName3, stdevLayerName, meanLayerName, attribute, operation, select, area, default)

		local meanSet = tl:getDataSet(proj, meanLayerName)

		unitTest:assertEquals(getn(meanSet), 9)

		for k, v in pairs(meanSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean"))
			unitTest:assertNotNil(v)
		end

		local meanLayerInfo = tl:getLayerInfo(proj, proj.layers[meanLayerName])
		unitTest:assertEquals(meanLayerInfo.name, meanLayerName)
		unitTest:assertEquals(meanLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(meanLayerInfo.rep, "polygon")
		unitTest:assertEquals(meanLayerInfo.host, host)
		unitTest:assertEquals(meanLayerInfo.port, port)
		unitTest:assertEquals(meanLayerInfo.user, user)
		unitTest:assertEquals(meanLayerInfo.password, password)
		unitTest:assertEquals(meanLayerInfo.database, database)
		unitTest:assertEquals(meanLayerInfo.table, string.lower(meanLayerName))
		unitTest:assertNotNil(meanLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION
		local weighLayerName = clName.."_"..layerName3.."_AvrgWeighted"

		pgData.table = string.lower(weighLayerName)
		tl:dropPgTable(pgData)

		operation = "average"
		attribute = "weighted"
		select = "POPULACAO_"
		area = true
		default = nil
		tl:attributeFill(proj, layerName3, meanLayerName, weighLayerName, attribute, operation, select, area, default)

		local weighSet = tl:getDataSet(proj, weighLayerName)

		unitTest:assertEquals(getn(weighSet), 9)

		for k, v in pairs(weighSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted"))
			unitTest:assertNotNil(v)
		end

		local weighLayerInfo = tl:getLayerInfo(proj, proj.layers[weighLayerName])
		unitTest:assertEquals(weighLayerInfo.name, weighLayerName)
		unitTest:assertEquals(weighLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(weighLayerInfo.rep, "polygon")
		unitTest:assertEquals(weighLayerInfo.host, host)
		unitTest:assertEquals(weighLayerInfo.port, port)
		unitTest:assertEquals(weighLayerInfo.user, user)
		unitTest:assertEquals(weighLayerInfo.password, password)
		unitTest:assertEquals(weighLayerInfo.database, database)
		unitTest:assertEquals(weighLayerInfo.table, string.lower(weighLayerName))
		unitTest:assertNotNil(weighLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH MAJORITY INTERSECTION OPERATION
		local interLayerName = clName.."_"..layerName3.."_Intersection"

		pgData.table = string.lower(interLayerName)
		tl:dropPgTable(pgData)

		operation = "mode"
		attribute = "mode_int"
		select = "POPULACAO_"
		area = true
		default = nil
		tl:attributeFill(proj, layerName3, weighLayerName, interLayerName, attribute, operation, select, area, default)

		local interSet = tl:getDataSet(proj, interLayerName)

		unitTest:assertEquals(getn(interSet), 9)

		for k, v in pairs(interSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int"))
			unitTest:assertNotNil(v)
		end

		local interLayerInfo = tl:getLayerInfo(proj, proj.layers[interLayerName])
		unitTest:assertEquals(interLayerInfo.name, interLayerName)
		unitTest:assertEquals(interLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(interLayerInfo.rep, "polygon")
		unitTest:assertEquals(interLayerInfo.host, host)
		unitTest:assertEquals(interLayerInfo.port, port)
		unitTest:assertEquals(interLayerInfo.user, user)
		unitTest:assertEquals(interLayerInfo.password, password)
		unitTest:assertEquals(interLayerInfo.database, database)
		unitTest:assertEquals(interLayerInfo.table, string.lower(interLayerName))
		unitTest:assertNotNil(interLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH MAJORITY OCCURRENCE OPERATION
		local occurLayerName = clName.."_"..layerName3.."_Occurence"

		pgData.table = string.lower(occurLayerName)
		tl:dropPgTable(pgData)

		operation = "mode"
		attribute = "mode_occur"
		select = "POPULACAO_"
		area = false
		default = nil
		tl:attributeFill(proj, layerName3, interLayerName, occurLayerName, attribute, operation, select, area, default)

		local occurSet = tl:getDataSet(proj, occurLayerName)

		unitTest:assertEquals(getn(occurSet), 9)

		for k, v in pairs(occurSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc_") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur"))
			unitTest:assertNotNil(v)
		end

		local occurLayerInfo = tl:getLayerInfo(proj, proj.layers[occurLayerName])
		unitTest:assertEquals(occurLayerInfo.name, occurLayerName)
		unitTest:assertEquals(occurLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(occurLayerInfo.rep, "polygon")
		unitTest:assertEquals(occurLayerInfo.host, host)
		unitTest:assertEquals(occurLayerInfo.port, port)
		unitTest:assertEquals(occurLayerInfo.user, user)
		unitTest:assertEquals(occurLayerInfo.password, password)
		unitTest:assertEquals(occurLayerInfo.database, database)
		unitTest:assertEquals(occurLayerInfo.table, string.lower(occurLayerName))
		unitTest:assertNotNil(occurLayerInfo.sid)


		-- FILL CELLULAR SPACE WITH SUM OPERATION
		local sumLayerName = clName.."_"..layerName3.."_Sum"

		pgData.table = string.lower(sumLayerName)
		tl:dropPgTable(pgData)

		operation = "sum"
		attribute = "sum"
		select = "POPULACAO_"
		area = false
		default = nil
		tl:attributeFill(proj, layerName3, occurLayerName, sumLayerName, attribute, operation, select, area, default)

		local sumSet = tl:getDataSet(proj, sumLayerName)

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

		local sumLayerInfo = tl:getLayerInfo(proj, proj.layers[sumLayerName])
		unitTest:assertEquals(sumLayerInfo.name, sumLayerName)
		unitTest:assertEquals(sumLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(sumLayerInfo.rep, "polygon")
		unitTest:assertEquals(sumLayerInfo.host, host)
		unitTest:assertEquals(sumLayerInfo.port, port)
		unitTest:assertEquals(sumLayerInfo.user, user)
		unitTest:assertEquals(sumLayerInfo.password, password)
		unitTest:assertEquals(sumLayerInfo.database, database)
		unitTest:assertEquals(sumLayerInfo.table, string.lower(sumLayerName))
		unitTest:assertNotNil(sumLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH WEIGHTED SUM OPERATION
		local wsumLayerName = clName.."_"..layerName3.."_Wsum"

		pgData.table = string.lower(wsumLayerName)
		tl:dropPgTable(pgData)

		operation = "sum"
		attribute = "wsum"
		select = "POPULACAO_"
		area = true
		default = nil
		tl:attributeFill(proj, layerName3, sumLayerName, wsumLayerName, attribute, operation, select, area, default)

		local wsumSet = tl:getDataSet(proj, wsumLayerName)

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

		local wsumLayerInfo = tl:getLayerInfo(proj, proj.layers[wsumLayerName])
		unitTest:assertEquals(wsumLayerInfo.name, wsumLayerName)
		unitTest:assertEquals(wsumLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(wsumLayerInfo.rep, "polygon")
		unitTest:assertEquals(wsumLayerInfo.host, host)
		unitTest:assertEquals(wsumLayerInfo.port, port)
		unitTest:assertEquals(wsumLayerInfo.user, user)
		unitTest:assertEquals(wsumLayerInfo.password, password)
		unitTest:assertEquals(wsumLayerInfo.database, database)
		unitTest:assertEquals(wsumLayerInfo.table, string.lower(wsumLayerName))
		unitTest:assertNotNil(wsumLayerInfo.sid)

		-- RASTER TESTS WITH POSTGIS
		-- FILL CELLULAR SPACE WITH PERCENTAGE OPERATION USING TIF
		local layerName4 = "Prodes_PA"
		local layerFile4 = filePath("test/prodes_polyc_10k.tif", "terralib")
		tl:addGdalLayer(proj, layerName4, layerFile4, wsumLayerInfo.srid)

		local percTifLayerName = clName.."_"..layerName4.."_RPercentage"

		pgData.table = string.lower(percTifLayerName)
		tl:dropPgTable(pgData)

		operation = "coverage"
		attribute = "rperc"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, wsumLayerName, percTifLayerName, attribute, operation, select, area, default)

		percentSet = tl:getDataSet(proj, percTifLayerName)

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

		local percTifLayerInfo = tl:getLayerInfo(proj, proj.layers[percTifLayerName])
		unitTest:assertEquals(percTifLayerInfo.name, percTifLayerName)
		unitTest:assertEquals(percTifLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(percTifLayerInfo.rep, "polygon")
		unitTest:assertEquals(percTifLayerInfo.host, host)
		unitTest:assertEquals(percTifLayerInfo.port, port)
		unitTest:assertEquals(percTifLayerInfo.user, user)
		unitTest:assertEquals(percTifLayerInfo.password, password)
		unitTest:assertEquals(percTifLayerInfo.database, database)
		unitTest:assertEquals(percTifLayerInfo.table, string.lower(percTifLayerName))
		unitTest:assertNotNil(percTifLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION FROM RASTER
		local rmeanLayerName = clName.."_"..layerName4.."_RMean"

		pgData.table = string.lower(rmeanLayerName)
		tl:dropPgTable(pgData)

		operation = "average"
		attribute = "rmean"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, percTifLayerName, rmeanLayerName, attribute, operation, select, area, default)

		local rmeanSet = tl:getDataSet(proj, rmeanLayerName)

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

		local rmeanLayerInfo = tl:getLayerInfo(proj, proj.layers[rmeanLayerName])
		unitTest:assertEquals(rmeanLayerInfo.name, rmeanLayerName)
		unitTest:assertEquals(rmeanLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(rmeanLayerInfo.rep, "polygon")
		unitTest:assertEquals(rmeanLayerInfo.host, host)
		unitTest:assertEquals(rmeanLayerInfo.port, port)
		unitTest:assertEquals(rmeanLayerInfo.user, user)
		unitTest:assertEquals(rmeanLayerInfo.password, password)
		unitTest:assertEquals(rmeanLayerInfo.database, database)
		unitTest:assertEquals(rmeanLayerInfo.table, string.lower(rmeanLayerName))
		unitTest:assertNotNil(rmeanLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH MINIMUM OPERATION FROM RASTER
		local rminLayerName = clName.."_"..layerName4.."_RMinimum"

		pgData.table = string.lower(rminLayerName)
		tl:dropPgTable(pgData)

		operation = "minimum"
		attribute = "rmin"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, rmeanLayerName, rminLayerName, attribute, operation, select, area, default)

		local rminSet = tl:getDataSet(proj, rminLayerName)

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

		local rminLayerInfo = tl:getLayerInfo(proj, proj.layers[rminLayerName])
		unitTest:assertEquals(rminLayerInfo.name, rminLayerName)
		unitTest:assertEquals(rminLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(rminLayerInfo.rep, "polygon")
		unitTest:assertEquals(rminLayerInfo.host, host)
		unitTest:assertEquals(rminLayerInfo.port, port)
		unitTest:assertEquals(rminLayerInfo.user, user)
		unitTest:assertEquals(rminLayerInfo.password, password)
		unitTest:assertEquals(rminLayerInfo.database, database)
		unitTest:assertEquals(rminLayerInfo.table, string.lower(rminLayerName))
		unitTest:assertNotNil(rminLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH MAXIMUM OPERATION FROM RASTER
		local rmaxLayerName = clName.."_"..layerName4.."_RMaximum"

		pgData.table = string.lower(rmaxLayerName)
		tl:dropPgTable(pgData)

		operation = "maximum"
		attribute = "rmax"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, rminLayerName, rmaxLayerName, attribute, operation, select, area, default)

		local rmaxSet = tl:getDataSet(proj, rmaxLayerName)

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

		local rmaxLayerInfo = tl:getLayerInfo(proj, proj.layers[rmaxLayerName])
		unitTest:assertEquals(rmaxLayerInfo.name, rmaxLayerName)
		unitTest:assertEquals(rmaxLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(rmaxLayerInfo.rep, "polygon")
		unitTest:assertEquals(rmaxLayerInfo.host, host)
		unitTest:assertEquals(rmaxLayerInfo.port, port)
		unitTest:assertEquals(rmaxLayerInfo.user, user)
		unitTest:assertEquals(rmaxLayerInfo.password, password)
		unitTest:assertEquals(rmaxLayerInfo.database, database)
		unitTest:assertEquals(rmaxLayerInfo.table, string.lower(rmaxLayerName))
		unitTest:assertNotNil(rmaxLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH STANDART DERIVATION OPERATION FROM RASTER
		local rstdevLayerName = clName.."_"..layerName4.."_RStdev"

		pgData.table = string.lower(rstdevLayerName)
		tl:dropPgTable(pgData)

		operation = "stdev"
		attribute = "rstdev"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, rmaxLayerName, rstdevLayerName, attribute, operation, select, area, default)

		local rstdevSet = tl:getDataSet(proj, rstdevLayerName)

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

		local rstdevLayerInfo = tl:getLayerInfo(proj, proj.layers[rstdevLayerName])
		unitTest:assertEquals(rstdevLayerInfo.name, rstdevLayerName)
		unitTest:assertEquals(rstdevLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(rstdevLayerInfo.rep, "polygon")
		unitTest:assertEquals(rstdevLayerInfo.host, host)
		unitTest:assertEquals(rstdevLayerInfo.port, port)
		unitTest:assertEquals(rstdevLayerInfo.user, user)
		unitTest:assertEquals(rstdevLayerInfo.password, password)
		unitTest:assertEquals(rstdevLayerInfo.database, database)
		unitTest:assertEquals(rstdevLayerInfo.table, string.lower(rstdevLayerName))
		unitTest:assertNotNil(rstdevLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH SUM OPERATION FROM RASTER
		local rsumLayerName = clName.."_"..layerName4.."_RSum"

		pgData.table = string.lower(rsumLayerName)
		tl:dropPgTable(pgData)

		operation = "sum"
		attribute = "rsum"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, rstdevLayerName, rsumLayerName, attribute, operation, select, area, default)

		local rsumSet = tl:getDataSet(proj, rsumLayerName)

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

		local rsumLayerInfo = tl:getLayerInfo(proj, proj.layers[rsumLayerName])
		unitTest:assertEquals(rsumLayerInfo.name, rsumLayerName)
		unitTest:assertEquals(rsumLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(rsumLayerInfo.rep, "polygon")
		unitTest:assertEquals(rsumLayerInfo.host, host)
		unitTest:assertEquals(rsumLayerInfo.port, port)
		unitTest:assertEquals(rsumLayerInfo.user, user)
		unitTest:assertEquals(rsumLayerInfo.password, password)
		unitTest:assertEquals(rsumLayerInfo.database, database)
		unitTest:assertEquals(rsumLayerInfo.table, string.lower(rsumLayerName))
		unitTest:assertNotNil(rsumLayerInfo.sid)

		-- OVERWRITE OUTPUT
		operation = "sum"
		attribute = "rsum_over"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, rsumLayerName, nil, attribute, operation, select, area, default)

		local rsumOverSet = tl:getDataSet(proj, rsumLayerName)

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

		local rsumOverLayerInfo = tl:getLayerInfo(proj, proj.layers[rsumLayerName])
		unitTest:assertEquals(rsumOverLayerInfo.name, rsumLayerName)
		unitTest:assertEquals(rsumOverLayerInfo.type, "POSTGIS")
		unitTest:assertEquals(rsumOverLayerInfo.rep, "polygon")
		unitTest:assertEquals(rsumOverLayerInfo.host, host)
		unitTest:assertEquals(rsumOverLayerInfo.port, port)
		unitTest:assertEquals(rsumOverLayerInfo.user, user)
		unitTest:assertEquals(rsumOverLayerInfo.password, password)
		unitTest:assertEquals(rsumOverLayerInfo.database, database)
		unitTest:assertEquals(rsumOverLayerInfo.table, string.lower(rsumLayerName))
		unitTest:assertNotNil(rsumOverLayerInfo.sid)

		-- END
		pgData.table = string.lower(clName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(presLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(areaLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(countLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(distLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(minLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(maxLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(percLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(stdevLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(meanLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(weighLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(interLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(occurLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(sumLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(wsumLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(percTifLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(rmeanLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(rminLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(rmaxLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(rstdevLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(rsumLayerName)
		tl:dropPgTable(pgData)
		-- END POSTGIS TESTS

		proj.file:delete()

		customWarning = customWarningBkp
	end,
	getDataSet = function(unitTest)
		-- see in saveDataSet() test --
		unitTest:assert(true)
	end,
	saveDataSet = function(unitTest)
		local tl = TerraLib{}
		local proj = {
			file = "myproject.tview",
			title = "TerraLib Tests",
			author = "Avancini Rodrigo"
		}

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		-- // create a database
		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)

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

		tl:dropPgDatabase(pgData)

		local clName1 = "SampaPgCells"
		local resolution = 1
		local mask = true
		tl:addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)

		local dSet = tl:getDataSet(proj, clName1)

		unitTest:assertEquals(getn(dSet), 37)

		for i = 0, #dSet do
			for k, v in pairs(dSet[i]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom"))
				unitTest:assertNotNil(v)
			end
		end

		local attrNames = tl:getPropertyNames(proj, proj.layers[clName1])
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

		tl:saveDataSet(proj, clName1, luaTable, newLayerName, {"attr1", "attr2", "attr3"})

		local newDSet = tl:getDataSet(proj, newLayerName)

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

		attrNames = tl:getPropertyNames(proj, proj.layers[newLayerName])
		unitTest:assertEquals("id", attrNames[0])
		unitTest:assertEquals("col", attrNames[1])
		unitTest:assertEquals("row", attrNames[2])
		unitTest:assertEquals("geom", attrNames[3])	-- TODO(avancinirodrigo): why cell space does not return geom?
		unitTest:assertEquals("attr1", attrNames[4])
		unitTest:assertEquals("attr2", attrNames[5])
		unitTest:assertEquals("attr3", attrNames[6])

		tl:saveDataSet(proj, clName1, luaTable, newLayerName, {"attr1"})
		newDSet = tl:getDataSet(proj, newLayerName)

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

		attrNames = tl:getPropertyNames(proj, proj.layers[newLayerName])
		unitTest:assertEquals("id", attrNames[0])
		unitTest:assertEquals("col", attrNames[1])
		unitTest:assertEquals("row", attrNames[2])
		unitTest:assertEquals("geom", attrNames[3])
		unitTest:assertEquals("attr1", attrNames[4])

		-- SAVE POLYGONS, POINTS AND LINES THAT ARE NOT CELLSPACE SPACE
		-- POLYGONS
		local polName = "ES_Limit"
		local polFile = filePath("test/limite_es_poly_wgs84.shp", "terralib")
		tl:addShpLayer(proj, polName, polFile)

		pgData.srid = 4326
		local polTable = "limite_es_poly_wgs84"
		pgData.table = polTable

		tl:saveLayerAs(proj, polName, pgData, true)

		local polDset = tl:getDataSet(proj, polName)
		local polLuaTable = {}
		for i = 0, getn(polDset) - 1 do
			local data = polDset[i]
			data.attr1 = i
			table.insert(polLuaTable, polDset[i])
		end

		polName = "ES_Limit_Pg"
		tl:addPgLayer(proj, polName, pgData)

		attrNames = tl:getPropertyNames(proj, proj.layers[polName])
		unitTest:assertEquals("fid", attrNames[0])
		unitTest:assertEquals("gm_layer", attrNames[1])
		unitTest:assertEquals("gm_type", attrNames[2])
		unitTest:assertEquals("layer", attrNames[3])
		unitTest:assertEquals("nm_estado", attrNames[4])
		unitTest:assertEquals("nm_regiao", attrNames[5])
		unitTest:assertEquals("cd_geocuf", attrNames[6])
		unitTest:assertEquals("nm_uf", attrNames[7])

		local newPolName = "ES_Limit_New"
		tl:saveDataSet(proj, polName, polLuaTable, newPolName, {"attr1"})

		local newPolDset = tl:getDataSet(proj, newPolName)
		unitTest:assertEquals(getn(newPolDset), 1)
		unitTest:assertEquals(getn(newPolDset), getn(polDset))

		attrNames = tl:getPropertyNames(proj, proj.layers[newPolName])
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
		local ptFile = filePath("test/ports.shp", "terralib")
		tl:addShpLayer(proj, ptName, ptFile)

		local ptTable = "ports"
		pgData.table = ptTable
		tl:saveLayerAs(proj, ptName, pgData, true)

		local ptDset = tl:getDataSet(proj, ptName)
		local ptLuaTable = {}
		for i = 0, getn(ptDset) - 1 do
			local data = ptDset[i]
			data.attr1 = i
			table.insert(ptLuaTable, ptDset[i])
		end

		ptName = "BR_Ports_Pg"
		tl:addPgLayer(proj, ptName, pgData)

		attrNames = tl:getPropertyNames(proj, proj.layers[ptName])
		unitTest:assertEquals("fid", attrNames[0])
		unitTest:assertEquals("tipo", attrNames[5])
		unitTest:assertEquals("gestao", attrNames[10])
		unitTest:assertEquals("pro_didade", attrNames[15])
		unitTest:assertEquals("cep", attrNames[20])
		unitTest:assertEquals("idr_rafica", attrNames[25])
		unitTest:assertEquals("observacao", attrNames[30])
		unitTest:assertEquals("cdc_troide", attrNames[32])

		local newPtName = "BR_Ports_New"
		tl:saveDataSet(proj, ptName, ptLuaTable, newPtName, {"attr1"})

		local newPtDset = tl:getDataSet(proj, newPtName)
		unitTest:assertEquals(getn(newPtDset), 8)
		unitTest:assertEquals(getn(newPtDset), getn(ptDset))

		attrNames = tl:getPropertyNames(proj, proj.layers[newPtName])
		unitTest:assertEquals("fid", attrNames[0])
		unitTest:assertEquals("tipo", attrNames[5])
		unitTest:assertEquals("gestao", attrNames[10])
		unitTest:assertEquals("pro_didade", attrNames[15])
		unitTest:assertEquals("cep", attrNames[20])
		unitTest:assertEquals("idr_rafica", attrNames[25])
		unitTest:assertEquals("observacao", attrNames[30])
		unitTest:assertEquals("cdc_troide", attrNames[32])
		unitTest:assertEquals("attr1", attrNames[34])

		-- LINES
		local lnName = "ES_Rails"
		local lnFile = filePath("test/rails.shp", "terralib")
		tl:addShpLayer(proj, lnName, lnFile)

		local lnTable = "rails"
		pgData.table = lnTable
		tl:saveLayerAs(proj, lnName, pgData, true)

		local lnDset = tl:getDataSet(proj, lnName)
		local lnLuaTable = {}
		for i = 0, getn(lnDset) - 1 do
			local data = lnDset[i]
			data.attr1 = i
			table.insert(lnLuaTable, lnDset[i])
		end

		lnName = "ES_Rails_Pg"
		tl:addPgLayer(proj, lnName, pgData)

		attrNames = tl:getPropertyNames(proj, proj.layers[lnName])
		unitTest:assertEquals("fid", attrNames[0])
		unitTest:assertEquals("observacao", attrNames[3])
		unitTest:assertEquals("produtos", attrNames[6])
		unitTest:assertEquals("operadora", attrNames[9])
		unitTest:assertEquals("bitola_ext", attrNames[12])
		unitTest:assertEquals("cod_pnv", attrNames[14])

		local newLnName = "ES_Rails_New"
		tl:saveDataSet(proj, lnName, lnLuaTable, newLnName, {"attr1"})

		local newLnDset = tl:getDataSet(proj, newLnName)
		unitTest:assertEquals(getn(newLnDset), 182)
		unitTest:assertEquals(getn(newLnDset), getn(lnDset))

		attrNames = tl:getPropertyNames(proj, proj.layers[newLnName])
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

		tl:saveDataSet(proj, newLnName, lnLuaTable, newLnName, {"attr1", "attr2", "attr3"})
		attrNames = tl:getPropertyNames(proj, proj.layers[newLnName])
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

		tl:saveDataSet(proj, newLnName, lnLuaTable, newLnName, {"attr1", "attr2", "attr3", "attr4"})
		attrNames = tl:getPropertyNames(proj, proj.layers[newLnName])
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

		tl:saveDataSet(proj, newLnName, lnLuaTable, newLnName, {"attr1"})
		attrNames = tl:getPropertyNames(proj, proj.layers[newLnName])
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

		tl:saveDataSet(proj, newLnName, lnLuaTable, newLnName, {"attr1", "attr2", "attr3"})
		attrNames = tl:getPropertyNames(proj, proj.layers[newLnName])
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
		tl:dropPgDatabase(pgData)
	end,
	getArea = function(unitTest)
		local tl = TerraLib{}
		local proj = {
			file = "myproject.tview",
			title = "TerraLib Tests",
			author = "Avancini Rodrigo"
		}

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)

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

		tl:dropPgDatabase(pgData)

		local clName1 = "SampaPgCells"
		local resolution = 1
		local mask = true
		tl:addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)

		local dSet = tl:getDataSet(proj, clName1)
		local area = tl:getArea(dSet[0].geom)
		unitTest:assertEquals(type(area), "number")
		unitTest:assertEquals(area, 1, 0.001)

		for i = 1, #dSet do
			for k, v in pairs(dSet[i]) do
				if k == "geom" then
					unitTest:assertEquals(area, tl:getArea(v), 0.001)
				end
			end
		end

		proj.file:delete()
		tl:dropPgDatabase(pgData)
	end,
	getProjection = function(unitTest)
		local tl = TerraLib{}
		local proj = {
			file = "myproject.tview",
			title = "TerraLib Tests",
			author = "Avancini Rodrigo"
		}

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		local layerName1 = "SetoresShp"
		local layerFile1 = filePath("itaituba-census.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)

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

		tl:dropPgDatabase(pgData)

		local clName1 = "SetoresPgCells"
		local resolution = 5e3
		local mask = true
		tl:addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)

		local prj = tl:getProjection(proj.layers[clName1])

		unitTest:assertEquals(prj.SRID, 29191.0)
		unitTest:assertEquals(prj.NAME, "SAD69 / UTM zone 21S")
		unitTest:assertEquals(prj.PROJ4, "+proj=utm +zone=21 +south +ellps=aust_SA +towgs84=-66.87,4.37,-38.52,0,0,0,0 +units=m +no_defs ")

		proj.file:delete()
		tl:dropPgTable(pgData)
		tl:dropPgDatabase(pgData)
	end,
	getPropertyNames = function(unitTest)
		local tl = TerraLib{}
		local proj = {
			file = "myproject.tview",
			title = "TerraLib Tests",
			author = "Avancini Rodrigo"
		}

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		local layerName1 = "SetoresShp"
		local layerFile1 = filePath("itaituba-census.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)

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

		tl:dropPgDatabase(pgData)

		local clName1 = "SetoresPgCells"
		local resolution = 5e3
		local mask = true
		tl:addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)

		local propNames = tl:getPropertyNames(proj, proj.layers[clName1])

		for i = 0, #propNames do
			unitTest:assert((propNames[i] == "id") or (propNames[i] == "geom") or
						(propNames[i] == "col") or (propNames[i] == "row"))
		end

		proj.file:delete()
		tl:dropPgTable(pgData)
		tl:dropPgDatabase(pgData)
	end,
	getDistance = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		-- // create a database
		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)

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

		tl:dropPgDatabase(pgData)

		local clName1 = "SampaPgCells"
		local resolution = 1
		local mask = true
		tl:addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)

		local dSet = tl:getDataSet(proj, clName1)
		local dist = tl:getDistance(dSet[0].geom, dSet[getn(dSet) - 1].geom)

		unitTest:assertEquals(dist, 4.1231056256177, 1.0e-13)

		proj.file:delete()
		tl:dropPgTable(pgData)
		tl:dropPgDatabase(pgData)
	end,
	saveLayerAs = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		local layerName1 = "Sampa"
		local layerFile1 = filePath("test/sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)

		-- POSTGIS
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = getConfig().password
		local database = "postgis_22_sample"
		local encoding = "CP1252"
		local tableName = "sampa"
		local srid = 4019

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

		tl:saveLayerAs(proj, layerName1, pgData, overwrite)
		local layerName2 = "PgLayer"
		tl:addPgLayer(proj, layerName2, pgData)

		-- SHP
		local toData = {}
		toData.file = "postgis2shp.shp"
		toData.type = "shp"
		File(toData.file):deleteIfExists()

		tl:saveLayerAs(proj, layerName2, toData, overwrite)
		unitTest:assert(File(toData.file):exists())

		-- OVERWRITE AND CHANGE SRID
		toData.srid = 4326
		tl:saveLayerAs(proj, layerName2, toData, overwrite)
		local layerName3 = "PG2SHP"
		tl:addShpLayer(proj, layerName3, File(toData.file))
		local info3 = tl:getLayerInfo(proj, proj.layers[layerName3])
		unitTest:assertEquals(info3.srid, toData.srid)

		-- OVERWRITE POSTGIS AND CHANGE SRID
		local info2 = tl:getLayerInfo(proj, proj.layers[layerName2])
		unitTest:assertEquals(info2.srid, 4019.0)
		pgData.srid = 4326
		tl:saveLayerAs(proj, layerName1, pgData, overwrite)
		info2 = tl:getLayerInfo(proj, proj.layers[layerName2])
		unitTest:assertEquals(info2.srid, 4326.0)

		-- GEOJSON
		toData.file = "postgis2geojson.geojson"
		toData.type = "geojson"
		File(toData.file):deleteIfExists()
		tl:saveLayerAs(proj, layerName2, toData, overwrite)
		unitTest:assert(File(toData.file):exists())

		-- OVERWRITE AND CHANGE SRID
		toData.srid = 4326
		tl:saveLayerAs(proj, layerName2, toData, overwrite)
		local layerName4 = "PG2GJ"
		tl:addGeoJSONLayer(proj, layerName4, File(toData.file))
		local info4 = tl:getLayerInfo(proj, proj.layers[layerName4])
		unitTest:assertEquals(info4.srid, toData.srid)

		-- OVERWRITE POSTGIS AND CHANGE SRID
		local table1 = pgData.table
		pgData.table = "ogrgeojson" -- TODO(#1243)
		tl:saveLayerAs(proj, layerName4, pgData, overwrite)

		local layerName5 = "PgLayerGJ"
		tl:addPgLayer(proj, layerName5, pgData)
		local info5 = tl:getLayerInfo(proj, proj.layers[layerName5])
		unitTest:assertEquals(info5.srid, 4326.0)

		pgData.srid = 2309
		tl:saveLayerAs(proj, layerName4, pgData, overwrite)
		info5 = tl:getLayerInfo(proj, proj.layers[layerName5])
		unitTest:assertEquals(info5.srid, 2309.0)

		-- SAVE THE DATA WITH ONLY ONE ATTRIBUTE FROM SHP
		local table2 = pgData.table
		pgData.table = "postgis2shp"
		tl:saveLayerAs(proj, layerName3, pgData, overwrite, {"nm_micro"})

		local layerName6 = "SHP2PG"
		tl:addPgLayer(proj, layerName6, pgData)
		local dset6 = tl:getDataSet(proj, layerName6)

		unitTest:assertEquals(getn(dset6), 63)

		for k, v in pairs(dset6[0]) do
			unitTest:assert(((k == "fid") and (v == 0)) or ((k == "ogr_geometry") and (v ~= nil) ) or
							((k == "nm_micro") and (v == "VOTUPORANGA")))
		end

		-- SAVE THE DATA WITH ONLY ONE ATTRIBUTE FROM GEOJSON
		local table3 = pgData.table
		pgData.table = "ogrgeojson"
		tl:saveLayerAs(proj, layerName4, pgData, overwrite, {"nm_micro", "id"})

		local layerName7 = "GJ2PG"
		tl:addPgLayer(proj, layerName7, pgData)
		local dset7 = tl:getDataSet(proj, layerName7)

		unitTest:assertEquals(getn(dset7), 63)

		for k, v in pairs(dset7[0]) do
			unitTest:assert(((k == "fid") and (v == 2)) or ((k == "ogr_geometry") and (v ~= nil) ) or
							((k == "nm_micro") and (v == "VOTUPORANGA")) or ((k == "id") and (v == 2)))
		end

		tl:dropPgTable(pgData)
		pgData.table = table1
		tl:dropPgTable(pgData)
		pgData.table = table2
		tl:dropPgTable(pgData)
		pgData.table = table3
		tl:dropPgTable(pgData)

		File("postgis2shp.shp"):delete()
		File("postgis2geojson.geojson"):delete()

		unitTest:assert(true)
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

		local layerName1 = "Sampa"
		local layerFile1 = filePath("test/sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)

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

		tl:saveLayerAs(proj, layerName1, pgData, overwrite)
		local layerName2 = "PgLayer"
		tl:addPgLayer(proj, layerName2, pgData)

		local size = tl:getLayerSize(proj, layerName2)

		unitTest:assertEquals(size, 63.0)

		tl:dropPgTable(pgData)

		unitTest:assert(true)
		file:delete()
	end,
	douglasPeucker = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		local file = File(proj.file)
		file:deleteIfExists()

		tl:createProject(proj, {})

		local lnName = "ES_Rails"
		local lnFile = filePath("test/rails.shp", "terralib")
		tl:addShpLayer(proj, lnName, lnFile, nil, 29101)

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
		tl:saveLayerAs(proj, lnName, pgData, overwrite)

		local layerName2 = "ES_Rails_Pg"
		tl:addPgLayer(proj, layerName2, pgData)

		local dpLayerName = "ES_Rails_Peucker"
		tl:douglasPeucker(proj, layerName2, dpLayerName, 500)

		pgData.table = string.lower(dpLayerName)
		tl:addPgLayer(proj, dpLayerName, pgData)

		local dpSet = tl:getDataSet(proj, dpLayerName)
		unitTest:assertEquals(getn(dpSet), 182)

		local attrNames = tl:getPropertyNames(proj, proj.layers[dpLayerName])
		unitTest:assertEquals("fid", attrNames[0])
		unitTest:assertEquals("observacao", attrNames[3])
		unitTest:assertEquals("produtos", attrNames[6])
		unitTest:assertEquals("operadora", attrNames[9])
		unitTest:assertEquals("bitola_ext", attrNames[12])
		unitTest:assertEquals("cod_pnv", attrNames[14])

		tl:dropPgTable(pgData)
		pgData.table = tableName
		tl:dropPgTable(pgData)
		proj.file:delete()
	end

}
