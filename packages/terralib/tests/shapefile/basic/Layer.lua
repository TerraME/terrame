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
		local projName = "layer_shape_basic.tview"

		local proj = Project {
			file = projName,
			clean = true
		}
		
		-- SPATIAL INDEX TEST
		local filePath1 = filePath("limitePA_polyc_pol.shp", "terralib")
		local qixFile = string.gsub(filePath1, ".shp", ".qix")
		rmFile(qixFile)
		
		local layerName1 = "limitepa"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath1,
			index = false
		}
		
		unitTest:assert(not isFile(qixFile))
		
		proj = Project {
			file = projName,
			clean = true
		}		
		
		Layer{
			project = proj,
			name = layerName1,
			file = filePath1
		}		
		
		unitTest:assert(isFile(qixFile))
		
		local clName1 = "PA_Cells50x50"
		local cl1 = Layer{
			project = proj,
			source = "shp",
			clean = true,
			input = layerName1,
			name = clName1,
			resolution = 50000,
			file = clName1..".shp",
			index = false
		}			
		
		qixFile = string.gsub(cl1.file, ".shp", ".qix")
		unitTest:assert(not isFile(qixFile))
		
		local clName2 = "PA_Cells60x60"
		local cl2 = Layer{
			project = proj,
			source = "shp",
			clean = true,
			input = layerName1,
			name = clName2,
			resolution = 60000,
			file = clName2..".shp"
		}
		
		qixFile = string.gsub(cl2.file, ".shp", ".qix")
		unitTest:assert(isFile(qixFile))	

		rmFile(cl1.file)
		rmFile(cl2.file)
		-- // SPATIAL INDEX
		
		rmFile(proj.file)
	end,
	fill = function(unitTest)
		local projName = "cellular_layer_fill_shape.tview"

		local proj = Project {
			file = projName,
			clean = true
		}

		local layerName1 = "limitepa"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath("limitePA_polyc_pol.shp", "terralib")
		}

		local protecao = "protecao"
		Layer{
			project = proj,
			name = protecao,
			file = filePath("BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "terralib")
		}

		local rodovias = "Rodovias"
		Layer{
			project = proj,
			name = rodovias,
			file = filePath("BCIM_Trecho_RodoviarioLine_PA_polyc_lin.shp", "terralib")	
		}

		local portos = "Portos"
		Layer{
			project = proj,
			name = portos,
			file = filePath("PORTOS_AMZ_pt.shp", "terralib")	
		}
		
		local clName1 = "cells"

		local municipios = "municipios"
		Layer{
			project = proj,
			name = municipios,
			file = filePath("municipiosAML_ok.shp", "terralib")	
		}

		local cl = Layer{
			project = proj,
			source = "shp",
			clean = true,
			input = layerName1,
			name = clName1,
			resolution = 50000,
			file = clName1..".shp"
		}

		local shapes = {}
		
		-- MODE

		local polmodeLayerName = clName1.."_polmode"
		local shp1 = polmodeLayerName..".shp"

		table.insert(shapes, shp1)

		cl:fill{
			operation = "mode",
			layer = municipios,
			attribute = "polmode",
			clean = true,
			select = "POPULACAO_",
			output = polmodeLayerName
		}

		local cs = CellularSpace{
			project = proj,
			layer = polmodeLayerName
		}

		--[[
		local unique = {}
		forEachCell(cs, function(cell)
			unique[cell.polmode] = true
		end)

		forEachElement(unique, function(idx)
			print(idx)
		end)
		--]]

		local map = Map{
			target = cs,
			select = "polmode",
			value = {"0", "53217", "37086", "14302"}, 
			color = {"red", "green", "blue", "yellow"}
		}

		unitTest:assertSnapshot(map, "polygons-mode.png")

		-- MODE (area = true)

		local polmode2LayerName = clName1.."_polmode2"
		shp1 = polmode2LayerName..".shp"

		table.insert(shapes, shp1)

		cl:fill{
			operation = "mode",
			layer = municipios,
			attribute = "polmode2",
			clean = true,
			select = "POPULACAO_",
			area = true,
			output = polmode2LayerName
		}

		cs = CellularSpace{
			project = proj,
			layer = polmode2LayerName
		}

		map = Map{
			target = cs,
			select = "polmode2",
			min = 0,
			max = 1410000,
			slices = 8,
			color = {"red", "green"}
		}

		unitTest:assertSnapshot(map, "polygons-mode-2.png")

		-- AREA

		local areaLayerName = clName1.."_area"
		shp1 = areaLayerName..".shp"

		table.insert(shapes, shp1)

		cl:fill{
			operation = "area",
			layer = protecao,
			clean = true,
			attribute = "marea",
			output = areaLayerName
		}

		cs = CellularSpace{
			project = proj,
			layer = areaLayerName
		}

		map = Map{
			target = cs,
			select = "marea",
			min = 0,
			max = 1,
			slices = 8,
			color = {"red", "green"}
		}

		unitTest:assertSnapshot(map, "polygons-area.png")

		-- DISTANCE

		local lindistLayerName = clName1.."_lindist"
		local shp2 = lindistLayerName..".shp"

		table.insert(shapes, shp2)

		cl:fill{
			operation = "distance",
			layer = rodovias,
			attribute = "lindist",
			clean = true,
			output = lindistLayerName
		}

		cs = CellularSpace{
			project = proj,
			layer = lindistLayerName
		}

		map = Map{
			target = cs,
			select = "lindist",
			min = 0,
			max = 200000,
			slices = 8,
			color = {"green", "red"}
		}

		unitTest:assertSnapshot(map, "lines-distance.png")

		local poldistLayerName = clName1.."_poldist"
		local shp3 = poldistLayerName..".shp"

		table.insert(shapes, shp3)

		cl:fill{
			operation = "distance",
			layer = protecao,
			attribute = "poldist",
			clean = true,
			output = poldistLayerName
		}

		cs = CellularSpace{
			project = proj,
			layer = poldistLayerName
		}

		map = Map{
			target = cs,
			select = "poldist",
			min = 0,
			max = 370000,
			slices = 8,
			color = {"green", "red"}
		}

		unitTest:assertSnapshot(map, "polygons-distance.png")

		local pointdistLayerName = clName1.."_pointdist"
		local shp4 = pointdistLayerName..".shp"

		table.insert(shapes, shp4)

		cl:fill{
			operation = "distance",
			layer = portos,
			attribute = "pointdist",
			clean = true,
			output = pointdistLayerName
		}

		cs = CellularSpace{
			project = proj,
			layer = pointdistLayerName
		}

		map = Map{
			target = cs,
			select = "pointdist",
			min = 0,
			max = 900000,
			slices = 8,
			color = {"green", "red"}
		}

		unitTest:assertSnapshot(map, "points-distance.png")

		-- PRESENCE

		local linpresLayerName = clName1.."_linpres"
		shp2 = linpresLayerName..".shp"

		table.insert(shapes, shp2)

		cl:fill{
			operation = "presence",
			layer = rodovias,
			attribute = "linpres",
			clean = true,
			output = linpresLayerName
		}

		cs = CellularSpace{
			project = proj,
			layer = linpresLayerName
		}

		map = Map{
			target = cs,
			select = "linpres",
			value = {0, 1},
			color = {"green", "red"}
		}

		unitTest:assertSnapshot(map, "lines-presence.png")

		local polpresLayerName = clName1.."_polpres"
		shp3 = polpresLayerName..".shp"

		table.insert(shapes, shp3)

		cl:fill{
			operation = "presence",
			layer = protecao,
			attribute = "polpres",
			clean = true,
			output = polpresLayerName
		}

		cs = CellularSpace{
			project = proj,
			layer = polpresLayerName
		}

		map = Map{
			target = cs,
			select = "polpres",
			value = {0, 1},
			color = {"green", "red"}
		}

		unitTest:assertSnapshot(map, "polygons-presence.png")

		local pointpresLayerName = clName1.."_pointpres"
		shp4 = pointpresLayerName..".shp"

		table.insert(shapes, shp4)

		cl:fill{
			operation = "presence",
			layer = portos,
			attribute = "pointpres",
			clean = true,
			output = pointpresLayerName
		}

		cs = CellularSpace{
			project = proj,
			layer = pointpresLayerName
		}

		map = Map{
			target = cs,
			select = "pointpres",
			value = {0, 1},
			color = {"green", "red"}
		}

		unitTest:assertSnapshot(map, "points-presence.png")

		-- COUNT
		local clName2 = "cells_large"
		shp1 = clName2..".shp"

		table.insert(shapes, shp1)

		if isFile(shp1) then
			rmFile(shp1)
		end

		local cl2 = Layer{
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName2,
			resolution = 100000,
			file = clName2..".shp"
		}

		local pointcountLayerName = clName2.."_pointcount"
		shp2 = pointcountLayerName..".shp"

		table.insert(shapes, shp2)

		cl2:fill{
			operation = "count",
			layer = portos,
			attribute = "pointcount",
			clean = true,
			output = pointcountLayerName
		}

		cs = CellularSpace{
			project = proj,
			layer = pointcountLayerName
		}

		map = Map{
			target = cs,
			select = "pointcount",
			value = {0, 1, 2},
			color = {"green", "red", "blue"}
		}

		unitTest:assertSnapshot(map, "points-count.png")

		local linecountLayerName = clName2.."_linecount"
		shp3 = linecountLayerName..".shp"

		table.insert(shapes, shp3)

		cl2:fill{
			operation = "count",
			layer = rodovias,
			attribute = "linecount",
			clean = true,
			output = linecountLayerName
		}

		cs = CellularSpace{
			project = proj,
			layer = linecountLayerName
		}

		map = Map{
			target = cs,
			select = "linecount",
			min = 0,
			max = 135,
			slices = 10,
			color = {"green", "blue"}
		}

		unitTest:assertSnapshot(map, "lines-count.png")

		local polcountLayerName = clName2.."_polcount"
		shp4 = polcountLayerName..".shp"

		table.insert(shapes, shp4)

		cl2:fill{
			operation = "count",
			layer = protecao,
			attribute = "polcount",
			clean = true,
			output = polcountLayerName
		}

		cs = CellularSpace{
			project = proj,
			layer = polcountLayerName
		}

		map = Map{
			target = cs,
			select = "polcount",
			value = {0, 1, 2},
			color = {"green", "red", "blue"}
		}

		unitTest:assertSnapshot(map, "polygons-count.png")

		-- MAXIMUM

		local polmaxLayerName = clName1.."_polmax"
		shp1 = polmaxLayerName..".shp"

		table.insert(shapes, shp1)

		if isFile(shp1) then
			rmFile(shp1)
		end

		cl:fill{
			operation = "maximum",
			layer = municipios,
			attribute = "polmax",
			select = "POPULACAO_",
			output = polmaxLayerName
		}

		cs = CellularSpace{
			project = proj,
			layer = polmaxLayerName
		}

		map = Map{
			target = cs,
			select = "polmax",
			min = 0,
			max = 1450000,
			slices = 8,
			color = {"red", "green"}
		}

		unitTest:assertSnapshot(map, "polygons-maximum.png")

		-- MINIMUM

		local polminLayerName = clName1.."_polinx"
		shp1 = polminLayerName..".shp"

		table.insert(shapes, shp1)

		if isFile(shp1) then
			rmFile(shp1)
		end

		cl:fill{
			operation = "minimum",
			layer = municipios,
			attribute = "polmin",
			select = "POPULACAO_",
			output = polminLayerName
		}

		cs = CellularSpace{
			project = proj,
			layer = polminLayerName
		}

		map = Map{
			target = cs,
			select = "polmin",
			min = 0,
			max = 275000,
			slices = 8,
			color = {"red", "green"}
		}

		unitTest:assertSnapshot(map, "polygons-minimum.png")

		-- AVERAGE

		local polavrgLayerName = clName1.."_polavrg"
		shp1 = polavrgLayerName..".shp"

		table.insert(shapes, shp1)

		if isFile(shp1) then
			rmFile(shp1)
		end

		cl:fill{
			operation = "average",
			layer = municipios,
			attribute = "polavrg",
			select = "POPULACAO_",
			output = polavrgLayerName
		}

		cs = CellularSpace{
			project = proj,
			layer = polavrgLayerName
		}

		map = Map{
			target = cs,
			select = "polavrg",
			min = 0,
			max = 311000,
			slices = 8,
			color = {"red", "green"}
		}

		unitTest:assertSnapshot(map, "polygons-average.png")

		-- STDEV

		local polstdevLayerName = clName1.."_polstdev"
		shp1 = polstdevLayerName..".shp"

		table.insert(shapes, shp1)

		if isFile(shp1) then
			rmFile(shp1)
		end

		cl:fill{
			operation = "stdev",
			layer = municipios,
			attribute = "stdev",
			select = "POPULACAO_",
			output = polstdevLayerName
		}

		cs = CellularSpace{
			project = proj,
			layer = polstdevLayerName
		}

		map = Map{
			target = cs,
			select = "stdev",
			min = 0,
			max = 550000,
			slices = 8,
			color = {"red", "green"}
		}

		unitTest:assertSnapshot(map, "polygons-stdev.png")

		-- LENGTH

		local lengthLayerName = clName1.."_length"
		local shp5 = lengthLayerName..".shp"

		if isFile(shp5) then
			rmFile(shp5)
		end

		local error_func = function()
			cl:fill{
				operation = "length",
				layer = rodovias,
				attribute = "mlength",
				output = lengthLayerName
			}
		end
		unitTest:assertError(error_func, "Sorry, this operation was not implemented in TerraLib yet.")

		-- SUM

		proj = Project {
			file = "sum_wba.tview",
			clean = true,
			setores = filePath("municipiosAML_ok.shp", "terralib")
		}

		clName1 = "cells_set"

		cl = Layer{
			project = proj,
			source = "shp",
			clean = true,
			input = "setores",
			name = clName1,
			resolution = 50000,
			file = clName1..".shp"
		}

		local polsumAreaLayerName = clName1.."_polavg"

		cl:fill{
			operation = "sum",
			layer = "setores",
			attribute = "polsuma",
			clean = true,
			select = "POPULACAO_",
			output = polsumAreaLayerName,
			area = true
		}

		cs = CellularSpace{
			project = proj,
			layer = "setores"
		}

		local sum1 = 0
		forEachCell(cs, function(cell)
			sum1 = sum1 + cell.POPULACAO_
		end)
	
		cs = CellularSpace{
			project = proj,
			layer = polsumAreaLayerName
		}

		local sum2 = 0
		forEachCell(cs, function(cell)
			sum2 = sum2 + cell.polsuma
		end)

		unitTest:assertEquals(sum1, sum2, 1e-4)

		map = Map{
			target = cs,
			select = "polsuma",
			min = 0,
			max = 1300000,
			slices = 20,
			color = {"red", "green"}
		}

		unitTest:assertSnapshot(map, "polygons-sum-area.png")

		-- AVERAGE (area = true)

		projName = "cellular_layer_fill_avg_area.tview"

		proj = Project {
			file = projName,
			clean = true,
			setores = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
		}

		clName1 = "cells_avg_area"

		cl = Layer{
			project = proj,
			source = "shp",
			clean = true,
			input = "setores",
			name = clName1,
			resolution = 10000,
			file = clName1..".shp"
		}

		local polavgLayerName = clName1.."_polavg"

		cl:fill{
			operation = "average",
			layer = "setores",
			attribute = "polavg",
			clean = true,
			select = "Densde_Pop",
			output = polavgLayerName,
			area = true
		}

		cs = CellularSpace{
			project = proj,
			layer = polavgLayerName
		}

		map = Map{
			target = cs,
			select = "polavg",
			min = 0,
			max = 36,
			slices = 8,
			color = {"red", "green"}
		}

		unitTest:assertSnapshot(map, "polygons-average-area.png")
--[[
		forEachElement(shapes, function(_, value)
			rmFile(value)
		end)
--]]
		unitTest:assertFile(projName)
	end
}

