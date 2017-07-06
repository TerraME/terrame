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
		shp[1] = File(clName..".shp")
		shp[1]:deleteIfExists()

		-- CREATE THE CELLULAR SPACE
		local resolution = 60e3
		local mask = true
		TerraLib().addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp[1], mask)

		-- CREATE A LAYER WITH POLYGONS TO DO OPERATIONS
		local layerName2 = "Protection_Unit"
		local layerFile2 = filePath("test/BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "gis")
		TerraLib().addShpLayer(proj, layerName2, layerFile2)

		-- SHAPE OUTPUT
		-- FILL CELLULAR SPACE WITH PRESENCE OPERATION
		local presLayerName = clName.."_"..layerName2.."_Presence"
		shp[2] = File(presLayerName..".shp")

		shp[2]:deleteIfExists()

		local operation = "presence"
		local attribute = "presence_truncate"
		local select = "FID"
		local area = nil
		local default = nil

		attribute = "FID"
		local attributeAlreadyExists = function()
			TerraLib().attributeFill(proj, layerName2, clName, presLayerName, attribute, operation, select, area, default)
		end

		unitTest:assertError(attributeAlreadyExists, "The attribute 'FID' already exists in the Layer.")

		local meanTypeError = function()
			TerraLib().attributeFill(proj, layerName2, clName, clName.."_Mean", "mean", "mean", "NOME", area, default)
		end

		unitTest:assertError(meanTypeError, "Operation 'mean' cannot be executed with an attribute of type string ('NOME').")

		local sumTypeError = function()
			TerraLib().attributeFill(proj, layerName2, clName, clName.."_Sum", "sum", "sum", "NOME", area, default)
		end

		unitTest:assertError(sumTypeError, "Operation 'sum' cannot be executed with an attribute of type string ('NOME').")

		local wsumTypeError = function()
			TerraLib().attributeFill(proj, layerName2, clName, clName.."_Wsum", "wsum", "wsum", "NOME", area, default)
		end

		unitTest:assertError(wsumTypeError, "Operation 'wsum' cannot be executed with an attribute of type string ('NOME').")

		local areaTypeError = function()
			TerraLib().attributeFill(proj, layerName2, clName, clName.."_Area", "area", "area", "NOME", area, default)
		end

		unitTest:assertError(areaTypeError, "Operation 'area' cannot be executed with an attribute of type string ('NOME').")

		local stdevTypeError = function()
			TerraLib().attributeFill(proj, layerName2, clName, clName.."_Stdev", "stdev", "stdev", "NOME", area, default)
		end

		unitTest:assertError(stdevTypeError, "Operation 'stdev' cannot be executed with an attribute of type string ('NOME').")

		local averageTypeError = function()
			TerraLib().attributeFill(proj, layerName2, clName, clName.."_Average", "average", "average", "NOME", area, default)
		end

		unitTest:assertError(averageTypeError, "Operation 'average' cannot be executed with an attribute of type string ('NOME').")

		local weightedTypeError = function()
			TerraLib().attributeFill(proj, layerName2, clName, clName.."_Weighted", "weighted", "weighted", "NOME", area, default)
		end

		unitTest:assertError(weightedTypeError, "Operation 'weighted' cannot be executed with an attribute of type string ('NOME').")

		local coverageTypeError = function()
			TerraLib().attributeFill(proj, layerName2, clName, clName.."_Coverage", "coverage", "coverage", "ANOCRIACAO", area, default)
		end

		unitTest:assertError(coverageTypeError, "Operation 'coverage' cannot be executed with an attribute of type real ('ANOCRIACAO').")

		local intersectionTypeError = function()
			TerraLib().attributeFill(proj, layerName2, clName, clName.."_Intersection", "intersec", "intersection", "ANOCRIACAO", area, default)
		end

		unitTest:assertError(intersectionTypeError, "Operation 'intersection' cannot be executed with an attribute of type real ('ANOCRIACAO').")

		local percLayerName = clName.."_"..layerName2.."_Percentage"
		shp[3] = File(percLayerName..".shp")
		shp[3]:deleteIfExists()

		operation = "coverage"
		attribute = "perc"
		select = "ADMINISTRA"
		area = nil
		default = nil
		TerraLib().attributeFill(proj, layerName2, clName, percLayerName, attribute, operation, select, area, default)

		-- getDataSet TEST
		local missingError = function()
			TerraLib().getDataSet(proj, percLayerName)
		end

		unitTest:assertError(missingError, "Data has a missing value in attribute 'perc_0'. Use argument 'missing' to set its value.")

		-- getOGRByFilePath TEST
		local missingOgrError = function()
			TerraLib().getOGRByFilePath(tostring(shp[3]))
		end

		unitTest:assertError(missingOgrError, "Data has a missing value in attribute 'perc_0'. Use argument 'missing' to set its value.")

		for j = 1, #shp do
			shp[j]:deleteIfExists()
		end

		proj.file:delete()
	end,
	saveLayerAs = function(unitTest)
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

		-- TIF
		local toData = {}
		toData.file = "shp2tif.tif"
		toData.type = "tif"

		local overwrite = true

		local shp2tifError = function()
			TerraLib().saveLayerAs(fromData, toData, overwrite)
		end
		unitTest:assertError(shp2tifError, "It was not possible save 'SampaShp' to raster data.")

		fromData = {}
		fromData.file = layerFile1
		shp2tifError = function()
			TerraLib().saveLayerAs(fromData, toData, overwrite)
		end
		unitTest:assertError(shp2tifError, "It was not possible save 'sampa.shp' to raster data.")

		proj.file:delete()
	end
}
