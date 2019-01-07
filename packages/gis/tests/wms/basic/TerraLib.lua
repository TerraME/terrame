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
		local wmsDir = Directory("wms")
		if wmsDir:exists() then
			wmsDir:delete()
		end

		local title = "TerraLib Tests"
		local author = "Avancini Rodrigo"
		local file = File("terralib_wms_basic.tview")
		local proj = {}
		proj.file = file:name(true)
		proj.title = title
		proj.author = author

		file:deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName = "WMS-Layer"
		local url = "http://terrabrasilis.info/geoserver/ows"
		local dataset = "Auxiliares:Global Land Cover 2000"
		local directory = currentDir()
		local srid = 29901

		local conn = {
			url = url,
			directory = directory,
			format = "jpeg"
		}

		TerraLib().addWmsLayer(proj, layerName, conn, dataset, srid)

		local layerInfo = TerraLib().getLayerInfo(proj, layerName)
		unitTest:assertEquals(layerInfo.name, layerName)
		unitTest:assertEquals(layerInfo.url, url)
		unitTest:assertEquals(layerInfo.type, "WMS2")
		unitTest:assertEquals(layerInfo.source, "wms")
		unitTest:assertEquals(layerInfo.rep, "raster")
		unitTest:assertEquals(layerInfo.srid, srid)

		file:delete()
		wmsDir:delete()
	end,
	createProject = function(unitTest)
		local insertNewLayerQgis = function()
			local wmsDir = Directory("wms")
			if wmsDir:exists() then
				wmsDir:delete()
			end

			local qgsfile = filePath("test/sampa_v3.qgs", "gis")
			local spfile = filePath("test/sampa.shp", "gis")

			qgsfile:copy(currentDir())
			spfile:copy(currentDir())

			local qgp = {
				file = File("sampa_v3.qgs")
			}

			TerraLib().createProject(qgp, {})

			local layerName = "LayerWMS"
			local url = "http://terrabrasilis.info/geoserver/ows"
			local dataset = "Prodes_2013:LANDSAT2013"
			local srid = 29901
			local directory = currentDir()
			local conn = {
				url = url,
				directory = directory,
				format = "jpeg"
			}

			TerraLib().addWmsLayer(qgp, layerName, conn, dataset, srid)

			local qgp2 = {
				file = File("sampa_v3.qgs")
			}

			TerraLib().createProject(qgp2)

			local layerInfo = TerraLib().getLayerInfo(qgp2, layerName)
			unitTest:assertEquals(layerInfo.name, layerName)
			unitTest:assertEquals(layerInfo.url, url)
			unitTest:assertEquals(layerInfo.type, "WMS2")
			unitTest:assertEquals(layerInfo.source, "wms")
			unitTest:assertEquals(layerInfo.rep, "raster")
			unitTest:assertEquals(layerInfo.srid, srid)

			qgp.file:delete()
			File("sampa_v3.tview"):delete()
			File("sampa.shp"):delete()
			wmsDir:delete()
		end

		unitTest:assert(insertNewLayerQgis)
	end
}
