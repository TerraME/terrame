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

return {
	Layer = function(unitTest)
		if _Gtme.sessionInfo().system == "windows" then
			local projName = "nc_basic.tview"

			local proj = Project {
				file = projName,
				clean = true
			}

			local customWarningBkp = customWarning
			customWarning = function(msg)
				return msg
			end

			local layerName1 = "Vegtype_layer"

			Layer {
				project = proj,
				name = layerName1,
				file = filePath("test/vegtype_2000.nc", "terralib")
			}

			local filePath1 = "vegtype_cells_nc_basic.shp"

			File(filePath1):deleteIfExists()

			local clName1 = "Vegtype_Cells"

			local cl1 = Layer {
				project = proj,
				source = "shp",
				input = layerName1,
				name = clName1,
				resolution = 60e3,
				file = filePath1
			}

			unitTest:assertEquals(clName1, cl1.name) -- SKIP
			unitTest:assertEquals(cl1.source, "shp") -- SKIP
			unitTest:assertEquals(cl1.file, currentDir()..filePath1) -- SKIP

			File(filePath1):deleteIfExists()
			File(projName):deleteIfExists()

			customWarning = customWarningBkp
		else
			unitTest:assert(true) -- SKIP
		end
	end,
	representation = function(unitTest)
		if _Gtme.sessionInfo().system == "windows" then
			local projName = "cellular_layer_fill_nc_repr.tview"

			local proj = Project {
				file = projName,
				clean = true
			}

			local customWarningBkp = customWarning
			customWarning = function(msg)
				return msg
			end

			local vegType = "Vegtype_layer"
			local l = Layer {
				project = proj,
				name = vegType,
				file = filePath("test/vegtype_2000.nc", "terralib")
			}

			unitTest:assertEquals(l:representation(), "raster") -- SKIP

			File(projName):deleteIfExists()

			customWarning = customWarningBkp
		else
			unitTest:assert(true) -- SKIP
		end
	end,
	bands = function(unitTest)
		if _Gtme.sessionInfo().system == "windows" then
			local projName = "cellular_layer_fill_nc_repr.tview"

			local proj = Project {
				file = projName,
				clean = true
			}

			local customWarningBkp = customWarning
			customWarning = function(msg)
				return msg
			end

			local vegType = "Vegtype_layer"
			local l = Layer {
				project = proj,
				name = vegType,
				file = filePath("test/vegtype_2000.nc", "terralib")
			}

			unitTest:assertEquals(l:bands(), 1) -- SKIP

			File(projName):deleteIfExists()

			customWarning = customWarningBkp
		else
			unitTest:assert(true) -- SKIP
		end
	end,
	__tostring = function(unitTest)
		if _Gtme.sessionInfo().system == "windows" then
			local projName = "cellular_layer_print_nc.tview"

			local proj = Project {
				file = projName,
				clean = true
			}

			local customWarningBkp = customWarning
			customWarning = function(msg)
				return msg
			end

			local layerName1 = "Vegtype_layer"

			local l = Layer {
				project = proj,
				name = layerName1,
				file = filePath("test/vegtype_2000.nc", "terralib")
			}

			unitTest:assertEquals( -- SKIP
tostring(l), [[epsg     number [0.0]
file     string [vegtype_2000.nc]
name     string [Vegtype_layer]
project  Project
rep      string [raster]
source   string [nc]
]], 0, true)

			File(projName):deleteIfExists()

			customWarning = customWarningBkp
		else
			unitTest:assert(true) -- SKIP
		end
	end
}

