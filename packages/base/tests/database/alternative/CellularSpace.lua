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
	CellularSpace = function(unitTest)	
		local error_func = function()
			cs = CellularSpace{
				source = "post",
				layer = "layer"
			}
		end
	
		local options = {
			asc = true,
 			csv = true,
 			map = true,
			nc = true,
			geojson = true,
 			shp = true,
 			virtual = true,
			tif = true,
			proj = true
 		}
 
		unitTest:assertError(error_func, switchInvalidArgumentMsg("post", "source", options))

 		error_func = function()
 			cs = CellularSpace{
				file = filePath("test/simple-cs.csv", "base"), 
				source = "map", 
				sep = ";"
			}
 		end
 		unitTest:assertError(error_func, "source and file extension should be the same.")
 
 		error_func = function()
 			cs = CellularSpace{file = 2, source = "map", sep = ";"}
 		end
 		unitTest:assertError(error_func, incompatibleTypeMsg("file", "string", 2))
 
 		error_func = function()
 			cs = CellularSpace{file = "abc123.map", sep = ";"}
 		end
		unitTest:assertError(error_func, resourceNotFoundMsg("file", "abc123.map"))
		
		error_func = function()
 			cs = CellularSpace{
 				file = "abc123.shp"
 			}
 		end
		unitTest:assertError(error_func, resourceNotFoundMsg("file", "abc123.shp"))

		os.execute("touch abc123.shp")
			
		error_func = function()
 			cs = CellularSpace{
 				file = "abc123.shp"
 			}
 		end
		unitTest:assertError(error_func, "File 'abc123.dbf' was not found.")

		rmFile("abc123.shp")

		error_func = function()
 			cs = CellularSpace{
 				file = "abc123.shp",
				xdim = 10
 			}
 		end
		unitTest:assertError(error_func, "More than one candidate to argument 'source': 'shp', 'virtual'.")
	end,
	loadNeighborhood = function(unitTest)
		local terralib = getPackage("terralib")

		local projName = "cellspace_neigh_alt.tview"

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

		local cs = CellularSpace{
			project = proj,
			layer = clName1
		}
		
		local error_func = function()
			cs:loadNeighborhood()
		end
		unitTest:assertError(error_func, tableArgumentMsg())
		
		error_func = function()
			cs:loadNeighborhood{}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("source"))		
		
		error_func = function()
			cs:loadNeighborhood{source = 123}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("source", "string", 123))

		error_func = function()
			cs:loadNeighborhood{source = "neighCabecaDeBoi900x900.gpm"}
		end
		unitTest:assertError(error_func, resourceNotFoundMsg("source", "neighCabecaDeBoi900x900.gpm"))

		local mfile = filePath("cabecadeboi-neigh.gpm", "base")
	
		error_func = function()
			cs:loadNeighborhood{source = mfile, name = 22}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("name", "string", 22))

		-- unitTest:assertFile(projName) -- SKIP #1301
		rmFile(projName) -- #1301
		tl:dropPgTable(pgData)			
		
		-- GAL from shapefile
		cs = CellularSpace{
			file = filePath("brazilstates.shp", "base")
		}		
		
		error_func = function()	
			cs:loadNeighborhood{source = filePath("test/brazil.gal", "base"), che = false}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("che"))		
		
		mfile = filePath("test/brazil.gal", "base")

		error_func = function()
			cs:loadNeighborhood{source = mfile}
		end
		unitTest:assertError(error_func, "Neighborhood file '"..mfile.."' was not built for this CellularSpace. CellularSpace layer: 'brazilstates.shp', GAL file layer: 'mylayer'.")	

		local cs2 = CellularSpace{xdim = 10}

		error_func = function()
			cs2:loadNeighborhood{source = "arquivo.gpm"}
		end
		unitTest:assertError(error_func, resourceNotFoundMsg("source", "arquivo.gpm"))

		error_func = function()
			cs2:loadNeighborhood{source = "gpmlinesDbEmas_invalid"}
		end
		unitTest:assertError(error_func, "Argument 'source' does not have an extension.")

		error_func = function()
			cs2:loadNeighborhood{source = "gpmlinesDbEmas_invalid.teste"}
		end
		unitTest:assertError(error_func, invalidFileExtensionMsg("source", "teste"))	

		error_func = function()
			local s = sessionInfo().separator
			cs:loadNeighborhood{
				source = filePath("test/error"..s.."cabecadeboi-invalid-neigh.gpm", "base"),
				check = false
			}
		end
		unitTest:assertError(error_func, "This function cannot load neighborhood between two layers. Use 'Environment:loadNeighborhood()' instead.")

		mfile = filePath("cabecadeboi-neigh.gpm", "base")

		error_func = function()
			cs2:loadNeighborhood{
				source = mfile,
				name = "my_neighborhood"
			}
		end
		unitTest:assertError(error_func, "Neighborhood file '"..mfile.."' was not built for this CellularSpace. CellularSpace layer: '', GPM file layer: 'cabecadeboi900.shp'.")

		mfile = filePath("test/cabecadeboi-neigh.gal", "base")

		error_func = function()
			cs2:loadNeighborhood{
				source = mfile,
				name = "my_neighborhood"
			}
		end
		unitTest:assertError(error_func, "Neighborhood file '"..mfile.."' was not built for this CellularSpace. CellularSpace layer: '', GAL file layer: 'cabecadeboi900.shp'.")

		mfile = filePath("test/cabecadeboi-neigh.gwt", "base")

		error_func = function()
			cs2:loadNeighborhood{
				source = mfile,
				name = "my_neighborhood"
			}
		end
		unitTest:assertError(error_func, "Neighborhood file '"..mfile.."' was not built for this CellularSpace. CellularSpace layer: '', GWT file layer: 'cabecadeboi900.shp'.")		
		
		local s = sessionInfo().separator
		mfile = filePath("test/error"..s.."cabecadeboi-neigh-header-invalid.gpm", "base")

		error_func = function()
			cs:loadNeighborhood{source = mfile}
		end
		unitTest:assertError(error_func, "Could not read file '"..mfile.."': invalid header.")

		local cs3 = CellularSpace{
			file = filePath("cabecadeboi900.shp", "base")	
		}

		error_func = function()
			cs3:loadNeighborhood{source = filePath("test/error"..s.."cabecadeboi-neigh-line-invalid1.gal", "base")}
		end

		unitTest:assertError(error_func, "Could not find id '' in line 2. It seems that it is corrupted.")

		error_func = function()
			cs3:loadNeighborhood{source = filePath("test/error"..s.."cabecadeboi-neigh-line-invalid2.gal", "base")}
		end

		unitTest:assertError(error_func, "Could not find id 'nil' in line 3. It seems that it is corrupted.")

		error_func = function()
			cs3:loadNeighborhood{source = filePath("test/error"..s.."cabecadeboi-neigh-line-invalid1.gpm", "base")}
		end

		unitTest:assertError(error_func, "Could not find id 'nil' in line 2. It seems that it is corrupted.")

		error_func = function()
			cs3:loadNeighborhood{source = filePath("test/error"..s.."cabecadeboi-neigh-line-invalid2.gpm", "base")}
		end

		unitTest:assertError(error_func, "Could not find id 'nil' in line 3. It seems that it is corrupted.")

		error_func = function()
			cs3:loadNeighborhood{source = filePath("test/error"..s.."cabecadeboi-neigh-line-invalid1.gwt", "base")}
		end

		unitTest:assertError(error_func, "Could not find id 'nil' in line 2. It seems that it is corrupted.")

		error_func = function()
			cs3:loadNeighborhood{source = filePath("test/error"..s.."cabecadeboi-neigh-line-invalid2.gwt", "base")}
		end

		unitTest:assertError(error_func, "Could not find id '' in line 2. It seems that it is corrupted.")

		error_func = function()
			cs3:loadNeighborhood{source = filePath("test/error"..s.."cabecadeboi-neigh-line-invalid3.gwt", "base")}
		end

		unitTest:assertError(error_func, "Could not find id 'nil' in line 2. It seems that it is corrupted.")
	end,
	save = function(unitTest)
		local terralib = getPackage("terralib")

		local projName = "cellspace_save_alt.tview"

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
		
		-- unitTest:assertFile(projName) -- SKIP #1301
		rmFile(projName) -- #1301
		tl:dropPgTable(pgData)	
	end
}

