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
		TerraLib().setProgressVisible(false)

		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()
		TerraLib().createProject(proj, {})
		TerraLib().setProgressVisible(false)

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
		local attribute = "FID"
		local select = "FID"

		local attributeAlreadyExists = function()
			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = clName,
				out = presLayerName,
				attribute = attribute,
				operation = operation,
				select = select
			}
		end

		unitTest:assertError(attributeAlreadyExists, "The attribute 'FID' already exists in the Layer.")

		local meanTypeError = function()
			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = clName,
				out = clName.."_Mean",
				attribute = "mean",
				operation = "mean",
				select = "NOME"
			}
		end

		unitTest:assertError(meanTypeError, "Operation 'mean' cannot be executed with an attribute of type string ('NOME').")

		local sumTypeError = function()
			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = clName,
				out = clName.."_Sum",
				attribute = "sum",
				operation = "sum",
				select = "NOME"
			}
		end

		unitTest:assertError(sumTypeError, "Operation 'sum' cannot be executed with an attribute of type string ('NOME').")

		local wsumTypeError = function()
			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = clName,
				out = clName.."_Wsum",
				attribute = "wsum",
				operation = "wsum",
				select = "NOME"
			}
		end

		unitTest:assertError(wsumTypeError, "Operation 'wsum' cannot be executed with an attribute of type string ('NOME').")

		local areaTypeError = function()
			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = clName,
				out = clName.."_Area",
				attribute = "area",
				operation = "area",
				select = "NOME"
			}
		end

		unitTest:assertError(areaTypeError, "Operation 'area' cannot be executed with an attribute of type string ('NOME').")

		local stdevTypeError = function()
			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = clName,
				out = clName.."_Stdev",
				attribute = "stdev",
				operation = "stdev",
				select = "NOME"
			}
		end

		unitTest:assertError(stdevTypeError, "Operation 'stdev' cannot be executed with an attribute of type string ('NOME').")

		local averageTypeError = function()
			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = clName,
				out = clName.."_Average",
				attribute = "average",
				operation = "average",
				select = "NOME"
			}
		end

		unitTest:assertError(averageTypeError, "Operation 'average' cannot be executed with an attribute of type string ('NOME').")

		local weightedTypeError = function()
			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = clName,
				out = clName.."_Weighted",
				attribute = "weighted",
				operation = "weighted",
				select = "NOME"
			}
		end

		unitTest:assertError(weightedTypeError, "Operation 'weighted' cannot be executed with an attribute of type string ('NOME').")

		local coverageTypeError = function()
			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = clName,
				out = clName.."_Coverage",
				attribute = "coverage",
				operation = "coverage",
				select = "ANOCRIACAO"
			}
		end

		unitTest:assertError(coverageTypeError, "Operation 'coverage' cannot be executed with an attribute of type real ('ANOCRIACAO').")

		local intersectionTypeError = function()
			TerraLib().attributeFill{
				project = proj,
				from = layerName2,
				to = clName,
				out = clName.."_Intersection",
				attribute = "intersec",
				operation = "intersection",
				select = "ANOCRIACAO"
			}
		end

		unitTest:assertError(intersectionTypeError, "Operation 'intersection' cannot be executed with an attribute of type real ('ANOCRIACAO').")

		local percLayerName = clName.."_"..layerName2.."_Percentage"
		shp[3] = File(percLayerName..".shp")
		shp[3]:deleteIfExists()

		operation = "coverage"
		attribute = "perc"
		select = "ADMINISTRA"

		TerraLib().attributeFill{
			project = proj,
			from = layerName2,
			to = clName,
			out = percLayerName,
			attribute = attribute,
			operation = operation,
			select = select,
		}

		-- getDataSet TEST
		local missingError = function()
			TerraLib().getDataSet{project = proj, layer = percLayerName}
		end

		unitTest:assertError(missingError, "Data has a missing value in attribute 'perc_0'. Use argument 'missing' to set its value.")

		local missingOgrError = function()
			TerraLib().getDataSet{file = shp[3]}
		end

		unitTest:assertError(missingOgrError, "Data has a missing value in attribute 'perc_0'. Use argument 'missing' to set its value.")

		for j = 1, #shp do
			shp[j]:deleteIfExists()
		end

		proj.file:delete()
	end,
	saveDataAs = function(unitTest)
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

		local fromData = {}
		fromData.project = proj
		fromData.layer = layerName1

		-- TIF
		local toData = {}
		toData.file = File("shp2tif.tif")
		toData.type = "tif"

		local overwrite = true

		local shp2tifError = function()
			TerraLib().saveDataAs(fromData, toData, overwrite)
		end
		unitTest:assertError(shp2tifError, "Vector data 'SampaShp' cannot be saved as raster.")

		fromData = {file = layerFile1}

		shp2tifError = function()
			TerraLib().saveDataAs(fromData, toData, overwrite)
		end
		unitTest:assertError(shp2tifError, "Vector data 'sampa.shp' cannot be saved as raster.")

		proj.file:delete()
	end
}
