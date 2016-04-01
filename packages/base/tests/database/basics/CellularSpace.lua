-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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

return{
	CellularSpace = function(unitTest)
		-- ###################### PROJECT #############################
		local terralib = getPackage("terralib")
		
		local projName = "cellspace_basic.tview"

		if isFile(projName) then
			rmFile(projName)
		end
		
		local author = "Avancini"
		local title = "Cellular Space"

		local proj = terralib.Project {
			file = projName,
			create = true,
			author = author,
			title = title
		}

		local layerName1 = "Sampa"
		proj:addLayer {
			layer = layerName1,
			file = filePath("sampa.shp", "terralib")
		}

		local clName1 = "Sampa_Cells_DB"
		local tName1 = "sampa_cells"
		
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
		local database = "postgis_22_sample"
		local encoding = "CP1252"

		local pgData = {
			type = "POSTGIS",
			host = host,
			port = port,
			user = user,
			password = password,
			database = database,
			table = tName1,
			encoding = encoding
		}

		local tl = terralib.TerraLib{}
		tl:dropPgTable(pgData)

		proj:addCellularLayer {
			source = "postgis",
			input = layerName1,
			layer = clName1,
			resolution = 0.3,
			user = user,
			password = password,
			database = database,
			table = tName1
		}

		-- ###################### 1 #############################
		local cs = CellularSpace{
			project = projName,
			layer = clName1,
			geometry = true
		}

		forEachCell(cs, function(cell)
			unitTest:assertNotNil(cell.geom)
			unitTest:assertNil(cell.OGR_GEOMETRY)
		end)

		local cs = CellularSpace{
			project = projName,
			layer = clName1
		}

		forEachCell(cs, function(cell)
			unitTest:assertNil(cell.geom)
			unitTest:assertNil(cell.OGR_GEOMETRY)
		end)

		if isFile(projName) then
			rmFile(projName)
		end

		pgData.table = string.lower(tName1)
		tl:dropPgTable(pgData)

		local cs = CellularSpace{
			file = filePath("simple.map", "base")
		}

		unitTest:assertEquals(#cs, 100)
	end,
	createNeighborhood = function(unitTest)
		unitTest:assert(true)
	end,
	loadNeighborhood = function(unitTest)
		unitTest:assert(true)
	end,
	save = function(unitTest)
		-- ###################### PROJECT #############################
		local terralib = getPackage("terralib")
		
		local projName = "cellspace_save_basic.tview"

		if isFile(projName) then
			rmFile(projName)
		end

		local author = "Avancini"
		local title = "Cellular Space"

		local proj = terralib.Project {
			file = projName,
			create = true,
			author = author,
			title = title
		}

		local layerName1 = "Sampa"
		proj:addLayer {
			layer = layerName1,
			file = filePath("sampa.shp", "terralib")
		}

		local clName1 = "Sampa_Cells_DB"
		local tName1 = "sampa_cells"

		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
		local database = "postgis_22_sample"
		local encoding = "CP1252"

		local pgData = {
			type = "POSTGIS",
			host = host,
			port = port,
			user = user,
			password = password,
			database = database,
			table = tName1,
			encoding = encoding
		}

		local tl = terralib.TerraLib{}
		tl:dropPgTable(pgData)

		proj:addCellularLayer {
			source = "postgis",
			input = layerName1,
			layer = clName1,
			resolution = 0.3,
			user = user,
			password = password,
			database = database,
			table = tName1
		}

		-- ###################### 1 #############################
		local cs = CellularSpace{
			project = proj,
			layer = clName1
		}

		forEachCell(cs, function(cell)
			cell.t0 = 1000
		end)

		local cellSpaceLayerNameT0 = clName1.."_CellSpace_T0"

		cs:save(cellSpaceLayerNameT0, "t0")

		local cellSpaceLayerInfo = proj:infoLayer(cellSpaceLayerNameT0)
		unitTest:assertEquals(cellSpaceLayerInfo.source, "postgis")
		unitTest:assertEquals(cellSpaceLayerInfo.host, host)
		unitTest:assertEquals(cellSpaceLayerInfo.port, port)
		unitTest:assertEquals(cellSpaceLayerInfo.user, user)
		unitTest:assertEquals(cellSpaceLayerInfo.password, password)
		unitTest:assertEquals(cellSpaceLayerInfo.database, database)
		unitTest:assertEquals(cellSpaceLayerInfo.table, cellSpaceLayerNameT0)	-- TODO: VERIFY LOWER CASE IF CHANGED

		-- ###################### 2 #############################
		local cellSpaceLayerName = clName1.."_CellSpace"

		cs:save(cellSpaceLayerName)

		local cellSpaceLayerInfo = proj:infoLayer(cellSpaceLayerName)
		unitTest:assertEquals(cellSpaceLayerInfo.source, "postgis")
		unitTest:assertEquals(cellSpaceLayerInfo.host, host)
		unitTest:assertEquals(cellSpaceLayerInfo.port, port)
		unitTest:assertEquals(cellSpaceLayerInfo.user, user)
		unitTest:assertEquals(cellSpaceLayerInfo.password, password)
		unitTest:assertEquals(cellSpaceLayerInfo.database, database)
		unitTest:assertEquals(cellSpaceLayerInfo.table, cellSpaceLayerName)	-- TODO: VERIFY LOWER CASE IF CHANGED

		-- ###################### 3 #############################
		local cs = CellularSpace{
			project = proj,
			layer = cellSpaceLayerNameT0
		}

		forEachCell(cs, function(cell)
			unitTest:assertEquals(cell.t0, 1000)
			cell.t0 = cell.t0 + 1000
		end)

		cs:save(cellSpaceLayerNameT0)

		local cs = CellularSpace{
			project = proj,
			layer = cellSpaceLayerNameT0
		}

		forEachCell(cs, function(cell)
			unitTest:assertEquals(cell.t0, 2000)
		end)

		-- ###################### 4 #############################
		-- DOUBLE PRECISION TEST
		local num = 0.123456789012345

		forEachCell(cs, function(cell)
			cell.number = num
		end)

		cs:save(cellSpaceLayerNameT0, "number")

		local cs = CellularSpace{
			project = proj,
			layer = cellSpaceLayerNameT0
		}

		forEachCell(cs, function(cell)
			unitTest:assertEquals(cell.number, num)
		end)

		-- ###################### 5 #############################
		local cs = CellularSpace{
			project = projName,
			layer = cellSpaceLayerNameT0
		}

		local cellSpaceLayerNameGeom = clName1.."_CellSpace_Geom"
		cs:save(cellSpaceLayerNameGeom)
		
		local cs = CellularSpace{
			project = projName,
			layer = cellSpaceLayerNameGeom,
			geometry = true
		}

		forEachCell(cs, function(cell)
			unitTest:assertNotNil(cell.geom)
		end)

		local cellSpaceLayerNameGeom2 = clName1.."_CellSpace_Geom2"
		cs:save(cellSpaceLayerNameGeom2)

		local cs = CellularSpace{
			project = projName,
			layer = cellSpaceLayerNameGeom2,
			geometry = true
		}

		forEachCell(cs, function(cell)
			unitTest:assertNotNil(cell.geom)
		end)

		if isFile(projName) then
			rmFile(projName)
		end

		pgData.table = string.lower(tName1)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(cellSpaceLayerName)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(cellSpaceLayerNameT0)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(cellSpaceLayerNameGeom)
		tl:dropPgTable(pgData)
		pgData.table = string.lower(cellSpaceLayerNameGeom2)
		tl:dropPgTable(pgData)

		tl:finalize()
	end,
	synchronize = function(unitTest)
		local terralib = getPackage("terralib")

		local projName = "cellspace_basic.tview"

		if isFile(projName) then
			rmFile(projName)
		end

		local author = "Avancini"
		local title = "Cellular Space"

		local proj = terralib.Project {
			file = projName,
			create = true,
			author = author,
			title = title
		}

		local layerName1 = "Sampa"
		proj:addLayer {
			layer = layerName1,
			file = filePath("sampa.shp", "terralib")
		}

		local cs = CellularSpace{
			project = proj,
			layer = layerName1,
			geometry = true
		}

		cs:synchronize()

		unitTest:assertNil(cs:sample().past.geom)

		if isFile(projName) then
			rmFile(projName)
		end
	end
}

