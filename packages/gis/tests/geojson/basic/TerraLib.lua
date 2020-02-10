-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.3 of the License, or (at your option) any later version.

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
	addGeoJSONLayer = function(unitTest)
		local title = "TerraLib Tests"
		local author = "Carneiro Heitor"
		local file = "mygeojsonproject.tview"
		local proj = {}
		proj.file = file
		proj.title = title
		proj.author = author

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName = "GeoJSONLayer"
		local layerFile = filePath("test/Setores_Censitarios_2000_pol.geojson", "gis")

		TerraLib().addGeoJSONLayer(proj, layerName, layerFile)

		local layerInfo = TerraLib().getLayerInfo(proj, layerName)

		unitTest:assertEquals(layerInfo.name, layerName)
		unitTest:assertEquals(layerInfo.file, tostring(layerFile))
		unitTest:assertEquals(layerInfo.type, "OGR")
		unitTest:assertEquals(layerInfo.rep, "polygon")

		proj.file:deleteIfExists()
	end,
	addGeoJSONCellSpaceLayer = function(unitTest)
		TerraLib().setProgressVisible(false)

		local title = "TerraLib Tests"
		local author = "Carneiro Heitor"
		local file = "mygeojsonproject.tview"
		local proj = {}
		proj.file = file
		proj.title = title
		proj.author = author

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName = "GeoJSONLayer"
		local layerFile = filePath("test/es_limit_sirgas2000_5880.geojson", "gis")
		TerraLib().addGeoJSONLayer(proj, layerName, layerFile)
		local layerInfo1 = TerraLib().getLayerInfo(proj, layerName)

		local clName = "GeoJSON_Cells"
		local geojson1 = File(clName..".geojson")

		geojson1:deleteIfExists()

		local resolution = 20e3
		local mask = true
		TerraLib().addGeoJSONCellSpaceLayer(proj, layerName, clName, resolution, geojson1, mask)

		local layerInfo = TerraLib().getLayerInfo(proj, clName)

		unitTest:assertEquals(layerInfo.name, clName)
		unitTest:assertEquals(layerInfo.file, tostring(geojson1))
		unitTest:assertEquals(layerInfo.type, "OGR")
		unitTest:assertEquals(layerInfo.rep, "polygon")
		unitTest:assertEquals(layerInfo.srid, layerInfo1.srid)

		-- NO MASK TEST
		local clSetSize = TerraLib().getLayerSize(proj, clName)
		unitTest:assertEquals(clSetSize, 154)

		clName = clName.."_NoMask"
		local geojson2 = File(clName..".geojson")

		geojson2:deleteIfExists()

		mask = false
		TerraLib().addGeoJSONCellSpaceLayer(proj, layerName, clName, resolution, geojson2, mask)

		clSetSize = TerraLib().getLayerSize(proj, clName)
		unitTest:assertEquals(clSetSize, 260)
		-- // NO MASK TEST

		unitTest:assertFile(geojson1)
		unitTest:assertFile(geojson2)
		proj.file:delete()
	end,
	getDataSet = function(unitTest)
		local shpFile = filePath("test/malha2015.geojson", "gis")
		local dSet = TerraLib().getDataSet{file = shpFile}

		unitTest:assertEquals(getn(dSet), 102)

		for i = 0, getn(dSet) - 1 do
			unitTest:assertEquals(dSet[i].FID, i)

			for k, v in pairs(dSet[i]) do
				unitTest:assert((k == "FID") or (k == "NM_MUNICIP") or (k == "Proposta") or
								(k == "UF") or (k == "OGR_GEOMETRY") or (k == "masc") or
								(k == "fem") or (k == "PPA") or (k == "IBGE") or (k == "CD_GEOCMU"))
				unitTest:assertNotNil(v)
			end
		end
	end,
	saveDataAs = function(unitTest)
		TerraLib().setProgressVisible(false)

		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "SampaGeoJson"
		local layerFile1 = filePath("test/sampa.geojson", "gis")
		TerraLib().addGeoJSONLayer(proj, layerName1, layerFile1)

		local fromData = {}
		fromData.project = proj
		fromData.layer = layerName1

		-- SHP
		local toData = {}
		toData.file = File("geojson2shp.shp")
		toData.type = "shp"
		local overwrite = true

		TerraLib().saveDataAs(fromData, toData, overwrite)
		unitTest:assert(toData.file:exists())

		-- OVERWRITE
		TerraLib().saveDataAs(fromData, toData, overwrite)
		unitTest:assert(toData.file:exists())

		-- OVERWRITE AND CHANGE SRID
		toData.srid = 4326
		TerraLib().saveDataAs(fromData, toData, overwrite)
		local layerName2 = "SHP"
		TerraLib().addShpLayer(proj, layerName2, toData.file)
		local info2 = TerraLib().getLayerInfo(proj, layerName2)
		unitTest:assertEquals(info2.srid, toData.srid)

		-- SAVE THE DATA WITH ONLY ONE ATTRIBUTE
		local file1 = toData.file
		toData.file = File("gj2gj.geojson")
		toData.type = "geojson"
		TerraLib().saveDataAs(fromData, toData, overwrite, {"NM_MICRO"})

		local layerName3 = "GJ2GJ"
		local layerFile3 = toData.file
		TerraLib().addGeoJSONLayer(proj, layerName3, layerFile3)

		local dset3 = TerraLib().getDataSet{project = proj, layer = layerName3}

		unitTest:assertEquals(getn(dset3), 63)

		for k, v in pairs(dset3[0]) do
			unitTest:assert(((k == "FID") and (v == 0)) or ((k == "OGR_GEOMETRY") and (v ~= nil) ) or
							((k == "NM_MICRO") and (v == "VOTUPORANGA")))
		end

		toData.file:delete()
		file1:delete()

		-- SAVE A DATA SUBSET
		local dset1 = TerraLib().getDataSet{project = proj, layer = layerName1}
		local sjc
		for i = 0, getn(dset1) - 1 do
			if dset1[i].ID == 27 then
				sjc = dset1[i]
			end
		end

		local touches = {}
		local j = 1
		for i = 0, getn(dset1) - 1 do
			if sjc.OGR_GEOMETRY:touches(dset1[i].OGR_GEOMETRY) then
				touches[j] = dset1[i]
				j = j + 1
			end
		end

		toData.file = File("touches_sjc.geojson")
		toData.srid = nil
		TerraLib().saveDataAs(fromData, toData, overwrite, {"NM_MICRO", "ID"}, touches)

		local tchsSjc = TerraLib().getDataSet{file = toData.file}

		unitTest:assertEquals(getn(tchsSjc), 2)
		unitTest:assertEquals(tchsSjc[0].ID, 55)
		unitTest:assertEquals(tchsSjc[1].ID, 109)

		toData.file:delete()
		proj.file:delete()

		-- SAVE WITHOUT LAYER
		fromData = {}
		fromData.file = layerFile1
		toData.file = File("touches_sjc_2.shp")

		TerraLib().saveDataAs(fromData, toData, overwrite, {"NM_MICRO", "ID"}, touches)

		local tchsSjc2 = TerraLib().getDataSet{file = toData.file}

		unitTest:assertEquals(getn(tchsSjc2), 2)
		unitTest:assertEquals(tchsSjc2[0].ID, 55)
		unitTest:assertEquals(tchsSjc2[1].ID, 109)

		toData.file:delete()
	end,
	getLayerSize = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		local file = File(proj.file)
		file:deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "SampaGeoJson"
		local layerFile1 = filePath("test/sampa.geojson", "gis")
		TerraLib().addGeoJSONLayer(proj, layerName1, layerFile1)

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
		toData.file = File("rails.geojson")
		toData.type = "geojson"
		toData.file:deleteIfExists()

		TerraLib().saveDataAs(fromData, toData, true)

		lnName = "ES_Rails_CurrDir"
		lnFile = toData.file
		TerraLib().addGeoJSONLayer(proj, lnName, lnFile)

		local dpLayerName = "ES_Rails_Peucker"
		local dpFile = File(string.lower(dpLayerName)..".geojson"):deleteIfExists()
		TerraLib().douglasPeucker(proj, lnName, dpLayerName, 500)
		TerraLib().addGeoJSONLayer(proj, dpLayerName, dpFile)

		local dpSet = TerraLib().getDataSet{project = proj, layer = dpLayerName, missing = -1}
		unitTest:assertEquals(getn(dpSet), 182)

		local missingCount = 0
		for i = 0, getn(dpSet) - 1 do
			if dpSet[i].PNVCOIN == -1 then
				missingCount = missingCount + 1
			end
		end

		unitTest:assertEquals(missingCount, 177)

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

		local outFile = File("emas-polygonized.geojson")
		outFile:deleteIfExists()

		local outInfo = {
			type = "geojson",
			file = outFile
		}

		TerraLib().polygonize(inInfo, outInfo)

		local polyName = "Polygonized"
		TerraLib().addGeoJSONLayer(proj, polyName, outFile)
		local dsetSize = TerraLib().getLayerSize(proj, polyName)

		unitTest:assertEquals(dsetSize, 381)

		local attrNames = TerraLib().getPropertyNames(proj, polyName)
		unitTest:assertEquals("FID", attrNames[0])
		unitTest:assertEquals("id", attrNames[1])
		unitTest:assertEquals("value", attrNames[2])

		proj.file:delete()
		outFile:delete()
	end,
	attributeFill = function(unitTest)
		TerraLib().setProgressVisible(false)

		-- TODO (#2179)
		local createProject = function()
			local proj = {
				file = "attributefill_geojson_basic.tview",
				title = "TerraLib Tests",
				author = "Avancini Rodrigo"
			}
			File(proj.file):deleteIfExists()
			TerraLib().createProject(proj, {})
			return proj
		end

		local allSupportedOperation = function()
			local proj = createProject()

			local layerName1 = "ES"
			local layerFile1 = filePath("test/es_limit_sirgas2000_5880.geojson", "gis")
			TerraLib().addGeoJSONLayer(proj, layerName1, layerFile1)

			local files = {}

			local clName = "ES_Cells"
			table.insert(files, File(clName..".geojson"):deleteIfExists())

			local resolution = 20e3
			local mask = true
			TerraLib().addGeoJSONCellSpaceLayer(proj, layerName1, clName, resolution, files[1], mask)

			local csSize = TerraLib().getDataSetSize(files[1])
			unitTest:assertEquals(csSize, 154)

			local layerName2 = "Protection_Unit"
			local layerFile2 = filePath("test/es_protected_areas_sirgas2000_5880.geojson", "gis")
			TerraLib().addGeoJSONLayer(proj, layerName2, layerFile2)

			-- PRESENCE
			local presLayerName = clName.."_"..layerName2.."_Presence"
			table.insert(files, File(presLayerName..".geojson"):deleteIfExists())
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

			local dset = TerraLib().getDataSet{project = proj, layer = presLayerName, missing = 0}

			unitTest:assertEquals(csSize, getn(dset))
			unitTest:assertEquals(dset[0][attribute], 0)
			unitTest:assertNotNil(dset[0].OGR_GEOMETRY)
			unitTest:assertEquals(dset[0].col, 1)
			unitTest:assertEquals(dset[0].row, 0)
			unitTest:assertEquals(dset[0].id, "C01L00")
			unitTest:assertEquals(dset[0].FID, 0)

			-- PERCENTAGE TOTAL AREA
			local areaLayerName = clName.."_"..layerName2.."_Percentage"
			table.insert(files, File(areaLayerName..".geojson"):deleteIfExists())
			operation = "area"
			attribute = "percent"
			select = "FID"

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = presLayerName,
				out = areaLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			dset = TerraLib().getDataSet{project = proj, layer = areaLayerName, missing = 0}

			unitTest:assertEquals(csSize, getn(dset))
			unitTest:assertEquals(dset[151][attribute], 0)
			unitTest:assertNotNil(dset[151].OGR_GEOMETRY)
			unitTest:assertEquals(dset[151].col, 9)
			unitTest:assertEquals(dset[151].row, 18)
			unitTest:assertEquals(dset[151].id, "C09L18")
			unitTest:assertEquals(dset[151].FID, 151)

			-- COUNT
			local countLayerName = clName.."_"..layerName2.."_Count"
			table.insert(files, File(countLayerName..".geojson"):deleteIfExists())
			operation = "count"
			attribute = "count"
			select = "FID"

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = areaLayerName,
				out = countLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			dset = TerraLib().getDataSet{project = proj, layer = countLayerName, missing = 0}

			unitTest:assertEquals(csSize, getn(dset))
			unitTest:assertEquals(dset[1][attribute], 0)
			unitTest:assertNotNil(dset[1].OGR_GEOMETRY)
			unitTest:assertEquals(dset[1].col, 2)
			unitTest:assertEquals(dset[1].row, 0)
			unitTest:assertEquals(dset[1].id, "C02L00")
			unitTest:assertEquals(dset[1].FID, 1)

			-- DISTANCE
			local distLayerName = clName.."_"..layerName2.."_Distance"
			table.insert(files, File(distLayerName..".geojson"):deleteIfExists())
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

			dset = TerraLib().getDataSet{project = proj, layer = distLayerName, missing = 0}

			unitTest:assertEquals(csSize, getn(dset))
			unitTest:assertEquals(dset[150][attribute], 49651.869711192, 1e-9)
			unitTest:assertNotNil(dset[150].OGR_GEOMETRY)
			unitTest:assertEquals(dset[150].col, 8)
			unitTest:assertEquals(dset[150].row, 18)
			unitTest:assertEquals(dset[150].id, "C08L18")
			unitTest:assertEquals(dset[150].FID, 150)

			-- MINIMUM
			local minLayerName = clName.."_"..layerName2.."_Minimum"
			table.insert(files, File(minLayerName..".geojson"):deleteIfExists())
			operation = "minimum"
			attribute = "minimum"
			select = "FID"

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = distLayerName,
				out = minLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			dset = TerraLib().getDataSet{project = proj, layer = minLayerName, missing = 0}

			unitTest:assertEquals(csSize, getn(dset))
			unitTest:assertEquals(dset[2][attribute], 0)
			unitTest:assertNotNil(dset[2].OGR_GEOMETRY)
			unitTest:assertEquals(dset[2].col, 3)
			unitTest:assertEquals(dset[2].row, 0)
			unitTest:assertEquals(dset[2].id, "C03L00")
			unitTest:assertEquals(dset[2].FID, 2)

			-- MAXIMUM
			local maxLayerName = clName.."_"..layerName2.."_Maximum"
			table.insert(files, File(maxLayerName..".geojson"):deleteIfExists())
			operation = "maximum"
			attribute = "maximum"
			select = "FID"

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = minLayerName,
				out = maxLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			dset = TerraLib().getDataSet{project = proj, layer = maxLayerName, missing = 0}

			unitTest:assertEquals(csSize, getn(dset))
			unitTest:assertEquals(dset[149][attribute], 0)
			unitTest:assertNotNil(dset[149].OGR_GEOMETRY)
			unitTest:assertEquals(dset[149].col, 7)
			unitTest:assertEquals(dset[149].row, 18)
			unitTest:assertEquals(dset[149].id, "C07L18")
			unitTest:assertEquals(dset[149].FID, 149)

			-- PERCENTAGE EACH CLASS
			local covLayerName = maxLayerName -- TODO(#2326)
			-- local covLayerName = clName.."_"..layerName2.."_Coverage"
			-- table.insert(files, File(covLayerName..".geojson"):deleteIfExists())
			-- operation = "coverage"
			-- attribute = "coverage"
			-- select = "ESFERA5"

			-- TerraLib().attributeFill{
				-- project = proj,
				-- from = layerName2,
				-- to = maxLayerName,
				-- out = covLayerName,
				-- attribute = attribute,
				-- operation = operation,
				-- select = select
			-- }

			-- dset = TerraLib().getDataSet{project = proj, layer = covLayerName, missing = 0}

			-- unitTest:assertEquals(csSize, getn(dset))
			-- unitTest:assertEquals(dset[3][attribute.."_municipal"], 0.00035664738308004, 1e-17) --SKIP
			-- unitTest:assertEquals(dset[3][attribute.."_estadual"], 0) --SKIP
			-- unitTest:assertEquals(dset[3][attribute.."_federal"], 0) --SKIP
			-- unitTest:assertNotNil(dset[3].OGR_GEOMETRY) --SKIP
			-- unitTest:assertEquals(dset[3].col, 4) --SKIP
			-- unitTest:assertEquals(dset[3].row, 0) --SKIP
			-- unitTest:assertEquals(dset[3].id, "C04L00") --SKIP
			-- unitTest:assertEquals(dset[3].FID, 3) --SKIP

			-- STANDARD DEVIATION
			local stdevLayerName = clName.."_"..layerName2.."_Stdev"
			table.insert(files, File(stdevLayerName..".geojson"):deleteIfExists())
			operation = "stdev"
			attribute = "stdev"
			select = "Shape_Area"

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = covLayerName,
				out = stdevLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			dset = TerraLib().getDataSet{project = proj, layer = stdevLayerName, missing = 0}

			unitTest:assertEquals(csSize, getn(dset))
			unitTest:assertEquals(dset[148][attribute], 0)
			unitTest:assertNotNil(dset[148].OGR_GEOMETRY)
			unitTest:assertEquals(dset[148].col, 6)
			unitTest:assertEquals(dset[148].row, 18)
			unitTest:assertEquals(dset[148].id, "C06L18")
			unitTest:assertEquals(dset[148].FID, 148)

			-- MEAN
			local meanLayerName = clName.."_"..layerName2.."_Mean"
			table.insert(files, File(meanLayerName..".geojson"):deleteIfExists())
			operation = "average"
			attribute = "mean"
			select = "Shape_Area"

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = stdevLayerName,
				out = meanLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			dset = TerraLib().getDataSet{project = proj, layer = meanLayerName, missing = 0}

			unitTest:assertEquals(csSize, getn(dset))
			unitTest:assertEquals(dset[4][attribute], 431423.284555, 1e-6)
			unitTest:assertNotNil(dset[4].OGR_GEOMETRY)
			unitTest:assertEquals(dset[4].col, 5)
			unitTest:assertEquals(dset[4].row, 0)
			unitTest:assertEquals(dset[4].id, "C05L00")
			unitTest:assertEquals(dset[4].FID, 4)

			-- WEIGHTED AVERAGE
			local weigLayerName = clName.."_"..layerName2.."_WeightedAverage"
			table.insert(files, File(weigLayerName..".geojson"):deleteIfExists())
			operation = "average"
			attribute = "weighted_average"
			select = "Shape_Area"
			local area = true

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = meanLayerName,
				out = weigLayerName,
				attribute = attribute,
				operation = operation,
				select = select,
				area = area
			}

			dset = TerraLib().getDataSet{project = proj, layer = weigLayerName, missing = 0}

			unitTest:assertEquals(csSize, getn(dset))
			unitTest:assertEquals(dset[147][attribute], 0)
			unitTest:assertNotNil(dset[147].OGR_GEOMETRY)
			unitTest:assertEquals(dset[147].col, 11)
			unitTest:assertEquals(dset[147].row, 17)
			unitTest:assertEquals(dset[147].id, "C11L17")
			unitTest:assertEquals(dset[147].FID, 147)

			-- MODE
			local modeLayerName = weigLayerName -- TODO(#2327)
			-- local modeLayerName = clName.."_"..layerName2.."_Mode"
			-- table.insert(files, File(modeLayerName..".geojson"):deleteIfExists())
			-- operation = "mode"
			-- attribute = "mode"
			-- select = "ESFERA5"

			-- TerraLib().attributeFill{
				-- project = proj,
				-- from = layerName2,
				-- to = weigLayerName,
				-- out = modeLayerName,
				-- attribute = attribute,
				-- operation = operation,
				-- select = select
			-- }

			-- dset = TerraLib().getDataSet{project = proj, layer = modeLayerName, missing = 0}

			-- unitTest:assertEquals(csSize, getn(dset)) --SKIP
			-- unitTest:assertEquals(dset[5][attribute], 0) --SKIP
			-- unitTest:assertNotNil(dset[5].OGR_GEOMETRY) --SKIP
			-- unitTest:assertEquals(dset[5].col, 0) --SKIP
			-- unitTest:assertEquals(dset[5].row, 1) --SKIP
			-- unitTest:assertEquals(dset[5].id, "C00L01") --SKIP
			-- unitTest:assertEquals(dset[5].FID, 5) --SKIP

			-- HIGHEST INTERSECTION
			local inteLayerName = clName.."_"..layerName2.."_HighIntersection"
			table.insert(files, File(inteLayerName..".geojson"):deleteIfExists())
			operation = "mode"
			attribute = "intersection"
			select = "ESFERA5"
			area = true

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = modeLayerName,
				out = inteLayerName,
				attribute = attribute,
				operation = operation,
				select = select,
				area = area
			}

			dset = TerraLib().getDataSet{project = proj, layer = inteLayerName, missing = 0}

			unitTest:assertEquals(csSize, getn(dset))
			unitTest:assertEquals(dset[146][attribute], 0)
			unitTest:assertNotNil(dset[146].OGR_GEOMETRY)
			unitTest:assertEquals(dset[146].col, 10)
			unitTest:assertEquals(dset[146].row, 17)
			unitTest:assertEquals(dset[146].id, "C10L17")
			unitTest:assertEquals(dset[146].FID, 146)

			-- SUM
			local sumLayerName = clName.."_"..layerName2.."_Sum"
			table.insert(files, File(sumLayerName..".geojson"):deleteIfExists())
			operation = "sum"
			attribute = "sum"
			select = "Shape_Area"

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = inteLayerName,
				out = sumLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}

			dset = TerraLib().getDataSet{project = proj, layer = sumLayerName, missing = 0}

			unitTest:assertEquals(csSize, getn(dset))
			unitTest:assertEquals(dset[6][attribute], 0)
			unitTest:assertNotNil(dset[6].OGR_GEOMETRY)
			unitTest:assertEquals(dset[6].col, 1)
			unitTest:assertEquals(dset[6].row, 1)
			unitTest:assertEquals(dset[6].id, "C01L01")
			unitTest:assertEquals(dset[6].FID, 6)

			-- WEIGHTED SUM
			local wsumLayerName = clName.."_"..layerName2.."_WeightedSum"
			table.insert(files, File(wsumLayerName..".geojson"):deleteIfExists())
			operation = "sum"
			attribute = "wsum"
			select = "Shape_Area"
			area = true

			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = sumLayerName,
				out = wsumLayerName,
				attribute = attribute,
				operation = operation,
				select = select,
				area = area
			}

			dset = TerraLib().getDataSet{project = proj, layer = wsumLayerName, missing = 0}

			unitTest:assertEquals(csSize, getn(dset))
			unitTest:assertEquals(dset[145][attribute], 0)
			unitTest:assertNotNil(dset[145].OGR_GEOMETRY)
			unitTest:assertEquals(dset[145].col, 9)
			unitTest:assertEquals(dset[145].row, 17)
			unitTest:assertEquals(dset[145].id, "C09L17")
			unitTest:assertEquals(dset[145].FID, 145)

			proj.file:delete()
			for i = 1, #files do
				files[i]:delete()
			end
		end

		unitTest:assert(allSupportedOperation)
	end,
	saveDataSet = function(unitTest)
		TerraLib().setProgressVisible(false)

		local overwriteLayer = function()
			local proj = {
				file = "savedataset-geojson-basic.tview",
				title = "TerraLib Tests",
				author = "Avancini Rodrigo"
			}

			File(proj.file):deleteIfExists()
			TerraLib().createProject(proj, {})

			local l1Name = "SampaShp"
			local l1File = filePath("test/sampa.shp", "gis")
			TerraLib().addShpLayer(proj, l1Name, l1File)

			local cl1Name = "SampaCellsGjson"
			local cl1File = File(cl1Name..".geojson"):deleteIfExists()
			local resolution = 1
			local mask = true
			TerraLib().addGeoJSONCellSpaceLayer(proj, l1Name, cl1Name, resolution, cl1File, mask)

			local dSet = TerraLib().getDataSet{project = proj, layer = cl1Name}
			local luaTable = {}
			for i = 0, getn(dSet) - 1 do
				local data = dSet[i]
				data.attr1 = i
				data.attr2 = "test"..i
				data.attr3 = (i % 2) == 0
				table.insert(luaTable, dSet[i])
			end

			local cl2Name = "New"..cl1Name
			local cl2File = File(cl2Name..".geojson"):deleteIfExists()  --< TODO(#2224)

			-- ADDING ALL SUPPORTED ATTRIBUTE TYPES
			TerraLib().saveDataSet(proj, cl1Name, luaTable, cl2Name, {"attr1", "attr2", "attr3"})

			local propInfo = TerraLib().getPropertyInfos(proj, cl2Name)

			unitTest:assertEquals(propInfo[0].name, "FID")
			unitTest:assertEquals(propInfo[0].type, "integer 32")
			unitTest:assertEquals(propInfo[1].name, "id")
			unitTest:assertEquals(propInfo[1].type, "string")
			unitTest:assertEquals(propInfo[2].name, "col")
			unitTest:assertEquals(propInfo[2].type, "integer 32")
			unitTest:assertEquals(propInfo[3].name, "row")
			unitTest:assertEquals(propInfo[3].type, "integer 32")
			unitTest:assertEquals(propInfo[4].name, "attr1")
			unitTest:assertEquals(propInfo[4].type, "double")
			unitTest:assertEquals(propInfo[5].name, "attr2")
			unitTest:assertEquals(propInfo[5].type, "string")
			unitTest:assertEquals(propInfo[6].name, "attr3")
			unitTest:assertEquals(propInfo[6].type, "string")
			unitTest:assertEquals(propInfo[7].name, "OGR_GEOMETRY")
			unitTest:assertEquals(propInfo[7].type, "geometry")

			-- OVERWRITE -- TODO(#2224)
			-- dSet = TerraLib().getDataSet{project = proj, layer = cl2Name}
			-- luaTable = {}
			-- for i = 0, getn(dSet) - 1 do
				-- local data = dSet[i]
				-- data.attr4 = i
				-- table.insert(luaTable, dSet[i])
			-- end

			-- TerraLib().saveDataSet(proj, cl2Name, luaTable, cl2Name, {"attr4"})

			-- propInfo = TerraLib().getPropertyInfos(proj, cl2Name)

			-- unitTest:assertEquals(propInfo[7].name, "attr4") -- SKIP
			-- unitTest:assertEquals(propInfo[7].type, "double") -- SKIP

			-- for i = 0, getn(propInfo) do
				-- for k, v in pairs(propInfo[i]) do
					-- _Gtme.print(k, v)
				-- end
			-- end

			cl1File:delete()
			cl2File:delete()
			proj.file:delete()
		end

		unitTest:assert(overwriteLayer)
	end
}
