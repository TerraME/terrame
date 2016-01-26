return {
	CellularLayer = function(unitTest)
		local projName = "cellular_layer_basic.tview"

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
		
		-- ###################### 1 #############################
		local author = "Avancini"
		local title = "Cellular Layer"
	
		local proj = Project {
			file = projName,
			create = true,
			author = "Avancini",
			title = "Cellular Layer"
		}		

		local layerName1 = "Sampa"
		proj:addLayer {
			layer = layerName1,
			file = file("sampa.shp", "fillcell")
		}	
		
		local clName1 = "Sampa_Cells_DB"
		local tName1 = "sampa_cells"
		
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
		local database = "postgis_22_sample"
		local encoding = "CP1252"
		local tableName = tName1	
		
		local pgData = {
			type = "POSTGIS",
			host = host,
			port = port,
			user = user,
			password = password,
			database = database,
			table = tName1,
			encoding = encoding
		}
		
		local tl = TerraLib{}
		tl:dropPgTable(pgData)
		
		proj:addCellularLayer {
			source = "postgis",
			input = layerName1,
			layer = clName1,
			resolution = 0.3,
			user = user,
			password = password,
			database = database,
			table = tName1
		}	
		
		local cl = CellularLayer{
			project = proj,
			layer = clName1
		}		
		
		unitTest:assertEquals(projName, cl.project.file)
		unitTest:assertEquals(clName1, cl.layer)
		
		-- ###################### 2 #############################
		proj = nil
		tl = TerraLib{}
		tl:finalize()
		
		local cl2 = CellularLayer{
			project = projName,
			layer = clName1
		}
		
		local clProj = cl2.project
		local clProjInfo = clProj:info()
		
		unitTest:assertEquals(clProjInfo.title, title)
		unitTest:assertEquals(clProjInfo.author, author)
		
		local clLayerInfo = clProj:infoLayer(clName1)
		unitTest:assertEquals(clLayerInfo.source, "postgis")
		unitTest:assertEquals(clLayerInfo.host, host)
		unitTest:assertEquals(clLayerInfo.port, port)
		unitTest:assertEquals(clLayerInfo.user, user)
		unitTest:assertEquals(clLayerInfo.password, password)
		unitTest:assertEquals(clLayerInfo.database, database)
		unitTest:assertEquals(clLayerInfo.table, tName1)
		
		-- ###################### END #############################
		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
		
		tl:dropPgTable(pgData)
		
		tl = TerraLib{}
		tl:finalize()		
	end,
	fillCells = function(unitTest)
		local projName = "cellular_layer_fillcells_basic.tview"

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
		
		-- ###################### 1 #############################
		local author = "Avancini"
		local title = "Cellular Layer"
	
		local proj = Project {
			file = projName,
			create = true,
			author = "Avancini",
			title = "Cellular Layer"
		}		

		local layerName1 = "Sampa"
		proj:addLayer {
			layer = layerName1,
			file = file("sampa.shp", "fillcell")
		}	
		
		local clName1 = "Sampa_Cells_DB"
		local tName1 = "sampa_cells"
		
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
		local database = "postgis_22_sample"
		local encoding = "CP1252"
		local tableName = tName1	
		
		local pgData = {
			type = "POSTGIS",
			host = host,
			port = port,
			user = user,
			password = password,
			database = database,
			table = tName1,
			encoding = encoding
		}
		
		local tl = TerraLib{}
		tl:dropPgTable(pgData)
		
		proj:addCellularLayer {
			source = "postgis",
			input = layerName1,
			layer = clName1,
			resolution = 0.9,
			user = user,
			password = password,
			database = database,
			table = tName1
		}	
		
		local cl = CellularLayer{
			project = proj,
			layer = clName1
		}
		
		local presenceLayerName = clName1.."_Presence"
		pgData.table = presenceLayerName
		tl:dropPgTable(pgData)

		cl:fillCells{
			operation = "presence",
			layer = layerName1,
			attribute = "presence",
			output = presenceLayerName
		}
		
		local presenceLayerInfo = proj:infoLayer(presenceLayerName)
		unitTest:assertEquals(presenceLayerInfo.source, "postgis")
		unitTest:assertEquals(presenceLayerInfo.host, host)
		unitTest:assertEquals(presenceLayerInfo.port, port)
		unitTest:assertEquals(presenceLayerInfo.user, user)
		unitTest:assertEquals(presenceLayerInfo.password, password)
		unitTest:assertEquals(presenceLayerInfo.database, database)
		unitTest:assertEquals(presenceLayerInfo.table, string.lower(presenceLayerName))		

		-- ###################### 2 #############################
		
		local areaLayerName = clName1.."_Area"
		pgData.table = areaLayerName
		tl:dropPgTable(pgData)
		
		local c2 = CellularLayer{
			project = proj,
			layer = presenceLayerName
		}		
		
		c2:fillCells{
			operation = "area",
			layer = layerName1,
			attribute = "area",
			output = areaLayerName
		}
		
		local areaLayerInfo = proj:infoLayer(areaLayerName)
		unitTest:assertEquals(areaLayerInfo.source, "postgis")
		unitTest:assertEquals(areaLayerInfo.host, host)
		unitTest:assertEquals(areaLayerInfo.port, port)
		unitTest:assertEquals(areaLayerInfo.user, user)
		unitTest:assertEquals(areaLayerInfo.password, password)
		unitTest:assertEquals(areaLayerInfo.database, database)
		unitTest:assertEquals(areaLayerInfo.table, string.lower(areaLayerName))			
		
		-- ###################### 3 #############################	
		local countLayerName = clName1.."_Count"
		pgData.table = countLayerName
		tl:dropPgTable(pgData)
		
		local c3 = CellularLayer{
			project = proj,
			layer = areaLayerName
		}		
		
		c3:fillCells{
			operation = "count",
			layer = layerName1,
			attribute = "count",
			output = countLayerName
		}
		
		local countLayerInfo = proj:infoLayer(countLayerName)
		unitTest:assertEquals(countLayerInfo.source, "postgis")
		unitTest:assertEquals(countLayerInfo.host, host)
		unitTest:assertEquals(countLayerInfo.port, port)
		unitTest:assertEquals(countLayerInfo.user, user)
		unitTest:assertEquals(countLayerInfo.password, password)
		unitTest:assertEquals(countLayerInfo.database, database)
		unitTest:assertEquals(countLayerInfo.table, string.lower(countLayerName))

		-- ###################### 4 #############################	
		local distanceLayerName = clName1.."_Distance"
		pgData.table = distanceLayerName
		tl:dropPgTable(pgData)	
		
		cl:fillCells{
			operation = "distance",
			layer = layerName1,
			attribute = "distance",
			output = distanceLayerName
		}
		
		local distanceLayerInfo = proj:infoLayer(distanceLayerName)
		unitTest:assertEquals(distanceLayerInfo.source, "postgis")
		unitTest:assertEquals(distanceLayerInfo.host, host)
		unitTest:assertEquals(distanceLayerInfo.port, port)
		unitTest:assertEquals(distanceLayerInfo.user, user)
		unitTest:assertEquals(distanceLayerInfo.password, password)
		unitTest:assertEquals(distanceLayerInfo.database, database)
		unitTest:assertEquals(distanceLayerInfo.table, string.lower(distanceLayerName))		

		-- ###################### 5 #############################	
		local minValueLayerName = clName1.."_Minimum"
		pgData.table = minValueLayerName
		tl:dropPgTable(pgData)	
		
		cl:fillCells{
			operation = "minimum",
			layer = layerName1,
			attribute = "minimum",
			output = minValueLayerName,
			select = "FID"
		}
		
		local minValueLayerInfo = proj:infoLayer(minValueLayerName)
		unitTest:assertEquals(minValueLayerInfo.source, "postgis")
		unitTest:assertEquals(minValueLayerInfo.host, host)
		unitTest:assertEquals(minValueLayerInfo.port, port)
		unitTest:assertEquals(minValueLayerInfo.user, user)
		unitTest:assertEquals(minValueLayerInfo.password, password)
		unitTest:assertEquals(minValueLayerInfo.database, database)
		unitTest:assertEquals(minValueLayerInfo.table, string.lower(minValueLayerName))			

		-- ###################### END #############################
		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
		
		pgData.table = string.lower(tName1)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(presenceLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(areaLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(countLayerName)
		tl:dropPgTable(pgData)		
		pgData.table = string.lower(distanceLayerName)
		tl:dropPgTable(pgData)			
		pgData.table = string.lower(minValueLayerName)
		tl:dropPgTable(pgData)		
		
		tl = TerraLib{}
		tl:finalize()		
	end
}