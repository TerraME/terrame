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
		local terralib = getPackage("terralib")

		local projName = "environment_alt.tview"

		if isFile(projName) then
			rmFile(projName)
		end

		local author = "Avancini"
		local title = "Cellular Space"

		local proj = terralib.Project{
			file = projName,
			clean = true,
			author = author,
			title = title
		}

		local layerName1 = "Sampa"
		terralib.Layer{
			project = proj,
			name = layerName1,
			file = filePath("test/sampa.shp", "terralib")
		}

		local clName1 = "Sampa_Cells_DB"
		local tName1 = "sampa_cells"
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = getConfig().password
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

		terralib.Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			name = clName1,
			resolution = 0.3,
			user = user,
			password = password,
			database = database,
			table = tName1
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
				source = filePath("test/gpmAreaCellsPols.gpm", "base"),
			}
		end
		unitTest:assertError(error_func, "CellularSpaces with layers 'emas.shp' and 'Limit_pol.shp' were not found in the Environment.")

		cs = CellularSpace{
			file = filePath("test/Limit_pol.shp")
		}

		env = Environment{cs, cs2}

		error_func = function()
			env:loadNeighborhood{
				source = filePath("test/gpmAreaCellsPols.gpm", "base"),
			}
		end
		unitTest:assertError(error_func, "CellularSpace with layer 'emas.shp' was not found in the Environment.")

		cs = CellularSpace{
			file = filePath("emas.shp")
		}

		env = Environment{cs, cs2}

		error_func = function()
			env:loadNeighborhood{
				source = filePath("test/gpmAreaCellsPols.gpm", "base"),
			}
		end
		unitTest:assertError(error_func, "CellularSpace with layer 'Limit_pol.shp' was not found in the Environment.")

		local cs1 = CellularSpace{xdim = 10}
		cs2 = CellularSpace{xdim = 10}

		env = Environment{cs1, cs2}

		cs1:createNeighborhood{}

		error_func = function()
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
				source = filePath("test/emas-pollin.gpm", "base"),
				name = 6,
				bidirect = true
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("name", "string", 6))

		error_func = function()
			env:loadNeighborhood{
				source = filePath("test/emas-pollin.gpm", "base"),		
				name = "neigh1",
				bidirect = 13
		}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("bidirect", "boolean", 13))

		error_func = function()
			env:loadNeighborhood{
				source = filePath("test/emas-distance.gpm", "base"),
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

		cs = CellularSpace{
			file = filePath("emas.shp")
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
				source = mfile,
				name = "my_neighborhood"..countTest
			}
		end
		unitTest:assertError(error_func, "The string 'bb' found as weight in the file '"..mfile.."' could not be converted to a number.")

		mfile = filePath("test/error"..s.."gpmAreaCellsPols-error2.gpm", "base")

		error_func = function()
	   		env:loadNeighborhood{
				source = mfile,
				name = "my_neighborhood"..countTest
			}
		end

		unitTest:assertError(error_func, "Could not read the file properly. It seems that it is corrupted.")

		mfile = filePath("test/error"..s.."gpmAreaCellsPols-error3.gpm", "base")

		error_func = function()
	   		env:loadNeighborhood{
				source = mfile,
				name = "my_neighborhood"..countTest
			}
		end

		unitTest:assertError(error_func, "The string 'abc' found as weight in the file '"..mfile.."' could not be converted to a number.")
	end
}

