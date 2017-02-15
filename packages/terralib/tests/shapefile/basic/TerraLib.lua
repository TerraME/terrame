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
	createProject = function(unitTest)
		local tl = TerraLib{}
		local title = "TerraLib Tests"
		local author = "Avancini Rodrigo"
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = title
		proj.author = author

		local file = File(proj.file)
		file:deleteIfExists()

		tl:createProject(proj, {})
		unitTest:assert(file:exists())
		unitTest:assertEquals(proj.file:name(), "myproject.tview")
		unitTest:assertEquals(proj.title, title)
		unitTest:assertEquals(proj.author, author)

		-- allow overwrite
		tl:createProject(proj, {})
		unitTest:assert(proj.file:exists())

		file:delete()
	end,
	addShpLayer = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		local file = File(proj.file)
		file:deleteIfExists()

		tl:createProject(proj, {})

		local layerName = "ShapeLayer"
		local layerFile = filePath("test/sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName, layerFile)

		local layerInfo = tl:getLayerInfo(proj, proj.layers[layerName])

		unitTest:assertEquals(layerInfo.name, layerName)
		unitTest:assertEquals(layerInfo.file, tostring(layerFile))
		unitTest:assertEquals(layerInfo.type, "OGR")
		unitTest:assertEquals(layerInfo.rep, "polygon")
		unitTest:assertNotNil(layerInfo.sid)

		file:delete()

		-- SPATIAL INDEX TEST
		proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		tl:createProject(proj, {})

		local layerName1 = "ShapeLayer1"
		local qixFile = string.gsub(tostring(layerFile), ".shp", ".qix")
		File(qixFile):delete()
		local addSpatialIdx = false
		tl:addShpLayer(proj, layerName1, layerFile, addSpatialIdx)
		unitTest:assert(not File(qixFile):exists())

		local layerName2 = "ShapeLayer2"
		addSpatialIdx = true
		tl:addShpLayer(proj, layerName2, layerFile, addSpatialIdx)
		unitTest:assert(File(qixFile):exists())

		file:delete()
		-- // SPATIAL INDEX TEST
	end,
	addShpCellSpaceLayer = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		local file = File(proj.file)
		file:deleteIfExists()

		tl:createProject(proj, {})

		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)

		local clName = "Sampa_Cells"
		local shp1 = File(clName..".shp")

		shp1:deleteIfExists()

		local resolution = 1
		local mask = true
		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp1, mask)

		local layerInfo = tl:getLayerInfo(proj, proj.layers[clName])

		unitTest:assertEquals(layerInfo.name, clName)
		unitTest:assertEquals(layerInfo.file, tostring(shp1))
		unitTest:assertEquals(layerInfo.type, "OGR")
		unitTest:assertEquals(layerInfo.rep, "polygon")
		unitTest:assertNotNil(layerInfo.sid)

		-- NO MASK TEST
		local clSet = tl:getDataSet(proj, clName)
		unitTest:assertEquals(getn(clSet), 37)

		clName = clName.."_NoMask"
		local shp2 = File(clName..".shp")

		shp2:deleteIfExists()

		mask = false
		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp2, mask)

		clSet = tl:getDataSet(proj, clName)
		unitTest:assertEquals(getn(clSet), 54)
		-- // NO MASK TEST

		-- SPATIAL INDEX TEST
		clName = "Sampa_Cells_NOSIDX"
		local shp3 = File(clName..".shp")
		local addSpatialIdx = false

		shp3:deleteIfExists()

		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp3, mask, addSpatialIdx)
		local qixFile1 = string.gsub(tostring(shp3), ".shp", ".qix")
		unitTest:assert(not File(qixFile1):exists())

		clName = "Sampa_Cells_SIDX"
		local shp4 = File(clName..".shp")
		addSpatialIdx = true

		shp4:deleteIfExists()

		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp4, mask, addSpatialIdx)
		local qixFile2 = string.gsub(tostring(shp4), ".shp", ".qix")
		unitTest:assert(File(qixFile2):exists())
		-- // SPATIAL INDEX TEST

		shp1:deleteIfExists()
		shp2:deleteIfExists()
		shp3:deleteIfExists()
		shp4:deleteIfExists()

		file:delete()
	end,
	attributeFill = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		local customWarningBkp = customWarning
		customWarning = function(msg)
			return msg
		end

		local layerName1 = "Para"
		local layerFile1 = filePath("test/limitePA_polyc_pol.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)

		local shp = {}

		local clName = "Para_Cells"
		shp[1] = clName..".shp"

		File(shp[1]):deleteIfExists()

		-- CREATE THE CELLULAR SPACE
		local resolution = 5e5
		local mask = true
		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, File(shp[1]), mask)

		local clSet = tl:getDataSet(proj, clName)

		unitTest:assertEquals(getn(clSet), 9)

		for k, v in pairs(clSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID"))
			unitTest:assertNotNil(v)
		end

		local clLayerInfo = tl:getLayerInfo(proj, proj.layers[clName])

		unitTest:assertEquals(clLayerInfo.name, clName)
		unitTest:assertEquals(clLayerInfo.file, currentDir()..shp[1])
		unitTest:assertEquals(clLayerInfo.type, "OGR")
		unitTest:assertEquals(clLayerInfo.rep, "polygon")
		unitTest:assertNotNil(clLayerInfo.sid)

		-- CREATE A LAYER WITH POLYGONS TO DO OPERATIONS
		local layerName2 = "Protection_Unit"
		local layerFile2 = filePath("test/BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "terralib")
		tl:addShpLayer(proj, layerName2, layerFile2)

		-- SHAPE OUTPUT
		-- FILL CELLULAR SPACE WITH PRESENCE OPERATION
		local presLayerName = clName.."_"..layerName2.."_Presence"
		shp[2] = presLayerName..".shp"

		File(shp[2]):deleteIfExists()

		local operation = "presence"
		local attribute = "presence"
		local select = "FID"
		local area = nil
		local default = nil
		tl:attributeFill(proj, layerName2, clName, presLayerName, attribute, operation, select, area, default)

		local presSet = tl:getDataSet(proj, presLayerName)

		unitTest:assertEquals(getn(presSet), 9)

		for k, v in pairs(presSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence"))
			unitTest:assertNotNil(v)
		end

		local presLayerInfo = tl:getLayerInfo(proj, proj.layers[presLayerName])
		unitTest:assertEquals(presLayerInfo.name, presLayerName)
		unitTest:assertEquals(presLayerInfo.file, currentDir()..shp[2])
		unitTest:assertEquals(presLayerInfo.type, "OGR")
		unitTest:assertEquals(presLayerInfo.rep, "polygon")
		unitTest:assertNotNil(presLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH PERCENTAGE TOTAL AREA OPERATION
		local areaLayerName = clName.."_"..layerName2.."_Area"
		shp[3] = areaLayerName..".shp"

		File(shp[3]):deleteIfExists()

		operation = "area"
		attribute = "area_perce" -- the attribute must have 10 characters (ogr truncate)
		select = "FID"
		area = nil
		default = 0
		tl:attributeFill(proj, layerName2, presLayerName, areaLayerName, attribute, operation, select, area, default)

		local areaSet = tl:getDataSet(proj, areaLayerName)

		unitTest:assertEquals(getn(areaSet), 9)

		for k, v in pairs(areaSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce"))
			unitTest:assertNotNil(v)
		end

		local areaLayerInfo = tl:getLayerInfo(proj, proj.layers[areaLayerName])
		unitTest:assertEquals(areaLayerInfo.name, areaLayerName)
		unitTest:assertEquals(areaLayerInfo.file, currentDir()..shp[3])
		unitTest:assertEquals(areaLayerInfo.type, "OGR")
		unitTest:assertEquals(areaLayerInfo.rep, "polygon")
		unitTest:assertNotNil(areaLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH COUNT OPERATION
		local countLayerName = clName.."_"..layerName2.."_Count"
		shp[4] = countLayerName..".shp"

		File(shp[4]):deleteIfExists()

		operation = "count"
		attribute = "count"
		select = "FID"
		area = nil
		default = 0
		tl:attributeFill(proj, layerName2, areaLayerName, countLayerName, attribute, operation, select, area, default)

		local countSet = tl:getDataSet(proj, countLayerName)

		unitTest:assertEquals(getn(countSet), 9)

		for k, v in pairs(countSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count"))
			unitTest:assertNotNil(v)
		end

		local countLayerInfo = tl:getLayerInfo(proj, proj.layers[countLayerName])
		unitTest:assertEquals(countLayerInfo.name, countLayerName)
		unitTest:assertEquals(countLayerInfo.file, currentDir()..shp[4])
		unitTest:assertEquals(countLayerInfo.type, "OGR")
		unitTest:assertEquals(countLayerInfo.rep, "polygon")
		unitTest:assertNotNil(countLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH DISTANCE OPERATION
		local distLayerName = clName.."_"..layerName2.."_Distance"
		shp[5] = distLayerName..".shp"

		File(shp[5]):deleteIfExists()

		operation = "distance"
		attribute = "distance"
		select = "FID"
		area = nil
		default = nil
		tl:attributeFill(proj, layerName2, countLayerName, distLayerName, attribute, operation, select, area, default)

		local distSet = tl:getDataSet(proj, distLayerName)

		unitTest:assertEquals(getn(distSet), 9)

		for k, v in pairs(distSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance"))
			unitTest:assertNotNil(v)
		end

		local distLayerInfo = tl:getLayerInfo(proj, proj.layers[distLayerName])
		unitTest:assertEquals(distLayerInfo.name, distLayerName)
		unitTest:assertEquals(distLayerInfo.file, currentDir()..shp[5])
		unitTest:assertEquals(distLayerInfo.type, "OGR")
		unitTest:assertEquals(distLayerInfo.rep, "polygon")
		unitTest:assertNotNil(distLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH MINIMUM OPERATION
		local layerName3 = "Amazon_Munic"
		local layerFile3 = filePath("test/municipiosAML_ok.shp", "terralib")
		tl:addShpLayer(proj, layerName3, layerFile3)

		local minLayerName = clName.."_"..layerName3.."_Minimum"
		shp[6] = minLayerName..".shp"

		File(shp[6]):deleteIfExists()

		operation = "minimum"
		attribute = "minimum"
		select = "POPULACAO_"
		area = nil
		default = nil
		tl:attributeFill(proj, layerName3, distLayerName, minLayerName, attribute, operation, select, area, default)

		local minSet = tl:getDataSet(proj, minLayerName)

		unitTest:assertEquals(getn(minSet), 9)

		for k, v in pairs(minSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum"))
			unitTest:assertNotNil(v)
		end

		local minLayerInfo = tl:getLayerInfo(proj, proj.layers[minLayerName])
		unitTest:assertEquals(minLayerInfo.name, minLayerName)
		unitTest:assertEquals(minLayerInfo.file, currentDir()..shp[6])
		unitTest:assertEquals(minLayerInfo.type, "OGR")
		unitTest:assertEquals(minLayerInfo.rep, "polygon")
		unitTest:assertNotNil(minLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH MAXIMUM OPERATION
		local maxLayerName = clName.."_"..layerName3.."_Maximum"
		shp[7] = maxLayerName..".shp"

		File(shp[7]):deleteIfExists()

		operation = "maximum"
		attribute = "maximum"
		select = "POPULACAO_"
		area = nil
		default = nil
		tl:attributeFill(proj, layerName3, minLayerName, maxLayerName, attribute, operation, select, area, default)

		local maxSet = tl:getDataSet(proj, maxLayerName)

		unitTest:assertEquals(getn(maxSet), 9)

		for k, v in pairs(maxSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum") or (k == "maximum"))
			unitTest:assertNotNil(v)
		end

		local maxLayerInfo = tl:getLayerInfo(proj, proj.layers[maxLayerName])
		unitTest:assertEquals(maxLayerInfo.name, maxLayerName)
		unitTest:assertEquals(maxLayerInfo.file, currentDir()..shp[7])
		unitTest:assertEquals(maxLayerInfo.type, "OGR")
		unitTest:assertEquals(maxLayerInfo.rep, "polygon")
		unitTest:assertNotNil(maxLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH PERCENTAGE OPERATION
		local percLayerName = clName.."_"..layerName2.."_Percentage"
		shp[8] = percLayerName..".shp"

		File(shp[8]):deleteIfExists()

		operation = "coverage"
		attribute = "perc"
		select = "NOME"
		area = nil
		default = nil
		tl:attributeFill(proj, layerName2, maxLayerName, percLayerName, attribute, operation, select, area, default)

		local percentSet = tl:getDataSet(proj, percLayerName)

		unitTest:assertEquals(getn(percentSet), 9)

		for k, v in pairs(percentSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil))
			unitTest:assertNotNil(v)
		end

		local percLayerInfo = tl:getLayerInfo(proj, proj.layers[percLayerName])
		unitTest:assertEquals(percLayerInfo.name, percLayerName)
		unitTest:assertEquals(percLayerInfo.file, currentDir()..shp[8])
		unitTest:assertEquals(percLayerInfo.type, "OGR")
		unitTest:assertEquals(percLayerInfo.rep, "polygon")
		unitTest:assertNotNil(percLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH STANDART DERIVATION OPERATION
		local stdevLayerName = clName.."_"..layerName3.."_Stdev"
		shp[9] = stdevLayerName..".shp"

		File(shp[9]):deleteIfExists()

		operation = "stdev"
		attribute = "stdev"
		select = "POPULACAO_"
		area = nil
		default = nil
		tl:attributeFill(proj, layerName3, percLayerName, stdevLayerName, attribute, operation, select, area, default)

		local stdevSet = tl:getDataSet(proj, stdevLayerName)

		unitTest:assertEquals(getn(stdevSet), 9)

		for k, v in pairs(stdevSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
							(k == "stdev"))
			unitTest:assertNotNil(v)
		end

		local stdevLayerInfo = tl:getLayerInfo(proj, proj.layers[stdevLayerName])
		unitTest:assertEquals(stdevLayerInfo.name, stdevLayerName)
		unitTest:assertEquals(stdevLayerInfo.file, currentDir()..shp[9])
		unitTest:assertEquals(stdevLayerInfo.type, "OGR")
		unitTest:assertEquals(stdevLayerInfo.rep, "polygon")
		unitTest:assertNotNil(stdevLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION
		local meanLayerName = clName.."_"..layerName3.."_AvrgMean"
		shp[10] = meanLayerName..".shp"

		File(shp[10]):deleteIfExists()

		operation = "average"
		attribute = "mean"
		select = "POPULACAO_"
		area = false
		default = nil
		tl:attributeFill(proj, layerName3, stdevLayerName, meanLayerName, attribute, operation, select, area, default)

		local meanSet = tl:getDataSet(proj, meanLayerName)

		unitTest:assertEquals(getn(meanSet), 9)

		for k, v in pairs(meanSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
							(k == "stdev") or (k == "mean"))
			unitTest:assertNotNil(v)
		end

		local meanLayerInfo = tl:getLayerInfo(proj, proj.layers[meanLayerName])
		unitTest:assertEquals(meanLayerInfo.name, meanLayerName)
		unitTest:assertEquals(meanLayerInfo.file, currentDir()..shp[10])
		unitTest:assertEquals(meanLayerInfo.type, "OGR")
		unitTest:assertEquals(meanLayerInfo.rep, "polygon")
		unitTest:assertNotNil(meanLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION
		local weighLayerName = clName.."_"..layerName3.."_AvrgWeighted"
		shp[11] = weighLayerName..".shp"

		File(shp[11]):deleteIfExists()

		operation = "average"
		attribute = "weighted"
		select = "POPULACAO_"
		area = true
		default = nil
		tl:attributeFill(proj, layerName3, meanLayerName, weighLayerName, attribute, operation, select, area, default)

		local weighSet = tl:getDataSet(proj, weighLayerName)

		unitTest:assertEquals(getn(weighSet), 9)

		for k, v in pairs(weighSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
							(k == "stdev") or (k == "mean") or (k == "weighted"))
			unitTest:assertNotNil(v)
		end

		local weighLayerInfo = tl:getLayerInfo(proj, proj.layers[weighLayerName])
		unitTest:assertEquals(weighLayerInfo.name, weighLayerName)
		unitTest:assertEquals(weighLayerInfo.file, currentDir()..shp[11])
		unitTest:assertEquals(weighLayerInfo.type, "OGR")
		unitTest:assertEquals(weighLayerInfo.rep, "polygon")
		unitTest:assertNotNil(weighLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH MAJORITY INTERSECTION OPERATION
		local interLayerName = clName.."_"..layerName3.."_Intersection"
		shp[12] = interLayerName..".shp"

		File(shp[12]):deleteIfExists()

		operation = "mode"
		attribute = "majo_int"
		select = "POPULACAO_"
		area = true
		default = nil
		tl:attributeFill(proj, layerName3, weighLayerName, interLayerName, attribute, operation, select, area, default)

		local interSet = tl:getDataSet(proj, interLayerName)

		unitTest:assertEquals(getn(interSet), 9)

		for k, v in pairs(interSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int"))
			unitTest:assertNotNil(v)
		end

		local interLayerInfo = tl:getLayerInfo(proj, proj.layers[interLayerName])
		unitTest:assertEquals(interLayerInfo.name, interLayerName)
		unitTest:assertEquals(interLayerInfo.file, currentDir()..shp[12])
		unitTest:assertEquals(interLayerInfo.type, "OGR")
		unitTest:assertEquals(interLayerInfo.rep, "polygon")
		unitTest:assertNotNil(interLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH MAJORITY OCCURRENCE OPERATION
		local occurLayerName = clName.."_"..layerName3.."_Occurence"
		shp[13] = occurLayerName..".shp"

		File(shp[13]):deleteIfExists()

		operation = "mode"
		attribute = "majo_occur"
		select = "POPULACAO_"
		area = false
		default = nil
		tl:attributeFill(proj, layerName3, interLayerName, occurLayerName, attribute, operation, select, area, default)

		local occurSet = tl:getDataSet(proj, occurLayerName)

		unitTest:assertEquals(getn(occurSet), 9)

		for k, v in pairs(occurSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
							(k == "majo_occur"))
			unitTest:assertNotNil(v)
		end

		local occurLayerInfo = tl:getLayerInfo(proj, proj.layers[occurLayerName])
		unitTest:assertEquals(occurLayerInfo.name, occurLayerName)
		unitTest:assertEquals(occurLayerInfo.file, currentDir()..shp[13])
		unitTest:assertEquals(occurLayerInfo.type, "OGR")
		unitTest:assertEquals(occurLayerInfo.rep, "polygon")
		unitTest:assertNotNil(occurLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH SUM OPERATION
		local sumLayerName = clName.."_"..layerName3.."_Sum"
		shp[14] = sumLayerName..".shp"

		File(shp[14]):deleteIfExists()

		operation = "sum"
		attribute = "sum"
		select = "POPULACAO_"
		area = false
		default = nil
		tl:attributeFill(proj, layerName3, occurLayerName, sumLayerName, attribute, operation, select, area, default)

		local sumSet = tl:getDataSet(proj, sumLayerName)

		unitTest:assertEquals(getn(sumSet), 9)

		for k, v in pairs(sumSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
							(k == "majo_occur") or (k == "sum"))
			unitTest:assertNotNil(v)
		end

		local sumLayerInfo = tl:getLayerInfo(proj, proj.layers[sumLayerName])
		unitTest:assertEquals(sumLayerInfo.name, sumLayerName)
		unitTest:assertEquals(sumLayerInfo.file, currentDir()..shp[14])
		unitTest:assertEquals(sumLayerInfo.type, "OGR")
		unitTest:assertEquals(sumLayerInfo.rep, "polygon")
		unitTest:assertNotNil(sumLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH WEIGHTED SUM OPERATION
		local wsumLayerName = clName.."_"..layerName3.."_Wsum"
		shp[15] = wsumLayerName..".shp"

		File(shp[15]):deleteIfExists()

		operation = "sum"
		attribute = "wsum"
		select = "POPULACAO_"
		area = true
		default = nil
		tl:attributeFill(proj, layerName3, sumLayerName, wsumLayerName, attribute, operation, select, area, default)

		local wsumSet = tl:getDataSet(proj, wsumLayerName)

		unitTest:assertEquals(getn(wsumSet), 9)

		for k, v in pairs(wsumSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
							(k == "majo_occur") or (k == "sum") or (k == "wsum"))
			unitTest:assertNotNil(v)
		end

		local wsumLayerInfo = tl:getLayerInfo(proj, proj.layers[wsumLayerName])
		unitTest:assertEquals(wsumLayerInfo.name, wsumLayerName)
		unitTest:assertEquals(wsumLayerInfo.file, currentDir()..shp[15])
		unitTest:assertEquals(wsumLayerInfo.type, "OGR")
		unitTest:assertEquals(wsumLayerInfo.rep, "polygon")
		unitTest:assertNotNil(wsumLayerInfo.sid)

		-- RASTER TESTS WITH SHAPE
		-- FILL CELLULAR SPACE WITH PERCENTAGE OPERATION USING TIF
		local layerName4 = "Prodes_PA"
		local layerFile4 = filePath("test/prodes_polyc_10k.tif", "terralib")
		tl:addGdalLayer(proj, layerName4, layerFile4, wsumLayerInfo.srid)

		local percTifLayerName = clName.."_"..layerName4.."_RPercentage"
		shp[16] = percTifLayerName..".shp"

		File(shp[16]):deleteIfExists()

		operation = "coverage"
		attribute = "rperc"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, wsumLayerName, percTifLayerName, attribute, operation, select, area, default)

		percentSet = tl:getDataSet(proj, percTifLayerName)

		unitTest:assertEquals(getn(percentSet), 9)

		for k, v in pairs(percentSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
							(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rperc_") ~= nil))
			unitTest:assertNotNil(v)
		end

		local percTifLayerInfo = tl:getLayerInfo(proj, proj.layers[percTifLayerName])
		unitTest:assertEquals(percTifLayerInfo.name, percTifLayerName)
		unitTest:assertEquals(percTifLayerInfo.file, currentDir()..shp[16])
		unitTest:assertEquals(percTifLayerInfo.type, "OGR")
		unitTest:assertEquals(percTifLayerInfo.rep, "polygon")
		unitTest:assertNotNil(percTifLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION FROM RASTER
		local rmeanLayerName = clName.."_"..layerName4.."_RMean"
		shp[17] = rmeanLayerName..".shp"

		File(shp[17]):deleteIfExists()

		operation = "average"
		attribute = "rmean"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, percTifLayerName, rmeanLayerName, attribute, operation, select, area, default)

		local rmeanSet = tl:getDataSet(proj, rmeanLayerName)

		unitTest:assertEquals(getn(rmeanSet), 9)

		for k, v in pairs(rmeanSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
							(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rperc_") ~= nil) or
							(k == "rmean"))
			unitTest:assertNotNil(v)
		end

		local rmeanLayerInfo = tl:getLayerInfo(proj, proj.layers[rmeanLayerName])
		unitTest:assertEquals(rmeanLayerInfo.name, rmeanLayerName)
		unitTest:assertEquals(rmeanLayerInfo.file, currentDir()..shp[17])
		unitTest:assertEquals(rmeanLayerInfo.type, "OGR")
		unitTest:assertEquals(rmeanLayerInfo.rep, "polygon")
		unitTest:assertNotNil(rmeanLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH MINIMUM OPERATION FROM RASTER
		local rminLayerName = clName.."_"..layerName4.."_RMinimum"
		shp[18] = rminLayerName..".shp"

		File(shp[18]):deleteIfExists()

		operation = "minimum"
		attribute = "rmin"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, rmeanLayerName, rminLayerName, attribute, operation, select, area, default)

		local rminSet = tl:getDataSet(proj, rminLayerName)

		unitTest:assertEquals(getn(rminSet), 9)

		for k, v in pairs(rminSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
							(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rperc_") ~= nil) or
							(k == "rmean") or (k == "rmin"))
			unitTest:assertNotNil(v)
		end

		local rminLayerInfo = tl:getLayerInfo(proj, proj.layers[rminLayerName])
		unitTest:assertEquals(rminLayerInfo.name, rminLayerName)
		unitTest:assertEquals(rminLayerInfo.file, currentDir()..shp[18])
		unitTest:assertEquals(rminLayerInfo.type, "OGR")
		unitTest:assertEquals(rminLayerInfo.rep, "polygon")
		unitTest:assertNotNil(rminLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH MAXIMUM OPERATION FROM RASTER
		local rmaxLayerName = clName.."_"..layerName4.."_RMaximum"
		shp[19] = rmaxLayerName..".shp"

		File(shp[19]):deleteIfExists()

		operation = "maximum"
		attribute = "rmax"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, rminLayerName, rmaxLayerName, attribute, operation, select, area, default)

		local rmaxSet = tl:getDataSet(proj, rmaxLayerName)

		unitTest:assertEquals(getn(rmaxSet), 9)

		for k, v in pairs(rmaxSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
							(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rperc_") ~= nil) or
							(k == "rmean") or (k == "rmin") or (k == "rmax"))
			unitTest:assertNotNil(v)
		end

		local rmaxLayerInfo = tl:getLayerInfo(proj, proj.layers[rmaxLayerName])
		unitTest:assertEquals(rmaxLayerInfo.name, rmaxLayerName)
		unitTest:assertEquals(rmaxLayerInfo.file, currentDir()..shp[19])
		unitTest:assertEquals(rmaxLayerInfo.type, "OGR")
		unitTest:assertEquals(rmaxLayerInfo.rep, "polygon")
		unitTest:assertNotNil(rmaxLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH STANDART DERIVATION OPERATION FROM RASTER
		local rstdevLayerName = clName.."_"..layerName4.."_RStdev"
		shp[20] = rstdevLayerName..".shp"

		File(shp[20]):deleteIfExists()

		operation = "stdev"
		attribute = "rstdev"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, rmaxLayerName, rstdevLayerName, attribute, operation, select, area, default)

		local rstdevSet = tl:getDataSet(proj, rstdevLayerName)

		unitTest:assertEquals(getn(rstdevSet), 9)

		for k, v in pairs(rstdevSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
							(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rperc_") ~= nil) or
							(k == "rmean") or (k == "rmin") or (k == "rmax") or (k == "rstdev"))
			unitTest:assertNotNil(v)
		end

		local rstdevLayerInfo = tl:getLayerInfo(proj, proj.layers[rstdevLayerName])
		unitTest:assertEquals(rstdevLayerInfo.name, rstdevLayerName)
		unitTest:assertEquals(rstdevLayerInfo.file, currentDir()..shp[20])
		unitTest:assertEquals(rstdevLayerInfo.type, "OGR")
		unitTest:assertEquals(rstdevLayerInfo.rep, "polygon")
		unitTest:assertNotNil(rstdevLayerInfo.sid)

		-- FILL CELLULAR SPACE WITH SUM OPERATION FROM RASTER
		local rsumLayerName = clName.."_"..layerName4.."_RSum"
		shp[21] = rsumLayerName..".shp"

		File(shp[21]):deleteIfExists()

		operation = "sum"
		attribute = "rsum"
		select = 0
		area = nil
		default = nil
		tl:attributeFill(proj, layerName4, rstdevLayerName, rsumLayerName, attribute, operation, select, area, default)

		local rsumSet = tl:getDataSet(proj, rsumLayerName)

		unitTest:assertEquals(getn(rsumSet), 9)

		for k, v in pairs(rsumSet[0]) do
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
							(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rperc_") ~= nil) or
							(k == "rmean") or (k == "rmin") or (k == "rmax") or (k == "rstdev") or (k == "rsum"))
			unitTest:assertNotNil(v)
		end

		local rsumLayerInfo = tl:getLayerInfo(proj, proj.layers[rsumLayerName])
		unitTest:assertEquals(rsumLayerInfo.name, rsumLayerName)
		unitTest:assertEquals(rsumLayerInfo.file, currentDir()..shp[21])
		unitTest:assertEquals(rsumLayerInfo.type, "OGR")
		unitTest:assertEquals(rsumLayerInfo.rep, "polygon")
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
			unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
							(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
							(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
							(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
							(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rperc_") ~= nil) or
							(k == "rmean") or (k == "rmin") or (k == "rmax") or (k == "rstdev") or (k == "rsum") or
							(k == "rsum_over"))
			unitTest:assertNotNil(v)
		end

		local rsumOverLayerInfo = tl:getLayerInfo(proj, proj.layers[rsumLayerName])
		unitTest:assertEquals(rsumOverLayerInfo.name, rsumLayerName)
		unitTest:assertEquals(rsumOverLayerInfo.file, currentDir()..shp[21])
		unitTest:assertEquals(rsumOverLayerInfo.type, "OGR")
		unitTest:assertEquals(rsumOverLayerInfo.rep, "polygon")
		unitTest:assertNotNil(rsumOverLayerInfo.sid)

		for j = 1, #shp do
			File(shp[j]):deleteIfExists()
		end

		proj.file:delete()

		customWarning = customWarningBkp
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

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		-- // create a database
		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)

		local clName1 = "SampaShpCells"
		local resolution = 1
		local mask = true
		local cellsShp = File(clName1..".shp")

		cellsShp:deleteIfExists()

		tl:addShpCellSpaceLayer(proj, layerName1, clName1, resolution, cellsShp, mask)

		local dSet = tl:getDataSet(proj, clName1)

		unitTest:assertEquals(getn(dSet), 37)

		for i = 0, getn(dSet) - 1 do
			for k, v in pairs(dSet[i]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID"))
				unitTest:assertNotNil(v)
			end
		end

		local attrNames = tl:getPropertyNames(proj, proj.layers[clName1])
		unitTest:assertEquals("FID", attrNames[0])
		unitTest:assertEquals("id", attrNames[1])
		unitTest:assertEquals("col", attrNames[2])
		unitTest:assertEquals("row", attrNames[3])

		local luaTable = {}

		for i = 0, getn(dSet) - 1 do
			local data = dSet[i]
			data.attr1 = i
			data.attr2 = "test"..i
			data.attr3 = (i % 2) == 0
			table.insert(luaTable, dSet[i])
		end

		local newLayerName = "New_Layer"
		local nlFile = File(newLayerName..".shp")
		nlFile:deleteIfExists()

		tl:saveDataSet(proj, clName1, luaTable, newLayerName, {"attr1", "attr2", "attr3"})

		local newDSet = tl:getDataSet(proj, newLayerName)
		unitTest:assertEquals(getn(newDSet), 37)

		for i = 0, getn(newDSet) - 1 do
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

		attrNames = tl:getPropertyNames(proj, proj.layers[newLayerName])
		unitTest:assertEquals("FID", attrNames[0])
		unitTest:assertEquals("id", attrNames[1])
		unitTest:assertEquals("col", attrNames[2])
		unitTest:assertEquals("row", attrNames[3])
		unitTest:assertEquals("attr1", attrNames[4])
		unitTest:assertEquals("attr2", attrNames[5])
		unitTest:assertEquals("attr3", attrNames[6])

		tl:saveDataSet(proj, clName1, luaTable, newLayerName, {"attr1"})
		newDSet = tl:getDataSet(proj, newLayerName)

		unitTest:assertEquals(getn(newDSet), 37)

		for i = 0, getn(newDSet) - 1 do
			unitTest:assertEquals(newDSet[i].attr1, i)
			for k, v in pairs(newDSet[i]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
								(k == "attr1"))

				if k == "attr1" then
					unitTest:assertEquals(type(v), "number")
				end
			end
		end

		attrNames = tl:getPropertyNames(proj, proj.layers[newLayerName])
		unitTest:assertEquals("FID", attrNames[0])
		unitTest:assertEquals("id", attrNames[1])
		unitTest:assertEquals("col", attrNames[2])
		unitTest:assertEquals("row", attrNames[3])
		unitTest:assertEquals("attr1", attrNames[4])

		-- OVERWRITE CELLSPACE
		tl:saveDataSet(proj, clName1, luaTable, clName1, {"attr1"})
		newDSet = tl:getDataSet(proj, newLayerName)

		unitTest:assertEquals(getn(newDSet), 37)

		for i = 0, getn(newDSet) - 1 do
			unitTest:assertEquals(newDSet[i].attr1, i)
			for k, v in pairs(newDSet[i]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == "OGR_GEOMETRY") or (k == "FID") or
								(k == "attr1"))

				if k == "attr1" then
					unitTest:assertEquals(type(v), "number")
				end
			end
		end

		attrNames = tl:getPropertyNames(proj, proj.layers[newLayerName])
		unitTest:assertEquals("FID", attrNames[0])
		unitTest:assertEquals("id", attrNames[1])
		unitTest:assertEquals("col", attrNames[2])
		unitTest:assertEquals("row", attrNames[3])
		unitTest:assertEquals("attr1", attrNames[4])

		-- SAVE POLYGONS, POINTS AND LINES THAT ARE NOT CELLSPACE SPACE
		-- POLYGONS
		local polName = "ES_Limit"
		local polFile = filePath("test/limite_es_poly_wgs84.shp", "terralib")
		tl:addShpLayer(proj, polName, polFile)

		local toData = {}
		toData.file = "limite_es_poly_wgs84-rep.shp"
		toData.type = "shp"
		toData.srid = 4326
		File(toData.file):deleteIfExists()

		tl:saveLayerAs(proj, polName, toData, true)

		local polDset = tl:getDataSet(proj, polName)
		local polLuaTable = {}
		for i = 0, getn(polDset) - 1 do
			local data = polDset[i]
			data.attr1 = i
			table.insert(polLuaTable, polDset[i])
		end

		polName = "ES_Limit_CurrDir"
		polFile = File(toData.file)
		tl:addShpLayer(proj, polName, polFile)

		attrNames = tl:getPropertyNames(proj, proj.layers[polName])
		unitTest:assertEquals("FID", attrNames[0])
		unitTest:assertEquals("GM_LAYER", attrNames[1])
		unitTest:assertEquals("GM_TYPE", attrNames[2])
		unitTest:assertEquals("LAYER", attrNames[3])
		unitTest:assertEquals("NM_ESTADO", attrNames[4])
		unitTest:assertEquals("NM_REGIAO", attrNames[5])
		unitTest:assertEquals("CD_GEOCUF", attrNames[6])
		unitTest:assertEquals("NM_UF", attrNames[7])

		local newPolName = "ES_Limit_New"
		tl:saveDataSet(proj, polName, polLuaTable, newPolName, {"attr1"})

		local newPolDset = tl:getDataSet(proj, newPolName)
		unitTest:assertEquals(getn(newPolDset), 1)
		unitTest:assertEquals(getn(newPolDset), getn(polDset))

		attrNames = tl:getPropertyNames(proj, proj.layers[newPolName])
		unitTest:assertEquals("FID", attrNames[0])
		unitTest:assertEquals("GM_LAYER", attrNames[1])
		unitTest:assertEquals("GM_TYPE", attrNames[2])
		unitTest:assertEquals("LAYER", attrNames[3])
		unitTest:assertEquals("NM_ESTADO", attrNames[4])
		unitTest:assertEquals("NM_REGIAO", attrNames[5])
		unitTest:assertEquals("CD_GEOCUF", attrNames[6])
		unitTest:assertEquals("NM_UF", attrNames[7])
		unitTest:assertEquals("attr1", attrNames[8])

		-- POINTS
		local ptName = "BR_Ports"
		local ptFile = filePath("test/ports.shp", "terralib")
		tl:addShpLayer(proj, ptName, ptFile)

		toData = {}
		toData.file = "ports-rep.shp"
		toData.type = "shp"
		toData.srid = 4326
		File(toData.file):deleteIfExists()

		tl:saveLayerAs(proj, ptName, toData, true)

		local ptDset = tl:getDataSet(proj, ptName)
		local ptLuaTable = {}
		for i = 0, getn(ptDset) - 1 do
			local data = ptDset[i]
			data.attr1 = i
			table.insert(ptLuaTable, ptDset[i])
		end

		ptName = "BR_Ports_CurrDir"
		ptFile = File(toData.file)
		tl:addShpLayer(proj, ptName, ptFile)

		attrNames = tl:getPropertyNames(proj, proj.layers[ptName])
		unitTest:assertEquals("FID", attrNames[0])
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
		unitTest:assertEquals("FID", attrNames[0])
		unitTest:assertEquals("tipo", attrNames[5])
		unitTest:assertEquals("gestao", attrNames[10])
		unitTest:assertEquals("pro_didade", attrNames[15])
		unitTest:assertEquals("cep", attrNames[20])
		unitTest:assertEquals("idr_rafica", attrNames[25])
		unitTest:assertEquals("observacao", attrNames[30])
		unitTest:assertEquals("cdc_troide", attrNames[32])
		unitTest:assertEquals("attr1", attrNames[33])

		-- LINES
		local lnName = "ES_Rails"
		local lnFile = filePath("test/rails.shp", "terralib")
		tl:addShpLayer(proj, lnName, lnFile)

		toData = {}
		toData.file = "rails-rep.shp"
		toData.type = "shp"
		toData.srid = 4326
		File(toData.file):deleteIfExists()

		tl:saveLayerAs(proj, lnName, toData, true)

		local lnDset = tl:getDataSet(proj, lnName)
		local lnLuaTable = {}
		for i = 0, getn(lnDset) - 1 do
			local data = lnDset[i]
			data.attr1 = i
			table.insert(lnLuaTable, lnDset[i])
		end

		lnName = "ES_Rails_CurrDir"
		lnFile = File(toData.file)
		tl:addShpLayer(proj, lnName, lnFile)

		attrNames = tl:getPropertyNames(proj, proj.layers[lnName])
		unitTest:assertEquals("FID", attrNames[0])
		unitTest:assertEquals("OBSERVACAO", attrNames[3])
		unitTest:assertEquals("PRODUTOS", attrNames[6])
		unitTest:assertEquals("OPERADORA", attrNames[9])
		unitTest:assertEquals("Bitola_Ext", attrNames[12])
		unitTest:assertEquals("COD_PNV", attrNames[14])

		local newLnName = "ES_Rails_New"
		tl:saveDataSet(proj, lnName, lnLuaTable, newLnName, {"attr1"})

		local newLnDset = tl:getDataSet(proj, newLnName)
		unitTest:assertEquals(getn(newLnDset), 182)
		unitTest:assertEquals(getn(newLnDset), getn(lnDset))

		attrNames = tl:getPropertyNames(proj, proj.layers[newLnName])
		unitTest:assertEquals("FID", attrNames[0])
		unitTest:assertEquals("OBSERVACAO", attrNames[3])
		unitTest:assertEquals("PRODUTOS", attrNames[6])
		unitTest:assertEquals("OPERADORA", attrNames[9])
		unitTest:assertEquals("Bitola_Ext", attrNames[12])
		unitTest:assertEquals("COD_PNV", attrNames[14])
		unitTest:assertEquals("attr1", attrNames[15])

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
		unitTest:assertEquals("FID", attrNames[0])
		unitTest:assertEquals("OBSERVACAO", attrNames[3])
		unitTest:assertEquals("PRODUTOS", attrNames[6])
		unitTest:assertEquals("OPERADORA", attrNames[9])
		unitTest:assertEquals("Bitola_Ext", attrNames[12])
		unitTest:assertEquals("COD_PNV", attrNames[14])
		unitTest:assertEquals("attr1", attrNames[15])
		unitTest:assertEquals("attr2", attrNames[16])
		unitTest:assertEquals("attr3", attrNames[17])

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
		unitTest:assertEquals("FID", attrNames[0])
		unitTest:assertEquals("OBSERVACAO", attrNames[3])
		unitTest:assertEquals("PRODUTOS", attrNames[6])
		unitTest:assertEquals("OPERADORA", attrNames[9])
		unitTest:assertEquals("Bitola_Ext", attrNames[12])
		unitTest:assertEquals("COD_PNV", attrNames[14])
		unitTest:assertEquals("attr1", attrNames[15])
		unitTest:assertEquals("attr2", attrNames[16])
		unitTest:assertEquals("attr3", attrNames[17])
		unitTest:assertEquals("attr4", attrNames[18])

		-- ONLY UPDATE SOME ATTRIBUTE
		lnLuaTable = {}
		for i = 0, getn(lnDset) - 1 do
			local data = lnDset[i]
			data.attr1 = i - 1000
			table.insert(lnLuaTable, lnDset[i])
		end

		tl:saveDataSet(proj, newLnName, lnLuaTable, newLnName, {"attr1"})
		attrNames = tl:getPropertyNames(proj, proj.layers[newLnName])
		unitTest:assertEquals("FID", attrNames[0])
		unitTest:assertEquals("OBSERVACAO", attrNames[3])
		unitTest:assertEquals("PRODUTOS", attrNames[6])
		unitTest:assertEquals("OPERADORA", attrNames[9])
		unitTest:assertEquals("Bitola_Ext", attrNames[12])
		unitTest:assertEquals("COD_PNV", attrNames[14])
		unitTest:assertEquals("attr1", attrNames[15])
		unitTest:assertEquals("attr2", attrNames[16])
		unitTest:assertEquals("attr3", attrNames[17])

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
		unitTest:assertEquals("FID", attrNames[0])
		unitTest:assertEquals("OBSERVACAO", attrNames[3])
		unitTest:assertEquals("PRODUTOS", attrNames[6])
		unitTest:assertEquals("OPERADORA", attrNames[9])
		unitTest:assertEquals("Bitola_Ext", attrNames[12])
		unitTest:assertEquals("COD_PNV", attrNames[14])
		unitTest:assertEquals("attr1", attrNames[15])
		unitTest:assertEquals("attr2", attrNames[16])
		unitTest:assertEquals("attr3", attrNames[17])
		unitTest:assertEquals("attr4", attrNames[18])

		cellsShp:delete()
		File(newLayerName..".shp"):delete()
		polFile:delete()
		File(newPolName..".shp"):delete()
		ptFile:delete()
		File(newPtName..".shp"):delete()
		lnFile:delete()
		File(newLnName..".shp"):delete()
		proj.file:delete()
	end,
	getOGRByFilePath = function(unitTest)
		local tl = TerraLib{}
		local shpPath = filePath("test/sampa.shp", "terralib")
		local dSet = tl:getOGRByFilePath(tostring(shpPath))

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

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)

		local clName1 = "SampaShpCells"
		local resolution = 1
		local mask = true
		local cellsShp = File(clName1..".shp")

		cellsShp:deleteIfExists()

		tl:addShpCellSpaceLayer(proj, layerName1, clName1, resolution, cellsShp, mask)

		local dSet = tl:getDataSet(proj, clName1)
		local area = tl:getArea(dSet[0].OGR_GEOMETRY)
		unitTest:assertEquals(type(area), "number")
		unitTest:assertEquals(area, 1, 0.001)

		for i = 1, #dSet do
			for k, v in pairs(dSet[i]) do
				if k == "OGR_GEOMETRY" then
					unitTest:assertEquals(area, tl:getArea(v), 0.001)
				end
			end
		end

		cellsShp:deleteIfExists()
		proj.file:delete()
	end,
	getProjection = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		local layerName1 = "Sampa"
		local layerFile1 = filePath("test/sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1, nil, 4019)

		local prj = tl:getProjection(proj.layers[layerName1])
		unitTest:assertEquals(prj.SRID, 4019.0)
		unitTest:assertEquals(prj.NAME, "Unknown datum based upon the GRS 1980 ellipsoid")
		unitTest:assertEquals(prj.PROJ4, "+proj=longlat +ellps=GRS80 +no_defs ")

		local layerName2 = "Setores"
		local layerFile2 = filePath("itaituba-census.shp", "terralib")
		tl:addShpLayer(proj, layerName2, layerFile2)

		prj = tl:getProjection(proj.layers[layerName2])

		unitTest:assertEquals(prj.SRID, 29191.0)
		unitTest:assertEquals(prj.NAME, "SAD69 / UTM zone 21S")
		unitTest:assertEquals(prj.PROJ4, "+proj=utm +zone=21 +south +ellps=aust_SA +towgs84=-66.87,4.37,-38.52,0,0,0,0 +units=m +no_defs ")

		proj.file:delete()
	end,
	getPropertyNames = function(unitTest)
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

		local propNames = tl:getPropertyNames(proj, proj.layers[layerName1])

		for i = 0, #propNames do
			unitTest:assert((propNames[i] == "FID") or (propNames[i] == "ID") or
						(propNames[i] == "NM_MICRO") or (propNames[i] == "CD_GEOCODU"))
		end

		proj.file:delete()
	end,
	getDistance = function(unitTest)
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

		local clName = "Sampa_Cells"
		local shp1 = File(clName..".shp")

		shp1:deleteIfExists()

		local resolution = 1
		local mask = true
		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp1, mask)

		local dSet = tl:getDataSet(proj, clName)
		local dist = tl:getDistance(dSet[0].OGR_GEOMETRY, dSet[getn(dSet) - 1].OGR_GEOMETRY)

		unitTest:assertEquals(dist, 4.1231056256177, 1.0e-13)

		proj.file:delete()
		shp1:delete()
	end,
	castGeomToSubtype = function(unitTest)
		local tl = TerraLib{}
		local shpPath = filePath("test/sampa.shp", "terralib")
		local dSet = tl:getOGRByFilePath(tostring(shpPath))
		local geom = dSet[1].OGR_GEOMETRY
		geom = tl:castGeomToSubtype(geom)
		unitTest:assertEquals(geom:getGeometryType(), "MultiPolygon")
		geom = tl:castGeomToSubtype(geom:getGeometryN(0))
		unitTest:assertEquals(geom:getGeometryType(), "Polygon")

		shpPath = filePath("amazonia-roads.shp", "terralib")
		dSet = tl:getOGRByFilePath(tostring(shpPath))
		geom = dSet[1].OGR_GEOMETRY
		geom = tl:castGeomToSubtype(geom)
		unitTest:assertEquals(geom:getGeometryType(), "MultiLineString")
		geom = tl:castGeomToSubtype(geom:getGeometryN(0))
		unitTest:assertEquals(geom:getGeometryType(), "LineString")

		shpPath = filePath("test/prodes_points_10km_PA_pt.shp", "terralib")
		dSet = tl:getOGRByFilePath(tostring(shpPath))
		geom = dSet[1].OGR_GEOMETRY
		geom = tl:castGeomToSubtype(geom)
		unitTest:assertEquals(geom:getGeometryType(), "MultiPoint")
		geom = tl:castGeomToSubtype(geom:getGeometryN(0))
		unitTest:assertEquals(geom:getGeometryType(), "Point")
	end,
	saveLayerAs = function(unitTest)
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

		-- GEOJSON
		local toData = {}
		toData.file = "shp2geojson.geojson"
		toData.type = "geojson"
		File(toData.file):deleteIfExists()

		local overwrite = true

		tl:saveLayerAs(proj, layerName1, toData, overwrite)
		unitTest:assert(File(toData.file):exists())

		-- OVERWRITE
		tl:saveLayerAs(proj, layerName1, toData, overwrite)
		unitTest:assert(File(toData.file):exists())

		-- OVERWRITE AND CHANGE SRID
		toData.srid = 4326.0
		tl:saveLayerAs(proj, layerName1, toData, overwrite)
		local layerName2 = "GJ"
		tl:addGeoJSONLayer(proj, layerName2, toData.file)
		local info2 = tl:getLayerInfo(proj, proj.layers[layerName2])
		unitTest:assertEquals(info2.srid, toData.srid)

		File(toData.file):delete()

		-- SHP
		toData.file = "shp2shp.shp"
		toData.type = "shp"
		File(toData.file):deleteIfExists()

		tl:saveLayerAs(proj, layerName1, toData, overwrite)
		unitTest:assert(File(toData.file):exists())

		-- OVERWRITE AND CHANGE SRID
		toData.srid = 4326
		tl:saveLayerAs(proj, layerName1, toData, overwrite)
		local layerName3 = "SHP"
		tl:addShpLayer(proj, layerName3, File(toData.file))
		local info3 = tl:getLayerInfo(proj, proj.layers[layerName3])
		unitTest:assertEquals(info3.srid, toData.srid)

		File(toData.file):delete()
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

		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)

		local size = tl:getLayerSize(proj, layerName1)

		unitTest:assertEquals(size, 63.0)
		file:delete()
	end
}
