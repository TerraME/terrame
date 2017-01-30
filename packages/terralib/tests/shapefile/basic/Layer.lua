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
		local projName = "layer_shape_basic.tview"

		local proj = Project {
			file = projName,
			clean = true
		}

		-- SPATIAL INDEX TEST
		local filePath1 = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
		local qixFile = string.gsub(tostring(filePath1), ".shp", ".qix")
		File(qixFile):delete()

		local layerName1 = "Setores"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath1,
			index = false
		}

		unitTest:assert(not File(qixFile):exists())

		proj = Project {
			file = projName,
			clean = true
		}

		Layer{
			project = proj,
			name = layerName1,
			file = filePath1
		}

		unitTest:assert(File(qixFile):exists())

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
		unitTest:assert(not File(qixFile):exists())

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
		unitTest:assert(File(qixFile):exists())

		File(cl1.file):delete()
		File(cl2.file):delete()

		-- VERIFY SRID
		local customWarningBkp = customWarning
		customWarning = function(msg)
			local _, nchars = string.find(msg, "It was not possible to find the projection of layer 'Elevation'.\nThe projection should be one of the availables in: ")
			unitTest:assertEquals(116, nchars)
		end

		Layer{
			project = proj,
			name = "Elevation",
			file = filePath("elevation_box.shp", "terralib")
		}

		customWarning = customWarningBkp
		-- // VERIFY SRID

		proj.file:delete()
	end,
	__len = function(unitTest)
		local projName = "layer_shape_basic.tview"

		local proj = Project{
			file = projName,
			setores = filePath("Setores_Censitarios_2000_pol.shp", "terralib"),
			clean = true
		}

		unitTest:assertEquals(#proj.setores, 58)

		proj.file:delete()
	end,
	fill = function(unitTest)
		local projName = "cellular_layer_fill_shape.tview"

		File(projName):deleteIfExists()

		local customWarningBkp = customWarning
		customWarning = function(msg)
			return msg
		end

		local layerName1 = "limitepa"
		local protecao = "protecao"
		local rodovias = "Rodovias"
		local portos = "Portos"
		local amaz = "limiteamaz"

		local proj = Project{
			file = projName,
			clean = true,
			[layerName1] = filePath("test/limitePA_polyc_pol.shp", "terralib"),
			[protecao] = filePath("BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "terralib"),
			[rodovias] = filePath("BCIM_Trecho_RodoviarioLine_PA_polyc_lin.shp", "terralib"),
			[portos] = filePath("PORTOS_AMZ_pt.shp", "terralib"),
			[amaz] = filePath("LIMITE_AMZ_pol.shp", "terralib")
		}

		local municipios = "municipios"
		Layer{
			project = proj,
			name = municipios,
			file = filePath("test/municipiosAML_ok.shp", "terralib")
		}

		local clName1 = "CellsShp"

		local shapes = {}

		local shp0 = clName1..".shp"
		table.insert(shapes, shp0)
		File(shp0):deleteIfExists()

		local cl = Layer{
			project = proj,
			source = "shp",
			clean = true,
			input = layerName1,
			name = clName1,
			resolution = 70000,
			file = clName1..".shp"
		}

		table.insert(shapes, "CellsAmaz.shp")
		File("CellsAmaz.shp"):deleteIfExists()

		local clamaz = Layer{
			project = proj,
			source = "shp",
			clean = true,
			input = amaz,
			name = "CellsAmaz",
			resolution = 200000,
			file = "CellsAmaz.shp"
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

		clamaz:fill{
			operation = "distance",
			layer = portos,
			attribute = "pointdist"
		}

		cs = CellularSpace{
			project = proj,
			layer = clamaz.name
		}

		map = Map{
			target = cs,
			select = "pointdist",
			min = 0,
			max = 2000000,
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

		clamaz:fill{
			operation = "presence",
			layer = portos,
			attribute = "pointpres"
		}

		cs = CellularSpace{
			project = proj,
			layer = clamaz.name
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
		File(shp1):deleteIfExists()

		local cl2 = Layer{
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName2,
			resolution = 100000,
			file = clName2..".shp"
		}

		clamaz:fill{
			operation = "count",
			layer = portos,
			attribute = "pointcount"
		}

		cs = CellularSpace{
			project = proj,
			layer = clamaz.name
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
		proj.file:delete()

		proj = Project {
			file = "sum_wba.tview",
			clean = true,
			setores = filePath("test/municipiosAML_ok.shp", "terralib")
		}

		clName1 = "cells_set"
		local shp2 = clName1..".shp"
		table.insert(shapes, shp2)
		File(shp2):deleteIfExists()

		cl = Layer{
			project = proj,
			source = "shp",
			clean = true,
			input = "setores",
			name = clName1,
			resolution = 300000,
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
			max = 4000000,
			slices = 20,
			color = {"red", "green"}
		}

		unitTest:assertSnapshot(map, "polygons-sum-area.png")

		-- AVERAGE (area = true)
		proj.file:delete()

		projName = "cellular_layer_fill_avg_area.tview"

		proj = Project {
			file = projName,
			clean = true,
			setores = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
		}

		clName1 = "cells_avg_area"
		local shp3 = clName1..".shp"
		table.insert(shapes, shp3)

		File(shp3):deleteIfExists()

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
			File(value):delete()
		end)

		-- unitTest:assertFile(projName) -- SKIP #1242
		proj.file:delete() -- #1242

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

		unitTest:assertEquals(layer:projection(), "'SAD69 / UTM zone 21S', with SRID: 29191.0 (PROJ4: '+proj=utm +zone=21 +south +ellps=aust_SA +towgs84=-66.87,4.37,-38.52,0,0,0,0 +units=m +no_defs ')")

		local customWarningBkp = customWarning
		customWarning = function(msg)
			return msg
		end

		layer = Layer{
			project = proj,
			name = "PA",
			file = filePath("test/limitePA_polyc_pol.shp", "terralib"),
			index = false
		}

		unitTest:assertEquals(layer:projection(), "'SAD69 / Brazil Polyconic', with SRID: 29101.0 (PROJ4: '+proj=poly +lat_0=0 +lon_0=-54 +x_0=5000000 +y_0=10000000 +ellps=aust_SA +towgs84=-66.87,4.37,-38.52,0,0,0,0 +units=m +no_defs ')")

		customWarning = customWarningBkp

		proj.file:delete()
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

		proj.file:delete()
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
		local data1 = {
			file = geojson,
			overwrite = overwrite
		}

		layer:export(data1)
		unitTest:assert(File(geojson):exists())

		-- OVERWRITE AND CHANGE SRID
		data1.srid = 4326
		layer:export(data1)

		local layerName2 = "GJ"
		local layer2 = Layer{
			project = proj,
			name = layerName2,
			file = geojson
		}

		unitTest:assertEquals(layer2.srid, data1.srid)
		unitTest:assert(layer.srid ~= data1.srid)

		local shp = "setores.shp"
		local data2 = {
			file = shp,
			overwrite = overwrite
		}

		layer:export(data2)
		unitTest:assert(File(shp):exists())

		-- OVERWRITE AND CHANGE SRID
		data2.srid = 4326
		layer:export(data2)

		local layerName3 = "SHP"
		local layer3 = Layer{
			project = proj,
			name = layerName3,
			file = shp
		}

		unitTest:assertEquals(layer3.srid, data2.srid)
		unitTest:assert(layer.srid ~= data2.srid)

		File(geojson):delete()
		File(shp):delete()
		proj.file:delete()
	end
}

