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
	Project = function(unitTest)
		local insertNewLayerQgis = function()
			local wmsDir = Directory("wms")
			if wmsDir:exists() then
				wmsDir:delete()
			end

			local qgpfile = filePath("test/sampa_v3.qgs", "gis")
			local spfile = filePath("test/sampa.shp", "gis")
			qgpfile:copy(currentDir())
			spfile:copy(currentDir())

			local qgp = Project {
				file = "sampa_v3.qgs"
			}

			local l2 = Layer{
				project = qgp,
				name = "LayerWMS",
				service = "http://terrabrasilis.dpi.inpe.br/geoserver/ows",
				map = "prodes-cerrado:prodes_cerrado_2000_2018_uf_mun"
			}

			local qgp2 =  Project{
				file = "sampa_v3.qgs"
			}

			local l3 = Layer{
				project = qgp2,
				name = l2.name
			}

			unitTest:assertEquals(l3.name, l2.name)
			unitTest:assertEquals(l3.source, "wms")
			unitTest:assertEquals(l3.service, l2.service)
			unitTest:assertEquals(l3.map, l2.map)
			unitTest:assertEquals(l3.epsg, l2.epsg)
			unitTest:assertEquals(l3.encoding, l2.encoding)

			qgp.file:delete()
			File("sampa.shp"):delete()
			wmsDir:delete()
		end

		unitTest:assert(insertNewLayerQgis)
	end
}
