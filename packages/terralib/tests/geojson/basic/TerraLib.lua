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
	createProject = function(unitTest)
		local tl = TerraLib{}
		local title = "TerraLib Tests"
		local author = "Carneiro Heitor"
		local file = "mygeojsonproject.tview"
		local proj = {}
		proj.file = file
		proj.title = title
		proj.author = author

		if isFile(proj.file) then
			rmFile(proj.file)
		end

		tl:createProject(proj, {})
		unitTest:assert(isFile(proj.file))
		unitTest:assertEquals(proj.file, file)
		unitTest:assertEquals(proj.title, title)
		unitTest:assertEquals(proj.author, author)

		-- allow overwrite
		tl:createProject(proj, {})
		unitTest:assert(isFile(proj.file))

		rmFile(proj.file)
	end,
	addGeoJSONLayer = function(unitTest)
		local tl = TerraLib {}
		local title = "TerraLib Tests"
		local author = "Carneiro Heitor"
		local file = "mygeojsonproject.tview"
		local proj = {}
		proj.file = file
		proj.title = title
		proj.author = author

		if isFile(proj.file) then
			rmFile(proj.file)
		end

		tl:createProject(proj, {})

		local layerName = "GeoJSONLayer"
		local layerFile = filePath("Setores_Censitarios_2000_pol.geojson", "terralib")

		tl:addGeoJSONLayer(proj, layerName, layerFile)

		local layerInfo = tl:getLayerInfo(proj, proj.layers[layerName])

		unitTest:assertEquals(layerInfo.name, layerName)
		unitTest:assertEquals(layerInfo.file, layerFile)
		unitTest:assertEquals(layerInfo.type, "OGR")
		unitTest:assertEquals(layerInfo.rep, "geometry")
		unitTest:assertNotNil(layerInfo.sid)

		if isFile(proj.file) then
			rmFile(proj.file)
		end
	end,
	addGeoJSONCellSpaceLayer = function(unitTest)
		local tl = TerraLib{}
		local title = "TerraLib Tests"
		local author = "Carneiro Heitor"
		local file = "mygeojsonproject.tview"
		local proj = {}
		proj.file = file
		proj.title = title
		proj.author = author

		if isFile(proj.file) then
			rmFile(proj.file)
		end

		tl:createProject(proj, {})

		local layerName = "GeoJSONLayer"
		local layerFile = filePath("Setores_Censitarios_2000_pol.geojson", "terralib")

		tl:addGeoJSONLayer(proj, layerName, layerFile)

		local clName = "GeoJSON_Cells"
		local geojson1 = clName..".geojson"

		if isFile(geojson1) then
			rmFile(geojson1)
		end

		local resolution = 10000
		local mask = true
		tl:addGeoJSONCellSpaceLayer(proj, layerName, clName, resolution, geojson1, mask)

		local layerInfo = tl:getLayerInfo(proj, proj.layers[clName])

		unitTest:assertEquals(layerInfo.name, clName)
		unitTest:assertEquals(layerInfo.file, _Gtme.makePathCompatibleToAllOS(currentDir() .. "/") .. geojson1)
		unitTest:assertEquals(layerInfo.type, "OGR")
		unitTest:assertEquals(layerInfo.rep, "polygon")
		unitTest:assertNotNil(layerInfo.sid)

		-- NO MASK TEST
		local clSet = tl:getDataSet(proj, clName)
		unitTest:assertEquals(getn(clSet), 160)

		clName = clName.."_NoMask"
		local geojson2 = clName..".geojson"

		if isFile(geojson2) then
			rmFile(geojson2)
		end

		mask = false
		tl:addGeoJSONCellSpaceLayer(proj, layerName, clName, resolution, geojson2, mask)

		clSet = tl:getDataSet(proj, clName)
		unitTest:assertEquals(getn(clSet), 160)
		-- // NO MASK TEST

		unitTest:assertFile(geojson1)
		unitTest:assertFile(geojson2)
		rmFile(proj.file)
	end
}
