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
		
		if isFile(proj.file) then
			rmFile(proj.file)
		end	
		
		tl:createProject(proj, {})
		
		local layerName1 = "SampaShp"
		local layerFile1 = filePath("sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)		
		
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
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
		
		tl:copyLayer(proj, layerName1, pgData)
		
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
		
		rmFile(proj.file)
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
	copyLayer = function(unitTest)
		-- see in addPgLayer() test --
		unitTest:assert(true)
	end,
	addPgCellSpaceLayer = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		if isFile(proj.file) then
			rmFile(proj.file)
		end	
		
		tl:createProject(proj, {})
		
		-- // create a database 
		local layerName1 = "SampaShp"
		local layerFile1 = filePath("sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)		
		
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
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
		local resolution = 0.7
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
		unitTest:assertEquals(getn(clSet), 68)
		
		clName1 = clName1.."_NoMask"
		local pgData2 = pgData
		pgData2.tableName = clName1
		
		tl:dropPgTable(pgData2)
		
		mask = false
		tl:addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData2, mask)
		
		clSet = tl:getDataSet(proj, clName1)
		unitTest:assertEquals(getn(clSet), 104)		
		
		-- END
		rmFile(proj.file)
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
		
		if isFile(proj.file) then
			rmFile(proj.file)
		end	
		-- CREATE A PROJECT
		tl:createProject(proj, {})

		-- CREATE A LAYER THAT WILL BE USED AS REFERENCE TO CREATE THE CELLULAR SPACE
		local layerName1 = "Para"
		local layerFile1 = filePath("limitePA_polyc_pol.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)		
		
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
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
		local resolution = 60e3
		local mask = true
		tl:addPgCellSpaceLayer(proj, layerName1, clName, resolution, pgData, mask)
		
		local clSet = tl:getDataSet(proj, clName)
		
		unitTest:assertEquals(getn(clSet), 402)
		
		for k, v in pairs(clSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom"))
			unitTest:assertNotNil(v)
		end						
		
		-- CREATE A LAYER WITH POLYGONS TO DO OPERATIONS
		local layerName2 = "Protection_Unit" 
		local layerFile2 = filePath("BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "terralib")
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
		
		unitTest:assertEquals(getn(presSet), 402)
		
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
		
		local operation = "area"
		local attribute = "area_percent"
		local select = "FID"
		local area = nil
		local default = 0
		tl:attributeFill(proj, layerName2, presLayerName, areaLayerName, attribute, operation, select, area, default)
		
		local areaSet = tl:getDataSet(proj, areaLayerName)
		
		unitTest:assertEquals(getn(areaSet), 402)
		
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
		
		local operation = "count"
		local attribute = "count"
		local select = "FID"
		local area = nil
		local default = 0
		tl:attributeFill(proj, layerName2, areaLayerName, countLayerName, attribute, operation, select, area, default)
		
		local countSet = tl:getDataSet(proj, countLayerName)
		
		unitTest:assertEquals(getn(countSet), 402)
		
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
		
		local operation = "distance"
		local attribute = "distance"
		local select = "FID"
		local area = nil
		local default = nil
		tl:attributeFill(proj, layerName2, countLayerName, distLayerName, attribute, operation, select, area, default)
		
		local distSet = tl:getDataSet(proj, distLayerName)
		
		unitTest:assertEquals(getn(distSet), 402)
		
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
		local layerFile3 = filePath("municipiosAML_ok.shp", "terralib")
		tl:addShpLayer(proj, layerName3, layerFile3)		
		
		local minLayerName = clName.."_"..layerName3.."_Minimum"		
		
		pgData.table = string.lower(minLayerName)
		tl:dropPgTable(pgData)
		
		local operation = "minimum"
		local attribute = "minimum"
		local select = "POPULACAO_"
		local area = nil
		local default = nil
		tl:attributeFill(proj, layerName3, distLayerName, minLayerName, attribute, operation, select, area, default)
		
		local minSet = tl:getDataSet(proj, minLayerName)
		
		unitTest:assertEquals(getn(minSet), 402)
		
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
		
		local operation = "maximum"
		local attribute = "maximum"
		local select = "POPULACAO_"
		local area = nil
		local default = nil
		tl:attributeFill(proj, layerName3, minLayerName, maxLayerName, attribute, operation, select, area, default)
		
		local maxSet = tl:getDataSet(proj, maxLayerName)
		
		unitTest:assertEquals(getn(maxSet), 402)
		
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
		
		local operation = "coverage"
		local attribute = "perc"
		local select = "ADMINISTRA"
		local area = nil
		local default = nil
		tl:attributeFill(proj, layerName2, maxLayerName, percLayerName, attribute, operation, select, area, default)
		
		local percentSet = tl:getDataSet(proj, percLayerName)
		
		unitTest:assertEquals(getn(percentSet), 402)
		
		for k, v in pairs(percentSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or 
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc") ~= nil))
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
		
		local operation = "stdev"
		local attribute = "stdev"
		local select = "POPULACAO_"
		local area = nil
		local default = nil
		tl:attributeFill(proj, layerName3, percLayerName, stdevLayerName, attribute, operation, select, area, default)
		
		local stdevSet = tl:getDataSet(proj, stdevLayerName)
		
		unitTest:assertEquals(getn(stdevSet), 402)
		
		for k, v in pairs(stdevSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or 
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc") ~= nil) or (k == "stdev"))
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
		
		local operation = "average"
		local attribute = "mean"
		local select = "POPULACAO_"
		local area = false
		local default = nil
		tl:attributeFill(proj, layerName3, stdevLayerName, meanLayerName, attribute, operation, select, area, default)
		
		local meanSet = tl:getDataSet(proj, meanLayerName)
		
		unitTest:assertEquals(getn(meanSet), 402)
		
		for k, v in pairs(meanSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or 
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc") ~= nil) or (k == "stdev") or (k == "mean"))
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
		
		local operation = "average"
		local attribute = "weighted"
		local select = "POPULACAO_"
		local area = true
		local default = nil
		tl:attributeFill(proj, layerName3, meanLayerName, weighLayerName, attribute, operation, select, area, default)
		
		local weighSet = tl:getDataSet(proj, weighLayerName)
		
		unitTest:assertEquals(getn(weighSet), 402)
		
		for k, v in pairs(weighSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or 
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc") ~= nil) or (k == "stdev") or (k == "mean") or
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
		
		local operation = "mode"
		local attribute = "mode_int"
		local select = "POPULACAO_"
		local area = true
		local default = nil
		tl:attributeFill(proj, layerName3, weighLayerName, interLayerName, attribute, operation, select, area, default)
		
		local interSet = tl:getDataSet(proj, interLayerName)
		
		unitTest:assertEquals(getn(interSet), 402)
		
		for k, v in pairs(interSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or 
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc") ~= nil) or (k == "stdev") or (k == "mean") or
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
		
		local operation = "mode"
		local attribute = "mode_occur"
		local select = "POPULACAO_"
		local area = false
		local default = nil
		tl:attributeFill(proj, layerName3, interLayerName, occurLayerName, attribute, operation, select, area, default)
		
		local occurSet = tl:getDataSet(proj, occurLayerName)
		
		unitTest:assertEquals(getn(occurSet), 402)
		
		for k, v in pairs(occurSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or 
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc") ~= nil) or (k == "stdev") or (k == "mean") or
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
		
		local operation = "sum"
		local attribute = "sum"
		local select = "POPULACAO_"
		local area = false
		local default = nil
		tl:attributeFill(proj, layerName3, occurLayerName, sumLayerName, attribute, operation, select, area, default)
		
		local sumSet = tl:getDataSet(proj, sumLayerName)
		
		unitTest:assertEquals(getn(sumSet), 402)
		
		for k, v in pairs(sumSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or 
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc") ~= nil) or (k == "stdev") or (k == "mean") or
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
		
		local operation = "sum"
		local attribute = "wsum"
		local select = "POPULACAO_"
		local area = true
		local default = nil
		tl:attributeFill(proj, layerName3, sumLayerName, wsumLayerName, attribute, operation, select, area, default)
		
		local wsumSet = tl:getDataSet(proj, wsumLayerName)
		
		unitTest:assertEquals(getn(wsumSet), 402)
		
		for k, v in pairs(wsumSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or 
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc") ~= nil) or (k == "stdev") or (k == "mean") or
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
		local layerFile4 = filePath("prodes_polyc_10k.tif", "terralib")
		tl:addTifLayer(proj, layerName4, layerFile4)		
		
		local percTifLayerName = clName.."_"..layerName4.."_RPercentage"		
		
		pgData.table = string.lower(percTifLayerName)
		tl:dropPgTable(pgData)
		
		local operation = "coverage"
		local attribute = "rperc"
		local select = 0
		local area = nil
		local default = nil
		tl:attributeFill(proj, layerName4, wsumLayerName, percTifLayerName, attribute, operation, select, area, default)
		
		local percentSet = tl:getDataSet(proj, percTifLayerName)
		
		unitTest:assertEquals(getn(percentSet), 402) 
		
		for k, v in pairs(percentSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or 
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur") or
							(k == "sum") or (k == "wsum") or (string.match(k, "rperc") ~= nil))
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
		
		local operation = "average"
		local attribute = "rmean"
		local select = 0
		local area = nil
		local default = nil
		tl:attributeFill(proj, layerName4, percTifLayerName, rmeanLayerName, attribute, operation, select, area, default)
		
		local rmeanSet = tl:getDataSet(proj, rmeanLayerName)
		
		unitTest:assertEquals(getn(rmeanSet), 402)
		
		for k, v in pairs(rmeanSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or 
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur") or
							(k == "sum") or (k == "wsum") or (string.match(k, "rperc") ~= nil) or 
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
		
		local operation = "minimum"
		local attribute = "rmin"
		local select = 0
		local area = nil
		local default = nil
		tl:attributeFill(proj, layerName4, rmeanLayerName, rminLayerName, attribute, operation, select, area, default)
		
		local rminSet = tl:getDataSet(proj, rminLayerName)
		
		unitTest:assertEquals(getn(rminSet), 402)
		
		for k, v in pairs(rminSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or 
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur") or
							(k == "sum") or (k == "wsum") or (string.match(k, "rperc") ~= nil) or 
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
		
		local operation = "maximum"
		local attribute = "rmax"
		local select = 0
		local area = nil
		local default = nil
		tl:attributeFill(proj, layerName4, rminLayerName, rmaxLayerName, attribute, operation, select, area, default)
		
		local rmaxSet = tl:getDataSet(proj, rmaxLayerName)
		
		unitTest:assertEquals(getn(rmaxSet), 402)
		
		for k, v in pairs(rmaxSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or 
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur") or
							(k == "sum") or (k == "wsum") or (string.match(k, "rperc") ~= nil) or 
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
		
		local operation = "stdev"
		local attribute = "rstdev"
		local select = 0
		local area = nil
		local default = nil
		tl:attributeFill(proj, layerName4, rmaxLayerName, rstdevLayerName, attribute, operation, select, area, default)
		
		local rstdevSet = tl:getDataSet(proj, rstdevLayerName)
		
		unitTest:assertEquals(getn(rstdevSet), 402)
		
		for k, v in pairs(rstdevSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or 
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur") or
							(k == "sum") or (k == "wsum") or (string.match(k, "rperc") ~= nil) or 
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
		
		local operation = "sum"
		local attribute = "rsum"
		local select = 0
		local area = nil
		local default = nil
		tl:attributeFill(proj, layerName4, rstdevLayerName, rsumLayerName, attribute, operation, select, area, default)
		
		local rsumSet = tl:getDataSet(proj, rsumLayerName)
		
		unitTest:assertEquals(getn(rsumSet), 402)
		
		for k, v in pairs(rsumSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom") or 
							(k == "presence") or (k == "area_percent") or (k == "count") or
							(k == "distance") or (k == "minimum") or (k == "maximum") or
							(string.match(k, "perc") ~= nil) or (k == "stdev") or (k == "mean") or
							(k == "weighted") or (k == "mode_int") or (k == "mode_occur") or
							(k == "sum") or (k == "wsum") or (string.match(k, "rperc") ~= nil) or 
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
		
		rmFile(proj.file)
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

		if isFile(proj.file) then
			rmFile(proj.file)
		end	
		
		tl:createProject(proj, {})
		
		-- // create a database 
		local layerName1 = "SampaShp"
		local layerFile1 = filePath("sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)		
		
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
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
		local resolution = 0.7
		local mask = true
		tl:addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData, mask)

		local dSet = tl:getDataSet(proj, clName1)
		
		unitTest:assertEquals(getn(dSet), 68)
		
		for i = 0, #dSet do
			for k, v in pairs(dSet[i]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "geom"))
				unitTest:assertNotNil(v)
			end			
		end			
		
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
		
		unitTest:assertEquals(getn(newDSet), 68)
		
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
		
		rmFile(proj.file)
		tl:dropPgDatabase(pgData)		
	end
}
