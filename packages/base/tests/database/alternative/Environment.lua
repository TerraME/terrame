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
	loadNeighborhood = function(unitTest)
		local cs2 = CellularSpace{xdim = 10}
		local cs = CellularSpace{xdim = 10}

		local env = Environment{cs, cs2}

		local error_func = function()
			env:loadNeighborhood{
				file = filePath("test/gpmAreaCellsPols.gpm", "base"),
			}
		end
		unitTest:assertError(error_func, "CellularSpaces with layers 'emas.shp' and 'Limit_pol.shp' were not found in the Environment.")

		cs = CellularSpace{
			file = filePath("test/Limit_pol.shp")
		}

		env = Environment{cs, cs2}

		error_func = function()
			env:loadNeighborhood{
				file = filePath("test/gpmAreaCellsPols.gpm", "base"),
			}
		end
		unitTest:assertError(error_func, "CellularSpace with layer 'emas.shp' was not found in the Environment.")

		cs = CellularSpace{
			file = filePath("test/emas.shp"),
			xy = {"Col", "Lin"}
		}

		env = Environment{cs, cs2}

		error_func = function()
			env:loadNeighborhood{
				file = filePath("test/gpmAreaCellsPols.gpm", "base"),
			}
		end
		unitTest:assertError(error_func, "CellularSpace with layer 'Limit_pol.shp' was not found in the Environment.")

		local cs1 = CellularSpace{xdim = 10}
		cs2 = CellularSpace{xdim = 10}

		env = Environment{cs1, cs2}

		cs1:createNeighborhood{}

		error_func = function()
			env:loadNeighborhood{
				file = nil,
				name = "neigh1",
				bidirect = true
			}
		end
		 unitTest:assertError(error_func, mandatoryArgumentMsg("file"))

		error_func = function()
			env:loadNeighborhood{
				file = 5,
				name = "neigh1",
				bidirect = true
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("file", "File", 5))

		error_func = function()
			env:loadNeighborhood{
				file = "teste1",
				name = "neigh1",
				bidirect = true
			}
		end
		unitTest:assertError(error_func, invalidFileExtensionMsg("file", ""))

		error_func = function()
			env:loadNeighborhood{
				file = "teste1.abc",
				name = "neigh1",
				bidirect = true
			}
		end
		unitTest:assertError(error_func, invalidFileExtensionMsg("file", "abc"))

		error_func = function()
			env:loadNeighborhood{
				file = filePath("test/emas-pollin.gpm", "base"),
				name = 6,
				bidirect = true
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("name", "string", 6))

		error_func = function()
			env:loadNeighborhood{
				file = filePath("test/emas-pollin.gpm", "base"),
				name = "neigh1",
				bidirect = 13
		}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("bidirect", "boolean", 13))

		error_func = function()
			env:loadNeighborhood{
				file = filePath("test/emas-distance.gpm", "base"),
				name = "my_neighborhood"
		}
		end
		unitTest:assertError(error_func, "This function does not load neighborhoods between cells from the same CellularSpace. Use CellularSpace:loadNeighborhood() instead.")

		error_func = function()
			env:loadNeighborhood{
				file = "emas-distance-xxx.gpm",
				name = "my_neighborhood"
			}
		end
		unitTest:assertError(error_func, resourceNotFoundMsg("file", File("emas-distance-xxx.gpm")))

		error_func = function()
			env:loadNeighborhood{
				file = "gpmlinesDbEmas_invalid.teste",
				name = "my_neighborhood"
			}
		end
		unitTest:assertError(error_func, invalidFileExtensionMsg("file", "teste"))

		cs = CellularSpace{
			file = filePath("test/emas.shp"),
			xy = {"Col", "Lin"}
		}

		cs2 = CellularSpace{
			file = filePath("test/Limit_pol.shp")
		}

		env = Environment{cs, cs2}

		local countTest = 1

		-- .gpm Regular CS x Irregular CS - without weights
		local s = sessionInfo().separator
		local mfile = filePath("test/error"..s.."gpmAreaCellsPols-error.gpm", "base")

		error_func = function()
			env:loadNeighborhood{
				file = mfile,
				name = "my_neighborhood"..countTest
			}
		end
		unitTest:assertError(error_func, "The string 'bb' found as weight in the file '"..mfile.."' could not be converted to a number.")

		mfile = filePath("test/error"..s.."gpmAreaCellsPols-error2.gpm", "base")

		error_func = function()
			env:loadNeighborhood{
				file = mfile,
				name = "my_neighborhood"..countTest
			}
		end

		unitTest:assertError(error_func, "Could not read the file properly. It seems that it is corrupted.")

		mfile = filePath("test/error"..s.."gpmAreaCellsPols-error3.gpm", "base")

		error_func = function()
			env:loadNeighborhood{
				file = mfile,
				name = "my_neighborhood"..countTest
			}
		end

		unitTest:assertError(error_func, "The string 'abc' found as weight in the file '"..mfile.."' could not be converted to a number.")
	end
}

