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
		unitTest:assertEquals(layerInfo.rep, "polygon")
		unitTest:assertNotNil(layerInfo.sid)

		rmFile(proj.file)
		
		-- SPATIAL INDEX TEST
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		if isFile(proj.file) then
			rmFile(proj.file)
		end
		
		tl:createProject(proj, {})
		
		local layerName1 = "ShapeLayer1"
		local layerFile = filePath("sampa.shp", "terralib")
		local qixFile = string.gsub(layerFile, ".shp", ".qix")
		rmFile(qixFile)
		local addSpatialIdx = false
		tl:addShpLayer(proj, layerName1, layerFile, addSpatialIdx)
		unitTest:assert(not isFile(qixFile))
		
		local layerName2 = "ShapeLayer2"
		local addSpatialIdx = true
		tl:addShpLayer(proj, layerName1, layerFile, addSpatialIdx)
		unitTest:assert(isFile(qixFile))
		
		rmFile(proj.file)		
		-- // SPATIAL INDEX TEST
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
		local shp1 = clName..".shp"

		if isFile(shp1) then
			rmFile(shp1)
		end	
		
		local resolution = 0.7
		local mask = true
		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp1, mask)
		
		local layerInfo = tl:getLayerInfo(proj, proj.layers[clName])
		
		unitTest:assertEquals(layerInfo.name, clName)
		unitTest:assertEquals(layerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp1)
		unitTest:assertEquals(layerInfo.type, "OGR")
		unitTest:assertEquals(layerInfo.rep, "polygon")
		unitTest:assertNotNil(layerInfo.sid)

		-- NO MASK TEST
		local clSet = tl:getDataSet(proj, clName)
		unitTest:assertEquals(getn(clSet), 68)
		
		clName = clName.."_NoMask"
		local shp2 = clName..".shp"
		
		if isFile(shp2) then
			rmFile(shp2)
		end			
		
		mask = false
		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp2, mask)
		
		clSet = tl:getDataSet(proj, clName)
		unitTest:assertEquals(getn(clSet), 104)
		-- // NO MASK TEST
		
		-- SPATIAL INDEX TEST
		clName = "Sampa_Cells_NOSIDX"
		local shp3 = clName..".shp"
		local addSpatialIdx = false
		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp3, mask, addSpatialIdx)
		local qixFile1 = string.gsub(shp3, ".shp", ".qix")
		unitTest:assert(not isFile(qixFile1))
		
		clName = "Sampa_Cells_SIDX"
		local shp4 = clName..".shp"
		local addSpatialIdx = true
		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp4, mask, addSpatialIdx)
		local qixFile2 = string.gsub(shp4, ".shp", ".qix")
		unitTest:assert(isFile(qixFile2))
		-- // SPATIAL INDEX TEST
		
		-- END
		if isFile(shp1) then
			rmFile(shp1)
		end	
		
		if isFile(shp2) then
			rmFile(shp2)
		end			
		
		if isFile(shp3) then
			rmFile(shp3)
		end			
		
		if isFile(shp4) then
			rmFile(shp4)
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
		
		tl:createProject(proj, {})

		local layerName1 = "Para"
		local layerFile1 = filePath("limitePA_polyc_pol.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)		
		
		local shp = {}

		local clName = "Para_Cells"
		shp[1] = clName..".shp"

		if isFile(shp[1]) then
			rmFile(shp[1])
		end
		
		-- CREATE THE CELLULAR SPACE
		local resolution = 60e3
		local mask = true
		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp[1], mask)
		
		local clSet = tl:getDataSet(proj, clName)
		
		unitTest:assertEquals(getn(clSet), 402)
		
		for k, v in pairs(clSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID"))
			unitTest:assertNotNil(v)
		end			
		
		local clLayerInfo = tl:getLayerInfo(proj, proj.layers[clName])
		
		unitTest:assertEquals(clLayerInfo.name, clName)
		unitTest:assertEquals(clLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[1])
		unitTest:assertEquals(clLayerInfo.type, "OGR")
		unitTest:assertEquals(clLayerInfo.rep, "polygon")
		unitTest:assertNotNil(clLayerInfo.sid)
		
		-- CREATE A LAYER WITH POLYGONS TO DO OPERATIONS
		local layerName2 = "Protection_Unit" 
		local layerFile2 = filePath("BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "terralib")
		tl:addShpLayer(proj, layerName2, layerFile2)
		
		-- SHAPE OUTPUT
		-- FILL CELLULAR SPACE WITH PRESENCE OPERATION
		local presLayerName = clName.."_"..layerName2.."_Presence"		
		shp[2] = presLayerName..".shp"
		
		if isFile(shp[2]) then
			rmFile(shp[2])
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
		unitTest:assertEquals(presLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[2])
		unitTest:assertEquals(presLayerInfo.type, "OGR")
		unitTest:assertEquals(presLayerInfo.rep, "polygon")
		unitTest:assertNotNil(presLayerInfo.sid)
		
		-- FILL CELLULAR SPACE WITH PERCENTAGE TOTAL AREA OPERATION
		local areaLayerName = clName.."_"..layerName2.."_Area"		
		shp[3] = areaLayerName..".shp"
		
		if isFile(shp[3]) then
			rmFile(shp[3])
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
		unitTest:assertEquals(areaLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[3])
		unitTest:assertEquals(areaLayerInfo.type, "OGR")
		unitTest:assertEquals(areaLayerInfo.rep, "polygon")
		unitTest:assertNotNil(areaLayerInfo.sid)		
		
		-- FILL CELLULAR SPACE WITH COUNT OPERATION
		local countLayerName = clName.."_"..layerName2.."_Count"		
		shp[4] = countLayerName..".shp"
		
		if isFile(shp[4]) then
			rmFile(shp[4])
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
		unitTest:assertEquals(countLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[4])
		unitTest:assertEquals(countLayerInfo.type, "OGR")
		unitTest:assertEquals(countLayerInfo.rep, "polygon")
		unitTest:assertNotNil(countLayerInfo.sid)	

		-- FILL CELLULAR SPACE WITH DISTANCE OPERATION
		local distLayerName = clName.."_"..layerName2.."_Distance"		
		shp[5] = distLayerName..".shp"
		
		if isFile(shp[5]) then
			rmFile(shp[5])
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
		unitTest:assertEquals(distLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[5])
		unitTest:assertEquals(distLayerInfo.type, "OGR")
		unitTest:assertEquals(distLayerInfo.rep, "polygon")
		unitTest:assertNotNil(distLayerInfo.sid)			

		-- FILL CELLULAR SPACE WITH MINIMUM OPERATION
		local layerName3 = "Amazon_Munic" 
		local layerFile3 = filePath("municipiosAML_ok.shp", "terralib")
		tl:addShpLayer(proj, layerName3, layerFile3)		
		
		local minLayerName = clName.."_"..layerName3.."_Minimum"		
		shp[6] = minLayerName..".shp"
		
		if isFile(shp[6]) then
			rmFile(shp[6])
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
		unitTest:assertEquals(minLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[6])
		unitTest:assertEquals(minLayerInfo.type, "OGR")
		unitTest:assertEquals(minLayerInfo.rep, "polygon")
		unitTest:assertNotNil(minLayerInfo.sid)	
		
		-- FILL CELLULAR SPACE WITH MAXIMUM OPERATION
		local maxLayerName = clName.."_"..layerName3.."_Maximum"		
		shp[7] = maxLayerName..".shp"
		
		if isFile(shp[7]) then
			rmFile(shp[7])
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
		unitTest:assertEquals(maxLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[7])
		unitTest:assertEquals(maxLayerInfo.type, "OGR")
		unitTest:assertEquals(maxLayerInfo.rep, "polygon")
		unitTest:assertNotNil(maxLayerInfo.sid)			
		
		-- FILL CELLULAR SPACE WITH PERCENTAGE OPERATION
		local percLayerName = clName.."_"..layerName2.."_Percentage"		
		shp[8] = percLayerName..".shp"
		
		if isFile(shp[8]) then
			rmFile(shp[8])
		end
		
		operation = "coverage"
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
		unitTest:assertEquals(percLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[8])
		unitTest:assertEquals(percLayerInfo.type, "OGR")
		unitTest:assertEquals(percLayerInfo.rep, "polygon")
		unitTest:assertNotNil(percLayerInfo.sid)	

		-- FILL CELLULAR SPACE WITH STANDART DERIVATION OPERATION
		local stdevLayerName = clName.."_"..layerName3.."_Stdev"		
		shp[9] = stdevLayerName..".shp"
		
		if isFile(shp[9]) then
			rmFile(shp[9])
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
		unitTest:assertEquals(stdevLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[9])
		unitTest:assertEquals(stdevLayerInfo.type, "OGR")
		unitTest:assertEquals(stdevLayerInfo.rep, "polygon")
		unitTest:assertNotNil(stdevLayerInfo.sid)			
		
		-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION
		local meanLayerName = clName.."_"..layerName3.."_AvrgMean"		
		shp[10] = meanLayerName..".shp"
		
		if isFile(shp[10]) then
			rmFile(shp[10])
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
		unitTest:assertEquals(meanLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[10])
		unitTest:assertEquals(meanLayerInfo.type, "OGR")
		unitTest:assertEquals(meanLayerInfo.rep, "polygon")
		unitTest:assertNotNil(meanLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION
		local weighLayerName = clName.."_"..layerName3.."_AvrgWeighted"		
		shp[11] = weighLayerName..".shp"
		
		if isFile(shp[11]) then
			rmFile(shp[11])
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
		unitTest:assertEquals(weighLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[11])
		unitTest:assertEquals(weighLayerInfo.type, "OGR")
		unitTest:assertEquals(weighLayerInfo.rep, "polygon")
		unitTest:assertNotNil(weighLayerInfo.sid)		
		
		-- FILL CELLULAR SPACE WITH MAJORITY INTERSECTION OPERATION
		local interLayerName = clName.."_"..layerName3.."_Intersection"		
		shp[12] = interLayerName..".shp"
		
		if isFile(shp[12]) then
			rmFile(shp[12])
		end
		
		operation = "mode"
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
		unitTest:assertEquals(interLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[12])
		unitTest:assertEquals(interLayerInfo.type, "OGR")
		unitTest:assertEquals(interLayerInfo.rep, "polygon")
		unitTest:assertNotNil(interLayerInfo.sid)			
		
		-- FILL CELLULAR SPACE WITH MAJORITY OCCURRENCE OPERATION
		local occurLayerName = clName.."_"..layerName3.."_Occurence"		
		shp[13] = occurLayerName..".shp"
		
		if isFile(shp[13]) then
			rmFile(shp[13])
		end
		
		operation = "mode"
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
		unitTest:assertEquals(occurLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[13])
		unitTest:assertEquals(occurLayerInfo.type, "OGR")
		unitTest:assertEquals(occurLayerInfo.rep, "polygon")
		unitTest:assertNotNil(occurLayerInfo.sid)	
		
		-- FILL CELLULAR SPACE WITH SUM OPERATION
		local sumLayerName = clName.."_"..layerName3.."_Sum"		
		shp[14] = sumLayerName..".shp"
		
		if isFile(shp[14]) then
			rmFile(shp[14])
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
		unitTest:assertEquals(sumLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[14])
		unitTest:assertEquals(sumLayerInfo.type, "OGR")
		unitTest:assertEquals(sumLayerInfo.rep, "polygon")
		unitTest:assertNotNil(sumLayerInfo.sid)		

		-- FILL CELLULAR SPACE WITH WEIGHTED SUM OPERATION
		local wsumLayerName = clName.."_"..layerName3.."_Wsum"		
		shp[15] = wsumLayerName..".shp"
		
		if isFile(shp[15]) then
			rmFile(shp[15])
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
		unitTest:assertEquals(wsumLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[15])
		unitTest:assertEquals(wsumLayerInfo.type, "OGR")
		unitTest:assertEquals(wsumLayerInfo.rep, "polygon")
		unitTest:assertNotNil(wsumLayerInfo.sid)						
		
		-- RASTER TESTS WITH POSTGIS
		-- FILL CELLULAR SPACE WITH PERCENTAGE OPERATION USING TIF
		local layerName4 = "Prodes_PA" 
		local layerFile4 = filePath("prodes_polyc_10k.tif", "terralib")
		tl:addTifLayer(proj, layerName4, layerFile4)		
		
		local percTifLayerName = clName.."_"..layerName4.."_RPercentage"		
		shp[16] = percTifLayerName..".shp"
		
		if isFile(shp[16]) then
			rmFile(shp[16])
		end
		
		operation = "coverage"
		attribute = "rperc"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, wsumLayerName, percTifLayerName, attribute, operation, select, area, default)
		
		percentSet = tl:getDataSet(proj, percTifLayerName)
		
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
		unitTest:assertEquals(percTifLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[16])
		unitTest:assertEquals(percTifLayerInfo.type, "OGR")
		unitTest:assertEquals(percTifLayerInfo.rep, "polygon")
		unitTest:assertNotNil(percTifLayerInfo.sid)					
		
		-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION FROM RASTER
		local rmeanLayerName = clName.."_"..layerName4.."_RMean"		
		shp[17] = rmeanLayerName..".shp"
		
		if isFile(shp[17]) then
			rmFile(shp[17])
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
		unitTest:assertEquals(rmeanLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[17])
		unitTest:assertEquals(rmeanLayerInfo.type, "OGR")
		unitTest:assertEquals(rmeanLayerInfo.rep, "polygon")
		unitTest:assertNotNil(rmeanLayerInfo.sid)			
		
		-- FILL CELLULAR SPACE WITH MINIMUM OPERATION FROM RASTER
		local rminLayerName = clName.."_"..layerName4.."_RMinimum"		
		shp[18] = rminLayerName..".shp"
		
		if isFile(shp[18]) then
			rmFile(shp[18])
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
		unitTest:assertEquals(rminLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[18])
		unitTest:assertEquals(rminLayerInfo.type, "OGR")
		unitTest:assertEquals(rminLayerInfo.rep, "polygon")
		unitTest:assertNotNil(rminLayerInfo.sid)		
		
		-- FILL CELLULAR SPACE WITH MAXIMUM OPERATION FROM RASTER
		local rmaxLayerName = clName.."_"..layerName4.."_RMaximum"		
		shp[19] = rmaxLayerName..".shp"
		
		if isFile(shp[19]) then
			rmFile(shp[19])
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
		unitTest:assertEquals(rmaxLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[19])
		unitTest:assertEquals(rmaxLayerInfo.type, "OGR")
		unitTest:assertEquals(rmaxLayerInfo.rep, "polygon")
		unitTest:assertNotNil(rmaxLayerInfo.sid)	

		-- FILL CELLULAR SPACE WITH STANDART DERIVATION OPERATION FROM RASTER
		local rstdevLayerName = clName.."_"..layerName4.."_RStdev"		
		shp[20] = rstdevLayerName..".shp"
		
		if isFile(shp[20]) then
			rmFile(shp[20])
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
		unitTest:assertEquals(rstdevLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[20])
		unitTest:assertEquals(rstdevLayerInfo.type, "OGR")
		unitTest:assertEquals(rstdevLayerInfo.rep, "polygon")
		unitTest:assertNotNil(rstdevLayerInfo.sid)		

		-- FILL CELLULAR SPACE WITH SUM OPERATION FROM RASTER
		local rsumLayerName = clName.."_"..layerName4.."_RSum"		
		shp[21] = rsumLayerName..".shp"
		
		if isFile(shp[21]) then
			rmFile(shp[21])
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
		unitTest:assertEquals(rsumLayerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/")..shp[21])
		unitTest:assertEquals(rsumLayerInfo.type, "OGR")
		unitTest:assertEquals(rsumLayerInfo.rep, "polygon")
		unitTest:assertNotNil(rsumLayerInfo.sid)					
		
		for j = 1, #shp do
			if isFile(shp[j]) then
				rmFile(shp[j])
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

		local clName1 = "SampaShpCells"	
		local resolution = 0.7
		local mask = true
		local cellsShp = clName1..".shp"
		
		if isFile(cellsShp) then
			rmFile(cellsShp)
		end
		
		tl:addShpCellSpaceLayer(proj, layerName1, clName1, resolution, cellsShp, mask)

		local dSet = tl:getDataSet(proj, clName1)
		
		unitTest:assertEquals(getn(dSet), 68)
		
		for i = 0, #dSet do
			for k, v in pairs(dSet[i]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID"))
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
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or 
								(k == "attr1") or (k == "attr2") or (k == "attr3"))
				
				if k == "attr1" then
					unitTest:assertEquals(type(v), "number")
				elseif k == "attr2" then
					unitTest:assertEquals(type(v), "string")
				elseif k == "attr3" then
					unitTest:assertEquals(type(v), "string")
				end
			end
		end					
		
		rmFile(cellsShp)
		rmFile(newLayerName..".shp")
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
	end,
	getArea = function(unitTest)
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

		local clName1 = "SampaShpCells"	
		local resolution = 0.7
		local mask = true
		local cellsShp = clName1..".shp"
		
		if isFile(cellsShp) then
			rmFile(cellsShp)
		end
		
		tl:addShpCellSpaceLayer(proj, layerName1, clName1, resolution, cellsShp, mask)

		local dSet = tl:getDataSet(proj, clName1)
		local area = tl:getArea(dSet[0].OGR_GEOMETRY)
		unitTest:assertEquals(type(area), "number")
		unitTest:assertEquals(area, 0.49, 0.001)
		
		for i = 1, #dSet do
			for k, v in pairs(dSet[i]) do
				if k == "OGR_GEOMETRY" then
					unitTest:assertEquals(area, tl:getArea(v), 0.001)
				end
			end
		end			
		
		if isFile(cellsShp) then
			rmFile(cellsShp)
		end		
		
		rmFile(proj.file)
	end
}
