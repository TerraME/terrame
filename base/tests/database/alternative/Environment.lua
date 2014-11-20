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
-- Authors: Tiago Carneiro
--          Pedro R. Andrade
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

return{
	loadNeighborhood = function(unitTest)
		local cs1 = CellularSpace{xdim = 10}
		local cs2 = CellularSpace{xdim = 10}

		local env = Environment{cs1, cs2}

		cs1:createNeighborhood{}

		local error_func = function()
			env:loadNeighborhood{
				source = nil,
				name = "neigh1",
				bidirect = true
			}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("source"))

		error_func = function()
			env:loadNeighborhood{
				source = 5,
				name = "neigh1",
				bidirect = true
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("source", "string", 5))

		error_func = function()
			env:loadNeighborhood{
				source = "teste1",
				name = "neigh1",
				bidirect = true
			}
		end
		unitTest:assert_error(error_func, invalidFileExtensionMsg("source", "teste1"))

		error_func = function()
			env:loadNeighborhood{
				source = "teste1.abc",
				name = "neigh1",
				bidirect = true
			}
		end
		unitTest:assert_error(error_func, invalidFileExtensionMsg("source", "abc"))

		error_func = function()
			env:loadNeighborhood{
				source = file("gpmPolLinDbEmas.gpm", "base"),
				name = 6,
				bidirect = true
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("name", "string", 6))

		error_func = function()
			env:loadNeighborhood{
				source = file("gpmPolLinDbEmas.gpm", "base"),
				name = "neigh1",
				bidirect = 13
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("bidirect", "boolean", 13))

		error_func = function()
			env:loadNeighborhood{
				source = file("gpmdistanceDbEmasCells.gpm", "base"),
				name = "my_neighborhood"
			}
		end
		unitTest:assert_error(error_func, "This function does not load neighborhoods between cells from the same CellularSpace. Use CellularSpace:loadNeighborhood() instead.")
		
		error_func = function()
			env:loadNeighborhood{
				source = "gpmlinesDbEmas_invalid.teste",
				name = "my_neighborhood"
			}
		end
		unitTest:assert_error(error_func, invalidFileExtensionMsg("source", "teste"))
	end
}

