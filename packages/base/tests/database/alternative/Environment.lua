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
	loadNeighborhood = function(unitTest)
		-- ###################### PROJECT #############################
		local terralib = getPackage("terralib")

		local projName = "environment_alt.tview"

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

		local cs = CellularSpace{
			project = proj,
			layer = clName1
		}

		if isFile(projName) then
			rmFile(projName)
		end
		
		tl:dropPgTable(pgData)			

		local cs2 = CellularSpace{xdim = 10}
		local cs = CellularSpace{xdim = 10}

		local env = Environment{cs, cs2}

		local error_func = function()
			env:loadNeighborhood{
				source = filePath("gpmAreaCellsPols.gpm", "base"),
			}
		end
		unitTest:assertError(error_func, "CellularSpaces with layers 'emas.shp' and 'Limit_pol.shp' were not found in the Environment.")

		local cs = CellularSpace{
			file = filePath("Limit_pol.shp")
		}

		local env = Environment{cs, cs2}

		local error_func = function()
			env:loadNeighborhood{
				source = filePath("gpmAreaCellsPols.gpm", "base"),
			}
		end
		unitTest:assertError(error_func, "CellularSpace with layer 'emas.shp' was not found in the Environment.")

		local env = Environment{cs2, cs}

		local error_func = function()
			env:loadNeighborhood{
				source = filePath("gpmAreaCellsPols.gpm", "base"),
			}
		end
		unitTest:assertError(error_func, "CellularSpace with layer 'emas.shp' was not found in the Environment.")

		local cs1 = CellularSpace{xdim = 10}
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

		local error_func = function()
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

		local error_func = function()
			env:loadNeighborhood{
				source = "teste1.abc",
				name = "neigh1",
				bidirect = true
			}
		end
		unitTest:assertError(error_func, invalidFileExtensionMsg("source", "abc"))

		local error_func = function()
			env:loadNeighborhood{
				source = filePath("emas-pollin.gpm", "base"),
				name = 6,
				bidirect = true
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("name", "string", 6))

		local error_func = function()
			env:loadNeighborhood{
				source = filePath("emas-pollin.gpm", "base"),		
				name = "neigh1",
				bidirect = 13
		}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("bidirect", "boolean", 13))

		local error_func = function()
			env:loadNeighborhood{
				source = filePath("emas-distance.gpm", "base"),
				name = "my_neighborhood"
		}
		end
		unitTest:assertError(error_func, "This function does not load neighborhoods between cells from the same CellularSpace. Use CellularSpace:loadNeighborhood() instead.")
		
		local error_func = function()
			env:loadNeighborhood{
				source = "emas-distance-xxx.gpm",
				name = "my_neighborhood"
			}
		end
		unitTest:assertError(error_func, resourceNotFoundMsg("source", "emas-distance-xxx.gpm"))

		local error_func = function()
			env:loadNeighborhood{
				source = "gpmlinesDbEmas_invalid.teste",
				name = "my_neighborhood"
			}
		end
		unitTest:assertError(error_func, invalidFileExtensionMsg("source", "teste"))

		local cs = CellularSpace{
			file = filePath("emas.shp")
		}

		local cs2 = CellularSpace{
			file = filePath("Limit_pol.shp")
		}

		local env = Environment{cs, cs2}

		local countTest = 1

		-- .gpm Regular CS x Irregular CS - without weights
		local s = sessionInfo().separator
		local mfile = filePath("error"..s.."gpmAreaCellsPols-error.gpm", "base")

		error_func = function()
	   		env:loadNeighborhood{
				source = mfile,
				name = "my_neighborhood"..countTest
			}
		end
		unitTest:assertError(error_func, "The string 'bb' found as weight in the file '"..mfile.."' could not be converted to a number.")

		local mfile = filePath("error"..s.."gpmAreaCellsPols-error2.gpm", "base")

		error_func = function()
	   		env:loadNeighborhood{
				source = mfile,
				name = "my_neighborhood"..countTest
			}
		end

		unitTest:assertError(error_func, "Could not read the file properly. It seems that it is corrupted.")

		local mfile = filePath("error"..s.."gpmAreaCellsPols-error3.gpm", "base")

		error_func = function()
	   		env:loadNeighborhood{
				source = mfile,
				name = "my_neighborhood"..countTest
			}
		end

		unitTest:assertError(error_func, "The string 'abc' found as weight in the file '"..mfile.."' could not be converted to a number.")
	end
}

