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
		local filePath1 = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
		local qixFile = string.gsub(filePath1, ".shp", ".qix")
		rmFile(qixFile)
		
		local layerName1 = "Setores"
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
		
		local clName1 = "Setores_Cells10x10"
		local cl1 = Layer{
			project = proj,
			source = "shp",
			clean = true,
			input = layerName1,
			name = clName1,
			resolution = 10e3,
			file = clName1..".shp",
			index = false
		}			
		
		qixFile = string.gsub(cl1.file, ".shp", ".qix")
		unitTest:assert(not isFile(qixFile))
		
		local clName2 = "Setores_Cells9x9"
		local cl2 = Layer{
			project = proj,
			source = "shp",
			clean = true,
			input = layerName1,
			name = clName2,
			resolution = 9e3,
			file = clName2..".shp"
		}
		
		qixFile = string.gsub(cl2.file, ".shp", ".qix")
		unitTest:assert(isFile(qixFile))	

		rmFile(cl1.file)
		rmFile(cl2.file)
		-- // SPATIAL INDEX
		
		-- VERIFY SRID
		local customWarningBkp = customWarning
		customWarning = function(msg)
			local _, nchars = string.find(msg, "It was not possible to find the projection of layer 'PA'.\nThe projection should be one of the availables in: ")
			unitTest:assertEquals(109, nchars)	
		end			
		
		Layer{
			project = proj,
			name = "PA",
			file = filePath("limitePA_polyc_pol.shp", "terralib")		
		}			
		
		customWarning = customWarningBkp
		-- // VERIFY SRID		
		
		rmFile(proj.file)
	end,
	fill = function(unitTest)
		local projName = "cellular_layer_fill_shape.tview"
		
		if isFile(projName) then
			rmFile(projName)
		end
		
		local proj = Project {
			file = projName,
			clean = true
		}
		
		local customWarningBkp = customWarning
		customWarning = function(msg)
			return msg
		end				

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
		
		local municipios = "municipios"
		Layer{
			project = proj,
			name = municipios,
			file = filePath("municipiosAML_ok.shp", "terralib")	
		}
		
		local clName1 = "CellsShp"
		
		local shapes = {}
		
		local shp0 = clName1..".shp"
		table.insert(shapes, shp0)
		if isFile(shp0) then
			rmFile(shp0)
		end
		
		local cl = Layer{
			project = proj,
			source = "shp",
			clean = true,
			input = layerName1,
			name = clName1,
			resolution = 50000,
			file = clName1..".shp"
		}
		
		-- MODE
		
		cl:fill{
			operation = "mode",
			layer = municipios,
			attribute = "polmode",
			select = "POPULACAO_"
		}

		local cs = CellularSpace{
			project = proj,
			layer = cl.name
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

		cl:fill{
			operation = "mode",
			layer = municipios,
			attribute = "polmode2",
			select = "POPULACAO_",
			area = true
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
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

		cl:fill{
			operation = "area",
			layer = protecao,
			attribute = "marea"
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
		}

		map = Map{
			target = cs,
			select = "marea",
			min = 0,
			max = 1,
			slices = 8,
			color = {"red", "green"}
		}

		unitTest:assertSnapshot(map, "polygons-area.png", 0.05)

		-- DISTANCE

		cl:fill{
			operation = "distance",
			layer = rodovias,
			attribute = "lindist"
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
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

		cl:fill{
			operation = "distance",
			layer = protecao,
			attribute = "poldist"
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
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

		cl:fill{
			operation = "distance",
			layer = portos,
			attribute = "pointdist"
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
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

		cl:fill{
			operation = "presence",
			layer = rodovias,
			attribute = "linpres"
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
		}

		map = Map{
			target = cs,
			select = "linpres",
			value = {0, 1},
			color = {"green", "red"}
		}

		unitTest:assertSnapshot(map, "lines-presence.png")

		cl:fill{
			operation = "presence",
			layer = protecao,
			attribute = "polpres"
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
		}

		map = Map{
			target = cs,
			select = "polpres",
			value = {0, 1},
			color = {"green", "red"}
		}

		unitTest:assertSnapshot(map, "polygons-presence.png")

		cl:fill{
			operation = "presence",
			layer = portos,
			attribute = "pointpres"
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
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

		local shp1 = clName2..".shp"
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

		cl2:fill{
			operation = "count",
			layer = portos,
			attribute = "pointcount"
		}

		cs = CellularSpace{
			project = proj,
			layer = cl2.name
		}

		map = Map{
			target = cs,
			select = "pointcount",
			value = {0, 1, 2},
			color = {"green", "red", "blue"}
		}

		unitTest:assertSnapshot(map, "points-count.png")

		cl2:fill{
			operation = "count",
			layer = rodovias,
			attribute = "linecount"
		}

		cs = CellularSpace{
			project = proj,
			layer = cl2.name
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

		cl2:fill{
			operation = "count",
			layer = protecao,
			attribute = "polcount"
		}

		cs = CellularSpace{
			project = proj,
			layer = cl2.name
		}

		map = Map{
			target = cs,
			select = "polcount",
			value = {0, 1, 2},
			color = {"green", "red", "blue"}
		}

		unitTest:assertSnapshot(map, "polygons-count.png")

		-- MAXIMUM

		cl:fill{
			operation = "maximum",
			layer = municipios,
			attribute = "polmax",
			select = "POPULACAO_"
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
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

		cl:fill{
			operation = "minimum",
			layer = municipios,
			attribute = "polmin",
			select = "POPULACAO_"
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
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

		cl:fill{
			operation = "average",
			layer = municipios,
			attribute = "polavrg",
			select = "POPULACAO_"
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
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

		cl:fill{
			operation = "stdev",
			layer = municipios,
			attribute = "stdev",
			select = "POPULACAO_"
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
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

		local error_func = function()
			cl:fill{
				operation = "length",
				layer = rodovias,
				attribute = "mlength"
			}
		end
		unitTest:assertError(error_func, "Sorry, this operation was not implemented in TerraLib yet.")

		-- SUM

		rmFile(proj.file)
		
		proj = Project {
			file = "sum_wba.tview",
			clean = true,
			setores = filePath("municipiosAML_ok.shp", "terralib")
		}

		clName1 = "cells_set"
		local shp2 = clName1..".shp"
		table.insert(shapes, shp2)
		if isFile(shp2) then
			rmFile(shp2)
		end		
		
		cl = Layer{
			project = proj,
			source = "shp",
			clean = true,
			input = "setores",
			name = clName1,
			resolution = 50000,
			file = shp2
		}

		cl:fill{
			operation = "sum",
			layer = "setores",
			attribute = "polsuma",
			select = "POPULACAO_",
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
			layer = cl.name
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
		
		rmFile(proj.file)
		
		projName = "cellular_layer_fill_avg_area.tview"

		proj = Project {
			file = projName,
			clean = true,
			setores = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
		}

		clName1 = "cells_avg_area"
		local shp3 = clName1..".shp"
		table.insert(shapes, shp3)

		if isFile(shp3) then
			rmFile(shp3)
		end
		
		cl = Layer{
			project = proj,
			source = "shp",
			clean = true,
			input = "setores",
			name = clName1,
			resolution = 10000,
			file = shp3
		}

		cl:fill{
			operation = "average",
			layer = "setores",
			attribute = "polavg",
			select = "Densde_Pop",
			area = true
		}

		cs = CellularSpace{
			project = proj,
			layer = cl.name
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
				

		forEachElement(shapes, function(_, value)
			rmFile(value)
		end)

		-- unitTest:assertFile(projName) -- SKIP #1301
		rmFile(projName) -- #1301
		
		customWarning = customWarningBkp
	end,
	projection = function(unitTest)
		local proj = Project {
			file = "layer_shape_basic.tview",
			clean = true
		}
		
		local layer = Layer{
			project = proj,
			name = "setores",
			file = filePath("Setores_Censitarios_2000_pol.shp", "terralib"),
			index = false
		}
		
		unitTest:assertEquals(layer:projection(), "'SAD69 / UTM zone 21S', with SRID: 29191.0 (PROJ4: '+proj=utm +zone=21 +south +ellps=aust_SA +towgs84=-66.87,4.37,-38.52,0,0,0,0 +units=m +no_defs ').")

		local customWarningBkp = customWarning
		customWarning = function(msg)
			return msg
		end		
		
		layer = Layer{
			project = proj,
			name = "PA",
			file = filePath("limitePA_polyc_pol.shp", "terralib"),
			index = false
		}	
	
		unitTest:assertEquals(layer:projection(), "Undefined, with SRID: 0.0 (PROJ4: Undefined).")
		
		customWarning = customWarningBkp

		rmFile(proj.file)
	end,
	attributes = function(unitTest)
		local projName = "layer_shape_basic.tview"

		local proj = Project {
			file = projName,
			clean = true
		}
		
		local filePath1 = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
	
		local layerName1 = "setores"
		local layer = Layer{
			project = proj,
			name = layerName1,
			file = filePath1,
			index = false
		}

		local propNames = layer:attributes()
		
		for i = 1, #propNames do
			unitTest:assert((propNames[i] == "FID") or (propNames[i] == "SPRAREA") or 
						(propNames[i] == "SPRPERIMET") or (propNames[i] == "SPRROTULO") or
						(propNames[i] == "Populacao") or (propNames[i] == "objet_id_8") or
						(propNames[i] == "Densde_Pop") or (propNames[i] == "Area"))
		end
		
		rmFile(proj.file)
	end,
	export = function(unitTest)
		local projName = "layer_shape_basic.tview"

		local proj = Project {
			file = projName,
			clean = true
		}
		
		local filePath1 = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
	
		local layerName1 = "setores"
		local layer = Layer{
			project = proj,
			name = layerName1,
			file = filePath1
		}
		
		local overwrite = true
		
		local geojson = "setores.geojson"
		layer:export(geojson, overwrite)
		unitTest:assert(isFile(geojson))
		
		local shp = "setores.shp"
		layer:export(shp, overwrite)
		unitTest:assert(isFile(shp))

		rmFile(geojson)
		rmFile(shp)
		rmFile(proj.file)
	end
}

