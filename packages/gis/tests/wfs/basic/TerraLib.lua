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
		local srid = 29901
		local encoding = "UTF-8"

		if TerraLib().isValidWfsUrl(url) then
			TerraLib().addWfsLayer(proj, layerName, url, dataset, srid, encoding)

			local layerInfo = TerraLib().getLayerInfo(proj, layerName)
			unitTest:assertEquals(layerInfo.name, layerName) -- SKIP
			unitTest:assertEquals(layerInfo.url, url) -- SKIP
			unitTest:assertEquals(layerInfo.type, "WFS") -- SKIP
			unitTest:assertEquals(layerInfo.source, "wfs") -- SKIP
			unitTest:assertEquals(layerInfo.rep, "polygon") -- SKIP
			unitTest:assertEquals(layerInfo.srid, srid) -- SKIP
			unitTest:assertEquals(layerInfo.encoding, encoding) -- SKIP
		else
			customError("WFS server '.."..url.."' is not responding, try again later.") -- SKIP
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
	end,
	createProject = function(unitTest)
		local insertNewLayerQgis = function()
			local qgsfile = filePath("test/sampa_v3.qgs", "gis")
			local spfile = filePath("test/sampa.shp", "gis")

			qgsfile:copy(currentDir())
			spfile:copy(currentDir())

			local qgp = {
				file = File("sampa_v3.qgs")
			}

			TerraLib().createProject(qgp, {})

			local layerName = "LayerWFS"
			local url = "http://terrabrasilis.info/redd-pac/wfs"
			local dataset = "reddpac:wfs_biomes"
			local srid = 29901

			TerraLib().addWfsLayer(qgp, layerName, url, dataset, srid)

			local qgp2 = {
				file = File("sampa_v3.qgs")
			}

			TerraLib().createProject(qgp2)

			local layerInfo = TerraLib().getLayerInfo(qgp2, layerName)
			unitTest:assertEquals(layerInfo.name, layerName)
			unitTest:assertEquals(layerInfo.url, url)
			unitTest:assertEquals(layerInfo.type, "WFS")
			unitTest:assertEquals(layerInfo.source, "wfs")
			unitTest:assertEquals(layerInfo.rep, "polygon")
			unitTest:assertEquals(layerInfo.srid, srid)

			qgp.file:delete()
			File("sampa.shp"):delete()
		end

		unitTest:assert(insertNewLayerQgis)
	end,
	saveDataAs = function(unitTest)
		TerraLib().setProgressVisible(false)

		local saveAsShp = function()
			local proj = {
				file = "savedataas_wfs_basic.tview",
				title = "TerraLib Tests",
				author = "Avancini Rodrigo"
			}

			File(proj.file):deleteIfExists()
			TerraLib().createProject(proj, {})


			local l1Name = "LayerWfs"
			local url = "http://terrabrasilis.info/redd-pac/wfs"
			local dataset = "reddpac:wfs_biomes"

			TerraLib().addWfsLayer(proj, l1Name, url, dataset)

			local fromData = {project = proj, layer = l1Name}
			local toData = {file = File("wfs2shp.shp"), encoding = "UTF-8"}

			TerraLib().saveDataAs(fromData, toData, true)

			local l2Name = "LayerShp"
			TerraLib().addShpLayer(proj, l2Name, toData.file)

			local l1Props = TerraLib().getPropertyInfos(proj, l1Name)
			local l2Props = TerraLib().getPropertyInfos(proj, l2Name)

			unitTest:assertEquals(getn(l1Props), getn(l2Props))
			unitTest:assertEquals(l1Props[0].name, l2Props[0].name)
			unitTest:assertEquals(l1Props[1].name, l2Props[1].name)
			unitTest:assertEquals(l1Props[2].name, l2Props[2].name)
			unitTest:assertEquals(l1Props[3].name, l2Props[3].name)
			unitTest:assertEquals(l1Props[4].name, l2Props[4].name)
			unitTest:assertEquals(l1Props[5].name, l2Props[5].name)
			unitTest:assertEquals(l1Props[6].name, l2Props[6].name)
			unitTest:assertNil(l1Props[7])
			unitTest:assertNil(l2Props[7])

			toData.file:delete()
			proj.file:delete()
		end

		unitTest:assert(saveAsShp)
	end
}
