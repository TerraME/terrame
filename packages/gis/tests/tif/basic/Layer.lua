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
		local indexUnnecessary = function()
			Layer{
				project = proj,
				name = layerName1,
				file = filePath("amazonia-prodes.tif", "gis"),
				index = true
			}
		end
		unitTest:assertWarning(indexUnnecessary, unnecessaryArgumentMsg("index"))

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

		local proj = Project{
			file = projName,
			prodes = filePath("test/prodes_polyc_10k.tif", "gis"),
			clean = true
		}

		unitTest:assertEquals(#proj.prodes, 20020)

		proj.file:delete()
	end,
	fill = function(unitTest)
		local projName = "layer_fill_tif.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local layerName1 = "limiteitaituba"
		local l1 = Layer{
			project = proj,
			name = layerName1,
			file = filePath("itaituba-census.shp", "gis")
		}

		local prodes = "prodes"
		Layer{
			project = proj,
			name = prodes,
			file = filePath("itaituba-deforestation.tif", "gis"),
			epsg = l1.epsg
		}

		local altimetria = "altimetria"
		local altLayer = Layer{
			project = proj,
			name = altimetria,
			file = filePath("itaituba-elevation.tif", "gis"),
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
			resolution = 5000,
			file = clName1..".shp"
		}

		-- MODE

		cl:fill{
			operation = "mode",
			attribute = "prod_mode",
			layer = prodes,
			missing = 1000
		}

		local cs = CellularSpace{
			project = proj,
			layer = cl.name
		}

		local split = cs:split("prod_mode")

		unitTest:assertEquals(getn(split), 3)
		unitTest:assertEquals(#split["7"], 498)
		unitTest:assertEquals(#split["87"], 102)
		unitTest:assertEquals(#split["167"], 20)

		unitTest:assertEquals(#cs, 498 + 102 + 20)

		local map = Map{
			target = cs,
			select = "prod_mode",
			value = {"7", "87", "167"},
			color = {"red", "green", "blue"}
		}

		unitTest:assertSnapshot(map, "tiff-mode.png", 0.1)

		cl:fill{
			operation = "mode",
			attribute = "prod_m_ov",
			layer = prodes,
			pixel = "overlap",
			missing = 1000
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
		}

		split = cs:split("prod_m_ov")

		unitTest:assertEquals(getn(split), 4)
		unitTest:assertEquals(#split["7"], 497)
		unitTest:assertEquals(#split["87"], 102)
		unitTest:assertEquals(#split["7,87"], 1)
		unitTest:assertEquals(#split["167"], 20)

		unitTest:assertEquals(#cs, 497 + 102 + 1 + 20)

		map = Map{
			target = cs,
			select = "prod_m_ov",
			value = {"7", "87", "167", "7,87"},
			color = {"red", "green", "blue", "black"}
		}

		unitTest:assertSnapshot(map, "tiff-mode-ov.png", 0.05)

		-- MINIMUM

		local clName2 = "itaituba2"
		local shp2 = clName2..".shp"
		File(shp2):deleteIfExists()
		table.insert(shapes, shp2)

		cl = Layer{
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName2,
			resolution = 10000,
			file = clName2..".shp"
		}

		local warningFunc = function()
			cl:fill{
				operation = "minimum",
				attribute = "prod_min",
				layer = altimetria,
				pixel = "centroid"
			}
		end

		unitTest:assertWarning(warningFunc, defaultValueMsg("pixel", "centroid"))

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

			unitTest:assert(sum -0.1 <= 1) -- this should be 'sum <= 1' #1968

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

			unitTest:assertSnapshot(mmap, "tiff-cov-"..cov[i]..".png", 0.1)
		end

		-- AVERAGE
		local nodataDefaultWarn = function()
			cl:fill{
				operation = "average",
				layer = "altimetria",
				attribute = "height",
				dummy = altLayer:dummy()
			}
		end
		unitTest:assertWarning(nodataDefaultWarn, defaultValueMsg("dummy", altLayer:dummy()))

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

		-- DUMMY
		cl:fill{
			operation = "average",
			layer = "altimetria",
			attribute = "height_nd",
			dummy = 256
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

		-- COUNT

		os.execute("cp "..filePath("amazonia-indigenous.shp", "gis").." .")
		os.execute("cp "..filePath("amazonia-indigenous.shx", "gis").." .")
		os.execute("cp "..filePath("amazonia-indigenous.prj", "gis").." .")
		os.execute("cp "..filePath("amazonia-indigenous.dbf", "gis").." .")

		proj = Project{
			file = "fill_mcount.tview",
			clean = true,
		}

		local protec = Layer{
		    name = "protected",
		    project = proj,
		    epsg = 29191,
		    file = "amazonia-indigenous.shp"
		}

		prodes = Layer{
		    name = "prodes",
		    project = proj,
		    epsg = 29191,
		    file = filePath("amazonia-prodes.tif", "gis")
		}

		protec:fill{
			operation = "count",
			attribute = "prod_count",
			layer = prodes
		}

		protec:fill{
			operation = "count",
			attribute = "prod_c_ov",
			layer = prodes,
			pixel = "overlap"
		}


		cs = CellularSpace{
			layer = protec
		}

		local sum = 0
		local sum_ov = 0

		unitTest:assertType(cs:sample().prod_count, "number")
		unitTest:assertType(cs:sample().prod_c_ov, "number")

		forEachCell(cs, function(cell)
			sum = sum + cell.prod_count
			sum_ov = sum_ov + cell.prod_c_ov

			unitTest:assert(cell.prod_count >= 0 and cell.prod_count <= 3796)
			unitTest:assert(cell.prod_c_ov >= 0 and cell.prod_c_ov <= 3989)
		end)

		unitTest:assertEquals(sum, 42844)
		unitTest:assertEquals(sum_ov, 51116)

		File("amazonia-indigenous.shp"):delete()
		File("fill_mcount.tview"):delete()
	end,
	representation = function(unitTest)
		local projName = "layer_fill_tiff_repr.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local prodes = "prodes"
		local l = Layer{
			project = proj,
			name = prodes,
			file = filePath("test/prodes_polyc_10k.tif", "gis")
		}

		unitTest:assertEquals(l:representation(), "raster")

		File(projName):delete()
	end,
	bands = function(unitTest)
		local projName = "layer_tif_bands.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local prodes = "prodes"
		local l = Layer{
			project = proj,
			name = prodes,
			file = filePath("test/prodes_polyc_10k.tif", "gis")
		}

		unitTest:assertEquals(l:bands(), 1)

		File(projName):delete()
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
			file = filePath("amazonia-prodes.tif", "gis"),
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
			file = filePath("amazonia-prodes.tif", "gis")
		}

		local props = layer:attributes()

		unitTest:assertNil(props)

		proj.file:delete()
	end,
	dummy = function(unitTest)
		local projName = "layer_tif_bands.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local prodes = "prodes"
		local l = Layer{
			project = proj,
			name = prodes,
			file = filePath("test/prodes_polyc_10k.tif", "gis")
		}

		unitTest:assertEquals(l:dummy(), 255.0)

		local portos = "Portos"
		l = Layer{
			project = proj,
			name = portos,
			file = filePath("amazonia-ports.shp", "gis")
		}

		unitTest:assertNil(l:dummy())

		File(projName):delete()
	end,
	export = function(unitTest)
		local proj = Project{
			file = "export_tif_basic.tview",
			author = "Avancini",
			clean = true
		}

		local layer = Layer{
			project = proj,
			name = "Prodes",
			file = filePath("test/prodes_polyc_10k.tif", "gis")
		}

		local toData = {file = File("tif2png.png"):deleteIfExists(), select = {"0", "1"}}
		local selectUnnecessary = function()
			layer:export(toData)
		end

		unitTest:assertWarning(selectUnnecessary, unnecessaryArgumentMsg("select"))
		unitTest:assert(toData.file:exists())

		local layer2 = Layer{
			project = proj,
			name = "Exported",
			epsg = 5808,
			file = toData.file
		}

		local toData2 = {file = File("png2tif.tif"), epsg = 4326}
		layer2:export(toData2)

		unitTest:assert(toData2.file:exists())

		local layer3 = Layer{
			project = proj,
			name = "Rexported",
			file = toData2.file
		}

		unitTest:assert(layer.epsg ~= layer2.epsg)
		unitTest:assert(layer3.epsg ~= layer2.epsg)
		unitTest:assertEquals(layer2.epsg, 5808)
		unitTest:assertEquals(layer3.epsg, 4326)

		proj.file:delete()
		toData.file:delete()
		toData2.file:delete()
	end
}

