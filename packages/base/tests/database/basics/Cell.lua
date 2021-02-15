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

return{
	area = function(unitTest)
		local projName = "cell_area.tview"

		local author = "Avancini"
		local title = "Cellular Space"

		local gis = getPackage("gis")

		local proj = gis.Project{
			file = projName,
			clean = true,
			author = author,
			title = title
		}

		local layerName1 = "Brazil"

		gis.Layer{
			project = proj,
			name = layerName1,
			file = filePath("brazilstates.shp", "base"),
			epsg = 4326
		}

		-- SHAPE
		local cs1 = CellularSpace{
			project = projName,
			layer = layerName1
		}

		local areas = {
			AM = 1601675499688.9,
			BA = 564229585351.11,
			AL = 28168487396.904,
			CE = 149907674247.99,
			MA = 330188402174.26,
			MG = 592198348836.93,
			MS = 361756445187.47,
			PA = 1214210378305.2,
			PE = 97860692177.33,
			PB = 54587304824.333,
			PR = 196600897555.39,
			RJ = 42120876433.086,
			RN = 53762908439.105,
			RO = 242382991893.6,
			RR = 244841730635.56,
			RS = 271939274442.49,
			SC = 95387870311.867,
			SE = 21982287629.894,
			SP = 247546936216.45,
			TO = 275466806493.38,
			PI = 255173646784.11,
			ES = 46478925246.813,
			AP = 136242737344.92,
			AC = 154725610931.57,
			DF = 6123834608.5798,
			GO = 338731171994.97,
			MT = 898282431069.91
		}

		forEachCell(cs1, function(cell)
			unitTest:assertEquals(math.floor(areas[cell.SIGLA]), math.floor(cell:area()))
		end)

		local shp1 = "brazil_cells.shp"
		local filePath1 = currentDir()..shp1

		File(filePath1):deleteIfExists()

		local clName1 = "Brazil_Cells"
		gis.Layer{
			project = proj,
			input = layerName1,
			name = clName1,
			resolution = 100e3,
			file = filePath1,
			progress = false
		}

		local cs = CellularSpace{
			project = projName,
			layer = clName1
		}

		for _ = 1, 10 do
			unitTest:assertEquals(cs:sample():area(), 10000000000)
		end

		-- POSTGIS
		local clName2 = "Brazil_Cells_PG"
		local password = getConfig().password
		local database = "postgis_22_sample"

		local pgLayer = gis.Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			name = clName2,
			resolution = 100e3,
			password = password,
			database = database,
			clean = true,
			progress = false
		}

		cs = CellularSpace{
			project = projName,
			layer = clName2
		}

		for _ = 1, 10 do
			unitTest:assertEquals(cs:sample():area(), 10000000000)
		end

		File(projName):deleteIfExists()
		File(filePath1):deleteIfExists()

		pgLayer:delete()
	end,
	distance = function(unitTest)
		local projName = "cell_area.tview"

		local author = "Avancini"
		local title = "Cellular Space"

		local gis = getPackage("gis")

		local proj = gis.Project{
			file = projName,
			clean = true,
			author = author,
			title = title
		}

		local layerName1 = "Brazil"

		gis.Layer{
			project = proj,
			name = layerName1,
			file = filePath("brazilstates.shp", "base"),
			epsg = 4326
		}

		-- SHAPE
		local shp1 = "brazil_cells.shp"
		local filePath1 = currentDir()..shp1

		File(filePath1):deleteIfExists()

		local clName1 = "Brazil_Cells"
		gis.Layer{
			project = proj,
			input = layerName1,
			name = clName1,
			resolution = 100e3,
			file = filePath1,
			progress = false
		}

		local cs = CellularSpace{
			project = projName,
			layer = clName1
		}

		local cell = cs.cells[1]
		unitTest:assertEquals(cell:distance(cell), 0)

		local othercell = cs.cells[#cs - 1]
		local dist = cell:distance(othercell)

		unitTest:assertEquals(dist, 4257933.7712088, 1.0e-7)

		-- POSTGIS
		local clName2 = "Brazil_Cells_PG"
		local password = "postgres"
		local database = "postgis_22_sample"

		local pgLayer = gis.Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			name = clName2,
			resolution = 100e3,
			password = password,
			database = database,
			clean = true,
			progress = false
		}

		cs = CellularSpace{
			project = projName,
			layer = clName2
		}

		cell = cs.cells[1]
		unitTest:assertEquals(cell:distance(cell), 0)

		othercell = cs.cells[#cs - 1]
		dist = cell:distance(othercell)

		unitTest:assertEquals(dist, 4257933.7712088, 1.0e-7)

		File(projName):deleteIfExists()
		File(filePath1):deleteIfExists()

		pgLayer:delete()
	end
}
