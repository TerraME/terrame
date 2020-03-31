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
	addShpLayer = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		local file = File(proj.file)
		file:deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName = "ShapeLayer"
		local layerFile = filePath("test/sampa.shp", "gis")
		TerraLib().addShpLayer(proj, layerName, layerFile)

		local layerInfo = TerraLib().getLayerInfo(proj, layerName)

		unitTest:assertEquals(layerInfo.name, layerName)
		unitTest:assertEquals(layerInfo.file, tostring(layerFile))
		unitTest:assertEquals(layerInfo.type, "OGR")
		unitTest:assertEquals(layerInfo.rep, "polygon")

		file:delete()

		-- SPATIAL INDEX TEST
		proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		TerraLib().createProject(proj, {})

		local layerName1 = "ShapeLayer1"
		local qixFile = string.gsub(tostring(layerFile), ".shp", ".qix")
		File(qixFile):delete()
		local addSpatialIdx = false
		TerraLib().addShpLayer(proj, layerName1, layerFile, addSpatialIdx)
		unitTest:assert(not File(qixFile):exists())

		local layerName2 = "ShapeLayer2"
		addSpatialIdx = true
		TerraLib().addShpLayer(proj, layerName2, layerFile, addSpatialIdx)
		unitTest:assert(File(qixFile):exists())

		file:delete()
		-- // SPATIAL INDEX TEST
	end,
	addShpCellSpaceLayer = function(unitTest)
		local createProject = function()
			local proj = {
				file = "addshpcellspacelayer_basic.tview",
				title = "TerraLib Tests",
				author = "Avancini Rodrigo"
			}
			File(proj.file):deleteIfExists()
			TerraLib().createProject(proj, {})
			return proj
		end

		local creatingFromShape = function()
			TerraLib().setProgressVisible(false)

			local proj = createProject()
			local layerName1 = "SampaShp"
			local layerFile1 = filePath("test/sampa.shp", "gis")
			TerraLib().addShpLayer(proj, layerName1, layerFile1)
			local layerInfo1 = TerraLib().getLayerInfo(proj, layerName1)

			local clName = "Sampa_Cells"
			local shp1 = File(clName..".shp")

			shp1:deleteIfExists()

			local resolution = 1
			local mask = true
			TerraLib().addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp1, mask)

			local layerInfo = TerraLib().getLayerInfo(proj, clName)

			unitTest:assertEquals(layerInfo.name, clName)
			unitTest:assertEquals(layerInfo.file, tostring(shp1))
			unitTest:assertEquals(layerInfo.type, "OGR")
			unitTest:assertEquals(layerInfo.rep, "polygon")
			unitTest:assertEquals(layerInfo.srid, layerInfo1.srid)

			-- NO MASK TEST
			local clSetSize = TerraLib().getLayerSize(proj, clName)
			unitTest:assertEquals(clSetSize, 37)

			clName = clName.."_NoMask"
			local shp2 = File(clName..".shp")

			shp2:deleteIfExists()

			mask = false
			TerraLib().addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp2, mask)

			clSetSize = TerraLib().getLayerSize(proj, clName)
			unitTest:assertEquals(clSetSize, 54)
			-- // NO MASK TEST

			-- SPATIAL INDEX TEST
			clName = "Sampa_Cells_NOSIDX"
			local shp3 = File(clName..".shp")
			local addSpatialIdx = false

			shp3:deleteIfExists()

			TerraLib().addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp3, mask, addSpatialIdx)
			local qixFile1 = string.gsub(tostring(shp3), ".shp", ".qix")
			unitTest:assert(not File(qixFile1):exists())

			clName = "Sampa_Cells_SIDX"
			local shp4 = File(clName..".shp")
			addSpatialIdx = true

			shp4:deleteIfExists()

			TerraLib().addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp4, mask, addSpatialIdx)
			local qixFile2 = string.gsub(tostring(shp4), ".shp", ".qix")
			unitTest:assert(File(qixFile2):exists())
			-- // SPATIAL INDEX TEST

			shp1:deleteIfExists()
			shp2:deleteIfExists()
			shp3:deleteIfExists()
			shp4:deleteIfExists()

			proj.file:delete()
		end

		local creatingFromTif = function()
			TerraLib().setProgressVisible(false)

			local proj = createProject()
			local layerName1 = "AmazoniaTif"
			local layerFile1 = filePath("amazonia-prodes.tif", "gis")
			TerraLib().addGdalLayer(proj, layerName1, layerFile1)

			local clName = "Amazonia_Cells"
			local shp1 = File(clName..".shp")

			shp1:deleteIfExists()

			local resolution = 3e5
			local mask = true

			local maskNotWork = function()
				TerraLib().addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp1, mask)
			end
			unitTest:assertWarning(maskNotWork, "The 'mask' not work to Raster, it was ignored.")

			local layerInfo = TerraLib().getLayerInfo(proj, clName)

			unitTest:assertEquals(layerInfo.name, clName)
			unitTest:assertEquals(layerInfo.file, tostring(shp1))
			unitTest:assertEquals(layerInfo.type, "OGR")
			unitTest:assertEquals(layerInfo.rep, "polygon")

			local clSetSize = TerraLib().getLayerSize(proj, clName)
			unitTest:assertEquals(clSetSize, 108)

			shp1:deleteIfExists()
			proj.file:delete()
		end

		unitTest:assert(creatingFromShape)
		unitTest:assert(creatingFromTif)
	end,
	attributeFill = function(unitTest)
		TerraLib().setProgressVisible(false)

		local createProject = function()
			local proj = {
				file = "attributefill_shp_basic.tview",
				title = "TerraLib Tests",
				author = "Avancini Rodrigo"
			}
			File(proj.file):deleteIfExists()
			TerraLib().createProject(proj, {})
			return proj
		end

		local allSupportedOperationTogether = function()
			local proj = createProject()

			local layerName1 = "Para"
			local layerFile1 = filePath("test/limitePA_polyc_pol.shp", "gis")
			TerraLib().addShpLayer(proj, layerName1, layerFile1)

			local testDir = Directory(currentDir().."/attribute fill/") --<< blank space
			if testDir:exists() then
				testDir:delete()
			end
			testDir:create()
			testDir = tostring(testDir).."/"

			local shp = {}
			local clName = "Para_Cells"
			shp[1] = testDir..clName..".shp"

			File(shp[1]):deleteIfExists()

			-- CREATE THE CELLULAR SPACE
			local resolution = 5e5
			local mask = true
			TerraLib().addShpCellSpaceLayer(proj, layerName1, clName, resolution, File(shp[1]), mask)

			local clSet = TerraLib().getDataSet{project = proj, layer = clName}
			local clInfo = TerraLib().getLayerInfo(proj, clName)
			local geomAttrName = clInfo.geometry

			unitTest:assertEquals(getn(clSet), 9)

			for k, v in pairs(clSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID"))
				unitTest:assertNotNil(v)
			end

			local clLayerInfo = TerraLib().getLayerInfo(proj, clName)

			unitTest:assertEquals(clLayerInfo.name, clName)
			unitTest:assertEquals(clLayerInfo.file, shp[1])
			unitTest:assertEquals(clLayerInfo.type, "OGR")
			unitTest:assertEquals(clLayerInfo.rep, "polygon")

			-- CREATE A LAYER WITH POLYGONS TO DO OPERATIONS
			local layerName2 = "Protection_Unit"
			local layerFile2 = filePath("test/BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "gis")
			TerraLib().addShpLayer(proj, layerName2, layerFile2)

			-- SHAPE OUTPUT
			-- FILL CELLULAR SPACE WITH PRESENCE OPERATION
			local presLayerName = clName.."_"..layerName2.."_Presence"
			shp[2] = testDir..presLayerName..".shp"

			File(shp[2]):deleteIfExists()

			local operation = "presence"
			local attribute = "presence"
			local select = "FID"

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = clName,
				out = presLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local presSet = TerraLib().getDataSet{project = proj, layer = presLayerName}

			unitTest:assertEquals(getn(presSet), 9)

			for k, v in pairs(presSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence"))
				unitTest:assertNotNil(v)
			end

			local presLayerInfo = TerraLib().getLayerInfo(proj, presLayerName)
			unitTest:assertEquals(presLayerInfo.name, presLayerName)
			unitTest:assertEquals(presLayerInfo.file, shp[2])
			unitTest:assertEquals(presLayerInfo.type, "OGR")
			unitTest:assertEquals(presLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH PERCENTAGE TOTAL AREA OPERATION
			local areaLayerName = clName.."_"..layerName2.."_Area"
			shp[3] = testDir..areaLayerName..".shp"

			File(shp[3]):deleteIfExists()

			operation = "area"
			attribute = "area_perce" -- the attribute must have 10 characters (ogr truncate)
			select = "FID"
			local default = 0

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = presLayerName,
				out = areaLayerName,
				attribute = attribute,
				operation = operation,
				select = select,
				default = default
			}

			local areaSet = TerraLib().getDataSet{project = proj, layer = areaLayerName}

			unitTest:assertEquals(getn(areaSet), 9)

			for k, v in pairs(areaSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce"))
				unitTest:assertNotNil(v)
			end

			local areaLayerInfo = TerraLib().getLayerInfo(proj, areaLayerName)
			unitTest:assertEquals(areaLayerInfo.name, areaLayerName)
			unitTest:assertEquals(areaLayerInfo.file, shp[3])
			unitTest:assertEquals(areaLayerInfo.type, "OGR")
			unitTest:assertEquals(areaLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH COUNT OPERATION
			local countLayerName = clName.."_"..layerName2.."_Count"
			shp[4] = testDir..countLayerName..".shp"

			File(shp[4]):deleteIfExists()

			operation = "count"
			attribute = "count"
			select = "FID"
			default = 0

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = areaLayerName,
				out = countLayerName,
				attribute = attribute,
				operation = operation,
				select = select,
				default = default
			}

			local countSet = TerraLib().getDataSet{project = proj, layer = countLayerName}

			unitTest:assertEquals(getn(countSet), 9)

			for k, v in pairs(countSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count"))
				unitTest:assertNotNil(v)
			end

			local countLayerInfo = TerraLib().getLayerInfo(proj, countLayerName)
			unitTest:assertEquals(countLayerInfo.name, countLayerName)
			unitTest:assertEquals(countLayerInfo.file, shp[4])
			unitTest:assertEquals(countLayerInfo.type, "OGR")
			unitTest:assertEquals(countLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH DISTANCE OPERATION
			local distLayerName = clName.."_"..layerName2.."_Distance"
			shp[5] = testDir..distLayerName..".shp"

			File(shp[5]):deleteIfExists()

			operation = "distance"
			attribute = "distance"
			select = "FID"

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = countLayerName,
				out = distLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local distSet = TerraLib().getDataSet{project = proj, layer = distLayerName}

			unitTest:assertEquals(getn(distSet), 9)

			for k, v in pairs(distSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance"))
				unitTest:assertNotNil(v)
			end

			local distLayerInfo = TerraLib().getLayerInfo(proj, distLayerName)
			unitTest:assertEquals(distLayerInfo.name, distLayerName)
			unitTest:assertEquals(distLayerInfo.file, shp[5])
			unitTest:assertEquals(distLayerInfo.type, "OGR")
			unitTest:assertEquals(distLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH MINIMUM OPERATION
			local layerName3 = "Amazon_Munic"
			local layerFile3 = filePath("test/municipiosAML_ok.shp", "gis")
			TerraLib().addShpLayer(proj, layerName3, layerFile3)

			local minLayerName = clName.."_"..layerName3.."_Minimum"
			shp[6] = testDir..minLayerName..".shp"

			File(shp[6]):deleteIfExists()

			operation = "minimum"
			attribute = "minimum"
			select = "POPULACAO_"

			TerraLib().attributeFill{
				project = proj,
				from = layerName3,
				to = distLayerName,
				out = minLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local minSet = TerraLib().getDataSet{project = proj, layer = minLayerName}

			unitTest:assertEquals(getn(minSet), 9)

			for k, v in pairs(minSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum"))
				unitTest:assertNotNil(v)
			end

			local minLayerInfo = TerraLib().getLayerInfo(proj, minLayerName)
			unitTest:assertEquals(minLayerInfo.name, minLayerName)
			unitTest:assertEquals(minLayerInfo.file, shp[6])
			unitTest:assertEquals(minLayerInfo.type, "OGR")
			unitTest:assertEquals(minLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH MAXIMUM OPERATION
			local maxLayerName = clName.."_"..layerName3.."_Maximum"
			shp[7] = testDir..maxLayerName..".shp"

			File(shp[7]):deleteIfExists()

			operation = "maximum"
			attribute = "maximum"
			select = "POPULACAO_"

			TerraLib().attributeFill{
				project = proj,
				from = layerName3,
				to = minLayerName,
				out = maxLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local maxSet = TerraLib().getDataSet{project = proj, layer = maxLayerName}

			unitTest:assertEquals(getn(maxSet), 9)

			for k, v in pairs(maxSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum"))
				unitTest:assertNotNil(v)
			end

			local maxLayerInfo = TerraLib().getLayerInfo(proj, maxLayerName)
			unitTest:assertEquals(maxLayerInfo.name, maxLayerName)
			unitTest:assertEquals(maxLayerInfo.file, shp[7])
			unitTest:assertEquals(maxLayerInfo.type, "OGR")
			unitTest:assertEquals(maxLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH PERCENTAGE OPERATION
			local percLayerName = clName.."_"..layerName2.."_Percentage"
			shp[8] = testDir..percLayerName..".shp"

			File(shp[8]):deleteIfExists()

			operation = "coverage"
			attribute = "perc"
			select = "ADMINISTRA"

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = maxLayerName,
				out = percLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local percentSet = TerraLib().getDataSet{project = proj, layer = percLayerName, missing = -1}

			unitTest:assertEquals(getn(percentSet), 9)

			local missCount = 0

			for k, v in pairs(percentSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (k == "perc_0") or (k == "perc_1"))
				unitTest:assertNotNil(v)

				if string.match(k, "perc_") then
					missCount = missCount + 1
				end
			end

			unitTest:assertEquals(missCount, 2)

			local percLayerInfo = TerraLib().getLayerInfo(proj, percLayerName)
			unitTest:assertEquals(percLayerInfo.name, percLayerName)
			unitTest:assertEquals(percLayerInfo.file, shp[8])
			unitTest:assertEquals(percLayerInfo.type, "OGR")
			unitTest:assertEquals(percLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH STANDARD DEVIATION OPERATION
			local stdevLayerName = clName.."_"..layerName3.."_Stdev"
			shp[9] = testDir..stdevLayerName..".shp"

			File(shp[9]):deleteIfExists()

			operation = "stdev"
			attribute = "stdev"
			select = "POPULACAO_"

			TerraLib().attributeFill{
				project = proj,
				from = layerName3,
				to = percLayerName,
				out = stdevLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local stdevSet = TerraLib().getDataSet{project = proj, layer = stdevLayerName, missing = 0}

			unitTest:assertEquals(getn(stdevSet), 9)

			for k, v in pairs(stdevSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
								(k == "stdev"))
				unitTest:assertNotNil(v)
			end

			local stdevLayerInfo = TerraLib().getLayerInfo(proj, stdevLayerName)
			unitTest:assertEquals(stdevLayerInfo.name, stdevLayerName)
			unitTest:assertEquals(stdevLayerInfo.file, shp[9])
			unitTest:assertEquals(stdevLayerInfo.type, "OGR")
			unitTest:assertEquals(stdevLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION
			local meanLayerName = clName.."_"..layerName3.."_AvrgMean"
			shp[10] = testDir..meanLayerName..".shp"

			File(shp[10]):deleteIfExists()

			operation = "average"
			attribute = "mean"
			select = "POPULACAO_"

			TerraLib().attributeFill{
				project = proj,
				from = layerName3,
				to = stdevLayerName,
				out = meanLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local meanSet = TerraLib().getDataSet{project = proj, layer = meanLayerName, missing = 0}

			unitTest:assertEquals(getn(meanSet), 9)

			for k, v in pairs(meanSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
								(k == "stdev") or (k == "mean"))
				unitTest:assertNotNil(v)
			end

			local meanLayerInfo = TerraLib().getLayerInfo(proj, meanLayerName)
			unitTest:assertEquals(meanLayerInfo.name, meanLayerName)
			unitTest:assertEquals(meanLayerInfo.file, shp[10])
			unitTest:assertEquals(meanLayerInfo.type, "OGR")
			unitTest:assertEquals(meanLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION
			local weighLayerName = clName.."_"..layerName3.."_AvrgWeighted"
			shp[11] = testDir..weighLayerName..".shp"

			File(shp[11]):deleteIfExists()

			operation = "average"
			attribute = "weighted"
			select = "POPULACAO_"
			local area = true

			TerraLib().attributeFill{
				project = proj,
				from = layerName3,
				to = meanLayerName,
				out = weighLayerName,
				attribute = attribute,
				operation = operation,
				select = select,
				area = area
			}

			local weighSet = TerraLib().getDataSet{project = proj, layer = weighLayerName, missing = 0}

			unitTest:assertEquals(getn(weighSet), 9)

			for k, v in pairs(weighSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
								(k == "stdev") or (k == "mean") or (k == "weighted"))
				unitTest:assertNotNil(v)
			end

			local weighLayerInfo = TerraLib().getLayerInfo(proj, weighLayerName)
			unitTest:assertEquals(weighLayerInfo.name, weighLayerName)
			unitTest:assertEquals(weighLayerInfo.file, shp[11])
			unitTest:assertEquals(weighLayerInfo.type, "OGR")
			unitTest:assertEquals(weighLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH MAJORITY INTERSECTION OPERATION
			local interLayerName = clName.."_"..layerName3.."_Intersection"
			shp[12] = testDir..interLayerName..".shp"

			File(shp[12]):deleteIfExists()

			operation = "mode"
			attribute = "majo_int"
			select = "POPULACAO_"
			area = true

			TerraLib().attributeFill{
				project = proj,
				from = layerName3,
				to = weighLayerName,
				out = interLayerName,
				attribute = attribute,
				operation = operation,
				select = select,
				area = area
			}

			local interSet = TerraLib().getDataSet{project = proj, layer = interLayerName, missing = 0}

			unitTest:assertEquals(getn(interSet), 9)

			for k, v in pairs(interSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
								(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int"))
				unitTest:assertNotNil(v)
			end

			local interLayerInfo = TerraLib().getLayerInfo(proj, interLayerName)
			unitTest:assertEquals(interLayerInfo.name, interLayerName)
			unitTest:assertEquals(interLayerInfo.file, shp[12])
			unitTest:assertEquals(interLayerInfo.type, "OGR")
			unitTest:assertEquals(interLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH MAJORITY OCCURRENCE OPERATION
			local occurLayerName = clName.."_"..layerName3.."_Occurence"
			shp[13] = testDir..occurLayerName..".shp"

			File(shp[13]):deleteIfExists()

			operation = "mode"
			attribute = "majo_occur"
			select = "POPULACAO_"

			TerraLib().attributeFill{
				project = proj,
				from = layerName3,
				to = interLayerName,
				out = occurLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local occurSet = TerraLib().getDataSet{project = proj, layer = occurLayerName, missing = 0}

			unitTest:assertEquals(getn(occurSet), 9)

			for k, v in pairs(occurSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
								(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
								(k == "majo_occur"))
				unitTest:assertNotNil(v)
			end

			local occurLayerInfo = TerraLib().getLayerInfo(proj, occurLayerName)
			unitTest:assertEquals(occurLayerInfo.name, occurLayerName)
			unitTest:assertEquals(occurLayerInfo.file, shp[13])
			unitTest:assertEquals(occurLayerInfo.type, "OGR")
			unitTest:assertEquals(occurLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH SUM OPERATION
			local sumLayerName = clName.."_"..layerName3.."_Sum"
			shp[14] = testDir..sumLayerName..".shp"

			File(shp[14]):deleteIfExists()

			operation = "sum"
			attribute = "sum"
			select = "POPULACAO_"

			TerraLib().attributeFill{
				project = proj,
				from = layerName3,
				to = occurLayerName,
				out = sumLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local sumSet = TerraLib().getDataSet{project = proj, layer = sumLayerName, missing = 0}

			unitTest:assertEquals(getn(sumSet), 9)

			for k, v in pairs(sumSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
								(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
								(k == "majo_occur") or (k == "sum"))
				unitTest:assertNotNil(v)
			end

			local sumLayerInfo = TerraLib().getLayerInfo(proj, sumLayerName)
			unitTest:assertEquals(sumLayerInfo.name, sumLayerName)
			unitTest:assertEquals(sumLayerInfo.file, shp[14])
			unitTest:assertEquals(sumLayerInfo.type, "OGR")
			unitTest:assertEquals(sumLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH WEIGHTED SUM OPERATION
			local wsumLayerName = clName.."_"..layerName3.."_Wsum"
			shp[15] = testDir..wsumLayerName..".shp"

			File(shp[15]):deleteIfExists()

			operation = "sum"
			attribute = "wsum"
			select = "POPULACAO_"
			area = true

			TerraLib().attributeFill{
				project = proj,
				from = layerName3,
				to = sumLayerName,
				out = wsumLayerName,
				attribute = attribute,
				operation = operation,
				select = select,
				area = area
			}

			local wsumSet = TerraLib().getDataSet{project = proj, layer = wsumLayerName, missing = 0}

			unitTest:assertEquals(getn(wsumSet), 9)

			for k, v in pairs(wsumSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
								(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
								(k == "majo_occur") or (k == "sum") or (k == "wsum"))
				unitTest:assertNotNil(v)
			end

			local wsumLayerInfo = TerraLib().getLayerInfo(proj, wsumLayerName)
			unitTest:assertEquals(wsumLayerInfo.name, wsumLayerName)
			unitTest:assertEquals(wsumLayerInfo.file, shp[15])
			unitTest:assertEquals(wsumLayerInfo.type, "OGR")
			unitTest:assertEquals(wsumLayerInfo.rep, "polygon")

			-- RASTER TESTS WITH SHAPE
			-- FILL CELLULAR SPACE WITH PERCENTAGE OPERATION USING TIF
			local layerName4 = "Prodes_PA"
			local layerFile4 = filePath("test/prodes_polyc_10k.tif", "gis")
			TerraLib().addGdalLayer(proj, layerName4, layerFile4, wsumLayerInfo.srid)

			local percTifLayerName = clName.."_"..layerName4.."_RPercentage"
			shp[16] = testDir..percTifLayerName..".shp"

			File(shp[16]):deleteIfExists()

			operation = "coverage"
			attribute = "rpercentage"
			select = 0

			local attributeTruncateWarning = function()
				TerraLib().attributeFill{
					project = proj,
					from = layerName4,
					to = wsumLayerName,
					out = percTifLayerName,
					attribute = attribute,
					operation = operation,
					select = select
				}
			end

			unitTest:assertWarning(attributeTruncateWarning, "The 'attribute' lenght has more than 10 characters. It was truncated to 'rpercentag'.")

			percentSet = TerraLib().getDataSet{project = proj, layer = percTifLayerName, missing = 0}

			unitTest:assertEquals(getn(percentSet), 9)

			for k, v in pairs(percentSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
								(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
								(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rpercent_") ~= nil) or
								(string.match(k, "rpercen_") ~= nil))
				unitTest:assertNotNil(v)
			end

			local percTifLayerInfo = TerraLib().getLayerInfo(proj, percTifLayerName)
			unitTest:assertEquals(percTifLayerInfo.name, percTifLayerName)
			unitTest:assertEquals(percTifLayerInfo.file, shp[16])
			unitTest:assertEquals(percTifLayerInfo.type, "OGR")
			unitTest:assertEquals(percTifLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH EVERAGE MEAN OPERATION FROM RASTER
			local rmeanLayerName = clName.."_"..layerName4.."_RMean"
			shp[17] = testDir..rmeanLayerName..".shp"

			File(shp[17]):deleteIfExists()

			operation = "average"
			attribute = "rmean"
			select = 0

			TerraLib().attributeFill{
				project = proj,
				from = layerName4,
				to = percTifLayerName,
				out = rmeanLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local rmeanSet = TerraLib().getDataSet{project = proj, layer = rmeanLayerName, missing = 0}

			unitTest:assertEquals(getn(rmeanSet), 9)

			for k, v in pairs(rmeanSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
								(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
								(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rpercent_") ~= nil) or
								(string.match(k, "rpercen_") ~= nil) or (k == "rmean"))
				unitTest:assertNotNil(v)
			end

			local rmeanLayerInfo = TerraLib().getLayerInfo(proj, rmeanLayerName)
			unitTest:assertEquals(rmeanLayerInfo.name, rmeanLayerName)
			unitTest:assertEquals(rmeanLayerInfo.file, shp[17])
			unitTest:assertEquals(rmeanLayerInfo.type, "OGR")
			unitTest:assertEquals(rmeanLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH MINIMUM OPERATION FROM RASTER
			local rminLayerName = clName.."_"..layerName4.."_RMinimum"
			shp[18] = testDir..rminLayerName..".shp"

			File(shp[18]):deleteIfExists()

			operation = "minimum"
			attribute = "rmin"
			select = 0

			TerraLib().attributeFill{
				project = proj,
				from = layerName4,
				to = rmeanLayerName,
				out = rminLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local rminSet = TerraLib().getDataSet{project = proj, layer = rminLayerName, missing = 0}

			unitTest:assertEquals(getn(rminSet), 9)

			for k, v in pairs(rminSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
								(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
								(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rpercent_") ~= nil) or
								(string.match(k, "rpercen_") ~= nil) or (k == "rmean") or (k == "rmin"))
				unitTest:assertNotNil(v)
			end

			local rminLayerInfo = TerraLib().getLayerInfo(proj, rminLayerName)
			unitTest:assertEquals(rminLayerInfo.name, rminLayerName)
			unitTest:assertEquals(rminLayerInfo.file, shp[18])
			unitTest:assertEquals(rminLayerInfo.type, "OGR")
			unitTest:assertEquals(rminLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH MAXIMUM OPERATION FROM RASTER
			local rmaxLayerName = clName.."_"..layerName4.."_RMaximum"
			shp[19] = testDir..rmaxLayerName..".shp"

			File(shp[19]):deleteIfExists()

			operation = "maximum"
			attribute = "rmax"
			select = 0

			TerraLib().attributeFill{
				project = proj,
				from = layerName4,
				to = rminLayerName,
				out = rmaxLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local rmaxSet = TerraLib().getDataSet{project = proj, layer = rmaxLayerName, missing = 0}

			unitTest:assertEquals(getn(rmaxSet), 9)

			for k, v in pairs(rmaxSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
								(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
								(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rpercent_") ~= nil) or
								(string.match(k, "rpercen_") ~= nil) or (k == "rmean") or (k == "rmin") or (k == "rmax"))
				unitTest:assertNotNil(v)
			end

			local rmaxLayerInfo = TerraLib().getLayerInfo(proj, rmaxLayerName)
			unitTest:assertEquals(rmaxLayerInfo.name, rmaxLayerName)
			unitTest:assertEquals(rmaxLayerInfo.file, shp[19])
			unitTest:assertEquals(rmaxLayerInfo.type, "OGR")
			unitTest:assertEquals(rmaxLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH STANDART DERIVATION OPERATION FROM RASTER
			local rstdevLayerName = clName.."_"..layerName4.."_RStdev"
			shp[20] = testDir..rstdevLayerName..".shp"

			File(shp[20]):deleteIfExists()

			operation = "stdev"
			attribute = "rstdev"
			select = 0

			TerraLib().attributeFill{
				project = proj,
				from = layerName4,
				to = rmaxLayerName,
				out = rstdevLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local rstdevSet = TerraLib().getDataSet{project = proj, layer = rstdevLayerName, missing = 0}

			unitTest:assertEquals(getn(rstdevSet), 9)

			for k, v in pairs(rstdevSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
								(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
								(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rpercent_") ~= nil) or
								(string.match(k, "rpercen_") ~= nil) or (k == "rmean") or (k == "rmin") or (k == "rmax") or
								(k == "rstdev"))
				unitTest:assertNotNil(v)
			end

			local rstdevLayerInfo = TerraLib().getLayerInfo(proj, rstdevLayerName)
			unitTest:assertEquals(rstdevLayerInfo.name, rstdevLayerName)
			unitTest:assertEquals(rstdevLayerInfo.file, shp[20])
			unitTest:assertEquals(rstdevLayerInfo.type, "OGR")
			unitTest:assertEquals(rstdevLayerInfo.rep, "polygon")

			-- FILL CELLULAR SPACE WITH SUM OPERATION FROM RASTER
			local rsumLayerName = clName.."_"..layerName4.."_RSum"
			shp[21] = testDir..rsumLayerName..".shp"

			File(shp[21]):deleteIfExists()

			operation = "sum"
			attribute = "rsum"
			select = 0

			TerraLib().attributeFill{
				project = proj,
				from = layerName4,
				to = rstdevLayerName,
				out = rsumLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local rsumSet = TerraLib().getDataSet{project = proj, layer = rsumLayerName, missing = 0}

			unitTest:assertEquals(getn(rsumSet), 9)

			for k, v in pairs(rsumSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
								(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
								(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rpercent_") ~= nil) or
								(string.match(k, "rpercen_") ~= nil) or (k == "rmean") or (k == "rmin") or (k == "rmax") or
								(k == "rstdev") or (k == "rsum"))
				unitTest:assertNotNil(v)
			end

			local rsumLayerInfo = TerraLib().getLayerInfo(proj, rsumLayerName)
			unitTest:assertEquals(rsumLayerInfo.name, rsumLayerName)
			unitTest:assertEquals(rsumLayerInfo.file, shp[21])
			unitTest:assertEquals(rsumLayerInfo.type, "OGR")
			unitTest:assertEquals(rsumLayerInfo.rep, "polygon")

			-- OVERWRITE OUTPUT
			operation = "sum"
			attribute = "rsum_over"
			select = 0
			default = 0

			TerraLib().attributeFill{
				project = proj,
				from = layerName4,
				to = rsumLayerName,
				attribute = attribute,
				operation = operation,
				select = select,
				default = default
			}

			local rsumOverSet = TerraLib().getDataSet{project = proj, layer = rsumLayerName, missing = 0}

			unitTest:assertEquals(getn(rsumOverSet), 9)

			for k, v in pairs(rsumOverSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
								(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
								(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rpercent_") ~= nil) or
								(string.match(k, "rpercen_") ~= nil) or (k == "rmean") or (k == "rmin") or (k == "rmax") or
								(k == "rstdev") or (k == "rsum") or (k == "rsum_over"))
				unitTest:assertNotNil(v)
			end

			local rsumOverLayerInfo = TerraLib().getLayerInfo(proj, rsumLayerName)
			unitTest:assertEquals(rsumOverLayerInfo.name, rsumLayerName)
			unitTest:assertEquals(rsumOverLayerInfo.file, shp[21])
			unitTest:assertEquals(rsumOverLayerInfo.type, "OGR")
			unitTest:assertEquals(rsumOverLayerInfo.rep, "polygon")

			-- RASTER NODATA
			local nodataLayerName = clName.."_"..layerName4.."_ND"
			shp[22] = testDir..nodataLayerName..".shp"

			File(shp[22]):deleteIfExists()

			operation = "average"
			attribute = "aver_nd"
			select = 0
			local nodata = 256

			TerraLib().attributeFill{
				project = proj,
				from = layerName4,
				to = rsumLayerName,
				out = nodataLayerName,
				attribute = attribute,
				operation = operation,
				select = select,
				nodata = nodata
			}

			local ndSet = TerraLib().getDataSet{project = proj, layer = nodataLayerName, missing = 0}

			unitTest:assertEquals(getn(ndSet), 9)

			for k, v in pairs(ndSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
								(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
								(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rpercent_") ~= nil) or
								(string.match(k, "rpercen_") ~= nil) or (k == "rmean") or (k == "rmin") or (k == "rmax") or
								(k == "rstdev") or (k == "rsum") or (k == "rsum_over") or (k == "aver_nd"))
				unitTest:assertNotNil(v)
			end

			local nodataLayerInfo = TerraLib().getLayerInfo(proj, nodataLayerName)
			unitTest:assertEquals(nodataLayerInfo.name, nodataLayerName)
			unitTest:assertEquals(nodataLayerInfo.file, shp[22])
			unitTest:assertEquals(nodataLayerInfo.type, "OGR")
			unitTest:assertEquals(nodataLayerInfo.rep, "polygon")

			-- COVERAGE ATTRIBUTE + SELECTED WITH MORE THAN 10 CHARACTERS
			local percLayerName2 = clName.."_"..layerName2.."_Percentage2"
			shp[23] = testDir..percLayerName2..".shp"

			File(shp[23]):deleteIfExists()

			operation = "coverage"
			attribute = "percentage"
			select = "ADMINISTRA"

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = nodataLayerName,
				out = percLayerName2,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local percentSet2 = TerraLib().getDataSet{project = proj, layer = percLayerName2, missing = 0}

			unitTest:assertEquals(getn(percentSet2), 9)

			unitTest:assertNotNil(percentSet2[0].percenta_0)
			unitTest:assertNotNil(percentSet2[0].percenta_1)

			-- COVERAGE ATTRIBUTE WITH 9 CHARACTERS
			local percLayerName3 = clName.."_"..layerName2.."_Percentage3"
			shp[24] = testDir..percLayerName3..".shp"

			File(shp[24]):deleteIfExists()

			operation = "coverage"
			attribute = "ninechars"
			select = "NOME"

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = percLayerName2,
				out = percLayerName3,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local percentSet3 = TerraLib().getDataSet{project = proj, layer = percLayerName3, missing = 0}

			unitTest:assertEquals(getn(percentSet3), 9)

			unitTest:assertNotNil(percentSet3[0].nine_REBIO)
			unitTest:assertNotNil(percentSet3[0].nine_PARES)
			unitTest:assertNotNil(percentSet3[0].nine_PARNA)

			-- FILL CELLULAR SPACE WITH COUNT OPERATION FROM RASTER
			local rcountLayerName = clName.."_"..layerName4.."_RCount"
			shp[25] = testDir..rcountLayerName..".shp"

			File(shp[25]):deleteIfExists()

			operation = "count"
			attribute = "rcount"
			select = 0

			TerraLib().attributeFill{
				project = proj,
				from = layerName4,
				to = nodataLayerName,
				out = rcountLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local rcountSet = TerraLib().getDataSet{project = proj, layer = rcountLayerName, missing = 0}

			unitTest:assertEquals(getn(rcountSet), 9)

			for k, v in pairs(rcountSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence") or (k == "area_perce") or (k == "count") or (k == "distance") or
								(k == "minimum") or (k == "maximum") or (string.match(k, "perc_") ~= nil) or
								(k == "stdev") or (k == "mean") or (k == "weighted") or (k == "majo_int") or
								(k == "majo_occur") or (k == "sum") or (k == "wsum") or (string.match(k, "rpercent_") ~= nil) or
								(string.match(k, "rpercen_") ~= nil) or (k == "rmean") or (k == "rmin") or (k == "rmax") or
								(k == "rstdev") or (k == "rsum") or (k == "rsum_over") or (k == "aver_nd") or (k == "rcount"))
				unitTest:assertNotNil(v)
			end

			local rcountLayerInfo = TerraLib().getLayerInfo(proj, rcountLayerName)
			unitTest:assertEquals(rcountLayerInfo.name, rcountLayerName)
			unitTest:assertEquals(rcountLayerInfo.file, shp[25])
			unitTest:assertEquals(rcountLayerInfo.type, "OGR")
			unitTest:assertEquals(rcountLayerInfo.rep, "polygon")

			for j = 1, #shp do
				File(shp[j]):deleteIfExists()
			end

			proj.file:delete()
			Directory(testDir):delete()
		end

		-- local coverageWithPointsData = function() -- TODO(#995)
			-- local proj = createProject()

			-- local layerName1 = "Amz"
			-- local layerFile1 = filePath("amazonia-limit.shp", "gis")
			-- TerraLib().addShpLayer(proj, layerName1, layerFile1)

			-- local clName = "Amz_Cells"
			-- local clFile = File(clName..".shp")
			-- clFile:deleteIfExists()
			-- local resolution = 100e3
			-- local mask = true
			-- TerraLib().addShpCellSpaceLayer(proj, layerName1, clName, resolution, clFile, mask)

			-- local clSet = TerraLib().getDataSet(proj, clName)
			-- unitTest:assertEquals(getn(clSet), 591) -- SKIP

			-- local layerName2 = "Amz_Ports"
			-- local layerFile2 = filePath("amazonia-ports.shp", "gis")
			-- TerraLib().addShpLayer(proj, layerName2, layerFile2)

			-- local clCoverLayerName = clName.."_"..layerName2.."_Cover"
			-- local clCoverLayerFile = File(clCoverLayerName..".shp")
			-- clCoverLayerFile:deleteIfExists()

			-- operation = "coverage"
			-- attribute = "cover"
			-- select = "FID"
			-- area = nil
			-- default = nil
			-- TerraLib().attributeFill(proj, layerName2, clName, clCoverLayerName, attribute, operation, select, area, default)

			-- clFile:delete()
			-- clCoverLayerFile:delete()
			-- proj.file:delete()
		-- end

		local coverageTotalArea = function()
			local proj = createProject()

			local l1Name = "ES_Limit"
			local l1File = filePath("test/limit_es_sirgas2000_5880.shp", "gis")
			TerraLib().addShpLayer(proj, l1Name, l1File)

			-- VectorToVector is generating but it is not correct
			local l2Name = "ES_Protected"
			local l2File = filePath("test/es-protected_areas_sirgas2000_5880.shp", "gis")
			TerraLib().addShpLayer(proj, l2Name, l2File)

			local csName = "Cells"
			local csShp = File(csName..".shp")
			local resolution = 50e3
			local mask = true
			csShp:deleteIfExists()
			TerraLib().addShpCellSpaceLayer(proj, l1Name, csName, resolution, csShp, mask)

			local l3Name = "cells_cov_total_area"
			local l3File = File(l3Name..".shp")
			local operation = "coverage"
			local attribute = "area"
			local select = "GRUPO4"
			local area = true
			local default = 0

			l3File:deleteIfExists()
			TerraLib().attributeFill{
				project = proj,
				from = l2Name,
				to = csName,
				out = l3Name,
				attribute = attribute,
				operation = operation,
				select = select,
				area = area,
				default = default
			}

			-- local l3Set = TerraLib().getDataSet{project = proj, layer = l3Name, missing = 0}

			csShp:delete()
			l3File:delete()
			proj.file:delete()
		end

		local fillQGisProject = function()
			local projFileName = "attributefill_shp_basic"
			local proj = {
				file = projFileName..".qgs"
			}
			File(proj.file):deleteIfExists()
			File(projFileName..".tview"):deleteIfExists()
			TerraLib().createProject(proj)

			local layerName1 = "Para"
			local layerFile1 = filePath("test/limitePA_polyc_pol.shp", "gis")
			TerraLib().addShpLayer(proj, layerName1, layerFile1)

			local clName = "Para_Cells"
			local clFile = File(clName..".shp")

			clFile:deleteIfExists()

			-- CREATE THE CELLULAR SPACE
			local resolution = 5e5
			local mask = true
			TerraLib().addShpCellSpaceLayer(proj, layerName1, clName, resolution, clFile, mask)

			local clSet = TerraLib().getDataSet{project = proj, layer = clName}
			local clInfo = TerraLib().getLayerInfo(proj, clName)
			local geomAttrName = clInfo.geometry

			unitTest:assertEquals(getn(clSet), 9)

			for k, v in pairs(clSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID"))
				unitTest:assertNotNil(v)
			end

			local clLayerInfo = TerraLib().getLayerInfo(proj, clName)
			unitTest:assertEquals(clLayerInfo.name, clName)
			unitTest:assertEquals(clLayerInfo.file, tostring(clFile))
			unitTest:assertEquals(clLayerInfo.type, "OGR")
			unitTest:assertEquals(clLayerInfo.rep, "polygon")

			local layerName2 = "Protection_Unit"
			local layerFile2 = filePath("test/BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "gis")
			TerraLib().addShpLayer(proj, layerName2, layerFile2)

			local operation = "presence"
			local attribute = "presence"
			local select = "FID"

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = clName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local presSet = TerraLib().getDataSet{project = proj, layer = clName}

			unitTest:assertEquals(getn(presSet), 9)

			for k, v in pairs(presSet[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "presence"))
				unitTest:assertNotNil(v)
			end

			File(projFileName..".qgs"):delete()
			clFile:delete()
		end

		local medianOperation = function()
			local proj = createProject()

			local l1Name = "ES_Limit"
			local l1File = filePath("test/limit_es_sirgas2000_5880.shp", "gis")
			TerraLib().addShpLayer(proj, l1Name, l1File)

			local l2Name = "ES_Protected"
			local l2File = filePath("test/es-protected_areas_sirgas2000_5880.shp", "gis")
			TerraLib().addShpLayer(proj, l2Name, l2File)

			local csName = "Cells"
			local csShp = File(csName..".shp")
			local resolution = 20e3
			local mask = true
			csShp:deleteIfExists()
			TerraLib().addShpCellSpaceLayer(proj, l1Name, csName, resolution, csShp, mask)

			local l3Name = csName.."_Median"
			local l3File = File(l3Name..".shp")
			local operation = "median"
			local attribute = "median"
			local select = "Shape_Area"

			l3File:deleteIfExists()
			TerraLib().attributeFill{
				project = proj,
				from = l2Name,
				to = csName,
				out = l3Name,
				attribute = attribute,
				operation = operation,
				select = select
			}

			local l3Set = TerraLib().getDataSet{project = proj, layer = l3Name, missing = 0}
			local l3Info = TerraLib().getLayerInfo(proj, l3Name)
			local geomAttrName = l3Info.geometry

			for k, v in pairs(l3Set[0]) do
				unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
								(k == "median"))
				unitTest:assertNotNil(v)
			end

			local ptPropsInfo = TerraLib().getPropertyInfos(proj, l3Name)
			unitTest:assertEquals(ptPropsInfo[4].name, "median")
			unitTest:assertEquals(ptPropsInfo[4].type, "double")

			csShp:delete()
			l3File:delete()
			proj.file:delete()
		end

		unitTest:assert(allSupportedOperationTogether)
		-- unitTest:assert(coverageWithPointsData) -- SKIP -- TODO(#995)
		unitTest:assert(coverageTotalArea)
		unitTest:assert(fillQGisProject)
		unitTest:assert(medianOperation)
	end,
	saveDataSet = function(unitTest)
		TerraLib().setProgressVisible(false)

		local createProject = function()
			local proj = {
				file = "savedataset-shp-basic.tview",
				title = "TerraLib Tests",
				author = "Avancini Rodrigo"
			}

			File(proj.file):deleteIfExists()
			TerraLib().createProject(proj, {})

			return proj
		end

		local handlingCellularSpace = function()
			local proj = createProject()

			local layerName = "SampaShp"
			local layerFile = filePath("test/sampa.shp", "gis")
			TerraLib().addShpLayer(proj, layerName, layerFile)

			local clName1 = "SampaShpCells"
			local cellsShp = File(clName1..".shp")
			local resolution = 1
			local mask = true
			cellsShp:deleteIfExists()
			TerraLib().addShpCellSpaceLayer(proj, layerName, clName1, resolution, cellsShp, mask)

			local newLayerName = "New_Layer"
			local dSet = TerraLib().getDataSet{project = proj, layer = clName1}
			local luaTable = {}
			for i = 0, getn(dSet) - 1 do
				local data = dSet[i]
				data.attr1 = i
				data.attr2 = "test"..i
				data.attr3 = (i % 2) == 0
				table.insert(luaTable, dSet[i])
			end

			local nlFile = File(newLayerName..".shp")
			nlFile:deleteIfExists()

			-- ADDING ALL SUPPORTED ATTRIBUTES
			TerraLib().saveDataSet(proj, clName1, luaTable, newLayerName, {"attr1", "attr2", "attr3"})

			local newDSet = TerraLib().getDataSet{project = proj, layer = newLayerName}
			local newLayerInfo = TerraLib().getLayerInfo(proj, newLayerName)
			local geomAttrName = newLayerInfo.geometry

			unitTest:assertEquals(getn(newDSet), 37)

			for i = 0, getn(newDSet) - 1 do
				unitTest:assertEquals(newDSet[i].attr1, i)
				for k, v in pairs(newDSet[i]) do
					unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
									(k == "attr1") or (k == "attr2") or (k == "attr3"))

					if k == "attr1" then
						unitTest:assertEquals(type(v), "number")
					elseif k == "attr2" then
						unitTest:assertEquals(type(v), "string")
					elseif k == "attr3" then
						unitTest:assertEquals(type(v), "string") -- boolean is saved as string in shapefile
					end
				end
			end

			local attrNames = TerraLib().getPropertyNames(proj, newLayerName)
			unitTest:assertEquals("FID", attrNames[0])
			unitTest:assertEquals("id", attrNames[1])
			unitTest:assertEquals("col", attrNames[2])
			unitTest:assertEquals("row", attrNames[3])
			unitTest:assertEquals("attr1", attrNames[4])
			unitTest:assertEquals("attr2", attrNames[5])
			unitTest:assertEquals("attr3", attrNames[6])

			-- OVERWRITE LAYER
			dSet = TerraLib().getDataSet{project = proj, layer = clName1}
			luaTable = {}
			for i = 0, getn(dSet) - 1 do
				local data = dSet[i]
				data.attr1 = i
				table.insert(luaTable, dSet[i])
			end

			TerraLib().saveDataSet(proj, clName1, luaTable, newLayerName, {"attr1"})
			newDSet = TerraLib().getDataSet{project = proj, layer = newLayerName}

			unitTest:assertEquals(getn(newDSet), 37)

			for i = 0, getn(newDSet) - 1 do
				unitTest:assertEquals(newDSet[i].attr1, i)
				for k, v in pairs(newDSet[i]) do
					unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
									(k == "attr1"))

					if k == "attr1" then
						unitTest:assertEquals(type(v), "number")
					end
				end
			end

			attrNames = TerraLib().getPropertyNames(proj, newLayerName)
			unitTest:assertEquals("FID", attrNames[0])
			unitTest:assertEquals("id", attrNames[1])
			unitTest:assertEquals("col", attrNames[2])
			unitTest:assertEquals("row", attrNames[3])
			unitTest:assertEquals("attr1", attrNames[4])

			-- OVERWRITE CELLSPACE
			dSet = TerraLib().getDataSet{project = proj, layer = clName1}
			luaTable = {}
			for i = 0, getn(dSet) - 1 do
				local data = dSet[i]
				data.attr1 = i
				table.insert(luaTable, dSet[i])
			end

			TerraLib().saveDataSet(proj, clName1, luaTable, clName1, {"attr1"})
			newDSet = TerraLib().getDataSet{project = proj, layer = newLayerName}

			unitTest:assertEquals(getn(newDSet), 37)

			for i = 0, getn(newDSet) - 1 do
				unitTest:assertEquals(newDSet[i].attr1, i)
				for k, v in pairs(newDSet[i]) do
					unitTest:assert((k == "id") or (k == "col") or (k == "row") or (k == geomAttrName) or (k == "FID") or
									(k == "attr1"))

					if k == "attr1" then
						unitTest:assertEquals(type(v), "number")
					end
				end
			end

			attrNames = TerraLib().getPropertyNames(proj, newLayerName)
			unitTest:assertEquals("FID", attrNames[0])
			unitTest:assertEquals("id", attrNames[1])
			unitTest:assertEquals("col", attrNames[2])
			unitTest:assertEquals("row", attrNames[3])
			unitTest:assertEquals("attr1", attrNames[4])

			File(newLayerName..".shp"):delete()
			cellsShp:delete()
			proj.file:delete()
		end

		-- SAVE POLYGONS, POINTS AND LINES THAT ARE NOT CELLSPACE SPACE
		local handlingAttributesFromPolygonsData = function()
			local proj = createProject()
			local polName = "ES_Limit"
			local polFile = filePath("test/limite_es_poly_wgs84.shp", "gis")
			TerraLib().addShpLayer(proj, polName, polFile)

			local fromData = {project = proj, layer = polName}
			local toData = {file = File("limite_es_poly_wgs84-rep.shp"), type = "shp", srid = 4326}
			TerraLib().saveDataAs(fromData, toData, true)

			local polDset = TerraLib().getDataSet{project = proj, layer = polName}
			local polLuaTable = {}
			for i = 0, getn(polDset) - 1 do
				local data = polDset[i]
				data.attr1 = i
				table.insert(polLuaTable, polDset[i])
			end

			polName = "ES_Limit_CurrDir"
			polFile = toData.file
			TerraLib().addShpLayer(proj, polName, polFile)

			local attrNames = TerraLib().getPropertyNames(proj, polName)
			unitTest:assertEquals("FID", attrNames[0])
			unitTest:assertEquals("GM_LAYER", attrNames[1])
			unitTest:assertEquals("GM_TYPE", attrNames[2])
			unitTest:assertEquals("LAYER", attrNames[3])
			unitTest:assertEquals("NM_ESTADO", attrNames[4])
			unitTest:assertEquals("NM_REGIAO", attrNames[5])
			unitTest:assertEquals("CD_GEOCUF", attrNames[6])
			unitTest:assertEquals("NM_UF", attrNames[7])

			local newPolName = "ES_Limit_New"
			TerraLib().saveDataSet(proj, polName, polLuaTable, newPolName, {"attr1"})

			local newPolDsetSize = TerraLib().getLayerSize(proj, newPolName)
			unitTest:assertEquals(newPolDsetSize, 1)
			unitTest:assertEquals(newPolDsetSize, getn(polDset))

			attrNames = TerraLib().getPropertyNames(proj, newPolName)
			unitTest:assertEquals("FID", attrNames[0])
			unitTest:assertEquals("GM_LAYER", attrNames[1])
			unitTest:assertEquals("GM_TYPE", attrNames[2])
			unitTest:assertEquals("LAYER", attrNames[3])
			unitTest:assertEquals("NM_ESTADO", attrNames[4])
			unitTest:assertEquals("NM_REGIAO", attrNames[5])
			unitTest:assertEquals("CD_GEOCUF", attrNames[6])
			unitTest:assertEquals("NM_UF", attrNames[7])
			unitTest:assertEquals("attr1", attrNames[8])

			polFile:delete()
			File(newPolName..".shp"):delete()
			proj.file:delete()
		end

		local handlingAttributesFromPointsData = function()
			local proj = createProject()
			local ptName = "BR_Ports"
			local ptFile = filePath("test/ports.shp", "gis")
			TerraLib().addShpLayer(proj, ptName, ptFile)

			local fromData = {project = proj, layer = ptName}
			local toData = {file = File("ports-rep.shp"), type = "shp", srid = 4326}
			toData.file:deleteIfExists()
			TerraLib().saveDataAs(fromData, toData, true)

			local ptDset = TerraLib().getDataSet{project = proj, layer = ptName, missing = 0}
			local ptLuaTable = {}
			for i = 0, getn(ptDset) - 1 do
				local data = ptDset[i]
				data.attr1 = i
				table.insert(ptLuaTable, ptDset[i])
			end

			ptName = "BR_Ports_CurrDir"
			ptFile = toData.file
			TerraLib().addShpLayer(proj, ptName, ptFile)

			local attrNames = TerraLib().getPropertyNames(proj, ptName)
			unitTest:assertEquals("FID", attrNames[0])
			unitTest:assertEquals("tipo", attrNames[5])
			unitTest:assertEquals("gestao", attrNames[10])
			unitTest:assertEquals("pro_didade", attrNames[15])
			unitTest:assertEquals("cep", attrNames[20])
			unitTest:assertEquals("idr_rafica", attrNames[25])
			unitTest:assertEquals("observacao", attrNames[30])
			unitTest:assertEquals("cdc_troide", attrNames[32])

			local newPtName = "BR_Ports_New"
			TerraLib().saveDataSet(proj, ptName, ptLuaTable, newPtName, {"attr1"})

			local newPtDsetSize = TerraLib().getLayerSize(proj, newPtName)
			unitTest:assertEquals(newPtDsetSize, 8)
			unitTest:assertEquals(newPtDsetSize, getn(ptDset))

			attrNames = TerraLib().getPropertyNames(proj, newPtName)
			unitTest:assertEquals("FID", attrNames[0])
			unitTest:assertEquals("tipo", attrNames[5])
			unitTest:assertEquals("gestao", attrNames[10])
			unitTest:assertEquals("pro_didade", attrNames[15])
			unitTest:assertEquals("cep", attrNames[20])
			unitTest:assertEquals("idr_rafica", attrNames[25])
			unitTest:assertEquals("observacao", attrNames[30])
			unitTest:assertEquals("cdc_troide", attrNames[32])
			unitTest:assertEquals("attr1", attrNames[33])

			ptFile:delete()
			File(newPtName..".shp"):delete()
			proj.file:delete()
		end

		local handlingAttributesFromLinesData = function()
			local proj = createProject()
			local lnName = "ES_Rails"
			local lnFile = filePath("test/rails.shp", "gis")
			TerraLib().addShpLayer(proj, lnName, lnFile)

			local fromData = {project = proj, layer = lnName}
			local toData = {file = File("rails-rep.shp"), type = "shp", srid = 4326}
			toData.file:deleteIfExists()
			TerraLib().saveDataAs(fromData, toData, true)

			local lnDset = TerraLib().getDataSet{project = proj, layer = lnName, missing = 0}
			local lnLuaTable = {}
			for i = 0, getn(lnDset) - 1 do
				local data = lnDset[i]
				data.attr1 = i
				table.insert(lnLuaTable, lnDset[i])
			end

			lnName = "ES_Rails_CurrDir"
			lnFile = toData.file
			TerraLib().addShpLayer(proj, lnName, lnFile)

			local attrNames = TerraLib().getPropertyNames(proj, lnName)
			unitTest:assertEquals("FID", attrNames[0])
			unitTest:assertEquals("OBSERVACAO", attrNames[3])
			unitTest:assertEquals("PRODUTOS", attrNames[6])
			unitTest:assertEquals("OPERADORA", attrNames[9])
			unitTest:assertEquals("Bitola_Ext", attrNames[12])
			unitTest:assertEquals("COD_PNV", attrNames[14])

			local newLnName = "ES_Rails_New"
			TerraLib().saveDataSet(proj, lnName, lnLuaTable, newLnName, {"attr1"})

			local newLnDsetSize = TerraLib().getLayerSize(proj, newLnName)
			unitTest:assertEquals(newLnDsetSize, 182)
			unitTest:assertEquals(newLnDsetSize, getn(lnDset))

			attrNames = TerraLib().getPropertyNames(proj, newLnName)
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

			TerraLib().saveDataSet(proj, newLnName, lnLuaTable, newLnName, {"attr1", "attr2", "attr3"})
			attrNames = TerraLib().getPropertyNames(proj, newLnName)
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

			TerraLib().saveDataSet(proj, newLnName, lnLuaTable, newLnName, {"attr1", "attr2", "attr3", "attr4"})
			attrNames = TerraLib().getPropertyNames(proj, newLnName)
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

			TerraLib().saveDataSet(proj, newLnName, lnLuaTable, newLnName, {"attr1"})
			attrNames = TerraLib().getPropertyNames(proj, newLnName)
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

			TerraLib().saveDataSet(proj, newLnName, lnLuaTable, newLnName, {"attr1", "attr2", "attr3"})
			attrNames = TerraLib().getPropertyNames(proj, newLnName)
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

			lnFile:delete()
			File(newLnName..".shp"):delete()
			proj.file:delete()
		end

		local handlingIntegerAttributeValues = function()
			local proj = createProject()
			local amlName = "Amazonia"
			local amlFile = filePath("test/municipiosAML_ok.shp", "gis")
			TerraLib().addShpLayer(proj, amlName, amlFile)

			local amlCurrDirName = "AmlCurrDir"
			local toData = {file = File(amlCurrDirName..".shp"), type = "shp"}
			local fromData = {project = proj, layer = amlName}
			TerraLib().saveDataAs(fromData, toData, true)
			TerraLib().addShpLayer(proj, amlCurrDirName, toData.file)

			local amlDset = TerraLib().getDataSet{project = proj, layer = amlName, missing = 0}
			local amlLuaTable = {}
			local sum1 = 0
			for i = 0, getn(amlDset) - 1 do
				local data = amlDset[i]
				sum1 = sum1 + data.CODMESO
				data.CODMESO = data.CODMESO * 2
				table.insert(amlLuaTable, amlDset[i])
			end

			local amlCurrDirNameNew = "AmlCurrDirNew"
			TerraLib().saveDataSet(proj, amlCurrDirName, amlLuaTable, amlCurrDirNameNew, {"CODMESO"})

			local amlDsetNew = TerraLib().getDataSet{project = proj, layer = amlCurrDirNameNew, missing = 0}
			local sum2 = 0
			for i = 0, getn(amlDsetNew) - 1 do
				local data = amlDsetNew[i]
				sum2 = sum2 + data.CODMESO
			end

			unitTest:assertEquals(sum2, 2 * sum1)

			local amlCurrDirNameNew2 = "AmlCurrDirNew2"
			local amlCurrDirLuaTable = {}
			for i = 0, getn(amlDsetNew) - 1 do
				local data = amlDsetNew[i]
				data.CODMESOBKP = data.CODMESO
				data.CODMESO = data.CODMESO * 2
				table.insert(amlCurrDirLuaTable, amlDsetNew[i])
			end
			TerraLib().saveDataSet(proj, amlCurrDirNameNew, amlCurrDirLuaTable, amlCurrDirNameNew2, {"CODMESO", "CODMESOBKP"})

			local amlDsetNew2 = TerraLib().getDataSet{project = proj, layer = amlCurrDirNameNew2, missing = 0}
			local sum3 = 0
			local bkpSum = 0
			for i = 0, getn(amlDsetNew2) - 1 do
				local data = amlDsetNew2[i]
				sum3 = sum3 + data.CODMESO
				bkpSum = bkpSum + data.CODMESOBKP
			end

			unitTest:assertEquals(sum3, 4 * sum1)
			unitTest:assertEquals(sum3, 2 * bkpSum)

			-- Integer 64
			local ptName = "BR_Ports"
			local ptFile = filePath("test/ports.shp", "gis")
			TerraLib().addShpLayer(proj, ptName, ptFile)

			fromData = {project = proj, layer = ptName}
			toData = {file = File("ports-rep.shp"), type = "shp", srid = 4326}
			TerraLib().saveDataAs(fromData, toData, true)

			local ptNameCd = "BR_Ports_CurrDir"
			local ptFileCd = toData.file
			TerraLib().addShpLayer(proj, ptNameCd, ptFileCd)

			local ptDset = TerraLib().getDataSet{project = proj, layer = ptNameCd, missing = 0}
			local ptLuaTable = {}
			for i = 0, getn(ptDset) - 1 do
				local data = ptDset[i]
				data.numbkp = data.numero
				data.numero = data.numero * 2
				table.insert(ptLuaTable, ptDset[i])
			end

			TerraLib().saveDataSet(proj, ptNameCd, ptLuaTable, ptNameCd, {"numero", "numbkp"})
			local ptDsetUp = TerraLib().getDataSet{project = proj, layer = ptNameCd, missing = 0}

			local ptPropsInfo = TerraLib().getPropertyInfos(proj, ptNameCd)
			unitTest:assertEquals(ptPropsInfo[18].name, "numero")
			unitTest:assertEquals(ptPropsInfo[18].type, "integer 64")
			local ptPropsInfoLastPos = getn(ptPropsInfo) - 2
			unitTest:assertEquals(ptPropsInfo[ptPropsInfoLastPos].name, "numbkp")
			unitTest:assertEquals(ptPropsInfo[ptPropsInfoLastPos].type, "double")

			for i = 0, getn(ptDsetUp) - 1 do
				unitTest:assertEquals(ptDsetUp[i].numero, ptDsetUp[i].numbkp * 2)
			end

			File(amlCurrDirName..".shp"):delete()
			File(amlCurrDirNameNew..".shp"):delete()
			File(amlCurrDirNameNew2..".shp"):delete()
			ptFileCd:delete()
			proj.file:delete()
		end

		unitTest:assert(handlingCellularSpace)
		unitTest:assert(handlingAttributesFromPolygonsData)
		unitTest:assert(handlingAttributesFromPointsData)
		unitTest:assert(handlingAttributesFromLinesData)
		unitTest:assert(handlingIntegerAttributeValues)
	end,
	getDataSet = function(unitTest)
		local shpFile = filePath("test/sampa.shp", "gis")
		local dSet = TerraLib().getDataSet{file = shpFile}
		local geomInfo = TerraLib().getGeometryInfo{file = shpFile}
		local geomAttrName = geomInfo.name

		unitTest:assertEquals(getn(dSet), 63)

		for i = 0, #dSet do
			unitTest:assertEquals(dSet[i].FID, i)

			for k, v in pairs(dSet[i]) do
				unitTest:assert((k == "FID") or (k == "ID") or (k == "NM_MICRO") or
								(k == "CD_GEOCODU") or (k == geomAttrName))
				unitTest:assertNotNil(v)
			end
		end
	end,
	getArea = function(unitTest)
		TerraLib().setProgressVisible(false)

		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local clName1 = "SampaShpCells"
		local resolution = 1
		local mask = true
		local cellsShp = File(clName1..".shp")

		cellsShp:deleteIfExists()

		TerraLib().addShpCellSpaceLayer(proj, layerName1, clName1, resolution, cellsShp, mask)

		local dSet = TerraLib().getDataSet{project = proj, layer = clName1}
		local clInfo1 = TerraLib().getLayerInfo(proj, clName1)
		local geomAttrName = clInfo1.geometry
		local area = TerraLib().getArea(dSet[0][geomAttrName])
		unitTest:assertEquals(type(area), "number")
		unitTest:assertEquals(area, 1, 0.001)

		for i = 1, #dSet do
			for k, v in pairs(dSet[i]) do
				if k == geomAttrName then
					unitTest:assertEquals(area, TerraLib().getArea(v), 0.001)
				end
			end
		end

		cellsShp:deleteIfExists()
		proj.file:delete()
	end,
	getProjection = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "Sampa"
		local layerFile1 = filePath("test/sampa.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1, nil, 4019)

		local prj = TerraLib().getProjection(proj.layers[layerName1])
		unitTest:assertEquals(prj.SRID, 4019.0)
		unitTest:assertEquals(prj.NAME, "Unknown datum based upon the GRS 1980 ellipsoid")
		unitTest:assertEquals(prj.PROJ4, "+proj=longlat +ellps=GRS80 +no_defs")

		local layerName2 = "Setores"
		local layerFile2 = filePath("itaituba-census.shp", "gis")
		TerraLib().addShpLayer(proj, layerName2, layerFile2)

		prj = TerraLib().getProjection(proj.layers[layerName2])

		unitTest:assertEquals(prj.SRID, 29191.0)
		unitTest:assertEquals(prj.NAME, "SAD69 / UTM zone 21S")
		unitTest:assertEquals(prj.PROJ4, "+proj=utm +zone=21 +south +ellps=aust_SA +towgs84=-66.87,4.37,-38.52,0,0,0,0 +units=m +no_defs")

		proj.file:delete()
	end,
	getPropertyNames = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "Sampa"
		local layerFile1 = filePath("test/sampa.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local propNames = TerraLib().getPropertyNames(proj, layerName1)

		for i = 0, #propNames do
			unitTest:assert((propNames[i] == "FID") or (propNames[i] == "ID") or
						(propNames[i] == "NM_MICRO") or (propNames[i] == "CD_GEOCODU"))
		end

		proj.file:delete()
	end,
	getPropertyInfos = function(unitTest)
		local proj = {}
		proj.file = "tlib_shp_bas.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "Sampa"
		local layerFile1 = filePath("test/sampa.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local propInfos = TerraLib().getPropertyInfos(proj, layerName1)
		local layerInfo = TerraLib().getLayerInfo(proj, layerName1)
		local geomAttrName = layerInfo.geometry

		unitTest:assertEquals(getn(propInfos), 5)
		unitTest:assertEquals(propInfos[0].name, "FID")
		unitTest:assertEquals(propInfos[0].type, "integer 32")
		unitTest:assertEquals(propInfos[1].name, "ID")
		unitTest:assertEquals(propInfos[1].type, "integer 64")
		unitTest:assertEquals(propInfos[2].name, "NM_MICRO")
		unitTest:assertEquals(propInfos[2].type, "string")
		unitTest:assertEquals(propInfos[3].name, "CD_GEOCODU")
		unitTest:assertEquals(propInfos[3].type, "string")
		unitTest:assertEquals(propInfos[4].name, geomAttrName)
		unitTest:assertEquals(propInfos[4].type, "geometry")

		proj.file:delete()
	end,
	getDistance = function(unitTest)
		TerraLib().setProgressVisible(false)

		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local clName = "Sampa_Cells"
		local shp1 = File(clName..".shp")

		shp1:deleteIfExists()

		local resolution = 1
		local mask = true
		TerraLib().addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp1, mask)

		local dSet = TerraLib().getDataSet{project = proj, layer = clName}
		local clInfo = TerraLib().getLayerInfo(proj, clName)
		local geomAttrName = clInfo.geometry
		local dist = TerraLib().getDistance(dSet[0][geomAttrName], dSet[getn(dSet) - 1][geomAttrName])

		unitTest:assertEquals(dist, 4.1231056256177, 1.0e-13)

		proj.file:delete()
		shp1:delete()
	end,
	castGeomToSubtype = function(unitTest)
		local shpFile = filePath("test/sampa.shp", "gis")
		local dSet = TerraLib().getDataSet{file = shpFile}
		local geomInfo = TerraLib().getGeometryInfo{file = shpFile}
		local geom = dSet[1][geomInfo.name]
		geom = TerraLib().castGeomToSubtype(geom)
		unitTest:assertEquals(geom:getGeometryType(), "MultiPolygon")
		geom = TerraLib().castGeomToSubtype(geom:getGeometryN(0))
		unitTest:assertEquals(geom:getGeometryType(), "Polygon")

		shpFile = filePath("amazonia-roads.shp", "gis")
		dSet = TerraLib().getDataSet{file = shpFile}
		geomInfo = TerraLib().getGeometryInfo{file = shpFile}
		geom = dSet[1][geomInfo.name]
		geom = TerraLib().castGeomToSubtype(geom)
		unitTest:assertEquals(geom:getGeometryType(), "MultiLineString")
		geom = TerraLib().castGeomToSubtype(geom:getGeometryN(0))
		unitTest:assertEquals(geom:getGeometryType(), "LineString")

		shpFile = filePath("test/prodes_points_10km_PA_pt.shp", "gis")
		dSet = TerraLib().getDataSet{file = shpFile}
		geomInfo = TerraLib().getGeometryInfo{file = shpFile}
		geom = dSet[1][geomInfo.name]
		geom = TerraLib().castGeomToSubtype(geom)
		unitTest:assertEquals(geom:getGeometryType(), "MultiPoint")
		geom = TerraLib().castGeomToSubtype(geom:getGeometryN(0))
		unitTest:assertEquals(geom:getGeometryType(), "Point")
	end,
	saveDataAs = function(unitTest)
		TerraLib().setProgressVisible(false)

		local sampaLayerName = "SampaShp"
		local createProjectWithSampaLayer = function()
			local proj = {
				file = "savedataas_shp_basic.tview",
				title = "TerraLib Tests",
				author = "Avancini Rodrigo"
			}
			File(proj.file):deleteIfExists()
			TerraLib().createProject(proj, {})
			TerraLib().addShpLayer(proj, sampaLayerName, filePath("test/sampa.shp", "gis"))
			return proj
		end

		local shpToGeoJson = function()
			local proj = createProjectWithSampaLayer()
			local fromData = {project = proj, layer = sampaLayerName}
			local toData = {file = File("shp2geojson.geojson"), type = "geojson"}
			toData.file:deleteIfExists()

			TerraLib().saveDataAs(fromData, toData)
			unitTest:assert(toData.file:exists())

			-- OVERWRITE
			local overwrite = true
			TerraLib().saveDataAs(fromData, toData, overwrite)
			unitTest:assert(toData.file:exists())

			-- OVERWRITE AND CHANGE SRID
			toData.srid = 4326
			TerraLib().saveDataAs(fromData, toData, overwrite)
			local layerName2 = "GJ"
			TerraLib().addGeoJSONLayer(proj, layerName2, toData.file)
			local info2 = TerraLib().getLayerInfo(proj, layerName2)
			unitTest:assertEquals(info2.srid, toData.srid)

			toData.file:delete()
			proj.file:delete()
		end

		local shpToShp = function()
			local proj = createProjectWithSampaLayer()
			local fromData = {project = proj, layer = sampaLayerName}
			local toData = {file = File("shp2shp.shp")}
			toData.file:deleteIfExists()

			TerraLib().saveDataAs(fromData, toData)
			unitTest:assert(toData.file:exists())

			-- OVERWRITE AND CHANGE SRID
			local overwrite = true
			toData.srid = 4326
			TerraLib().saveDataAs(fromData, toData, overwrite)
			local layerName3 = "SHP"
			TerraLib().addShpLayer(proj, layerName3, toData.file)
			local info3 = TerraLib().getLayerInfo(proj, layerName3)
			unitTest:assertEquals(info3.srid, toData.srid)

			toData.file:delete()
			proj.file:delete()
		end

		local saveJustOneProperty = function()
			local proj = createProjectWithSampaLayer()
			local fromData = {project = proj, layer = sampaLayerName}
			local toData = {file = File("shp2shp.shp")}
			local overwrite = true

			TerraLib().saveDataAs(fromData, toData, overwrite, {"NM_MICRO"})

			local layerName2 = "OneProp"
			TerraLib().addShpLayer(proj, layerName2, toData.file)
			local dset = TerraLib().getDataSet{project = proj, layer = layerName2}
			local layerInfo = TerraLib().getLayerInfo(proj, layerName2)
			local geomAttrName = layerInfo.geometry

			unitTest:assertEquals(getn(dset), 63)
			for k, v in pairs(dset[0]) do
				unitTest:assert(((k == "FID") and (v == 0)) or ((k == geomAttrName) and (v ~= nil) ) or
								((k == "NM_MICRO") and (v == "VOTUPORANGA")))
			end

			toData.file:delete()
			proj.file:delete()
		end

		-- SAVE DATA SUBSET TESTS
		local createSubsetTable = function()
			local proj = createProjectWithSampaLayer()
			local dset1 = TerraLib().getDataSet{project = proj, layer = sampaLayerName}
			local sjc
			for i = 0, getn(dset1) - 1 do
				if dset1[i].ID == 27 then
					sjc = dset1[i]
				end
			end

			local layerInfo = TerraLib().getLayerInfo(proj, sampaLayerName)
			local geomAttrName = layerInfo.geometry

			local touches = {}
			local j = 1
			for i = 0, getn(dset1) - 1 do
				if sjc[geomAttrName]:touches(dset1[i][geomAttrName]) then
					touches[j] = dset1[i]
					j = j + 1
				end
			end

			proj.file:delete()

			return touches
		end

		local subset = createSubsetTable()

		local saveLayerSubset = function()
			local proj = createProjectWithSampaLayer()
			local fromData = {project = proj, layer = sampaLayerName}
			local toData = {file = File("touches_sjc.shp"), type = "shp"}
			local overwrite = true

			TerraLib().saveDataAs(fromData, toData, overwrite, {"NM_MICRO", "ID"}, subset)

			local tchsSjc = TerraLib().getDataSet{file = toData.file}

			unitTest:assertEquals(getn(tchsSjc), 2)
			unitTest:assertEquals(tchsSjc[0].ID, 55)
			unitTest:assertEquals(tchsSjc[1].ID, 109)

			toData.file:delete()
			proj.file:delete()
		end

		local saveSubsetWithoutLayer = function()
			local fromData = {file = filePath("test/sampa.shp", "gis")}
			local toData1 = {file = File("touches_sjc_1.shp"), type = "shp"}
			local overwrite = true

			-- Save just two
			TerraLib().saveDataAs(fromData, toData1, overwrite, {"NM_MICRO", "ID"}, subset)

			local tchsSjc1 = TerraLib().getDataSet{file = toData1.file}

			unitTest:assertEquals(getn(tchsSjc1), 2)
			unitTest:assertEquals(tchsSjc1[0].ID, 55)
			unitTest:assertEquals(tchsSjc1[1].ID, 109)

			local toData2 = {file = File("touches_sjc_2.shp")}

			-- Save all
			TerraLib().saveDataAs(fromData, toData2, overwrite, nil, subset)

			local tchsSjc2 = TerraLib().getDataSet{file = toData2.file}

			unitTest:assertEquals(getn(tchsSjc2), 2)
			unitTest:assertEquals(tchsSjc2[1].FID, 1)
			unitTest:assertEquals(tchsSjc2[1].ID, 109)
			unitTest:assertEquals(tchsSjc2[1].NM_MICRO, "GUARULHOS")
			unitTest:assertEquals(tchsSjc2[1].CD_GEOCODU, "35")

			toData1.file:delete()
			toData2.file:delete()
		end

		unitTest:assert(shpToGeoJson)
		unitTest:assert(shpToShp)
		unitTest:assert(saveJustOneProperty)
		unitTest:assert(saveLayerSubset)
		unitTest:assert(saveSubsetWithoutLayer)
	end,
	getLayerSize = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		local file = File(proj.file)
		file:deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local size = TerraLib().getLayerSize(proj, layerName1)

		unitTest:assertEquals(size, 63.0)
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
		TerraLib().addShpLayer(proj, lnName, lnFile)

		local fromData = {}
		fromData.project = proj
		fromData.layer = lnName

		local toData = {}
		toData.file = File("rails-rep.shp")
		toData.type = "shp"
		toData.file:deleteIfExists()

		TerraLib().saveDataAs(fromData, toData, true)

		lnName = "ES_Rails_CurrDir"
		lnFile = toData.file
		TerraLib().addShpLayer(proj, lnName, lnFile)

		local dpLayerName = "ES_Rails_Peucker"
		local dpFile = File(string.lower(dpLayerName)..".shp"):deleteIfExists()

		TerraLib().douglasPeucker(proj, lnName, dpLayerName, 500)
		TerraLib().addShpLayer(proj, dpLayerName, dpFile)

		local dpSetSize = TerraLib().getLayerSize(proj, dpLayerName)
		unitTest:assertEquals(dpSetSize, 182)

		local attrNames = TerraLib().getPropertyNames(proj, dpLayerName)
		unitTest:assertEquals("FID", attrNames[0])
		unitTest:assertEquals("OBSERVACAO", attrNames[3])
		unitTest:assertEquals("PRODUTOS", attrNames[6])
		unitTest:assertEquals("OPERADORA", attrNames[9])
		unitTest:assertEquals("Bitola_Ext", attrNames[12])
		unitTest:assertEquals("COD_PNV", attrNames[14])

		dpFile:delete()
		lnFile:delete()
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
		TerraLib().addGdalLayer(proj, layerName, layerFile)

		local inInfo = {
			project = proj,
			layer = layerName,
			band = 0,
		}

		local outFile = File("emas-polygonized.shp")
		outFile:deleteIfExists()

		local outInfo = {
			type = "shp",
			file = outFile
		}

		TerraLib().polygonize(inInfo, outInfo)

		local polyName = "Polygonized"
		TerraLib().addShpLayer(proj, polyName, outFile)
		local dsetSize = TerraLib().getLayerSize(proj, polyName)

		unitTest:assertEquals(dsetSize, 381)

		local attrNames = TerraLib().getPropertyNames(proj, polyName)
		unitTest:assertEquals("FID", attrNames[0])
		unitTest:assertEquals("id", attrNames[1])
		unitTest:assertEquals("value", attrNames[2])

		proj.file:delete()
		outFile:delete()
	end,
	getDataSetSize = function(unitTest)
		local shpFile = filePath("test/es_sirgas2000_5880.shp", "gis")
		local dsetSize = TerraLib().getDataSetSize(shpFile)

		unitTest:assertEquals(dsetSize, 77)
	end,
	checkLayerGeometries = function(unitTest)
		local proj = {
			file = "check_layer_geometry.qgs",
			title = "TerraLib Tests",
			author = "Avancini Rodrigo"
		}
		File(proj.file):deleteIfExists()
		TerraLib().createProject(proj)

		local defectFile = filePath("test/biomassa.shp", "gis")
		defectFile:copy(currentDir())

		local l1Name = "DefectiveBio"
		local l1File = File("biomassa.shp")
		TerraLib().addShpLayer(proj, l1Name, l1File)

		TerraLib().setProgressVisible(false)

		local problems = TerraLib().checkLayerGeometries(proj, l1Name)

		unitTest:assertEquals(problems[1].pk.value, "404")
		unitTest:assertEquals(problems[2].pk.value, "448")
		unitTest:assertEquals(problems[3].pk.value, "607")
		unitTest:assertEquals(problems[4].pk.value, "640")
		unitTest:assertEquals(problems[5].pk.value, "763")

		l1File:delete()
		proj.file:delete()
	end
}
