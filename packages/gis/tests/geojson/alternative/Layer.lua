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
	Layer = function(unitTest)
		local fileAlreadyExistsError = function()
			local projName = "layer_basic_geojson.tview"

			local proj = Project{
				file = projName,
				clean = true
			}

			local l1 = Layer{
				project = proj,
				name = "Prodes",
				file = filePath("amazonia-prodes.tif", "gis")
			}

			local cl1 = Layer{
				project = proj,
				input = l1.name,
				clean = true,
				name = "Prodes-Cells",
				resolution = 60e3,
				file = "prodes_cells.geojson",
				progress = false
			}

			local errorMsg = function()
				Layer{
					project = proj,
					input = l1.name,
					name = "Prodes-Cells-2",
					resolution = 60e3,
					file = "prodes_cells.geojson"
				}
			end

			unitTest:assertError(errorMsg, "File 'prodes_cells.geojson' already exists. Please set clean = true or remove it manually.")

			File(cl1.file):delete()
			proj.file:delete()
		end

		unitTest:assert(fileAlreadyExistsError)
	end
}
