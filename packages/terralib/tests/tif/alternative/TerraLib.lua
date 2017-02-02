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
	addShpCellSpaceLayer = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		local layerName1 = "AmazoniaTif"
		local layerFile1 = filePath("amazonia-prodes.tif", "terralib")
		tl:addGdalLayer(proj, layerName1, layerFile1)

		local clName = "Amazonia_Cells"
		local shp1 = File(clName..".shp")

		shp1:deleteIfExists()

		local resolution = 60e3
		local mask = true

		local maskNotWork = function()
			tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp1, mask)
		end
		unitTest:assertError(maskNotWork, "The 'mask' not work to Raster, it was ignored.")

		proj.file:delete()
	end,
	--addPgCellSpaceLayer = function(unitTest)
		-- #1152
	--end,
	getNumOfBands = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		local layerName = "SampaShp"
		local layerFile = filePath("test/sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName, layerFile)

		local noRasterLayer = function()
			tl:getNumOfBands(proj, layerName)
		end
		unitTest:assertError(noRasterLayer, "The layer '"..layerName.."' is not a Raster.")

		proj.file:delete()
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
		local resolution = 60e3
		local mask = true
		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, File(shp[1]), mask)

		local layerName2 = "Prodes_PA"
		local layerFile4 = filePath("test/prodes_polyc_10k.tif", "terralib")
		tl:addGdalLayer(proj, layerName2, layerFile4)

		local percTifLayerName = clName.."_"..layerName2.."_RPercentage"
		shp[2] = percTifLayerName..".shp"

		File(shp[2]):deleteIfExists()

		local operation = "coverage"
		local attribute = "rperc"
		local select = 5
		local area = nil
		local default = nil
		local repr = "raster"

		local differentSrids = function()
			tl:attributeFill(proj, layerName2, clName, percTifLayerName, attribute, operation, select, area, default, repr)
		end
		local layerInfo2 = tl:getLayerInfo(proj, proj.layers[layerName2])
		unitTest:assertError(differentSrids, "The projections of the layers are different: (Prodes_PA, "..layerInfo2.srid..") and (Para_Cells, 29101.0). Set the correct one.")

		local layerName3 = "Prodes_PA_NewSRID"
		tl:addGdalLayer(proj, layerName3, layerFile4, 29101)

		local bandNoExists = function()
			tl:attributeFill(proj, layerName3, clName, percTifLayerName, attribute, operation, select, area, default, repr)
		end
		unitTest:assertError(bandNoExists, "Selected band '"..select.."' does not exist in layer '"..layerName3.."'.")

		for j = 1, #shp do
			File(shp[j]):deleteIfExists()
		end

		proj.file:delete()

		customWarning = customWarningBkp
	end,
	getDummyValue = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		local layerName = "TifLayer"
		local layerFile = filePath("test/cbers_rgb342_crop1.tif", "terralib")
		tl:addGdalLayer(proj, layerName, layerFile)

		local bandNoExists =  function()
			tl:getDummyValue(proj, layerName, 3)
		end
		unitTest:assertError(bandNoExists, "The maximum band is '2.0'.")

		local layerName2 = "TifLayer2"
		local layerFile2 = filePath("test/prodes_polyc_10k.tif", "terralib")
		tl:addGdalLayer(proj, layerName2, layerFile2)

		local bandNoExists2 =  function()
			tl:getDummyValue(proj, layerName2, 3)
		end
		unitTest:assertError(bandNoExists2, "The only available band is '0.0'.")

		proj.file:delete()
	end,
	saveLayerAs = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		local layerName1 = "TifLayer"
		local layerFile1 = filePath("test/cbers_rgb342_crop1.tif", "terralib")
		tl:addGdalLayer(proj, layerName1, layerFile1)

		local customWarningBkp = customWarning
		local currDir = currentDir()
		customWarning = function(msg)
			unitTest:assert((msg == "It was not possible to convert the data in layer 'TifLayer' to 'tif2tif.tif'.") or
							(msg == "Attempt to save data of the layer in '"..currDir.."/cbers_rgb342_crop1.tif'.") or
							(msg == "It was not possible to convert the data in layer 'TifLayer' to 'cbers_rgb342_crop1.tif'.") or
							(msg == "It was not possible to change SRID from raster data."))
		end

		local overwrite = true

		-- SHP
		local toData = {}
		toData.file = "tif2shp.shp"
		toData.type = "shp"

		local tif2shpError = function()
			tl:saveLayerAs(proj, layerName1, toData, overwrite)
		end
		unitTest:assertError(tif2shpError, "It was not possible save the data in layer 'TifLayer' to vector data.")

		-- GEOJSON
		toData.file = "tif2geojson.geojson"
		toData.type = "geojson"

		local tif2geojsonError = function()
			tl:saveLayerAs(proj, layerName1, toData, overwrite)
		end
		unitTest:assertError(tif2geojsonError, "It was not possible save the data in layer 'TifLayer' to vector data.")

		-- POSTGIS
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = getConfig().password
		local database = "postgis_22_sample"
		local encoding = "CP1252"

		local pgData = {
			type = "postgis",
			host = host,
			port = port,
			user = user,
			password = password,
			database = database,
			encoding = encoding
		}

		local tif2postgisError = function()
			tl:saveLayerAs(proj, layerName1, pgData, overwrite)
		end
		unitTest:assertError(tif2postgisError,  "It was not possible save the data in layer 'TifLayer' to postgis data.")

		-- OVERWRITE
		toData.file = "tif2tif.tif"
		toData.type = "tif"
		tl:saveLayerAs(proj, layerName1, toData, overwrite)

		overwrite = false

		local overwriteError = function()
			tl:saveLayerAs(proj, layerName1, toData, overwrite)
		end
		unitTest:assertError(overwriteError, "The file '"..currDir.."/cbers_rgb342_crop1.tif' already exists.")

		-- TRY OVERWRITE AND CHANGE SRID
		overwrite = true
		toData.file = "cbers_rgb342_crop1.tif"
		toData.type = "tif"
		toData.srid = 4326
		tl:saveLayerAs(proj, layerName1, toData, overwrite)

		File("cbers_rgb342_crop1.tif"):delete()
		proj.file:delete()

		customWarning = customWarningBkp
	end
}

