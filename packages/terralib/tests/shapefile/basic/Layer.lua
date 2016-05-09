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

		local shp1 = clName1..".shp"

		if isFile(shp1) then
			rmFile(shp1)
		end

		local cl = Layer{
			project = proj,
			source = "shp",
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

		if isFile(shp1) then
			rmFile(shp1)
		end

		cl:fill{
			operation = "mode",
			name = municipios,
			attribute = "polmode",
			select = "POPULACAO_",
			output = polmodeLayerName
		}

		local cs = CellularSpace{
			project = proj,
			layer = polmodeLayerName
		}
--[[
		max = 0
forEachCell(cs, function(cell)
		if cell.polmin > max then max = cell.polmin
		end
	end)

	print(max)
--]]
		local map = Map{
			target = cs,
			select = "polmode",
			min = 0,
			max = 275000,
			slices = 8,
			color = {"red", "green"}
		}

		unitTest:assertSnapshot(map, "polygons-mode.png")

		-- AREA

		local areaLayerName = clName1.."_area"
		local shp1 = areaLayerName..".shp"

		table.insert(shapes, shp1)

		if isFile(shp1) then
			rmFile(shp1)
		end

		cl:fill{
			operation = "area",
			name = protecao,
			attribute = "marea",
			output = areaLayerName
		}

		local cs = CellularSpace{
			project = proj,
			layer = areaLayerName
		}

		local map = Map{
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

		if isFile(shp2) then
			rmFile(shp2)
		end

		cl:fill{
			operation = "distance",
			name = rodovias,
			attribute = "lindist",
			output = lindistLayerName
		}

		local cs = CellularSpace{
			project = proj,
			layer = lindistLayerName
		}

		local map = Map{
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

		if isFile(shp3) then
			rmFile(shp3)
		end

		cl:fill{
			operation = "distance",
			name = protecao,
			attribute = "poldist",
			output = poldistLayerName
		}

		local cs = CellularSpace{
			project = proj,
			layer = poldistLayerName
		}

		local map = Map{
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

		if isFile(shp4) then
			rmFile(shp4)
		end

		cl:fill{
			operation = "distance",
			name = portos,
			attribute = "pointdist",
			output = pointdistLayerName
		}

		local cs = CellularSpace{
			project = proj,
			layer = pointdistLayerName
		}

		local map = Map{
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
		local shp2 = linpresLayerName..".shp"

		table.insert(shapes, shp2)

		if isFile(shp2) then
			rmFile(shp2)
		end

		cl:fill{
			operation = "presence",
			name = rodovias,
			attribute = "linpres",
			output = linpresLayerName
		}

		local cs = CellularSpace{
			project = proj,
			layer = linpresLayerName
		}

		local map = Map{
			target = cs,
			select = "linpres",
			value = {0, 1},
			color = {"green", "red"}
		}

		unitTest:assertSnapshot(map, "lines-presence.png")

		local polpresLayerName = clName1.."_polpres"
		local shp3 = polpresLayerName..".shp"

		table.insert(shapes, shp3)

		if isFile(shp3) then
			rmFile(shp3)
		end

		cl:fill{
			operation = "presence",
			name = protecao,
			attribute = "polpres",
			output = polpresLayerName
		}

		local cs = CellularSpace{
			project = proj,
			layer = polpresLayerName
		}

		local map = Map{
			target = cs,
			select = "polpres",
			value = {0, 1},
			color = {"green", "red"}
		}

		unitTest:assertSnapshot(map, "polygons-presence.png")

		local pointpresLayerName = clName1.."_pointpres"
		local shp4 = pointpresLayerName..".shp"

		table.insert(shapes, shp4)

		if isFile(shp4) then
			rmFile(shp4)
		end

		cl:fill{
			operation = "presence",
			name = portos,
			attribute = "pointpres",
			output = pointpresLayerName
		}

		local cs = CellularSpace{
			project = proj,
			layer = pointpresLayerName
		}

		local map = Map{
			target = cs,
			select = "pointpres",
			value = {0, 1},
			color = {"green", "red"}
		}

		unitTest:assertSnapshot(map, "points-presence.png")

		-- COUNT
		local clName2 = "cells_large"
		local shp1 = clName2..".shp"

		table.insert(shapes, shp1)

		if isFile(shp1) then
			rmFile(shp1)
		end

		local cl = Layer{
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName2,
			resolution = 100000,
			file = clName2..".shp"
		}

		local pointcountLayerName = clName2.."_pointcount"
		local shp2 = pointcountLayerName..".shp"

		table.insert(shapes, shp2)

		if isFile(shp2) then
			rmFile(shp2)
		end

		cl:fill{
			operation = "count",
			name = portos,
			attribute = "pointcount",
			output = pointcountLayerName
		}

		local cs = CellularSpace{
			project = proj,
			layer = pointcountLayerName
		}

		local map = Map{
			target = cs,
			select = "pointcount",
			value = {0, 1, 2},
			color = {"green", "red", "blue"}
		}

		unitTest:assertSnapshot(map, "points-count.png")

		local linecountLayerName = clName2.."_linecount"
		local shp3 = linecountLayerName..".shp"

		table.insert(shapes, shp3)

		if isFile(shp3) then
			rmFile(shp3)
		end

		cl:fill{
			operation = "count",
			name = rodovias,
			attribute = "linecount",
			output = linecountLayerName
		}

		local cs = CellularSpace{
			project = proj,
			layer = linecountLayerName
		}

		local map = Map{
			target = cs,
			select = "linecount",
			min = 0,
			max = 135,
			slices = 10,
			color = {"green", "blue"}
		}

		unitTest:assertSnapshot(map, "lines-count.png")

		local polcountLayerName = clName2.."_polcount"
		local shp4 = polcountLayerName..".shp"

		table.insert(shapes, shp4)

		if isFile(shp4) then
			rmFile(shp4)
		end

		cl:fill{
			operation = "count",
			name = protecao,
			attribute = "polcount",
			output = polcountLayerName
		}

		local cs = CellularSpace{
			project = proj,
			layer = polcountLayerName
		}

		local map = Map{
			target = cs,
			select = "polcount",
			value = {0, 1, 2},
			color = {"green", "red", "blue"}
		}

		unitTest:assertSnapshot(map, "polygons-count.png")

		-- MAXIMUM

		local polmaxLayerName = clName1.."_polmax"
		local shp1 = polmaxLayerName..".shp"

		table.insert(shapes, shp1)

		if isFile(shp1) then
			rmFile(shp1)
		end

		cl:fill{
			operation = "maximum",
			name = municipios,
			attribute = "polmax",
			select = "POPULACAO_",
			output = polmaxLayerName
		}

		local cs = CellularSpace{
			project = proj,
			layer = polmaxLayerName
		}
		local map = Map{
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
		local shp1 = polminLayerName..".shp"

		table.insert(shapes, shp1)

		if isFile(shp1) then
			rmFile(shp1)
		end

		cl:fill{
			operation = "minimum",
			name = municipios,
			attribute = "polmin",
			select = "POPULACAO_",
			output = polminLayerName
		}

		local cs = CellularSpace{
			project = proj,
			layer = polminLayerName
		}

		local map = Map{
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
		local shp1 = polavrgLayerName..".shp"

		table.insert(shapes, shp1)

		if isFile(shp1) then
			rmFile(shp1)
		end

		cl:fill{
			operation = "average",
			name = municipios,
			attribute = "polavrg",
			select = "POPULACAO_",
			output = polavrgLayerName
		}

		local cs = CellularSpace{
			project = proj,
			layer = polavrgLayerName
		}

		local map = Map{
			target = cs,
			select = "polavrg",
			min = 0,
			max = 311000,
			slices = 8,
			color = {"red", "green"}
		}

		unitTest:assertSnapshot(map, "polygons-average.png")



		-- LENGTH

		local lengthLayerName = clName1.."_length"
		local shp5 = lengthLayerName..".shp"

		if isFile(shp5) then
			rmFile(shp5)
		end

		local error_func = function()
			cl:fill{
				operation = "length",
				name = rodovias,
				attribute = "mlength",
				output = lengthLayerName
			}
		end
		unitTest:assertError(error_func, "Sorry, this operation was not implemented in TerraLib yet.")

		local tl = TerraLib()
		tl:finalize()

		forEachElement(shapes, function(_, value)
			rmFile(value)
		end)

		unitTest:assertFile(projName)
	end
}

