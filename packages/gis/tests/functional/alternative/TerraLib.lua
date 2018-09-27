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
	attributeFill = function(unitTest)
		local proj = {}
		proj.file = "amazonia.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "ES"
		local layerFile1 = filePath("test/limite_es_poly_wgs84.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1, nil, 29101)

		local layerName2 = "PA"
		local layerFile2 = filePath("test/limitePA_polyc_pol.shp", "gis")
		TerraLib().addShpLayer(proj, layerName2, layerFile2, nil, 29101)

		local clName = "esCs"
		local clFile = File(clName..".shp")
		clFile:deleteIfExists()

		local resolution = 20e3
		local mask = true
		TerraLib().addShpCellSpaceLayer(proj, layerName1, clName, resolution, clFile, mask)

		local operation = "distance"
		local attribute = "pol"
		local select = "FID"
		local area = nil
		local default = 0

		local layersNotIntersect = function()
			TerraLib().attributeFill(proj, layerName2, clName, nil, attribute, operation, select, area, default)
		end

		unitTest:assertError(layersNotIntersect, "The two layers do not intersect.")

		proj.file:delete()
		clFile:delete()
	end,
	createProject = function(unitTest)
		local proj = {}
		proj.file = "file.xml"
		local mandatoryExt = function()
			TerraLib().createProject(proj, {})
		end

		unitTest:assertError(mandatoryExt, "Please, the file extension must be '.tview' or '.qgs'.")
	end,
	openProject = function(unitTest)
		local proj = {}
		local mandatoryExt = function()
			TerraLib().openProject(proj, "file.xml")
		end

		unitTest:assertError(mandatoryExt, "Please, the file extension must be '.tview' or '.qgs'.")
	end,
	saveDataSet = function(unitTest)
		local proj = {}
		proj.file = "tlib_savedset.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		-- // create a database
		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local clName1 = "SampaShpCells"
		local resolution = 1
		local mask = true
		local cellsShp = File(clName1..".shp")
		cellsShp:deleteIfExists()
		TerraLib().addShpCellSpaceLayer(proj, layerName1, clName1, resolution, cellsShp, mask)

		local spDset = TerraLib().getDataSet{project = proj, layer = clName1}

		local luaTable = {}
		for i = 0, getn(spDset) - 1 do
			local data = spDset[i]
			data["attr-1"] = i
			table.insert(luaTable, spDset[i])
		end

		local newLayerName = "New_Layer"

		local invalidAttrName = function()
			TerraLib().saveDataSet(proj, clName1, luaTable, newLayerName, {"attr-1"})
		end

		unitTest:assertError(invalidAttrName, "Invalid attribute name 'attr-1'.")

		luaTable = {}
		for i = 0, getn(spDset) - 1 do
			local data = spDset[i]
			data["at?tr2"] = i
			data["at#r3"] = i
			table.insert(luaTable, spDset[i])
		end

		local invalidAttrNames = function()
			TerraLib().saveDataSet(proj, clName1, luaTable, newLayerName, {"attr-1", "at?tr2", "at#r3"})
		end

		unitTest:assertError(invalidAttrNames, "Invalid attribute names 'attr-1', 'at?tr2' and 'at#r3'.")

		luaTable = {}
		for i = 0, getn(spDset) - 1 do
			local data = spDset[i]
			data.id = i
			table.insert(luaTable, spDset[i])
		end

		local typeValueError = function()
			TerraLib().saveDataSet(proj, clName1, luaTable, newLayerName, {"id"})
		end

		unitTest:assertError(typeValueError, "Attempt to set 'id' with type 'number'. Please, set the correct type.")

		local typeValueError2 = function()
			TerraLib().saveDataSet(proj, clName1, luaTable, clName1, {"id"})
		end

		unitTest:assertError(typeValueError2, "Attempt to set 'id' with type 'number'. Please, set the correct type.")

		proj.file:delete()
		cellsShp:delete()
	end,
	saveDataAs = function(unitTest)
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

		local toData = {}
		toData.file = File("shp2shp.shp")
		toData.type = "shp"

		local attrNotExist = function()
			TerraLib().saveDataAs(fromData, toData, true, {"ATTR"})
		end
		unitTest:assertError(attrNotExist, "There is no attribute 'ATTR' in 'SampaShp'.")

		local attrsNotExist = function()
			TerraLib().saveDataAs(fromData, toData, true, {"ATTR1", "ATTR2", "ATTR3"})
		end
		unitTest:assertError(attrsNotExist,  "There are no attributes 'ATTR1', 'ATTR2' and 'ATTR3' in 'SampaShp'.")

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

		fromData = {file = layerFile1}
		toData = {file = File("touches_sjc.shp"), type = "shp"}

		for i = 1, #touches do
			touches[i].FID = nil
		end

		local pkSaveError = function()
			local overwrite = true
			TerraLib().saveDataAs(fromData, toData, overwrite, {"NM_MICRO", "ID"}, touches)
		end
		unitTest:assertError(pkSaveError,  "Primary key not found (sampa.shp, FID). Please, check your subset.")

		proj.file:delete()
	end,
	douglasPeucker = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		local file = File(proj.file)
		file:deleteIfExists()

		TerraLib().createProject(proj, {})

		local lName1 = "Prodes"
		local lFile1 = filePath("test/prodes_polyc_10k.tif", "gis")
		TerraLib().addGdalLayer(proj, lName1, lFile1)

		local invalidRaster = function()
			TerraLib().douglasPeucker(proj, lName1, "Peucker", 500)
		end

		unitTest:assertError(invalidRaster, "This function works only with line geometry.")

		local lName2 = "Ports"
		local lFile2 = filePath("test/ports.shp", "gis")
		TerraLib().addShpLayer(proj, lName2, lFile2)

		local invalidGeometry = function()
			TerraLib().douglasPeucker(proj, lName2, "Peucker", 500)
		end

		unitTest:assertError(invalidGeometry, "This function works only with line and multi-line geometry.")

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

		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local inInfo = {
			project = proj,
			layer = layerName1,
			band = 0,
		}

		local outFile = File("emas-polygonized.shp")

		local outInfo = {
			type = "shp",
			file = outFile
		}

		local invalidInput = function()
			TerraLib().polygonize(inInfo, outInfo)
		end

		unitTest:assertError(invalidInput, "Input layer must be a Raster.")

		inInfo.layer = layerName
		outInfo.type = "nc"

		local invalidOutput = function()
			TerraLib().polygonize(inInfo, outInfo)
		end

		unitTest:assertError(invalidOutput, "Output type 'nc' is not supported.")

		proj.file:delete()
	end,
	removeLayer = function(unitTest)
		local proj = {
			file = "removelayer_alt_func.tview",
			title = "TerraLib Tests",
			author = "Avancini Rodrigo"
		}

		File(proj.file):deleteIfExists()
		TerraLib().createProject(proj, {})

		local layerName = "inputLayer"
		local layerFile = filePath("itaituba-localities.shp", "gis")
		TerraLib().addShpLayer(proj, layerName, layerFile)

		local layerNotFound = function()
			TerraLib().removeLayer(proj, "xxxx")
		end

		unitTest:assertError(layerNotFound, "Layer 'xxxx' not found.")

		proj.file:delete()
	end,
	getDataSet = function(unitTest)
		local proj = {
			file = "getdataset_func_basic.tview",
			title = "TerraLib Tests",
			author = "Avancini Rodrigo"
		}
		File(proj.file):deleteIfExists()
		TerraLib().createProject(proj, {})

		local layerName1 = "Shp"
		local layerFile1 = filePath("test/ParaRodovias2.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local missingGeomError = function()
			local missing = 0
			TerraLib().getDataSet{project = proj, layer = layerName1, missing = missing}
		end

		unitTest:assertError(missingGeomError, "Data cannot be loaded because it has a missing geometry. Please, fix your data.")

		proj.file:delete()
	end
}
