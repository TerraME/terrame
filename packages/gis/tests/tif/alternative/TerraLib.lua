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
	--addPgCellSpaceLayer = function(unitTest)
		-- #1152
	--end,
	getNumOfBands = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName = "SampaShp"
		local layerFile = filePath("test/sampa.shp", "gis")
		TerraLib().addShpLayer(proj, layerName, layerFile)

		local noRasterLayer = function()
			TerraLib().getNumOfBands(proj, layerName)
		end

		unitTest:assertError(noRasterLayer, "The layer '"..layerName.."' is not a Raster.")

		proj.file:delete()
	end,
	attributeFill = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "Para"
		local layerFile1 = filePath("test/limitePA_polyc_pol.shp", "gis")
		TerraLib().addShpLayer(proj, layerName1, layerFile1)

		local shp = {}

		local clName = "Para_Cells"
		shp[1] = clName..".shp"

		File(shp[1]):deleteIfExists()

		-- CREATE THE CELLULAR SPACE
		local resolution = 60e3
		local mask = true
		TerraLib().addShpCellSpaceLayer(proj, layerName1, clName, resolution, File(shp[1]), mask)

		local layerName2 = "Prodes_PA"
		local layerFile4 = filePath("test/prodes_polyc_10k.tif", "gis")
		TerraLib().addGdalLayer(proj, layerName2, layerFile4, 29100)

		local percTifLayerName = clName.."_"..layerName2.."_RPercentage"
		shp[2] = percTifLayerName..".shp"

		File(shp[2]):deleteIfExists()

		local operation = "coverage"
		local attribute = "rperc"
		local select = 0
		local area = nil
		local default = nil
		local repr = "raster"

		local differentSrids = function()
			TerraLib().attributeFill(proj, layerName2, clName, percTifLayerName, attribute, operation, select, area, default, repr)
		end

		unitTest:assertError(differentSrids, "Layer projections are different: (Prodes_PA, 29100) and (Para_Cells, 29101). Please, reproject your data to the right one.")

		local layerName3 = "Prodes_PA_NewSRID"
		TerraLib().addGdalLayer(proj, layerName3, layerFile4, 29101)

		select = 5
		local bandNoExists = function()
			TerraLib().attributeFill(proj, layerName3, clName, percTifLayerName, attribute, operation, select, area, default, repr)
		end

		unitTest:assertError(bandNoExists, "Selected band '"..select.."' does not exist in Layer '"..layerName3.."'.")

		for j = 1, #shp do
			File(shp[j]):deleteIfExists()
		end

		proj.file:delete()
	end,
	getDummyValue = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName = "TifLayer"
		local layerFile = filePath("test/cbers_rgb342_crop1.tif", "gis")
		TerraLib().addGdalLayer(proj, layerName, layerFile)

		local bandNoExists =  function()
			TerraLib().getDummyValue(proj, layerName, 3)
		end

		unitTest:assertError(bandNoExists, "The maximum band is '2'.")

		local layerName2 = "TifLayer2"
		local layerFile2 = filePath("test/prodes_polyc_10k.tif", "gis")
		TerraLib().addGdalLayer(proj, layerName2, layerFile2)

		local bandNoExists2 =  function()
			TerraLib().getDummyValue(proj, layerName2, 3)
		end

		unitTest:assertError(bandNoExists2, "The only available band is '0'.")

		proj.file:delete()
	end,
	saveDataAs = function(unitTest)
		local usingProject = function()
			local proj = {}
			proj.file = "myproject.tview"
			proj.title = "TerraLib Tests"
			proj.author = "Avancini Rodrigo"

			File(proj.file):deleteIfExists()

			TerraLib().createProject(proj, {})

			local layerName1 = "TifLayer"
			local layerFile1 = filePath("test/cbers_rgb342_crop1.tif", "gis")
			TerraLib().addGdalLayer(proj, layerName1, layerFile1)

			local overwrite = true

			local fromData = {}
			fromData.project = proj
			fromData.layer = layerName1

			-- SHP
			local toData = {}
			toData.file = File("tif2shp.shp")
			toData.type = "shp"

			local tif2shpError = function()
				TerraLib().saveDataAs(fromData, toData, overwrite)
			end
			unitTest:assertError(tif2shpError, "Raster data 'TifLayer' cannot be saved as vector.")

			-- GEOJSON
			toData.file = File("tif2geojson.geojson")
			toData.type = "geojson"

			local tif2geojsonError = function()
				TerraLib().saveDataAs(fromData, toData, overwrite)
			end
			unitTest:assertError(tif2geojsonError, "Raster data 'TifLayer' cannot be saved as vector.")

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
				TerraLib().saveDataAs(fromData, pgData, overwrite)
			end
			unitTest:assertError(tif2postgisError, "Raster data 'TifLayer' cannot be saved as vector.")

			proj.file:delete()
		end

		local withoutProject = function()
			local fromData = {file = filePath("test/prodes_polyc_10k.tif", "gis")}
			local toData = {file = File("tif2shp.shp"), type = "shp"}

			local raster2vectorError = function()
				TerraLib().saveDataAs(fromData, toData, true)
			end

			unitTest:assertError(raster2vectorError, "Raster data 'prodes_polyc_10k.tif' cannot be saved as vector.")

			toData = {file = File("tif2png.png")}
			TerraLib().saveDataAs(fromData, toData, true)

			local alreadyExistsError = function()
				TerraLib().saveDataAs(fromData, toData, false)
			end

			unitTest:assertError(alreadyExistsError, "File 'tif2png.png' already exists.")

			toData.file:delete()

			fromData = {file = filePath("test/es_limit_sirgas2000_5880.shp", "gis")}
			toData = {file = File("shp2tif.tif"), type = "tif"}

			local vector2rasterError = function()
				TerraLib().saveDataAs(fromData, toData, true)
			end

			unitTest:assertError(vector2rasterError, "Vector data 'es_limit_sirgas2000_5880.shp' cannot be saved as raster.")


		end

		unitTest:assert(usingProject)
		unitTest:assert(withoutProject)
	end
}

