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
			pgm = true,
			nc = true,
			geojson = true,
			shp = true,
			virtual = true,
			tif = true,
			proj = true,
			directory = true
		}

		unitTest:assertError(error_func, switchInvalidArgumentMsg("post", "source", options))

		error_func = function()
			cs = CellularSpace{
				file = filePath("test/simple-cs.csv", "base"),
				source = "pgm",
				sep = ";"
			}
		end

		unitTest:assertError(error_func, "source and file extension should be the same.")

		local pgmFile = filePath("test/error/pgm-invalid-identifier.pgm", "base")
		error_func = function()
			cs = CellularSpace{
				file = pgmFile
			}
		end

		unitTest:assertError(error_func, "File '"..pgmFile.."' does not contain the PGM identifier 'P2' in its first line.")

		error_func = function()
			cs = CellularSpace{file = 2, source = "pgm", sep = ";"}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("file", "File", 2))

		error_func = function()
			cs = CellularSpace{file = "abc123.pgm", sep = ";"}
		end

		unitTest:assertError(error_func, resourceNotFoundMsg("file", File("abc123.pgm")))

		error_func = function()
			cs = CellularSpace{
				file = "abc123.shp"
			}
		end

		unitTest:assertError(error_func, resourceNotFoundMsg("file", File("abc123.shp")))

		os.execute("touch abc123.shp")

		error_func = function()
			cs = CellularSpace{
				file = "abc123.shp"
			}
		end

		unitTest:assertError(error_func, "File '"..File("abc123.dbf").."' was not found.")

		File("abc123.shp"):delete()

		error_func = function()
			cs = CellularSpace{
				file = "abc123.shp",
				xdim = 10
			}
		end

		unitTest:assertError(error_func, "More than one candidate to argument 'source': 'shp', 'virtual'.")

		error_func = function()
			CellularSpace{
				file = filePath("cabecadeboi.shp"),
				xy = {"Col", "Lin"},
				as = 2
			}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("as", "table", 2))

		error_func = function()
			CellularSpace{
				file = filePath("cabecadeboi.shp"),
				xy = {"Col", "Lin"},
				as = {x = 2}
			}
		end

		unitTest:assertError(error_func, "All values of 'as' should be 'string', got 'number'.")

		error_func = function()
			CellularSpace{
				file = filePath("cabecadeboi.shp"),
				xy = {"Col", "Lin"},
				as = {"height_"}
			}
		end

		unitTest:assertError(error_func, "All indexes of 'as' should be 'string', got 'number'.")

		error_func = function()
			CellularSpace{
				file = filePath("test/cabecadeboi900.shp"),
				xy = {"Col", "Lin"},
				as = {x = "height_2"}
			}
		end

		unitTest:assertError(error_func, "Cannot rename 'height_2' to 'x' as it already exists.")

		error_func = function()
			CellularSpace{
				file = filePath("test/cabecadeboi900.shp"),
				xy = {"Col", "Lin"},
				as = {
					height = "height_2"
				}
			}
		end

		unitTest:assertError(error_func, "Cannot rename attribute 'height_2' as it does not exist.")

		local missingShpError = function()
			CellularSpace{
				file = filePath("test/CellsAmaz.shp")
			}
		end

		unitTest:assertError(missingShpError, "Data has a missing value in attribute 'pointcount'. Use argument 'missing' to set its value.")

		local missingNotNumber = function()
			CellularSpace{
				file = filePath("test/CellsAmaz.shp"),
				missing = "null"
			}
		end

		unitTest:assertError(missingNotNumber, incompatibleTypeMsg("missing", "number", "null"))

		local gis = getPackage("gis")

		local usingProject = function()
			local file = File("cellspace_alt.tview")
			local author = "Avancini"
			local title = "Cellular Space"

			local proj = gis.Project{
				file = tostring(file),
				clean = true,
				author = author,
				title = title
			}

			local missLayerName = "CellsAmaz"
			gis.Layer{
				project = proj,
				name = missLayerName,
				file = filePath("test/CellsAmaz.shp")
			}

			local missingLayerError = function()
				CellularSpace{
					project = proj,
					layer = missLayerName
				}
			end

			unitTest:assertError(missingLayerError, "Data has a missing value in attribute 'pointcount'. Use argument 'missing' to set its value.")

			file:deleteIfExists()
		end

		unitTest:assert(usingProject)

		local loadTifDirectory = function()
			local dir = Directory("csdir")

			if dir:exists() then
				dir:delete()
			end

			dir:create()

			local emptyDirectory = function()
				CellularSpace{
					directory = dir
				}
			end

			unitTest:assertError(emptyDirectory, "Directory 'csdir' is empty.")

			local proj = gis.Project{
				file = "cellspace_alt.tview",
				clean = true,
				author = "Avancini"
			}

			local layer0 =  gis.Layer{
				project = proj,
				name = "Shp",
				epsg = 5880,
				file = filePath("cabecadeboi.shp", "gis")
			}

			local toData0 = {file = File(tostring(dir).."/cabecadeboi.shp"), overwrite = true, progress = false}
			layer0:export(toData0)

			local noTifFound = function()
				CellularSpace{
					directory = dir
				}
			end

			unitTest:assertError(noTifFound, "There is no tif file in directory 'csdir/'.")

			local layer1 = gis.Layer{
				project = proj,
				name = "Tif1",
				epsg = 5880,
				file = filePath("cabecadeboi-elevation.tif", "gis")
			}

			local toData1 = {file = File(tostring(dir).."/elevation1.tif"), overwrite = true, progress = false}
			layer1:export(toData1)

			local oneTifFound = function()
				CellularSpace{
					directory = dir
				}
			end

			unitTest:assertError(oneTifFound, "There is just one tif file on directory 'csdir/'. Please use argument file or layer instead of directory.")

			local layer2 = gis.Layer{
				project = proj,
				name = "Tif2",
				epsg = 5880,
				file = filePath("emas-accumulation.tif", "gis")
			}

			local toData2 = {file = File(tostring(dir).."/elevation2.tif"), overwrite = true, progress = false}
			layer2:export(toData2)

			local difSizeError = function()
				CellularSpace{
					directory = dir
				}
			end

			unitTest:assertError(difSizeError, "Tif files 'elevation1.tif' and 'elevation2.tif' have different sizes: 100x100 and 2323x2853.")

			dir:delete()
			proj.file:delete()
		end

		unitTest:assert(loadTifDirectory)
	end,
	loadNeighborhood = function(unitTest)
		local cs = CellularSpace{
			xdim = 2
		}

		local error_func = function()
			cs:loadNeighborhood()
		end

		unitTest:assertError(error_func, tableArgumentMsg())

		error_func = function()
			cs:loadNeighborhood{}
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg("file"))

		error_func = function()
			cs:loadNeighborhood{file = 123}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("file", "File", 123))

		error_func = function()
			cs:loadNeighborhood{file = "neighCabecaDeBoi900x900.gpm"}
		end

		unitTest:assertError(error_func, resourceNotFoundMsg("file", File("neighCabecaDeBoi900x900.gpm")))

		local mfile = filePath("cabecadeboi-neigh.gpm", "base")

		error_func = function()
			cs:loadNeighborhood{file = mfile, name = 22}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("name", "string", 22))


		-- GAL from shapefile
		cs = CellularSpace{
			file = filePath("brazilstates.shp")
		}

		mfile = filePath("test/brazil.gal")

		error_func = function()
			cs:loadNeighborhood{file = mfile}
		end

		unitTest:assertError(error_func, "Neighborhood file '"..mfile.."' was not built for this CellularSpace. CellularSpace layer: 'brazilstates.shp', GAL file layer: 'mylayer'.")

		local cs2 = CellularSpace{xdim = 10}

		error_func = function()
			cs2:loadNeighborhood{file = "arquivo.gpm"}
		end

		unitTest:assertError(error_func, resourceNotFoundMsg("file", File("arquivo.gpm")))

		error_func = function()
			cs2:loadNeighborhood{file = "gpmlinesDbEmas_invalid"}
		end

		unitTest:assertError(error_func, "Argument 'file' does not have an extension.")

		error_func = function()
			cs2:loadNeighborhood{file = "gpmlinesDbEmas_invalid.teste"}
		end

		unitTest:assertError(error_func, invalidFileExtensionMsg("file", "teste"))

		error_func = function()
			local s = sessionInfo().separator
			cs:loadNeighborhood{
				file = filePath("test/error"..s.."cabecadeboi-invalid-neigh.gpm", "base"),
				check = false
			}
		end

		unitTest:assertError(error_func, "This function cannot load neighborhood between two layers. Use 'Environment:loadNeighborhood()' instead.")

		mfile = filePath("cabecadeboi-neigh.gpm", "base")

		error_func = function()
			cs2:loadNeighborhood{
				file = mfile,
				name = "my_neighborhood"
			}
		end

		unitTest:assertError(error_func, "Neighborhood file '"..mfile.."' was not built for this CellularSpace. CellularSpace layer: '', GPM file layer: 'cabecadeboi900.shp'.")

		mfile = filePath("test/cabecadeboi-neigh.gal", "base")

		error_func = function()
			cs2:loadNeighborhood{
				file = mfile,
				name = "my_neighborhood"
			}
		end

		unitTest:assertError(error_func, "Neighborhood file '"..mfile.."' was not built for this CellularSpace. CellularSpace layer: '', GAL file layer: 'cabecadeboi900.shp'.")

		mfile = filePath("test/cabecadeboi-neigh.gwt", "base")

		error_func = function()
			cs2:loadNeighborhood{
				file = mfile,
				name = "my_neighborhood"
			}
		end

		unitTest:assertError(error_func, "Neighborhood file '"..mfile.."' was not built for this CellularSpace. CellularSpace layer: '', GWT file layer: 'cabecadeboi900.shp'.")

		local s = sessionInfo().separator
		mfile = filePath("test/error"..s.."cabecadeboi-neigh-header-invalid.gpm", "base")

		error_func = function()
			cs:loadNeighborhood{file = mfile}
		end

		unitTest:assertError(error_func, "Could not read file '"..mfile.."': invalid header.")

		local cs3 = CellularSpace{
			file = filePath("test/cabecadeboi900.shp", "base"),
			xy = {"Col", "Lin"},
		}

		error_func = function()
			cs3:loadNeighborhood{file = filePath("test/error"..s.."cabecadeboi-neigh-line-invalid1.gal", "base")}
		end


		unitTest:assertError(error_func, "Could not find id '' in line 2. It seems that it is corrupted.")

		error_func = function()
			cs3:loadNeighborhood{file = filePath("test/error"..s.."cabecadeboi-neigh-line-invalid2.gal", "base")}
		end


		unitTest:assertError(error_func, "Could not find id 'nil' in line 3. It seems that it is corrupted.")

		error_func = function()
			cs3:loadNeighborhood{file = filePath("test/error"..s.."cabecadeboi-neigh-line-invalid1.gpm", "base")}
		end


		unitTest:assertError(error_func, "Could not find id 'nil' in line 2. It seems that it is corrupted.")

		error_func = function()
			cs3:loadNeighborhood{file = filePath("test/error"..s.."cabecadeboi-neigh-line-invalid2.gpm", "base")}
		end


		unitTest:assertError(error_func, "Could not find id 'nil' in line 3. It seems that it is corrupted.")

		error_func = function()
			cs3:loadNeighborhood{file = filePath("test/error"..s.."cabecadeboi-neigh-line-invalid1.gwt", "base")}
		end


		unitTest:assertError(error_func, "Could not find id 'nil' in line 2. It seems that it is corrupted.")

		error_func = function()
			cs3:loadNeighborhood{file = filePath("test/error"..s.."cabecadeboi-neigh-line-invalid2.gwt", "base")}
		end


		unitTest:assertError(error_func, "Could not find id '' in line 2. It seems that it is corrupted.")

		error_func = function()
			cs3:loadNeighborhood{file = filePath("test/error"..s.."cabecadeboi-neigh-line-invalid3.gwt", "base")}
		end


		unitTest:assertError(error_func, "Could not find id 'nil' in line 2. It seems that it is corrupted.")
	end,
	save = function(unitTest)
		local gis = getPackage("gis")

		local usingProject = function()
			local projName = File("cellspace_save_alt.tview")

			local author = "Avancini"
			local title = "Cellular Space"

			projName:deleteIfExists()

			local proj = gis.Project{
				file = projName:name(true),
				clean = true,
				author = author,
				title = title
			}

			local layerName1 = "Sampa"
			gis.Layer{
				project = proj,
				name = layerName1,
				file = filePath("test/sampa.shp", "gis")
			}

			local clName1 = "Sampa_Cells_DB"
			local tName1 = "sampa_cells"
			local password = getConfig().password
			local database = "postgis_22_sample"

			local layer1 = gis.Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				clean = true,
				name = clName1,
				resolution = 0.3,
				password = password,
				database = database,
				table = tName1,
				progress = false
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

			-- unitTest:assertFile(projName) -- SKIP #TODO(#1242)

			projName:deleteIfExists()
			layer1:delete()
		end

		unitTest:assert(usingProject)

		local saveTifDirectory = function()
			local dir = Directory("csdir")

			if dir:exists() then
				dir:delete()
			end

			dir:create()

			local proj = gis.Project{
				file = "cellspace_basic.tview",
				clean = true,
				author = "Avancini"
			}

			local layer = gis.Layer{
				project = proj,
				name = "Tif",
				epsg = 5880,
				file = filePath("cabecadeboi-elevation.tif", "gis")
			}

			local toData1 = {file = File(tostring(dir).."/elevation1.tif"), overwrite = true, progress = false}
			local toData2 = {file = File(tostring(dir).."/elevation2.tif"), overwrite = true, progress = false}
			layer:export(toData1)
			layer:export(toData2)

			local cs = CellularSpace{
				directory = dir
			}

			forEachCell(cs, function(cell)
				cell.elevation3 = cell.elevation1 + cell.elevation2
			end)

			local outFile = File(tostring(dir).."/elevation3.tif"):deleteIfExists()

			local saveMoreAttrError = function()
				cs:save(outFile, {"elevation3", "elevation1"})
			end

			unitTest:assertError(saveMoreAttrError, "It is only possible to save one attribute in each call to save() when working with tif files.")

			dir:delete()
			proj.file:delete()
		end

		unitTest:assert(saveTifDirectory)
	end
}

