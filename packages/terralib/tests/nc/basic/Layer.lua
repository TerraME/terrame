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

return {
	Layer = function(unitTest)
		local projName = "nc_basic.tview"


		if isFile(projName) then
			rmFile(projName)
		end

		local proj = Project {
			file = projName,
			clean = true
		}

		local layerName1 = "Vegtype_layer"

		Layer {
			project = proj,
			name = layerName1,
			file = filePath("vegtype_2000.nc", "terralib")
		}

		local filePath1 = "vegtype_cells_nc_basic.shp"

		if isFile(filePath1) then
			rmFile(filePath1)
		end

		local clName1 = "Vegtype_Cells"

		local cl1 = Layer {
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName1,
			resolution = 60e3,
			file = filePath1
		}

		unitTest:assertEquals(clName1, cl1.name)
		unitTest:assertEquals(cl1.source, "shp")
		unitTest:assertEquals(cl1.file, _Gtme.makePathCompatibleToAllOS(currentDir() .. "/" .. filePath1))

		if isFile(filePath1) then
			rmFile(filePath1)
		end

		if isFile(projName) then
			rmFile(projName)
		end
	end,
	representation = function(unitTest)
		local projName = "cellular_layer_fill_nc_repr.tview"

		if isFile(projName) then
			rmFile(projName)
		end

		local proj = Project {
			file = projName,
			clean = true
		}

		local vegType = "Vegtype_layer"
		local l = Layer {
			project = proj,
			name = vegType,
			file = filePath("vegtype_2000.nc", "terralib")
		}

		unitTest:assertEquals(l:representation(), "raster")

		if isFile(projName) then
			rmFile(projName)
		end
	end,
	bands = function(unitTest)
		local projName = "cellular_layer_fill_nc_repr.tview"

		if isFile(projName) then
			rmFile(projName)
		end

		local proj = Project {
			file = projName,
			clean = true
		}

		local vegType = "Vegtype_layer"
		local l = Layer {
			project = proj,
			name = vegType,
			file = filePath("vegtype_2000.nc", "terralib")
		}

		unitTest:assertEquals(l:bands(), 1)

		if isFile(projName) then
			rmFile(projName)
		end
	end,
	__tostring = function(unitTest)
		local projName = "cellular_layer_print_nc.tview"

		if isFile(projName) then
			rmFile(projName)
		end

		local proj = Project {
			file = projName,
			clean = true
		}

		local layerName1 = "Vegtype_layer"

		local l = Layer {
			project = proj,
			name = layerName1,
			file = filePath("vegtype_2000.nc", "terralib")
		}

		unitTest:assertEquals(tostring(l), [[file     string [C:\TerraME\bin\packages\terralib\data\vegtype_2000.nc]
name     string [Vegtype_layer]
project  Project
rep      string [raster]
sid      string [14825bac-96e7-418d-a340-f97f49ac3ed1]
source   string [nc]
]], 33)
		unitTest:assertFile(projName)

		if isFile(projName) then
			rmFile(projName)
		end
	end
}

