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

		local terralib = getPackage("terralib")

		local proj = terralib.Project{
			file = projName,
			clean = true,
			author = author,
			title = title
		}

		local customWarningBkp = customWarning
		customWarning = function(msg)
			return msg
		end

		local layerName1 = "Brazil"

		terralib.Layer{
			project = proj,
			name = layerName1,
			file = filePath("brazilstates.shp", "base")
		}

		-- SHAPE
		local testDir = currentDir()
		local shp1 = "brazil_cells.shp"
		local filePath1 = testDir..shp1

		File(filePath1):deleteIfExists()

		local clName1 = "Brazil_Cells"
		terralib.Layer{
			project = proj,
			input = layerName1,
			name = clName1,
			resolution = 100e3,
			file = filePath1
		}

		local cs = CellularSpace{
			project = projName,
			layer = clName1
		}

		local cellWithoutGeom = function()
			local cell = cs:sample()
			cell:area()
		end
		unitTest:assertError(cellWithoutGeom, "It was not possible to calculate the area. Geometry was not found.")

		-- POSTGIS
		local clName2 = "Brazil_Cells_PG"
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = getConfig().password
		local database = "postgis_22_sample"
		local tName = string.lower(clName2)

		local pgLayer = terralib.Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			name = clName2,
			resolution = 100e3,
			user = user,
			password = password,
			database = database,
			clean = true
		}

		cs = CellularSpace{
			project = projName,
			layer = clName2
		}

		cellWithoutGeom = function()
			local cell = cs:sample()
			cell:area()
		end
		unitTest:assertError(cellWithoutGeom, "It was not possible to calculate the area. Geometry was not found.")

		File(projName):deleteIfExists()
		File(filePath1):deleteIfExists()

		pgLayer:delete()

		customWarning = customWarningBkp
	end
}
