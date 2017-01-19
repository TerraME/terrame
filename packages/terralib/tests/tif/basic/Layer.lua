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
			file = filePath("PRODES_5KM.tif", "terralib")
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

		-- #1152
		-- local host = "localhost"
		-- local port = "5432"
		-- local user = "postgres"
		-- local password = "postgres"
		-- local database = "postgis_22_sample"
		-- local encoding = "CP1252"
		-- local tableName = "prodes_pg_cells"

		-- local pgData = {
			-- type = "POSTGIS",
			-- host = host,
			-- port = port,
			-- user = user,
			-- password = password,
			-- database = database,
			-- table = tableName,
			-- encoding = encoding

		-- }

		-- -- USED ONLY TO TESTS
		-- local tl = TerraLib{}
		-- tl:dropPgTable(pgData)
		-- local clName2 = "ProdesPg"

		-- local layer2 = Layer{
			-- project = proj,
			-- source = "postgis",
			-- input = layerName1
			-- name = clName2,
			-- resolution = 60e3,
			-- user = user,
			-- password = password,
			-- database = database,
			-- table = tableName
		-- }

		-- END
		-- tl:dropPgTable(pgData)

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

		File(projName):deleteIfExists()

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
			file = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
		}

		local prodes = "prodes"
		Layer{
			project = proj,
			name = prodes,
			file = filePath("Desmatamento_2000.tif", "terralib"),
			srid = l1.srid
		}

		local altimetria = "altimetria"
		Layer{
			project = proj,
			name = altimetria,
			file = filePath("altimetria.tif", "terralib"),
			srid = l1.srid
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
				max = 100,
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

		forEachElement(shapes, function(_, value)
			File(value):delete()
		end)

		-- unitTest:assertFile(projName) -- SKIP #1242
		File(projName):delete() -- #1242

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

		-- unitTest:assertFile(projName) -- SKIP #1242
		File(projName):delete() -- #1242

		customWarning = customWarningBkp
	end,
	bands = function(unitTest)
		local projName = "layer_tif_bands.tview"

		File(projName):deleteIfExists()

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
	if sessionInfo().system ~= "mac" then -- TODO(#1380)
		local layerName1 = "Prodes"

		local layer = Layer{
			project = proj,
			name = layerName1,
			file = filePath("PRODES_5KM.tif", "terralib")
		}
		unitTest:assertEquals(layer:projection(), "'SAD69 / UTM zone 21S - old 29191', with SRID: 100017.0 (PROJ4: '+proj=utm +zone=21 +south +ellps=aust_SA +towgs84=-57,1,-41,0,0,0,0 +units=m +no_defs ').") -- SKIP
	else
		unitTest:assert(true) -- SKIP
	end

		proj.file:delete()
	end,
	attributes = function(unitTest)
		local projName = "tif_basic.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

	if sessionInfo().system ~= "mac" then -- TODO(1448)
		local layerName1 = "Prodes"

		local layer = Layer{
			project = proj,
			name = layerName1,
			file = filePath("PRODES_5KM.tif", "terralib")
		}

		local props = layer:attributes()

		unitTest:assertNil(props) -- SKIP
	else
		unitTest:assert(true) -- SKIP
	end

		proj.file:delete()
	end,
	dummy = function(unitTest)
		local projName = "layer_tif_bands.tview"

		File(projName):deleteIfExists()

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

		unitTest:assertEquals(l:dummy(0), 255.0)

		local portos = "Portos"
		l = Layer{
			project = proj,
			name = portos,
			file = filePath("PORTOS_AMZ_pt.shp", "terralib")
		}

		unitTest:assertNil(l:dummy(0))

		File(projName):delete()

		customWarning = customWarningBkp
	end
}

