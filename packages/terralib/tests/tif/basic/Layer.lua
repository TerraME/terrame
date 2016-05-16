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
	fill = function(unitTest)
		local projName = "cellular_layer_fill_tiff.tview"

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
		local shp1 = clName1..".shp"

		if isFile(shp1) then
			rmFile(shp1)
		end

		local cl = Layer{
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName1,
			resolution = 20000,
			file = clName1..".shp"
		}

		local shapes = {}

		-- MODE

		local modeTifLayerName = clName1.."_"..prodes.."_mode"
		local shp = modeTifLayerName..".shp"

		table.insert(shapes, shp)
		
		if isFile(shp) then
			rmFile(shp)
		end

		cl:fill{
			operation = "mode",
			attribute = "prod_mode",
			layer = prodes,
			output = modeTifLayerName,
			select = 0,
		}

		local cs = CellularSpace{
			project = proj,
			layer = modeTifLayerName 
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

		local minTifLayerName = clName1.."_"..prodes.."_min"		
		local shp = minTifLayerName..".shp"

		table.insert(shapes, shp)
		
		if isFile(shp) then
			rmFile(shp)
		end

		cl:fill{
			operation = "minimum",
			attribute = "prod_min",
			layer = prodes,
			output = minTifLayerName,
			select = 0,
		}

		local cs = CellularSpace{
			project = proj,
			layer = minTifLayerName 
		}

		forEachCell(cs, function(cell)
			unitTest:assertType(cell.prod_min, "number")
			unitTest:assert(cell.prod_min >= 0)
			unitTest:assert(cell.prod_min <= 254)
		end)

		local map = Map{
			target = cs,
			select = "prod_min",
			value = {0, 49, 169, 253, 254},
			color = {"red", "green", "blue", "orange", "purple"}
		}

		unitTest:assertSnapshot(map, "tiff-min.png")

		-- MAXIMUM

		local maxTifLayerName = clName1.."_"..prodes.."_max"		
		local shp = maxTifLayerName..".shp"

		table.insert(shapes, shp)
		
		if isFile(shp) then
			rmFile(shp)
		end

		cl:fill{
			operation = "maximum",
			attribute = "prod_max",
			layer = prodes,
			output = maxTifLayerName,
			select = 0,
		}

		local cs = CellularSpace{
			project = proj,
			layer = maxTifLayerName 
		}

		forEachCell(cs, function(cell)
			unitTest:assertType(cell.prod_max, "number")
			unitTest:assert(cell.prod_max >= 0)
			unitTest:assert(cell.prod_max <= 254)
		end)

		local map = Map{
			target = cs,
			select = "prod_max",
			value = {0, 49, 169, 253, 254},
			color = {"red", "green", "blue", "orange", "purple"}
		}

		unitTest:assertSnapshot(map, "tiff-max.png")

		-- SUM

		local sumTifLayerName = clName1.."_"..prodes.."_sum"		
		local shp = sumTifLayerName..".shp"

		table.insert(shapes, shp)
		
		if isFile(shp) then
			rmFile(shp)
		end

		cl:fill{
			operation = "sum",
			attribute = "prod_sum",
			layer = prodes,
			output = sumTifLayerName,
			select = 0,
		}

		local cs = CellularSpace{
			project = proj,
			layer = sumTifLayerName 
		}

		forEachCell(cs, function(cell)
			unitTest:assertType(cell.prod_sum, "number")
			unitTest:assert(cell.prod_sum >= 0)
		end)

		local map = Map{
			target = cs,
			select = "prod_sum",
			min = 0,
			max = 2300,
			color = "RdPu",
			slices = 8
		}

		unitTest:assertSnapshot(map, "tiff-sum.png")

		-- COVERAGE

		local covTifLayerName = clName1.."_"..prodes.."_cov"		
		local shp = covTifLayerName..".shp"

		table.insert(shapes, shp)
		
		if isFile(shp) then
			rmFile(shp)
		end

		cl:fill{
			operation = "coverage",
			attribute = "cov",
			layer = prodes,
			output = covTifLayerName,
			select = 0,
		}

		local cs = CellularSpace{
			project = proj,
			layer = covTifLayerName 
		}

		local cov = {0, 49, 169, 253, 254}

		forEachCell(cs, function(cell)
			local sum = 0

			for i = 1, #cov do
				unitTest:assertType(cell["cov_"..cov[i]],   "number")
				sum = sum + cell["cov_"..cov[i]]
			end

			--unitTest:assert(math.abs(sum - 100) < 0.001) -- SKIP
			
			--if math.abs(sum - 100) > 0.001 then
			--	print(sum)
			--end
		end)

		for i = 1, #cov do
			local map = Map{
				target = cs,
				select = "cov_"..cov[i],
				min = 0,
				max = 100,
				slices = 10,
				color = "RdPu"
			}

			unitTest:assertSnapshot(map, "tiff-cov-"..cov[i]..".png")
		end

		-- AVERAGE

		local box = Layer{
			project = proj,
			name = "box",
			file = filePath("elevation_box.shp", "terralib")
		}

		local altimetria = Layer{
			project = proj,
			name = "altimetria",
			file = filePath("elevation.tif", "terralib")
		}

		if isFile("mycells.shp") then rmFile("mycells.shp") end
		if isFile("mycells-avg.shp") then rmFile("mycells-avg.shp") end

		table.insert(shapes, "mycells.shp")
		table.insert(shapes, "mycells-avg.shp")

		cl = Layer{
			project = proj,
			file = "mycells.shp",
			input = "box",
			name = "cells_elev",
			resolution = 200,
		}

		cl:fill{
			operation = "average",
			select = 0,
			layer = "altimetria",
			output = "mycells-avg",
			attribute = "height"
		}

		local cs = CellularSpace{
			project = proj,
			layer = "mycells-avg"
		}

		local map = Map{
			target = cs,
			select = "height",
			min = 0,
			max = 255,
			color = "RdPu",
			slices = 7
		}

		unitTest:assertSnapshot(map, "tiff-average.png")

		-- STDEV
		if isFile("cells-std.shp") then rmFile("cells-std.shp") end

		table.insert(shapes, "cells-std.shp")

		cl:fill{
			operation = "stdev",
			select = 0,
			layer = "altimetria",
			output = "cells-std",
			attribute = "std"
		}

		local cs = CellularSpace{
			project = proj,
			layer = "cells-std"
		}

		local map = Map{
			target = cs,
			select = "std",
			min = 0,
			max = 80,
			color = "RdPu",
			slices = 7
		}

		unitTest:assertSnapshot(map, "tiff-std.png")

		local tl = TerraLib()
		tl:finalize()

		forEachElement(shapes, function(_, value)
			rmFile(value)
		end)

		unitTest:assertFile(projName)
	end
}

