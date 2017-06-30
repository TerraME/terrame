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
	Layer = function(unitTest)
		local projName = "layer_shape_alt.tview"

		local proj = Project {
			file = projName,
			clean = true
		}

		-- SPATIAL INDEX TEST
		local layerName1 = "Setores"

		local indexDefaultError1 = function()
			Layer{
				project = proj,
				name = layerName1.."c",
				file = filePath("itaituba-census.shp", "gis"),
				index = true
			}
		end

		unitTest:assertWarning(indexDefaultError1, defaultValueMsg("index", true))

		Layer{
			project = proj,
			name = layerName1,
			file = filePath("itaituba-census.shp", "gis")
		}

		local clName1 = "PA_Cells50x50"
		local indexDefaultError2 = function()
			Layer{
				project = proj,
				source = "shp",
				clean = true,
				input = layerName1,
				name = clName1,
				resolution = 50000,
				file = clName1..".shp",
				index = true
			}
		end

		unitTest:assertWarning(indexDefaultError2, defaultValueMsg("index", true))
		File(clName1..".shp"):delete()

		local epsgError = function()
			Layer{
				project = proj,
				name = "Elevation",
				file = filePath("cabecadeboi-box.shp", "gis")
			}
		end
		unitTest:assertWarning(epsgError, "It was not possible to find the projection of layer 'Elevation'. It should be one of the projections available at www.terrame.org/projections.html")

		proj.file:delete()
	end,
	export = function(unitTest)
		local projName = "layer_func_alt.tview"

		local proj = Project {
			file = projName,
			clean = true
		}

		local filePath1 = filePath("itaituba-census.shp", "gis")

		local layerName1 = "setores"
		local layer1 = Layer{
			project = proj,
			name = layerName1,
			file = filePath1
		}

		local invalidFile = function()
			layer1:export{file = "invalid.org"}
		end

		unitTest:assertError(invalidFile, invalidFileExtensionMsg("data", "org"))

		local selectNoExist = function()
			layer1:export{select = {"uf", "pop"}, source = "shp", file = "shape.shp"}
		end
		unitTest:assertError(selectNoExist, "There are no attributes 'uf' and 'pop' in 'setores'.")

		local selectWrongType = function()
			layer1:export{select = true, source = "shp", file = "shape.shp"}
		end

		unitTest:assertError(selectWrongType, incompatibleTypeMsg("select", "table", true))

		proj.file:delete()
	end
}

