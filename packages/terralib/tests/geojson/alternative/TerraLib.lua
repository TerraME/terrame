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
	saveLayerAs = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib:createProject(proj, {})

		local layerName1 = "SampaGeoJson"
		local layerFile1 = filePath("test/sampa.geojson", "terralib")
		TerraLib:addGeoJSONLayer(proj, layerName1, layerFile1)

		-- TIF
		local toData = {}
		toData.file = "geojson2tif.tif"
		toData.type = "tif"

		local overwrite = true

		local geojson2tifError = function()
			TerraLib:saveLayerAs(proj, layerName1, toData, overwrite)
		end
		unitTest:assertError(geojson2tifError, "It was not possible to convert the data in layer 'SampaGeoJson' to 'geojson2tif.tif'.")

		-- SHP
		toData.file = "geojson2shp.shp"
		toData.type = "shp"
		TerraLib:saveLayerAs(proj, layerName1, toData, overwrite)

		File(toData.file):delete()
		proj.file:delete()
	end
}
