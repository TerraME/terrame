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
	createProject = function(unitTest)
		local tl = TerraLib{}
		local title = "TerraLib Tests"
		local author = "Avancini Rodrigo"
		local file = "myproject.tview"
		local proj = {}
		proj.file = file
		proj.title = title
		proj.author = author
		
		if isFile(proj.file) then
			rmFile(proj.file)
		end
		
		tl:createProject(proj, {})
		unitTest:assert(isFile(proj.file))
		unitTest:assertEquals(proj.file, file)
		unitTest:assertEquals(proj.title, title)
		unitTest:assertEquals(proj.author, author)
		
		-- allow overwrite
		tl:createProject(proj, {})
		unitTest:assert(isFile(proj.file))
		
		rmFile(proj.file)
	end,
	openProject = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		if isFile(proj.file) then
			rmFile(proj.file)
		end
		
		tl:createProject(proj, {})
		
		local proj2 = {}
		
		tl:openProject(proj2, proj.file)
		
		unitTest:assertEquals(proj2.file, proj.file)
		unitTest:assertEquals(proj2.title, proj.title)
		unitTest:assertEquals(proj2.author, proj.author)
		
		rmFile(proj.file)
	end,
	getLayerInfo = function(unitTest)
		-- see in other functions e.g. addPgLayer() --
		unitTest:assert(true)
	end,
	addShpLayer = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		if isFile(proj.file) then
			rmFile(proj.file)
		end
		
		tl:createProject(proj, {})
		
		local layerName = "ShapeLayer"
		local layerFile = filePath("sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName, layerFile)
		
		local layerInfo = tl:getLayerInfo(proj, proj.layers[layerName])
		
		unitTest:assertEquals(layerInfo.name, layerName)
		unitTest:assertEquals(layerInfo.file, layerFile)
		unitTest:assertEquals(layerInfo.type, "OGR")
		unitTest:assertEquals(layerInfo.rep, "geometry")
		unitTest:assertNotNil(layerInfo.sid)
		
		rmFile(proj.file)
	end,
	addTifLayer = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		if isFile(proj.file) then
			rmFile(proj.file)
		end
		
		tl:createProject(proj, {})
		
		local layerName = "TifLayer"
		local layerFile = filePath("cbers_rgb342_crop1.tif", "terralib")
		tl:addTifLayer(proj, layerName, layerFile)
		
		local layerInfo = tl:getLayerInfo(proj, proj.layers[layerName])
		
		unitTest:assertEquals(layerInfo.name, layerName)
		unitTest:assertEquals(layerInfo.file, layerFile)
		unitTest:assertEquals(layerInfo.type, "GDAL")
		unitTest:assertEquals(layerInfo.rep, "raster")
		unitTest:assertNotNil(layerInfo.sid)
		
		rmFile(proj.file)
	end,
	copyLayer = function(unitTest)
		-- see in addPgLayer() test --
		unitTest:assert(true)
	end,
	addShpCellSpaceLayer = function(unitTest)
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
		
				
		local clName = "Sampa_Cells"
		local testDir = _Gtme.makePathCompatibleToAllOS(currentDir())
		local shp1 = clName..".shp"
		local filePath1 = testDir.."/"..shp1	
		local fn1 = getFileName(filePath1)
		fn1 = testDir.."/"..fn1	

		local exts = {".dbf", ".prj", ".shp", ".shx"}
		
		for i = 1, #exts do
			local f = fn1..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end	
		
		local resolution = 0.7
		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, filePath1)
		
		local layerInfo = tl:getLayerInfo(proj, proj.layers[clName])
		
		unitTest:assertEquals(layerInfo.name, clName)
		unitTest:assertEquals(layerInfo.file, filePath1)
		unitTest:assertEquals(layerInfo.type, "OGR")
		unitTest:assertEquals(layerInfo.rep, "geometry")
		unitTest:assertNotNil(layerInfo.sid)

		for i = 1, #exts do
			local f = fn1..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end	
		
		rmFile(proj.file)
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
		
		
		local testDir = _Gtme.makePathCompatibleToAllOS(currentDir())
		local shp = {}
		local fn = {}
		
		local clName = "Para_Cells"
		shp[1] = clName..".shp"
		local filePath1 = testDir.."/"..shp[1]	
		fn[1] = getFileName(filePath1)
		fn[1] = testDir.."/"..fn[1]	

		local exts = {".dbf", ".prj", ".shp", ".shx"}
		
		for i = 1, #exts do
			local f = fn[1]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end	
		
		-- CREATE THE CELLULAR SPACE
		local resolution = 60e3
		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, filePath1)
		
		local clSet = tl:getDataSet(proj, clName)
		
		unitTest:assertEquals(getn(clSet), 402)
		
		for k, v in pairs(clSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID"))
			unitTest:assertNotNil(v)
		end			
		
		local clLayerInfo = tl:getLayerInfo(proj, proj.layers[clName])
		
		unitTest:assertEquals(clLayerInfo.name, clName)
		unitTest:assertEquals(clLayerInfo.file, filePath1)
		unitTest:assertEquals(clLayerInfo.type, "OGR")
		unitTest:assertEquals(clLayerInfo.rep, "geometry")
		unitTest:assertNotNil(clLayerInfo.sid)
		
		-- CREATE A LAYER WITH POLYGONS TO DO OPERATIONS
		local layerName2 = "Protection_Unit" 
		local layerFile2 = filePath("BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "terralib")
		tl:addShpLayer(proj, layerName2, layerFile2)
		
		-- SHAPE OUTPUT
		-- FILL CELLULAR SPACE WITH PRESENCE OPERATION
		local presLayerName = clName.."_"..layerName2.."_Presence"		
		shp[2] = presLayerName..".shp"
		local filePath2 = testDir.."/"..shp[2]	
		fn[2] = getFileName(filePath2)
		fn[2] = testDir.."/"..fn[2]	
		
		for i = 1, #exts do
			local f = fn[2]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end	
		
		local operation = "presence"
		local attribute = "presence"
		local select = "FID"
		local area = nil
		local default = nil
		tl:attributeFill(proj, layerName2, clName, presLayerName, attribute, operation, select, area, default)
		
		local presSet = tl:getDataSet(proj, presLayerName)
		
		unitTest:assertEquals(getn(presSet), 402)
		
		for k, v in pairs(presSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence"))
			unitTest:assertNotNil(v)
		end		

		local presLayerInfo = tl:getLayerInfo(proj, proj.layers[presLayerName])
		unitTest:assertEquals(presLayerInfo.name, presLayerName)
		unitTest:assertEquals(presLayerInfo.file, filePath2)
		unitTest:assertEquals(presLayerInfo.type, "OGR")
		unitTest:assertEquals(presLayerInfo.rep, "geometry")
		unitTest:assertNotNil(presLayerInfo.sid)
		
		-- FILL CELLULAR SPACE WITH PERCENTAGE TOTAL AREA OPERATION
		local areaLayerName = clName.."_"..layerName2.."_Area"		
		shp[3] = areaLayerName..".shp"
		local filePath3 = testDir.."/"..shp[3]	
		fn[3] = getFileName(filePath3)
		fn[3] = testDir.."/"..fn[3]	
		
		for i = 1, #exts do
			local f = fn[3]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "area"
		attribute = "area_perce" -- the attribute must have 10 characters (ogr truncate)
		select = "FID"
		area = nil
		default = 0
		tl:attributeFill(proj, layerName2, presLayerName, areaLayerName, attribute, operation, select, area, default)
		
		local areaSet = tl:getDataSet(proj, areaLayerName)
		
		unitTest:assertEquals(getn(areaSet), 402)
		
		for k, v in pairs(areaSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce"))
			unitTest:assertNotNil(v)
		end		

		local areaLayerInfo = tl:getLayerInfo(proj, proj.layers[areaLayerName])
		unitTest:assertEquals(areaLayerInfo.name, areaLayerName)
		unitTest:assertEquals(areaLayerInfo.file, filePath3)
		unitTest:assertEquals(areaLayerInfo.type, "OGR")
		unitTest:assertEquals(areaLayerInfo.rep, "geometry")
		unitTest:assertNotNil(areaLayerInfo.sid)		
		
		-- FILL CELLULAR SPACE WITH COUNT OPERATION
		local countLayerName = clName.."_"..layerName2.."_Count"		
		shp[4] = countLayerName..".shp"
		local filePath4 = testDir.."/"..shp[4]	
		fn[4] = getFileName(filePath4)
		fn[4] = testDir.."/"..fn[4]	
		
		for i = 1, #exts do
			local f = fn[4]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "count"
		attribute = "count"
		select = "FID"
		area = nil
		default = 0
		tl:attributeFill(proj, layerName2, areaLayerName, countLayerName, attribute, operation, select, area, default)
		
		local countSet = tl:getDataSet(proj, countLayerName)
		
		unitTest:assertEquals(getn(countSet), 402)
		
		for k, v in pairs(countSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count"))
			unitTest:assertNotNil(v)
		end		

		local countLayerInfo = tl:getLayerInfo(proj, proj.layers[countLayerName])
		unitTest:assertEquals(countLayerInfo.name, countLayerName)
		unitTest:assertEquals(countLayerInfo.file, filePath4)
		unitTest:assertEquals(countLayerInfo.type, "OGR")
		unitTest:assertEquals(countLayerInfo.rep, "geometry")
		unitTest:assertNotNil(countLayerInfo.sid)	

		-- FILL CELLULAR SPACE WITH DISTANCE OPERATION
		local distLayerName = clName.."_"..layerName2.."_Distance"		
		shp[5] = distLayerName..".shp"
		local filePath5 = testDir.."/"..shp[5]	
		fn[5] = getFileName(filePath5)
		fn[5] = testDir.."/"..fn[5]	
		
		for i = 1, #exts do
			local f = fn[5]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "distance"
		attribute = "distance"
		select = "FID"
		area = nil
		default = nil
		tl:attributeFill(proj, layerName2, countLayerName, distLayerName, attribute, operation, select, area, default)
		
		local distSet = tl:getDataSet(proj, distLayerName)
		
		unitTest:assertEquals(getn(distSet), 402)
		
		for k, v in pairs(distSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance"))
			unitTest:assertNotNil(v)
		end		

		local distLayerInfo = tl:getLayerInfo(proj, proj.layers[distLayerName])
		unitTest:assertEquals(distLayerInfo.name, distLayerName)
		unitTest:assertEquals(distLayerInfo.file, filePath5)
		unitTest:assertEquals(distLayerInfo.type, "OGR")
		unitTest:assertEquals(distLayerInfo.rep, "geometry")
		unitTest:assertNotNil(distLayerInfo.sid)			

		-- FILL CELLULAR SPACE WITH MINIMUM OPERATION
		local layerName3 = "Amazon_Munic" 
		local layerFile3 = filePath("municipiosAML_ok.shp", "terralib")
		tl:addShpLayer(proj, layerName3, layerFile3)		
		
		local minLayerName = clName.."_"..layerName3.."_Minimum"		
		shp[6] = minLayerName..".shp"
		local filePath6 = testDir.."/"..shp[6]	
		fn[6] = getFileName(filePath6)
		fn[6] = testDir.."/"..fn[6]	
		
		for i = 1, #exts do
			local f = fn[6]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "minimum"
		attribute = "minimum"
		select = "POPULACAO_"
		area = nil
		default = nil
		tl:attributeFill(proj, layerName3, distLayerName, minLayerName, attribute, operation, select, area, default)
		
		local minSet = tl:getDataSet(proj, minLayerName)
		
		unitTest:assertEquals(getn(minSet), 402)
		
		for k, v in pairs(minSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or 
							(k == "minimum"))
			unitTest:assertNotNil(v)
		end		

		local minLayerInfo = tl:getLayerInfo(proj, proj.layers[minLayerName])
		unitTest:assertEquals(minLayerInfo.name, minLayerName)
		unitTest:assertEquals(minLayerInfo.file, filePath6)
		unitTest:assertEquals(minLayerInfo.type, "OGR")
		unitTest:assertEquals(minLayerInfo.rep, "geometry")
		unitTest:assertNotNil(minLayerInfo.sid)	
		
		-- FILL CELLULAR SPACE WITH MAXIMUM OPERATION
		local maxLayerName = clName.."_"..layerName3.."_Maximum"		
		shp[7] = maxLayerName..".shp"
		local filePath7 = testDir.."/"..shp[7]	
		fn[7] = getFileName(filePath7)
		fn[7] = testDir.."/"..fn[7]	
		
		for i = 1, #exts do
			local f = fn[7]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "maximum"
		attribute = "maximum"
		select = "POPULACAO_"
		area = nil
		default = nil
		tl:attributeFill(proj, layerName3, minLayerName, maxLayerName, attribute, operation, select, area, default)
		
		local maxSet = tl:getDataSet(proj, maxLayerName)
		
		unitTest:assertEquals(getn(maxSet), 402)
		
		for k, v in pairs(maxSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or 
							(k == "minimum") or (k == "maximum"))
			unitTest:assertNotNil(v)
		end		

		local maxLayerInfo = tl:getLayerInfo(proj, proj.layers[maxLayerName])
		unitTest:assertEquals(maxLayerInfo.name, maxLayerName)
		unitTest:assertEquals(maxLayerInfo.file, filePath7)
		unitTest:assertEquals(maxLayerInfo.type, "OGR")
		unitTest:assertEquals(maxLayerInfo.rep, "geometry")
		unitTest:assertNotNil(maxLayerInfo.sid)			
		
		-- FILL CELLULAR SPACE WITH PERCENTAGE OPERATION
		local percLayerName = clName.."_"..layerName2.."_Percentage"		
		shp[8] = percLayerName..".shp"
		local filePath8 = testDir.."/"..shp[8]	
		fn[8] = getFileName(filePath8)
		fn[8] = testDir.."/"..fn[8]	
		
		for i = 1, #exts do
			local f = fn[8]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "percentage"
		attribute = "perc"
		select = "ADMINISTRA"
		area = nil
		default = nil
		tl:attributeFill(proj, layerName2, maxLayerName, percLayerName, attribute, operation, select, area, default)
		
		local percentSet = tl:getDataSet(proj, percLayerName)
		
		unitTest:assertEquals(getn(percentSet), 402)
		
		for k, v in pairs(percentSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or 
							(k == "minimum") or (k == "maximum") or (string.match(k, "ADMIN") ~= nil))
			unitTest:assertNotNil(v)
		end		

		local percLayerInfo = tl:getLayerInfo(proj, proj.layers[percLayerName])
		unitTest:assertEquals(percLayerInfo.name, percLayerName)
		unitTest:assertEquals(percLayerInfo.file, filePath8)
		unitTest:assertEquals(percLayerInfo.type, "OGR")
		unitTest:assertEquals(percLayerInfo.rep, "geometry")
		unitTest:assertNotNil(percLayerInfo.sid)	

		-- FILL CELLULAR SPACE WITH STANDART DERIVATION OPERATION
		local stdevLayerName = clName.."_"..layerName3.."_Stdev"		
		shp[9] = stdevLayerName..".shp"
		local filePath9 = testDir.."/"..shp[9]	
		fn[9] = getFileName(filePath9)
		fn[9] = testDir.."/"..fn[9]	
		
		for i = 1, #exts do
			local f = fn[9]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "stdev"
		attribute = "stdev"
		select = "POPULACAO_"
		area = nil
		default = nil
		tl:attributeFill(proj, layerName3, percLayerName, stdevLayerName, attribute, operation, select, area, default)
		
		local stdevSet = tl:getDataSet(proj, stdevLayerName)
		
		unitTest:assertEquals(getn(stdevSet), 402)
		
		for k, v in pairs(stdevSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or 
							(k == "minimum") or (k == "maximum") or (string.match(k, "ADMIN") ~= nil) or 
							(k == "stdev"))
			unitTest:assertNotNil(v)
		end		

		local stdevLayerInfo = tl:getLayerInfo(proj, proj.layers[stdevLayerName])
		unitTest:assertEquals(stdevLayerInfo.name, stdevLayerName)
		unitTest:assertEquals(stdevLayerInfo.file, filePath9)
		unitTest:assertEquals(stdevLayerInfo.type, "OGR")
		unitTest:assertEquals(stdevLayerInfo.rep, "geometry")
		unitTest:assertNotNil(stdevLayerInfo.sid)			
		
		-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION
		local meanLayerName = clName.."_"..layerName3.."_AvrgMean"		
		shp[10] = meanLayerName..".shp"
		local filePath10 = testDir.."/"..shp[10]	
		fn[10] = getFileName(filePath10)
		fn[10] = testDir.."/"..fn[10]	
		
		for i = 1, #exts do
			local f = fn[10]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "average"
		attribute = "mean"
		select = "POPULACAO_"
		area = false
		default = nil
		tl:attributeFill(proj, layerName3, stdevLayerName, meanLayerName, attribute, operation, select, area, default)
		
		local meanSet = tl:getDataSet(proj, meanLayerName)
		
		unitTest:assertEquals(getn(meanSet), 402)
		
		for k, v in pairs(meanSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or 
							(k == "minimum") or (k == "maximum") or (string.match(k, "ADMIN") ~= nil) or 
							(k == "stdev") or (k == "mean"))
			unitTest:assertNotNil(v)
		end		

		local meanLayerInfo = tl:getLayerInfo(proj, proj.layers[meanLayerName])
		unitTest:assertEquals(meanLayerInfo.name, meanLayerName)
		unitTest:assertEquals(meanLayerInfo.file, filePath10)
		unitTest:assertEquals(meanLayerInfo.type, "OGR")
		unitTest:assertEquals(meanLayerInfo.rep, "geometry")
		unitTest:assertNotNil(meanLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION
		local weighLayerName = clName.."_"..layerName3.."_AvrgWeighted"		
		shp[11] = weighLayerName..".shp"
		local filePath11 = testDir.."/"..shp[11]	
		fn[11] = getFileName(filePath11)
		fn[11] = testDir.."/"..fn[11]	
		
		for i = 1, #exts do
			local f = fn[11]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "average"
		attribute = "weighted"
		select = "POPULACAO_"
		area = true
		default = nil
		tl:attributeFill(proj, layerName3, meanLayerName, weighLayerName, attribute, operation, select, area, default)
		
		local weighSet = tl:getDataSet(proj, weighLayerName)
		
		unitTest:assertEquals(getn(weighSet), 402)
		
		for k, v in pairs(weighSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or 
							(k == "minimum") or (k == "maximum") or (string.match(k, "ADMIN") ~= nil) or 
							(k == "stdev") or (k == "mean") or (k == "weighted"))
			unitTest:assertNotNil(v)
		end		
		
		local weighLayerInfo = tl:getLayerInfo(proj, proj.layers[weighLayerName])
		unitTest:assertEquals(weighLayerInfo.name, weighLayerName)
		unitTest:assertEquals(weighLayerInfo.file, filePath11)
		unitTest:assertEquals(weighLayerInfo.type, "OGR")
		unitTest:assertEquals(weighLayerInfo.rep, "geometry")
		unitTest:assertNotNil(weighLayerInfo.sid)		
		
		-- FILL CELLULAR SPACE WITH MAJORITY INTERSECTION OPERATION
		local interLayerName = clName.."_"..layerName3.."_Intersection"		
		shp[12] = interLayerName..".shp"
		local filePath12 = testDir.."/"..shp[12]	
		fn[12] = getFileName(filePath12)
		fn[12] = testDir.."/"..fn[12]	
		
		for i = 1, #exts do
			local f = fn[12]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "majority"
		attribute = "majo_int"
		select = "POPULACAO_"
		area = true
		default = nil
		tl:attributeFill(proj, layerName3, weighLayerName, interLayerName, attribute, operation, select, area, default)
		
		local interSet = tl:getDataSet(proj, interLayerName)
		
		unitTest:assertEquals(getn(interSet), 402)
		
		for k, v in pairs(interSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or 
							(k == "minimum") or (k == "maximum") or (string.match(k, "ADMIN") ~= nil) or 
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int"))
			unitTest:assertNotNil(v)
		end		
		
		local interLayerInfo = tl:getLayerInfo(proj, proj.layers[interLayerName])
		unitTest:assertEquals(interLayerInfo.name, interLayerName)
		unitTest:assertEquals(interLayerInfo.file, filePath12)
		unitTest:assertEquals(interLayerInfo.type, "OGR")
		unitTest:assertEquals(interLayerInfo.rep, "geometry")
		unitTest:assertNotNil(interLayerInfo.sid)			
		
		-- FILL CELLULAR SPACE WITH MAJORITY OCCURRENCE OPERATION
		local occurLayerName = clName.."_"..layerName3.."_Occurence"		
		shp[13] = occurLayerName..".shp"
		local filePath13 = testDir.."/"..shp[13]	
		fn[13] = getFileName(filePath13)
		fn[13] = testDir.."/"..fn[13]	
		
		for i = 1, #exts do
			local f = fn[13]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "majority"
		attribute = "majo_occur"
		select = "POPULACAO_"
		area = false
		default = nil
		tl:attributeFill(proj, layerName3, interLayerName, occurLayerName, attribute, operation, select, area, default)
		
		local occurSet = tl:getDataSet(proj, occurLayerName)
		
		unitTest:assertEquals(getn(occurSet), 402)
		
		for k, v in pairs(occurSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or 
							(k == "minimum") or (k == "maximum") or (string.match(k, "ADMIN") ~= nil) or 
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or 
							(k == "majo_occur"))
			unitTest:assertNotNil(v)
		end		
		
		local occurLayerInfo = tl:getLayerInfo(proj, proj.layers[occurLayerName])
		unitTest:assertEquals(occurLayerInfo.name, occurLayerName)
		unitTest:assertEquals(occurLayerInfo.file, filePath13)
		unitTest:assertEquals(occurLayerInfo.type, "OGR")
		unitTest:assertEquals(occurLayerInfo.rep, "geometry")
		unitTest:assertNotNil(occurLayerInfo.sid)	
		
		-- FILL CELLULAR SPACE WITH SUM OPERATION
		local sumLayerName = clName.."_"..layerName3.."_Sum"		
		shp[14] = sumLayerName..".shp"
		local filePath14 = testDir.."/"..shp[14]	
		fn[14] = getFileName(filePath14)
		fn[14] = testDir.."/"..fn[14]	
		
		for i = 1, #exts do
			local f = fn[14]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "sum"
		attribute = "sum"
		select = "POPULACAO_"
		area = false
		default = nil
		tl:attributeFill(proj, layerName3, occurLayerName, sumLayerName, attribute, operation, select, area, default)
		
		local sumSet = tl:getDataSet(proj, sumLayerName)
		
		unitTest:assertEquals(getn(sumSet), 402)
		
		for k, v in pairs(sumSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or 
							(k == "minimum") or (k == "maximum") or (string.match(k, "ADMIN") ~= nil) or 
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or 
							(k == "majo_occur") or (k == "sum"))
			unitTest:assertNotNil(v)
		end		
		
		local sumLayerInfo = tl:getLayerInfo(proj, proj.layers[sumLayerName])
		unitTest:assertEquals(sumLayerInfo.name, sumLayerName)
		unitTest:assertEquals(sumLayerInfo.file, filePath14)
		unitTest:assertEquals(sumLayerInfo.type, "OGR")
		unitTest:assertEquals(sumLayerInfo.rep, "geometry")
		unitTest:assertNotNil(sumLayerInfo.sid)		

		-- FILL CELLULAR SPACE WITH WEIGHTED SUM OPERATION
		local wsumLayerName = clName.."_"..layerName3.."_Wsum"		
		shp[15] = wsumLayerName..".shp"
		local filePath15 = testDir.."/"..shp[15]	
		fn[15] = getFileName(filePath15)
		fn[15] = testDir.."/"..fn[15]	
		
		for i = 1, #exts do
			local f = fn[15]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "sum"
		attribute = "wsum"
		select = "POPULACAO_"
		area = true
		default = nil
		tl:attributeFill(proj, layerName3, sumLayerName, wsumLayerName, attribute, operation, select, area, default)
		
		local wsumSet = tl:getDataSet(proj, wsumLayerName)
		
		unitTest:assertEquals(getn(wsumSet), 402)
		
		for k, v in pairs(wsumSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or 
							(k == "minimum") or (k == "maximum") or (string.match(k, "ADMIN") ~= nil) or 
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or 
							(k == "majo_occur") or (k == "sum") or (k == "wsum"))
			unitTest:assertNotNil(v)
		end		
		
		local wsumLayerInfo = tl:getLayerInfo(proj, proj.layers[wsumLayerName])
		unitTest:assertEquals(wsumLayerInfo.name, wsumLayerName)
		unitTest:assertEquals(wsumLayerInfo.file, filePath15)
		unitTest:assertEquals(wsumLayerInfo.type, "OGR")
		unitTest:assertEquals(wsumLayerInfo.rep, "geometry")
		unitTest:assertNotNil(wsumLayerInfo.sid)						
		
		-- RASTER TESTS WITH POSTGIS
		-- FILL CELLULAR SPACE WITH PERCENTAGE OPERATION USING TIF
		local layerName4 = "Prodes_PA" 
		local layerFile4 = filePath("prodes_polyc_10k.tif", "terralib")
		tl:addTifLayer(proj, layerName4, layerFile4)		
		
		local percTifLayerName = clName.."_"..layerName4.."_RPercentage"		
		shp[16] = percTifLayerName..".shp"
		local filePath16 = testDir.."/"..shp[16]	
		fn[16] = getFileName(filePath16)
		fn[16] = testDir.."/"..fn[16]	
		
		for i = 1, #exts do
			local f = fn[16]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "percentage"
		attribute = "rperc"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, wsumLayerName, percTifLayerName, attribute, operation, select, area, default)
		
		local percentSet = tl:getDataSet(proj, percTifLayerName)
		
		unitTest:assertEquals(getn(percentSet), 402) 
		
		for k, v in pairs(percentSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or 
							(k == "minimum") or (k == "maximum") or (string.match(k, "ADMIN") ~= nil) or 
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or 
							(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rperc") ~= nil))
			unitTest:assertNotNil(v) 
		end		

		local percTifLayerInfo = tl:getLayerInfo(proj, proj.layers[percTifLayerName]) 
		unitTest:assertEquals(percTifLayerInfo.name, percTifLayerName)
		unitTest:assertEquals(percTifLayerInfo.file, filePath16)
		unitTest:assertEquals(percTifLayerInfo.type, "OGR")
		unitTest:assertEquals(percTifLayerInfo.rep, "geometry")
		unitTest:assertNotNil(percTifLayerInfo.sid)					
		
		-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION FROM RASTER
		local rmeanLayerName = clName.."_"..layerName4.."_RMean"		
		shp[17] = rmeanLayerName..".shp"
		local filePath17 = testDir.."/"..shp[17]	
		fn[17] = getFileName(filePath17)
		fn[17] = testDir.."/"..fn[17]	
		
		for i = 1, #exts do
			local f = fn[17]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "average"
		attribute = "rmean"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, percTifLayerName, rmeanLayerName, attribute, operation, select, area, default)
		
		local rmeanSet = tl:getDataSet(proj, rmeanLayerName)
		
		unitTest:assertEquals(getn(rmeanSet), 402)
		
		for k, v in pairs(rmeanSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or 
							(k == "minimum") or (k == "maximum") or (string.match(k, "ADMIN") ~= nil) or 
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or 
							(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rperc") ~= nil) or 
							(k == "rmean"))
			unitTest:assertNotNil(v)
		end		

		local rmeanLayerInfo = tl:getLayerInfo(proj, proj.layers[rmeanLayerName])
		unitTest:assertEquals(rmeanLayerInfo.name, rmeanLayerName)
		unitTest:assertEquals(rmeanLayerInfo.file, filePath17)
		unitTest:assertEquals(rmeanLayerInfo.type, "OGR")
		unitTest:assertEquals(rmeanLayerInfo.rep, "geometry")
		unitTest:assertNotNil(rmeanLayerInfo.sid)			
		
		-- FILL CELLULAR SPACE WITH MINIMUM OPERATION FROM RASTER
		local rminLayerName = clName.."_"..layerName4.."_RMinimum"		
		shp[18] = rminLayerName..".shp"
		local filePath18 = testDir.."/"..shp[18]	
		fn[18] = getFileName(filePath18)
		fn[18] = testDir.."/"..fn[18]	
		
		for i = 1, #exts do
			local f = fn[18]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "minimum"
		attribute = "rmin"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, rmeanLayerName, rminLayerName, attribute, operation, select, area, default)
		
		local rminSet = tl:getDataSet(proj, rminLayerName)
		
		unitTest:assertEquals(getn(rminSet), 402)
		
		for k, v in pairs(rminSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or 
							(k == "minimum") or (k == "maximum") or (string.match(k, "ADMIN") ~= nil) or 
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or 
							(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rperc") ~= nil) or 
							(k == "rmean") or (k == "rmin"))
			unitTest:assertNotNil(v)
		end		

		local rminLayerInfo = tl:getLayerInfo(proj, proj.layers[rminLayerName])
		unitTest:assertEquals(rminLayerInfo.name, rminLayerName)
		unitTest:assertEquals(rminLayerInfo.file, filePath18)
		unitTest:assertEquals(rminLayerInfo.type, "OGR")
		unitTest:assertEquals(rminLayerInfo.rep, "geometry")
		unitTest:assertNotNil(rminLayerInfo.sid)		
		
		-- FILL CELLULAR SPACE WITH MAXIMUM OPERATION FROM RASTER
		local rmaxLayerName = clName.."_"..layerName4.."_RMaximum"		
		shp[19] = rmaxLayerName..".shp"
		local filePath19 = testDir.."/"..shp[19]	
		fn[19] = getFileName(filePath19)
		fn[19] = testDir.."/"..fn[19]	
		
		for i = 1, #exts do
			local f = fn[19]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "maximum"
		attribute = "rmax"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, rminLayerName, rmaxLayerName, attribute, operation, select, area, default)
		
		local rmaxSet = tl:getDataSet(proj, rmaxLayerName)
		
		unitTest:assertEquals(getn(rmaxSet), 402)
		
		for k, v in pairs(rmaxSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or 
							(k == "minimum") or (k == "maximum") or (string.match(k, "ADMIN") ~= nil) or 
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or 
							(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rperc") ~= nil) or 
							(k == "rmean") or (k == "rmin") or (k == "rmax"))
			unitTest:assertNotNil(v)
		end		

		local rmaxLayerInfo = tl:getLayerInfo(proj, proj.layers[rmaxLayerName])
		unitTest:assertEquals(rmaxLayerInfo.name, rmaxLayerName)
		unitTest:assertEquals(rmaxLayerInfo.file, filePath19)
		unitTest:assertEquals(rmaxLayerInfo.type, "OGR")
		unitTest:assertEquals(rmaxLayerInfo.rep, "geometry")
		unitTest:assertNotNil(rmaxLayerInfo.sid)	

		-- FILL CELLULAR SPACE WITH STANDART DERIVATION OPERATION FROM RASTER
		local rstdevLayerName = clName.."_"..layerName4.."_RStdev"		
		shp[20] = rstdevLayerName..".shp"
		local filePath20 = testDir.."/"..shp[20]	
		fn[20] = getFileName(filePath20)
		fn[20] = testDir.."/"..fn[20]	
		
		for i = 1, #exts do
			local f = fn[20]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "stdev"
		attribute = "rstdev"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, rmaxLayerName, rstdevLayerName, attribute, operation, select, area, default)
		
		local rstdevSet = tl:getDataSet(proj, rstdevLayerName)
		
		unitTest:assertEquals(getn(rstdevSet), 402)
		
		for k, v in pairs(rstdevSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or 
							(k == "minimum") or (k == "maximum") or (string.match(k, "ADMIN") ~= nil) or 
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or 
							(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rperc") ~= nil) or 
							(k == "rmean") or (k == "rmin") or (k == "rmax") or (k == "rstdev"))
			unitTest:assertNotNil(v)
		end		

		local rstdevLayerInfo = tl:getLayerInfo(proj, proj.layers[rstdevLayerName])
		unitTest:assertEquals(rstdevLayerInfo.name, rstdevLayerName)
		unitTest:assertEquals(rstdevLayerInfo.file, filePath20)
		unitTest:assertEquals(rstdevLayerInfo.type, "OGR")
		unitTest:assertEquals(rstdevLayerInfo.rep, "geometry")
		unitTest:assertNotNil(rstdevLayerInfo.sid)		

		-- FILL CELLULAR SPACE WITH SUM OPERATION FROM RASTER
		local rsumLayerName = clName.."_"..layerName4.."_RSum"		
		shp[21] = rsumLayerName..".shp"
		local filePath21 = testDir.."/"..shp[21]	
		fn[21] = getFileName(filePath21)
		fn[21] = testDir.."/"..fn[21]	
		
		for i = 1, #exts do
			local f = fn[21]..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		operation = "sum"
		attribute = "rsum"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, rstdevLayerName, rsumLayerName, attribute, operation, select, area, default)
		
		local rsumSet = tl:getDataSet(proj, rsumLayerName)
		
		unitTest:assertEquals(getn(rsumSet), 402)
		
		for k, v in pairs(rsumSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or 
							(k == "minimum") or (k == "maximum") or (string.match(k, "ADMIN") ~= nil) or 
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or 
							(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rperc") ~= nil) or 
							(k == "rmean") or (k == "rmin") or (k == "rmax") or (k == "rstdev") or (k == "rsum"))
			unitTest:assertNotNil(v)
		end		

		local rsumLayerInfo = tl:getLayerInfo(proj, proj.layers[rsumLayerName])
		unitTest:assertEquals(rsumLayerInfo.name, rsumLayerName)
		unitTest:assertEquals(rsumLayerInfo.file, filePath21)
		unitTest:assertEquals(rsumLayerInfo.type, "OGR")
		unitTest:assertEquals(rsumLayerInfo.rep, "geometry")
		unitTest:assertNotNil(rsumLayerInfo.sid)					
		
		-- END
		tl:finalize()
		
		for i = 1, #exts do
			for j = 1, #fn do
				local f = fn[j]..exts[i]
				if isFile(f) then
					rmFile(f)
				end		
			end
		end	
		
		rmFile(proj.file)						
	end,
	getDataSet = function(unitTest)
		-- see in saveDataSet() test --
		unitTest:assert(true)
	end,
	saveDataSet = function(unitTest)
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
		
		unitTest:assert(true)
		
		rmFile(proj.file)
	end,
	getShpByFilePath = function(unitTest)
		local tl = TerraLib{}
		local shpPath = filePath("sampa.shp", "terralib")
		local dSet = tl:getShpByFilePath(shpPath)
		
		unitTest:assertEquals(getn(dSet), 63)

		for i = 0, #dSet do
			unitTest:assertEquals(dSet[i].FID, i)

			for k, v in pairs(dSet[i]) do
				unitTest:assert((k == "FID") or (k == "ID") or (k == "NM_MICRO") or 
								(k == "CD_GEOCODU") or (k == "OGR_GEOMETRY"))
				unitTest:assertNotNil(v)
			end
		end		
	end	
}