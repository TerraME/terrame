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
		local projName = "tif_basic.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local layerName1 = "Prodes"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath("amazonia-prodes.tif", "terralib")
		}

		local filePath1 = "prodes_cells_tif_basic.shp"

		File(filePath1):deleteIfExists()

		local clName1 = "Prodes_Cells"

		local cl1 = Layer{
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName1,
			resolution = 60e3,
			file = filePath1
		}

		unitTest:assertEquals(clName1, cl1.name)
		unitTest:assertEquals(cl1.source, "shp")
		unitTest:assertEquals(cl1.file, currentDir()..filePath1)

		File(filePath1):deleteIfExists()
		File(projName):deleteIfExists()
	end,
	__len = function(unitTest)
		local projName = "layer_tiff_basic.tview"

		local customWarningBkp = customWarning
		customWarning = function(msg)
			return msg
		end

		local proj = Project{
			file = projName,
			prodes = filePath("test/prodes_polyc_10k.tif", "terralib"),
			clean = true
		}

		customWarning = customWarningBkp

		unitTest:assertEquals(#proj.prodes, 20020)

		proj.file:delete()
	end,
	fill = function(unitTest)
		local projName = "layer_fill_tif.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local customWarningBkp = customWarning
		customWarning = function(msg)
			return msg
		end

		local layerName1 = "limiteitaituba"
		local l1 = Layer{
			project = proj,
			name = layerName1,
			file = filePath("itaituba-census.shp", "terralib")
		}

		local prodes = "prodes"
		Layer{
			project = proj,
			name = prodes,
			file = filePath("itaituba-deforestation.tif", "terralib"),
			epsg = l1.epsg
		}

		local altimetria = "altimetria"
		Layer{
			project = proj,
			name = altimetria,
			file = filePath("itaituba-elevation.tif", "terralib"),
			epsg = l1.epsg
		}

		local clName1 = "CellsTif"

		local shapes = {}

		local shp1 = clName1..".shp"
		File(shp1):deleteIfExists()
		table.insert(shapes, shp1)

		local cl = Layer{
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName1,
			resolution = 10000,
			file = clName1..".shp"
		}

		-- MODE

		cl:fill{
			operation = "mode",
			attribute = "prod_mode",
			layer = prodes
		}

		local cs = CellularSpace{
			project = proj,
			layer = cl.name
		}

		local count = 0
		forEachCell(cs, function(cell)
			unitTest:assertType(cell.prod_mode, "string")
			if not belong(cell.prod_mode, {"7", "87", "167", "255"}) then
				print(cell.prod_mode)
				count = count + 1
			end
		end)

		unitTest:assertEquals(count, 0)

		local map = Map{
			target = cs,
			select = "prod_mode",
			value = {"7", "87", "167", "255"},
			color = {"red", "green", "blue", "orange"}
		}

		unitTest:assertSnapshot(map, "tiff-mode.png")

		-- MINIMUM

		cl:fill{
			operation = "minimum",
			attribute = "prod_min",
			layer = altimetria
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
		}

		forEachCell(cs, function(cell)
			unitTest:assertType(cell.prod_min, "number")
			unitTest:assert(cell.prod_min >= 0)
			unitTest:assert(cell.prod_min <= 185)
		end)

		map = Map{
			target = cs,
			select = "prod_min",
			min = 0,
			max = 255,
			color = "RdPu",
			slices = 10
		}

		unitTest:assertSnapshot(map, "tiff-min.png")

		-- MAXIMUM

		cl:fill{
			operation = "maximum",
			attribute = "prod_max",
			layer = altimetria
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
		}

		forEachCell(cs, function(cell)
			unitTest:assertType(cell.prod_max, "number")
			unitTest:assert(cell.prod_max >= 7)
			unitTest:assert(cell.prod_max <= 255)
		end)

		map = Map{
			target = cs,
			select = "prod_max",
			min = 0,
			max = 255,
			color = "RdPu",
			slices = 10
		}

		unitTest:assertSnapshot(map, "tiff-max.png")

		-- SUM

		cl:fill{
			operation = "sum",
			attribute = "prod_sum",
			layer = altimetria
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
		}

		forEachCell(cs, function(cell)
			unitTest:assertType(cell.prod_sum, "number")
			unitTest:assert(cell.prod_sum >= 0)
		end)

		map = Map{
			target = cs,
			select = "prod_sum",
			min = 0,
			max = 24000,
			color = "RdPu",
			slices = 10
		}

		unitTest:assertSnapshot(map, "tiff-sum.png")

		-- COVERAGE

		cl:fill{
			operation = "coverage",
			attribute = "cov",
			layer = prodes
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
		}

		local cov = {7, 87, 167, 255}

		forEachCell(cs, function(cell)
			local sum = 0

			for i = 1, #cov do
				unitTest:assertType(cell["cov_"..cov[i]], "number")
				sum = sum + cell["cov_"..cov[i]]
			end

			--unitTest:assert(math.abs(sum - 100) < 0.001) -- SKIP

			--if math.abs(sum - 100) > 0.001 then
			--	print(sum)
			--end
		end)

		for i = 1, #cov do
			local mmap = Map{
				target = cs,
				select = "cov_"..cov[i],
				min = 0,
				max = 1,
				slices = 10,
				color = "RdPu"
			}

			unitTest:assertSnapshot(mmap, "tiff-cov-"..cov[i]..".png")
		end

		-- AVERAGE

		cl:fill{
			operation = "average",
			layer = "altimetria",
			attribute = "height"
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
		}

		map = Map{
			target = cs,
			select = "height",
			min = 0,
			max = 255,
			color = "RdPu",
			slices = 7
		}

		unitTest:assertSnapshot(map, "tiff-average.png")

		-- STDEV

		cl:fill{
			operation = "stdev",
			layer = "altimetria",
			attribute = "std"
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
		}

		map = Map{
			target = cs,
			select = "std",
			min = 0,
			max = 80,
			color = "RdPu",
			slices = 7
		}

		unitTest:assertSnapshot(map, "tiff-std.png")

		-- NODATA
		cl:fill{
			operation = "average",
			layer = "altimetria",
			attribute = "height_nd",
			nodata = 256
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
		}

		map = Map{
			target = cs,
			select = "height_nd",
			min = 0,
			max = 255,
			color = "RdPu",
			slices = 7
		}

		unitTest:assertSnapshot(map, "tiff-average-nodata.png")

		forEachElement(shapes, function(_, value)
			File(value):delete()
		end)

		File(projName):delete()

		customWarning = customWarningBkp
	end,
	representation = function(unitTest)
		local projName = "layer_fill_tiff_repr.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local customWarningBkp = customWarning
		customWarning = function(msg)
			return msg
		end

		local prodes = "prodes"
		local l = Layer{
			project = proj,
			name = prodes,
			file = filePath("test/prodes_polyc_10k.tif", "terralib")
		}

		unitTest:assertEquals(l:representation(), "raster")

		File(projName):delete()

		customWarning = customWarningBkp
	end,
	bands = function(unitTest)
		local projName = "layer_tif_bands.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local customWarningBkp = customWarning
		customWarning = function(msg)
			return msg
		end

		local prodes = "prodes"
		local l = Layer{
			project = proj,
			name = prodes,
			file = filePath("test/prodes_polyc_10k.tif", "terralib")
		}

		unitTest:assertEquals(l:bands(), 1)

		File(projName):delete()

		customWarning = customWarningBkp
	end,
	projection = function(unitTest)
		local projName = "tif_basic.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local layerName1 = "Prodes"
		local layer = Layer{
			project = proj,
			name = layerName1,
			file = filePath("amazonia-prodes.tif", "terralib"),
			epsg = 100017
		}
		unitTest:assertEquals(layer:projection(), "'SAD69 / UTM zone 21S - old 29191', with EPSG: 100017 (PROJ4: '+proj=utm +zone=21 +south +ellps=aust_SA +towgs84=-57,1,-41,0,0,0,0 +units=m +no_defs ')")

		proj.file:delete()
	end,
	attributes = function(unitTest)
		local projName = "tif_basic.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local layerName1 = "Prodes"
		local layer = Layer{
			project = proj,
			name = layerName1,
			file = filePath("amazonia-prodes.tif", "terralib")
		}

		local props = layer:attributes()

		unitTest:assertNil(props)

		proj.file:delete()
	end,
	nodata = function(unitTest)
		local projName = "layer_tif_bands.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local customWarningBkp = customWarning
		customWarning = function(msg)
			return msg
		end

		local prodes = "prodes"
		local l = Layer{
			project = proj,
			name = prodes,
			file = filePath("test/prodes_polyc_10k.tif", "terralib")
		}

		unitTest:assertEquals(l:nodata(), 255.0)

		local portos = "Portos"
		l = Layer{
			project = proj,
			name = portos,
			file = filePath("amazonia-ports.shp", "terralib")
		}

		unitTest:assertNil(l:nodata())

		File(projName):delete()

		customWarning = customWarningBkp
	end
}

