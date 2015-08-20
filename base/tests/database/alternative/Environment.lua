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
		local config = getConfig()
		local mdbType = config.dbType
		local mhost = config.host
		local muser = config.user
		local mpassword = config.password
		local mport = config.port
		local mdatabase

		if mdbType == "ado" then
			mdatabase = data("emas.mdb", "base")
		else
			mdatabase = "emas"
		end

		local cs1 = CellularSpace{
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "cells1000x1000"
		}

		unitTest:assert(true)

		local cs2 = CellularSpace{xdim = 10}

		local env = Environment{cs1, cs2}

		local error_func = function()
			env:loadNeighborhood{
				source = file("gpmAreaCellsPols.gpm", "base"),
			}
		end
		unitTest:assertError(error_func, "CellularSpaces with layers 'cells1000x1000' and 'Limit' were not found in the Environment.")

		cs1 = CellularSpace{xdim = 10}
		cs2 = CellularSpace{xdim = 10}

		local env = Environment{cs1, cs2}

		cs1:createNeighborhood{}

		local error_func = function()
			env:loadNeighborhood{
				source = nil,
				name = "neigh1",
				bidirect = true
			}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("source"))

		error_func = function()
			env:loadNeighborhood{
				source = 5,
				name = "neigh1",
				bidirect = true
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("source", "string", 5))

		error_func = function()
			env:loadNeighborhood{
				source = "teste1",
				name = "neigh1",
				bidirect = true
			}
		end
		unitTest:assertError(error_func, invalidFileExtensionMsg("source", "teste1"))

		error_func = function()
			env:loadNeighborhood{
				source = "teste1.abc",
				name = "neigh1",
				bidirect = true
			}
		end
		unitTest:assertError(error_func, invalidFileExtensionMsg("source", "abc"))

		error_func = function()
			env:loadNeighborhood{
				source = file("emas-pollin.gpm", "base"),
				name = 6,
				bidirect = true
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("name", "string", 6))

		error_func = function()
			env:loadNeighborhood{
				source = file("emas-pollin.gpm", "base"),
				name = "neigh1",
				bidirect = 13
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("bidirect", "boolean", 13))

		error_func = function()
			env:loadNeighborhood{
				source = file("emas-distance.gpm", "base"),
				name = "my_neighborhood"
			}
		end
		unitTest:assertError(error_func, "This function does not load neighborhoods between cells from the same CellularSpace. Use CellularSpace:loadNeighborhood() instead.")
	
		error_func = function()
			env:loadNeighborhood{
				source = "emas-distance-xxx.gpm",
				name = "my_neighborhood"
			}
		end
		unitTest:assertError(error_func, resourceNotFoundMsg("source", "emas-distance-xxx.gpm"))
		
		error_func = function()
			env:loadNeighborhood{
				source = "gpmlinesDbEmas_invalid.teste",
				name = "my_neighborhood"
			}
		end
		unitTest:assertError(error_func, invalidFileExtensionMsg("source", "teste"))

		local config = getConfig()
		local mdbType = config.dbType
		local mhost = config.host
		local muser = config.user
		local mpassword = config.password
		local mport = config.port

		local cs = CellularSpace{
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "River"
		}

		local cs2 = CellularSpace{
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "cells1000x1000"
		}

		local cs3 = CellularSpace{
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			database = mdatabase,
			theme = "Limit"
		}

		local env = Environment{cs, cs2, cs3}

		local countTest = 1

		-- .gpm Regular CS x Irregular CS - without weights
		local s = sessionInfo().separator
		local mfile = file("error"..s.."gpmAreaCellsPols-error.gpm", "base")

		error_func = function()
	   		env:loadNeighborhood{
				source = mfile,
				name = "my_neighborhood"..countTest
			}
		end
		unitTest:assertError(error_func, "The string 'bb' found as weight in the file '"..mfile.."' could not be converted to a number.")

		local mfile = file("error"..s.."gpmAreaCellsPols-error2.gpm", "base")

		error_func = function()
	   		env:loadNeighborhood{
				source = mfile,
				name = "my_neighborhood"..countTest
			}
		end
		if not _Gtme.isWindowsOS() then
			unitTest:assertError(error_func, "The string '' found as weight in the file '"..mfile.."' could not be converted to a number.") -- SKIP
		else
			unitTest:assert(true) -- SKIP
		end
	end
}

