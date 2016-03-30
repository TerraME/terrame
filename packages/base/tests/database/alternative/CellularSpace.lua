-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP.
--
-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.
--
-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or caonsequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Pedro R. Andrade
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

return{
	CellularSpace = function(unitTest)
		unitTest:assert(true)
	end,
	loadNeighborhood = function(unitTest)
		unitTest:assert(true)
	end,
	save = function(unitTest)
		-- ###################### PROJECT #############################
		local terralib = getPackage("terralib")

		local projName = "cellspace_save_alt.tview"

		if isFile(projName) then
			os.execute("rm -f "..projName)
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

		local cs = CellularSpace{
			project = proj,
			layer = clName1
		}

		forEachCell(cs, function(cell)
			cell.t0 = 1000
		end)

		local cellSpaceLayerName = clName1.."_CellSpace"

		local attrNotExists = function()
			cs:save(cellSpaceLayerName, "t1")
		end
		unitTest:assertError(attrNotExists, "Attribute 't1' does not exist in the CellularSpace.")

		local outLayerNotString = function()
			cs:save(123, "t0")
		end
		unitTest:assertError(outLayerNotString, incompatibleTypeMsg("#1", "string", 123))

		local attrNotStringOrTable = function()
			cs:save(cellSpaceLayerName, 123)
		end
		unitTest:assertError(attrNotStringOrTable, "Incompatible types. Argument '#2' expected table or string.")

		local outLayerMandatory = function()
			cs:save()
		end
		unitTest:assertError(outLayerMandatory, mandatoryArgumentMsg("#1"))
	end
}

