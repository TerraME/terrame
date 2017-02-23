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
		shp[1] = File(clName..".shp")
		shp[1]:deleteIfExists()

		-- CREATE THE CELLULAR SPACE
		local resolution = 60e3
		local mask = true
		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp[1], mask)

		-- CREATE A LAYER WITH POLYGONS TO DO OPERATIONS
		local layerName2 = "Protection_Unit"
		local layerFile2 = filePath("test/BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "terralib")
		tl:addShpLayer(proj, layerName2, layerFile2)

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

		customWarning = customWarningBkp

		local attributeTruncateWarning = function()
			tl:attributeFill(proj, layerName2, clName, presLayerName, attribute, operation, select, area, default)
		end
		unitTest:assertError(attributeTruncateWarning, "The 'attribute' lenght has more than 10 characters. It was truncated to 'presence_t'.")

		attribute = "FID"
		local attributeAlreadyExists = function()
			tl:attributeFill(proj, layerName2, clName, presLayerName, attribute, operation, select, area, default)
		end
		unitTest:assertError(attributeAlreadyExists, "The attribute 'FID' already exists in the Layer.")

		local meanTypeError = function()
			tl:attributeFill(proj, layerName2, clName, clName.."_Mean", "mean", "mean", "NOME", area, default)
		end
		unitTest:assertError(meanTypeError, "Operation 'mean' cannot be executed with an attribute of type string('NOME').")

		local sumTypeError = function()
			tl:attributeFill(proj, layerName2, clName, clName.."_Sum", "sum", "sum", "NOME", area, default)
		end
		unitTest:assertError(sumTypeError, "Operation 'sum' cannot be executed with an attribute of type string('NOME').")

		local wsumTypeError = function()
			tl:attributeFill(proj, layerName2, clName, clName.."_Wsum", "wsum", "wsum", "NOME", area, default)
		end
		unitTest:assertError(wsumTypeError, "Operation 'wsum' cannot be executed with an attribute of type string('NOME').")

		local areaTypeError = function()
			tl:attributeFill(proj, layerName2, clName, clName.."_Area", "area", "area", "NOME", area, default)
		end
		unitTest:assertError(areaTypeError, "Operation 'area' cannot be executed with an attribute of type string('NOME').")

		local stdevTypeError = function()
			tl:attributeFill(proj, layerName2, clName, clName.."_Stdev", "stdev", "stdev", "NOME", area, default)
		end
		unitTest:assertError(stdevTypeError, "Operation 'stdev' cannot be executed with an attribute of type string('NOME').")

		local averageTypeError = function()
			tl:attributeFill(proj, layerName2, clName, clName.."_Average", "average", "average", "NOME", area, default)
		end
		unitTest:assertError(averageTypeError, "Operation 'average' cannot be executed with an attribute of type string('NOME').")

		local weightedTypeError = function()
			tl:attributeFill(proj, layerName2, clName, clName.."_Weighted", "weighted", "weighted", "NOME", area, default)
		end
		unitTest:assertError(weightedTypeError, "Operation 'weighted' cannot be executed with an attribute of type string('NOME').")

		local coverageTypeError = function()
			tl:attributeFill(proj, layerName2, clName, clName.."_Coverage", "coverage", "coverage", "ANOCRIACAO", area, default)
		end
		unitTest:assertError(coverageTypeError, "Operation 'coverage' cannot be executed with an attribute of type real('ANOCRIACAO').")

		local intersectionTypeError = function()
			tl:attributeFill(proj, layerName2, clName, clName.."_Intersection", "intersec", "intersection", "ANOCRIACAO", area, default)
		end
		unitTest:assertError(intersectionTypeError, "Operation 'intersection' cannot be executed with an attribute of type real('ANOCRIACAO').")

		for j = 1, #shp do
			shp[j]:deleteIfExists()
		end

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

		local layerName1 = "SampaShp"
		local layerFile1 = filePath("test/sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)

		-- TIF
		local toData = {}
		toData.file = "shp2tif.tif"
		toData.type = "tif"

		local overwrite = true

		local shp2tifError = function()
			tl:saveLayerAs(proj, layerName1, toData, overwrite)
		end
		unitTest:assertError(shp2tifError, "It was not possible to convert the data in layer 'SampaShp' to 'shp2tif.tif'.")

		local customWarningBkp = customWarning
		customWarning = function(msg)
			return msg
		end

		shp2tifError = function()
			tl:saveLayerAs(proj, layerName1, toData, overwrite)
		end
		unitTest:assertError(shp2tifError, "It was not possible save the data in layer 'SampaShp' to raster data.")

		customWarning = customWarningBkp

		-- GEOJSON
		toData.file = "shp2geojson.geojson"
		toData.type = "geojson"
		tl:saveLayerAs(proj, layerName1, toData, overwrite)

		File(toData.file):delete()
		proj.file:delete()
	end
}
