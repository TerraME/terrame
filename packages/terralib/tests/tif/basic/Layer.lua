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
		
		if isFile(filePath1) then
			rmFile(filePath1)
		end
		
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
		unitTest:assertEquals(cl1.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/"..filePath1))			
		
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
		
		if isFile(filePath1) then
			rmFile(filePath1)
		end				
		
		if isFile(projName) then
			rmFile(projName)
		end		
	end,
	fill = function(unitTest)
		local projName = "layer_fill_tif.tview"
		
		if isFile(projName) then
			rmFile(projName)
		end
		
		local proj = Project{
			file = projName,
			clean = true
		}

		local layerName1 = "limitepa"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath("limitePA_polyc_pol.shp", "terralib")
		}

		local prodes = "prodes"
		Layer{
			project = proj,
			name = prodes,
			file = filePath("prodes_polyc_10k.tif", "terralib")	
		}
		
		local clName1 = "cells"
		
		local shapes = {}
		
		local shp1 = clName1..".shp"
		if isFile(shp1) then
			rmFile(shp1)
		end
		table.insert(shapes, shp1)

		local cl = Layer{
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName1,
			resolution = 20000,
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
			if not belong(cell.prod_mode, {"0", "49", "169", "253", "254"}) then
				-- print(cell.prod_mode)
				count = count + 1
			end
		end)

		unitTest:assertEquals(count, 163)

		local map = Map{
			target = cs,
			select = "prod_mode",
			value = {"0", "49", "169", "253", "254"},
			color = {"red", "green", "blue", "orange", "purple"}
		}

		unitTest:assertSnapshot(map, "tiff-mode.png")

		-- MINIMUM

		cl:fill{
			operation = "minimum",
			attribute = "prod_min",
			layer = prodes
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name 
		}

		forEachCell(cs, function(cell)
			unitTest:assertType(cell.prod_min, "number")
			unitTest:assert(cell.prod_min >= 0)
			unitTest:assert(cell.prod_min <= 254)
		end)

		map = Map{
			target = cs,
			select = "prod_min",
			value = {0, 49, 169, 253, 254},
			color = {"red", "green", "blue", "orange", "purple"}
		}

		unitTest:assertSnapshot(map, "tiff-min.png")
		
		if _Gtme.isWindowsOS() then -- #1306
			-- MAXIMUM

			cl:fill{
				operation = "maximum",
				attribute = "prod_max",
				layer = prodes
			}

			cs = CellularSpace{
				project = proj,
				layer = cl.name 
			}

			forEachCell(cs, function(cell)
				unitTest:assertType(cell.prod_max, "number") -- SKIP
				unitTest:assert(cell.prod_max >= 0) -- SKIP
				unitTest:assert(cell.prod_max <= 254) -- SKIP
			end)

			map = Map{
				target = cs,
				select = "prod_max",
				value = {0, 49, 169, 253, 254},
				color = {"red", "green", "blue", "orange", "purple"}
			}

			unitTest:assertSnapshot(map, "tiff-max.png") -- SKIP

			-- SUM

			cl:fill{
				operation = "sum",
				attribute = "prod_sum",
				layer = prodes
			}

			cs = CellularSpace{
				project = proj,
				layer = cl.name 
			}

			forEachCell(cs, function(cell)
				unitTest:assertType(cell.prod_sum, "number") -- SKIP
				unitTest:assert(cell.prod_sum >= 0) -- SKIP
			end)

			map = Map{
				target = cs,
				select = "prod_sum",
				min = 0,
				max = 2300,
				color = "RdPu",
				slices = 8
			}

			unitTest:assertSnapshot(map, "tiff-sum.png") -- SKIP

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

			local cov = {0, 49, 169, 253, 254}

			forEachCell(cs, function(cell)
				local sum = 0

				for i = 1, #cov do
					unitTest:assertType(cell["cov_"..cov[i]],   "number") -- SKIP
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

				unitTest:assertSnapshot(mmap, "tiff-cov-"..cov[i]..".png") -- SKIP
			end

			-- AVERAGE

			Layer{
				project = proj,
				name = "box",
				file = filePath("elevation_box.shp", "terralib")
			}

			Layer{
				project = proj,
				name = "altimetria",
				file = filePath("elevation.tif", "terralib")
			}

			if isFile("mycells.shp") then rmFile("mycells.shp") end
			table.insert(shapes, "mycells.shp")
			
			cl = Layer{
				project = proj,
				file = "mycells.shp",
				input = "box",
				name = "cells_elev",
				resolution = 200,
			}

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

			unitTest:assertSnapshot(map, "tiff-average.png") -- SKIP

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

			unitTest:assertSnapshot(map, "tiff-std.png") -- SKIP
		end
		
		forEachElement(shapes, function(_, value)
			rmFile(value)
		end)

		-- unitTest:assertFile(projName) -- SKIP #1301
		rmFile(projName) -- #1301
	end,
	representation = function(unitTest)
		if _Gtme.isWindowsOS() then -- #1307
			local projName = "cellular_layer_fill_tiff_repr.tview"

			local proj = Project{
				file = projName,
				clean = true
			}

			local prodes = "prodes"
			local l = Layer{
				project = proj,
				name = prodes,
				file = filePath("prodes_polyc_10k.tif", "terralib")	
			}

			unitTest:assertEquals(l:representation(), "raster") -- SKIP
			
			-- unitTest:assertFile(projName) -- SKIP #1301
			rmFile(projName) -- #1301
		else
			unitTest:assert(true)
		end
	end,
	bands = function(unitTest)
		local projName = "cellular_layer_fill_tiff_repr.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local prodes = "prodes"
		local l = Layer{
			project = proj,
			name = prodes,
			file = filePath("prodes_polyc_10k.tif", "terralib")	
		}

		unitTest:assertEquals(l:bands(), 4)
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
			file = filePath("PRODES_5KM.tif", "terralib")
		}
		
		unitTest:assertEquals(layer:projection(), "'SAD69 / UTM zone 21S - old 29191', with SRID: 100017.0 (PROJ4: '+proj=utm +zone=21 +south +ellps=aust_SA +towgs84=-57,1,-41,0,0,0,0 +units=m +no_defs ').")

		rmFile(proj.file)
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
			file = filePath("PRODES_5KM.tif", "terralib")
		}
		
		local props = layer:attributes()
		
		unitTest:assertNil(props)
		
		rmFile(proj.file)	
	end
}

