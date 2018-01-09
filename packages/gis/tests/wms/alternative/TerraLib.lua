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
	addWmsLayer = function(unitTest)
		local title = "TerraLib Tests"
		local author = "Avancini Rodrigo"
		local file = File("terralib_wms_alt.tview")
		local proj = {}
		proj.file = file:name(true)
		proj.title = title
		proj.author = author

		file:deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName = "WMS-Layer"
		local url = "http://terrabrasilis.info/terraamazon/ow"
		local dataset = "IMG_02082016_321077D"
		local directory = currentDir()
		local conn = {
			url = url,
			directory = directory,
			format = "jpeg"
		}

		local invalidUrl = function()
			TerraLib().addWmsLayer(proj, layerName, conn, dataset)
		end
		unitTest:assertError(invalidUrl, "The URL 'http://terrabrasilis.info/terraamazon/ow' is invalid.")

		conn.url = "http://terrabrasilis.info/terraamazon/ows"
		dataset = "INVALID_DATASET"

		local invalidDataset = function()
			TerraLib().addWmsLayer(proj, layerName, conn, dataset)
		end
		unitTest:assertError(invalidDataset,  "Map 'INVALID_DATASET' was not found in WMS server.")

		file:delete()
	end
}
