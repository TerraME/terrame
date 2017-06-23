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
	save = function(unitTest)
		local cs = CellularSpace{
			file = filePath("test/sampa.shp", "terralib")
		}

		local t = Trajectory{
			target = cs,
			select = function(cell)
				return cell.ID % 2 == 0
			end
		}

		local mandatoryFileError = function()
			t:save("foo.shp")
		end
		unitTest:assertError(mandatoryFileError, incompatibleTypeMsg("#1", "File", "foo.shp"))

		local file = File("odd.shp")

		local paramTypeError = function()
			t:save(file, true)
		end
		unitTest:assertError(paramTypeError, "Incompatible types. Argument '#2' expected table or string.")

		local attrNotExist = function()
			t:save(file, "FOO")
		end
		unitTest:assertError(attrNotExist, "Attribute 'FOO' does not exist in the target CellularSpace.")

		local attrNotExist2 = function()
			t:save(file, {"ID", "BAR"})
		end
		unitTest:assertError(attrNotExist2, "Attribute 'BAR' does not exist in the target CellularSpace.")

		local cs1 = CellularSpace{
			xdim = 3
		}

		local t1 = Trajectory{
			target = cs1
		}

		local file1 = File("foo.shp")

		local targetSourceError = function()
			t1:save(file1)
		end
		unitTest:assertError(targetSourceError, "Target CellularSpace must come from a file or layer.")
	end
}

