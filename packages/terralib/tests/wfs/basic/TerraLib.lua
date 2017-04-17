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
	addWfsLayer = function(unitTest)
		local title = "TerraLib Tests"
		local author = "Avancini Rodrigo"
		local file = File("terralib_wfs_basic.tview")
		local proj = {}
		proj.file = file:name(true)
		proj.title = title
		proj.author = author

		file:deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName = "WFS-Layer"
		local url = "http://terrabrasilis.info/redd-pac/wfs"
		local dataset = "reddpac:wfs_biomes"

		if TerraLib().isValidWfsUrl(url) then
			TerraLib().addWfsLayer(proj, layerName, url, dataset)

			local layerInfo = TerraLib().getLayerInfo(proj, layerName)
			unitTest:assertEquals(layerInfo.name, layerName) -- SKIP
			unitTest:assertEquals(layerInfo.url, url) -- SKIP
			unitTest:assertEquals(layerInfo.type, "WFS") -- SKIP
			unitTest:assertEquals(layerInfo.source, "wfs") -- SKIP
			unitTest:assertEquals(layerInfo.rep, "surface") -- SKIP
			unitTest:assertNotNil(layerInfo.sid) -- SKIP
		else
			customError("WFS server '.."..service.."' is not responding, try again later.") -- SKIP
		end

		file:delete()
	end,
	isValidWfsUrl = function(unitTest)
		local title = "TerraLib Tests"
		local author = "Avancini Rodrigo"
		local file = File("terralib_wfs_basic.tview")
		local proj = {}
		proj.file = file:name(true)
		proj.title = title
		proj.author = author

		file:deleteIfExists()

		TerraLib().createProject(proj, {})

		local url = "WFS:http://terrabrasilis.info"

		unitTest:assert(not TerraLib().isValidWfsUrl(url))

		file:delete()
	end
}
