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

		-- ###################### 6 #############################	
		local maxValueLayerName = clName1.."_Maximum"
		pgData.table = maxValueLayerName
		tl:dropPgTable(pgData)	
		
		cl:fillCells{
			operation = "maximum",
			layer = layerName1,
			attribute = "maximum",
			output = maxValueLayerName,
			select = "FID"
		}
		
		local maxValueLayerInfo = proj:infoLayer(maxValueLayerName)
		unitTest:assertEquals(maxValueLayerInfo.source, "postgis")
		unitTest:assertEquals(maxValueLayerInfo.host, host)
		unitTest:assertEquals(maxValueLayerInfo.port, port)
		unitTest:assertEquals(maxValueLayerInfo.user, user)
		unitTest:assertEquals(maxValueLayerInfo.password, password)
		unitTest:assertEquals(maxValueLayerInfo.database, database)
		unitTest:assertEquals(maxValueLayerInfo.table, string.lower(maxValueLayerName))	
		
		-- ###################### 7 #############################	
		local percentageLayerName = clName1.."_Percentage"
		pgData.table = percentageLayerName
		tl:dropPgTable(pgData)	
		
		cl:fillCells{
			operation = "percentage",
			layer = layerName1,
			attribute = "percentage",
			output = percentageLayerName,
			select = "NM_MICRO"
		}
		
		local percentageLayerInfo = proj:infoLayer(percentageLayerName)
		unitTest:assertEquals(percentageLayerInfo.source, "postgis")
		unitTest:assertEquals(percentageLayerInfo.host, host)
		unitTest:assertEquals(percentageLayerInfo.port, port)
		unitTest:assertEquals(percentageLayerInfo.user, user)
		unitTest:assertEquals(percentageLayerInfo.password, password)
		unitTest:assertEquals(percentageLayerInfo.database, database)
		unitTest:assertEquals(percentageLayerInfo.table, string.lower(percentageLayerName))	
		
		-- ###################### 8 #############################	
		local stdevLayerName = clName1.."_Stdev"
		pgData.table = stdevLayerName
		tl:dropPgTable(pgData)	
		
		cl:fillCells{
			operation = "stdev",
			layer = layerName1,
			attribute = "stdev",
			output = stdevLayerName,
			select = "FID"
		}
		
		local stdevLayerInfo = proj:infoLayer(stdevLayerName)
		unitTest:assertEquals(stdevLayerInfo.source, "postgis")
		unitTest:assertEquals(stdevLayerInfo.host, host)
		unitTest:assertEquals(stdevLayerInfo.port, port)
		unitTest:assertEquals(stdevLayerInfo.user, user)
		unitTest:assertEquals(stdevLayerInfo.password, password)
		unitTest:assertEquals(stdevLayerInfo.database, database)
		unitTest:assertEquals(stdevLayerInfo.table, string.lower(stdevLayerName))
		
		-- ###################### 9 #############################	
		local meanLayerName = clName1.."_Average_Mean"
		pgData.table = meanLayerName
		tl:dropPgTable(pgData)	
		
		cl:fillCells{
			operation = "average",
			layer = layerName1,
			attribute = "mean",
			output = meanLayerName,
			select = "FID"
		}
		
		local meanLayerInfo = proj:infoLayer(meanLayerName)
		unitTest:assertEquals(meanLayerInfo.source, "postgis")
		unitTest:assertEquals(meanLayerInfo.host, host)
		unitTest:assertEquals(meanLayerInfo.port, port)
		unitTest:assertEquals(meanLayerInfo.user, user)
		unitTest:assertEquals(meanLayerInfo.password, password)
		unitTest:assertEquals(meanLayerInfo.database, database)
		unitTest:assertEquals(meanLayerInfo.table, string.lower(meanLayerName))		

		-- ###################### 10 #############################	
		local weighLayerName = clName1.."_Average_Weighted"
		pgData.table = weighLayerName
		tl:dropPgTable(pgData)	
		
		cl:fillCells{
			operation = "average",
			layer = layerName1,
			attribute = "weighted",
			output = weighLayerName,
			select = "FID",
			area = true
		}
		
		local weighLayerInfo = proj:infoLayer(weighLayerName)
		unitTest:assertEquals(weighLayerInfo.source, "postgis")
		unitTest:assertEquals(weighLayerInfo.host, host)
		unitTest:assertEquals(weighLayerInfo.port, port)
		unitTest:assertEquals(weighLayerInfo.user, user)
		unitTest:assertEquals(weighLayerInfo.password, password)
		unitTest:assertEquals(weighLayerInfo.database, database)
		unitTest:assertEquals(weighLayerInfo.table, string.lower(weighLayerName))

		-- ###################### 11 #############################	
		local intersecLayerName = clName1.."_Mojority_Intersection"
		pgData.table = intersecLayerName
		tl:dropPgTable(pgData)	
		
		cl:fillCells{
			operation = "majority",
			layer = layerName1,
			attribute = "high_intersection",
			output = intersecLayerName,
			select = "CD_GEOCODU",
			area = true
		}
		
		local intersecLayerInfo = proj:infoLayer(intersecLayerName)
		unitTest:assertEquals(intersecLayerInfo.source, "postgis")
		unitTest:assertEquals(intersecLayerInfo.host, host)
		unitTest:assertEquals(intersecLayerInfo.port, port)
		unitTest:assertEquals(intersecLayerInfo.user, user)
		unitTest:assertEquals(intersecLayerInfo.password, password)
		unitTest:assertEquals(intersecLayerInfo.database, database)
		unitTest:assertEquals(intersecLayerInfo.table, string.lower(intersecLayerName))
		
		-- ###################### 12 #############################	
		local occurrenceLayerName = clName1.."_Mojority_Occurrence"
		pgData.table = occurrenceLayerName
		tl:dropPgTable(pgData)	
		
		cl:fillCells{
			operation = "majority",
			layer = layerName1,
			attribute = "high_occurrence",
			output = occurrenceLayerName,
			select = "CD_GEOCODU"
		}
		
		local occurrenceLayerInfo = proj:infoLayer(occurrenceLayerName)
		unitTest:assertEquals(occurrenceLayerInfo.source, "postgis")
		unitTest:assertEquals(occurrenceLayerInfo.host, host)
		unitTest:assertEquals(occurrenceLayerInfo.port, port)
		unitTest:assertEquals(occurrenceLayerInfo.user, user)
		unitTest:assertEquals(occurrenceLayerInfo.password, password)
		unitTest:assertEquals(occurrenceLayerInfo.database, database)
		unitTest:assertEquals(occurrenceLayerInfo.table, string.lower(occurrenceLayerName))		

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
		pgData.table = string.lower(maxValueLayerName)
		tl:dropPgTable(pgData)	
		pgData.table = string.lower(percentageLayerName)
		tl:dropPgTable(pgData)	
		pgData.table = string.lower(stdevLayerName)
		tl:dropPgTable(pgData)	
		pgData.table = string.lower(meanLayerName)
		tl:dropPgTable(pgData)	
		pgData.table = string.lower(weighLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(intersecLayerName)
		tl:dropPgTable(pgData)	
		pgData.table = string.lower(occurrenceLayerName)
		tl:dropPgTable(pgData)			
		
		tl = TerraLib{}
		tl:finalize()		
	end
}