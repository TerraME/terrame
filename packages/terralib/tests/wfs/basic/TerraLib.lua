-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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
		local tl = TerraLib {}
		local title = "TerraLib Tests"
		local author = "Avancini Rodrigo"
		local file = "terralib_wfs_basic.tview"
		local proj = {}
		proj.file = file
		proj.title = title
		proj.author = author

		if isFile(proj.file) then
			rmFile(proj.file)
		end

		tl:createProject(proj, {})

		local layerName = "WFS-Layer"
		local url = "http://terrabrasilis.info/redd-pac/wfs/wfs_biomes"
		local dataset = "reddpac:BAU"

		if tl:isValidWfsUrl(url) then
			tl:addWfsLayer(proj, layerName, url, dataset)

			local layerInfo = tl:getLayerInfo(proj, proj.layers[layerName])
			unitTest:assertEquals(layerInfo.name, layerName) -- SKIP
			unitTest:assertEquals(layerInfo.url, "WFS:"..url) -- SKIP
			unitTest:assertEquals(layerInfo.type, "WFS") -- SKIP
			unitTest:assertEquals(layerInfo.source, "wfs") -- SKIP
			unitTest:assertEquals(layerInfo.rep, "unknown") -- SKIP
			unitTest:assertNotNil(layerInfo.sid) -- SKIP
		else
			unitTest:assert(true) -- SKIP
		end
		
		rmFile(proj.file)
	end,
	isValidWfsUrl = function(unitTest)
		local tl = TerraLib {}
		local title = "TerraLib Tests"
		local author = "Avancini Rodrigo"
		local file = "terralib_wfs_basic.tview"
		local proj = {}
		proj.file = file
		proj.title = title
		proj.author = author

		if isFile(proj.file) then
			rmFile(proj.file)
		end

		tl:createProject(proj, {})

		local layerName = "WFS-Layer"
		local url = "WFS:http://terrabrasilis.info"
		local dataset = "reddpac:BAU"

		unitTest:assert(not tl:isValidWfsUrl(url))
		
		rmFile(proj.file)
	end
}