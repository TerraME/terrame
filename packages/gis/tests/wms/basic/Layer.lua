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
		local wmsDir = Directory("wms")
		if wmsDir:exists() then
			wmsDir:delete()
		end

		local projName = "layer_wms_basic.tview"

		local proj = Project {
			file = projName,
			clean = true
		}

		local layerName = "WMS-Layer"
		local service = "http://terrabrasilis.info/geoserver/ows"
		local map = "Prodes_2013:LANDSAT2013"
		local epsg = 29901

		local layer = Layer {
			project = proj,
			name = layerName,
			service = service,
			map = map,
			epsg = epsg
		}

		unitTest:assertEquals(layer.name, layerName)
		unitTest:assertEquals(layer.source, "wms")
		unitTest:assertEquals(layer.service, service)
		unitTest:assertEquals(layer.map, map)
		unitTest:assertEquals(layer.epsg, epsg)

		service = "http://www.geoservicos.inde.gov.br:80/geoserver/ows"
		map = "MPOG:BRA_AH070_N"
		epsg = 4601

		local layer2 = Layer {
			project = proj,
			name = "AnotherWmsLayer",
			service = service,
			map = map,
			epsg = epsg
		}

		unitTest:assertEquals(layer2.epsg, epsg)

		File(projName):delete()
		wmsDir:delete()
	end
}

