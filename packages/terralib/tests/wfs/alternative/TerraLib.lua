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
		local tl = TerraLib {}
		local title = "TerraLib Tests"
		local author = "Avancini Rodrigo"
		local file = "terralib_wfs_alternative.tview"
		local proj = {}
		proj.file = file
		proj.title = title
		proj.author = author

		File(proj.file):deleteIfExists()

		tl:createProject(proj, {})

		local layerName = "WFS-Layer"
		local url = "http://terrabrasilis.info/redd-pac"
		local dataset = "reddpac:BAU"

		local invalidUrl = function()
			tl:addWfsLayer(proj, layerName, url, dataset)
		end
		unitTest:assertError(invalidUrl, "The URL 'http://terrabrasilis.info/redd-pac' is invalid.")

		url = "http://terrabrasilis.info/redd-pac/wfs/wfs_biomes"
		dataset = "reddpac:B"

		if tl:isValidWfsUrl(url) then
			local invalidDataSet = function()
				tl:addWfsLayer(proj, layerName, url, dataset)
			end
			unitTest:assertError(invalidDataSet, "It was not possible to find data set 'reddpac:B' of type 'WFS'. Layer 'WFS-Layer' does not created.") -- SKIP
		end

		proj.file:delete()
	end
}
