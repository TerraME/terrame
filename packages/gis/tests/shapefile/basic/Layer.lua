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
		local filePath1 = filePath("itaituba-census.shp", "gis")
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
			index = false,
			progress = false
		}

		qixFile = string.gsub(cl1.file, ".shp", ".qix")
		unitTest:assert(not File(qixFile):exists())

		local clName2 = "Setores_Cells9x9"
		local cl2
		local indexWarn2 = function()
			cl2 = Layer{
				project = proj,
				source = "shp",
				clean = true,
				input = layerName1,
				name = clName2,
				resolution = 9e3,
				file = clName2..".shp",
				index = true,
				progress = false
			}
		end
		unitTest:assertWarning(indexWarn2, defaultValueMsg("index", true))
		qixFile = string.gsub(cl2.file, ".shp", ".qix")
		unitTest:assert(File(qixFile):exists())

		File(cl1.file):delete()
		File(cl2.file):delete()
		-- \\ SPATIAL INDEX

		local l1Name = "Elevation"
		local l1
		local epsgWarn = function()
			l1 = Layer{
				project = proj,
				name = l1Name,
				file = filePath("cabecadeboi-box.shp", "gis")
			}
		end
		unitTest:assertWarning(epsgWarn, "It was not possible to find the projection of layer 'Elevation'. It should be one of the projections available at www.terrame.org/projections.html")
		unitTest:assertEquals(l1.name, l1Name)

		local clName3 = "PA_Cells50x50"
		local clLayer3
		local indexWarn = function()
			clLayer3 = Layer{
				project = proj,
				source = "shp",
				clean = true,
				input = layerName1,
				name = clName3,
				resolution = 50000,
				file = clName3..".shp",
				index = true,
				progress = false
			}
		end
		unitTest:assertWarning(indexWarn, defaultValueMsg("index", true))
		unitTest:assertEquals(clLayer3.name, clName3)

		proj.file:delete()
		File(clLayer3.file):delete()
	end,
	__len = function(unitTest)
		local projName = "layer_shape_basic.tview"

		local proj = Project{
			file = projName,
			setores = filePath("itaituba-census.shp", "gis"),
			clean = true
		}

		unitTest:assertEquals(#proj.setores, 58)

		proj.file:delete()
	end,
	fill = function(unitTest)
		local allSupportedOperation = function()
			local projName = "cellular_layer_fill_shape.tview"
			local layerName1 = "limitepa"
			local protecao = "protecao"
			local rodovias = "Rodovias"
			local portos = "Portos"
			local amaz = "limiteamaz"

			local proj = Project{
				file = projName,
				clean = true,
				[layerName1] = filePath("test/limitePA_polyc_pol.shp", "gis"),
				[protecao] = filePath("test/BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "gis"),
				[rodovias] = filePath("test/BCIM_Trecho_RodoviarioLine_PA_polyc_lin.shp", "gis"),
				[portos] = filePath("amazonia-ports.shp", "gis"),
				[amaz] = filePath("amazonia-limit.shp", "gis")
			}

			local municipios = "municipios"
			Layer{
				project = proj,
				name = municipios,
				file = filePath("test/municipiosAML_ok.shp", "gis")
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
				file = clName1..".shp",
				progress = false
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
				file = "CellsAmaz.shp",
				progress = false
			}

			-- MODE
			cl:fill{
				operation = "mode",
				layer = municipios,
				attribute = "polmode",
				select = "POPULACAO_",
				progress = false
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
				area = true,
				progress = false
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
				attribute = "marea",
				progress = false
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
				attribute = "lindist",
				progress = false
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
				attribute = "poldist",
				progress = false
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
				attribute = "pointdist",
				progress = false
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
				attribute = "linpres",
				progress = false
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
				attribute = "polpres",
				progress = false
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
				attribute = "pointpres",
				progress = false
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
				file = clName2..".shp",
				progress = false
			}

			clamaz:fill{
				operation = "count",
				layer = portos,
				attribute = "pointcount",
				progress = false
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
				attribute = "linecount",
				progress = false
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
				attribute = "polcount",
				progress = false
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
				select = "POPULACAO_",
				progress = false
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
				select = "POPULACAO_",
				progress = false
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
				select = "POPULACAO_",
				progress = false
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
				select = "POPULACAO_",
				progress = false
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

			-- SUM
			proj.file:delete()

			proj = Project {
				file = "sum_wba.tview",
				clean = true,
				setores = filePath("test/municipiosAML_ok.shp", "gis")
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
				file = shp2,
				progress = false
			}

			cl:fill{
				operation = "sum",
				layer = "setores",
				attribute = "polsuma",
				select = "POPULACAO_",
				area = true,
				progress = false
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
				setores = filePath("itaituba-census.shp", "gis")
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
				file = shp3,
				progress = false
			}

			cl:fill{
				operation = "average",
				layer = "setores",
				attribute = "polavg",
				select = "dens_pop",
				area = true,
				progress = false
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

			proj.file:delete()

			proj = Project{
				file = "municipiosAML.qgs",
				clean = true,
				cities = filePath("test/municipiosAML_ok.shp", "gis")
			}

			cl = Layer{
				project = proj,
				resolution = 200000,
				clean = true,
				file = "munic_cells.shp",
				name = "cells",
				input = "cities",
				progress = false
			}

			table.insert(shapes, "munic_cells.shp")

			local warning_function = function()
				cl:fill{
					operation = "coverage",
					layer = "cities",
					dummy = -1,
					select = "CODMESO",
					attribute = "meso",
					progress = false
				}
			end

			unitTest:assertWarning(warning_function, unnecessaryArgumentMsg("dummy"))

			cs = CellularSpace{
				project = proj,
				layer = "cells"
			}

			map = Map{
				target = cs,
				select = "meso_2",
				color = "RdPu",
				slices = 5
			}

			unitTest:assertSnapshot(map, "polygons-coverage-1.png", 0.1)

			map = Map{
				target = cs,
				select = "meso_3",
				color = "RdPu",
				slices = 5
			}

			unitTest:assertSnapshot(map, "polygons-coverage-2.png", 0.1)

			proj.file:delete()

			forEachElement(shapes, function(_, value)
				File(value):delete()
			end)
		end

		local distanceWithMissing = function()
			local proj = Project{
				file = "layer_shape_basic.tview",
				clean = true
			}

			local l1 = Layer{
				project = proj,
				name = "limit",
				file = filePath("test/compartimento_clip.shp", "gis")
			}

			local l2 = Layer{
				project = proj,
				name = "layer2",
				file = filePath("test/f_silva_clip.shp", "gis")
			}

			local cl = Layer{
				project = proj,
				source = "shp",
				name = "cs",
				input = l1.name,
				resolution = 1000,
				file = "clip.shp",
				clean = true,
				progress = false
			}

			cl:fill{
				layer = l2.name,
				operation = "distance",
				attribute = "dist_f",
				missing = -1,
				progress = false
			}

			local cs = CellularSpace{
				project = proj,
				layer = cl.name
			}

			forEachCell(cs, function(cell)
				if cell.dist_f < 0 then
					unitTest:assertEquals(cell.dist_f, -1)
				end
			end)

			cl:delete()
			proj.file:delete()
		end

		local averageInvalidGeometries = function()
			local proj = Project {
				file = "average_invalid_geom.qgs",
				clean = true
			}

			local csFile = filePath("test/cs2k_teste.shp", "gis")
			csFile:copy(currentDir())

			local cl = Layer{
				project = proj,
				name = "Cells",
				file = "cs2k_teste.shp",
			}

			local defectFile = filePath("test/biomassa.shp", "gis")
			defectFile:copy(currentDir())

			local l1 = Layer{
				project = proj,
				name = "DefectBio",
				file = "biomassa.shp"
			}

			cl:fill{
				layer = l1.name,
				operation = "average",
				attribute = "agb1",
				select = "ABG",
				area = true,
				missing = -999,
				progress = false
			}

			local cs = CellularSpace{
				project = proj,
				layer = cl.name
			}

			forEachCell(cs, function(cell)
				if cell.agb1 < 0 then
					unitTest:assertEquals(cell.agb1, -999)
				end
			end)

			unitTest:assertEquals(#cs, 212)

			local checkWarn = function()
				unitTest:assert(not l1:check(true, false))
			end

		unitTest:assertWarning(checkWarn, [[The following problems were found in the geometries:
1. FID 404: Self-intersection (5502300.9611873, 8212207.8945397).
2. FID 448: Self-intersection (5499667.9683502, 8209876.5162455).
3. FID 607: Self-intersection (5495108.3147666, 8215278.0127216).
4. FID 640: Self-intersection (5494485.5853231, 8210317.9905857).
5. FID 763: Self-intersection (5488464.5058169, 8212262.4394308).]])

			cl:delete()
			csFile:copy(currentDir())

			cl:fill{
				layer = l1.name,
				operation = "average",
				attribute = "agb2",
				select = "ABG",
				area = true,
				progress = false
			}

			cs = CellularSpace{
				project = proj,
				layer = cl.name
			}

			unitTest:assertEquals(#cs, 221)

			forEachCell(cs, function(cell)
				unitTest:assert(cell.agb1 ~= -999)
			end)

			cl:delete()
			l1:delete()
			proj.file:delete()
		end

		unitTest:assert(allSupportedOperation)
		unitTest:assert(distanceWithMissing)
		unitTest:assert(averageInvalidGeometries)
	end,
	projection = function(unitTest)
		local proj = Project {
			file = "layer_shape_basic.tview",
			clean = true
		}

		local layer = Layer{
			project = proj,
			name = "setores",
			file = filePath("itaituba-census.shp", "gis"),
			index = false
		}

		unitTest:assertEquals(layer:projection(), "'SAD69 / UTM zone 21S', with EPSG: 29191 (PROJ4: '+proj=utm +zone=21 +south +ellps=aust_SA +towgs84=-66.87,4.37,-38.52,0,0,0,0 +units=m +no_defs ')")

		layer = Layer{
			project = proj,
			name = "PA",
			file = filePath("test/limitePA_polyc_pol.shp", "gis"),
			index = false
		}

		unitTest:assertEquals(layer:projection(), "'SAD69 / Brazil Polyconic', with EPSG: 29101 (PROJ4: '+proj=poly +lat_0=0 +lon_0=-54 +x_0=5000000 +y_0=10000000 +ellps=aust_SA +towgs84=-66.87,4.37,-38.52,0,0,0,0 +units=m +no_defs ')")

		proj.file:delete()
	end,
	attributes = function(unitTest)
		local projName = "layer_shape_basic.tview"

		local proj = Project {
			file = projName,
			clean = true
		}

		local filePath1 = filePath("itaituba-census.shp", "gis")

		local layerName1 = "setores"
		local layer = Layer{
			project = proj,
			name = layerName1,
			file = filePath1,
			index = false
		}

		local propInfos = layer:attributes()

		unitTest:assertEquals(#propInfos, 3)
		unitTest:assertEquals(propInfos[1].name, "FID")
		unitTest:assertEquals(propInfos[1].type, "integer 32")
		unitTest:assertEquals(propInfos[2].name, "population")
		unitTest:assertEquals(propInfos[2].type, "double")
		unitTest:assertEquals(propInfos[3].name, "dens_pop")
		unitTest:assertEquals(propInfos[3].type, "double")

		proj.file:delete()
	end,
	export = function(unitTest)
		local projName = "layer_shape_basic.tview"

		local proj = Project {
			file = projName,
			clean = true
		}

		local filePath1 = filePath("itaituba-census.shp", "gis")

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
			overwrite = overwrite,
			progress = false
		}

		layer:export(data1)
		unitTest:assert(File(geojson):exists())

		-- OVERWRITE AND CHANGE EPSG
		data1.epsg = 4326
		layer:export(data1)

		local layerName2 = "GJ"
		local layer2 = Layer{
			project = proj,
			name = layerName2,
			file = geojson
		}

		unitTest:assertEquals(layer2.epsg, data1.epsg)
		unitTest:assert(layer.epsg ~= data1.epsg)

		local shp = "setores.shp"
		local data2 = {
			file = shp,
			overwrite = overwrite,
			progress = false
		}

		layer:export(data2)
		unitTest:assert(File(shp):exists())

		-- OVERWRITE AND CHANGE EPSG
		data2.epsg = 4326
		layer:export(data2)

		local layerName3 = "SHP"
		local layer3 = Layer{
			project = proj,
			name = layerName3,
			file = shp
		}

		unitTest:assertEquals(layer3.epsg, data2.epsg)
		unitTest:assert(layer.epsg ~= data2.epsg)

		-- SELECT ONE ATTRIBUTE TO GEOJSON
		data1.select = "population"
		layer:export(data1)
		local attrs1 = layer2:attributes()

		unitTest:assertEquals(attrs1[1].name, "FID")
		unitTest:assertEquals(attrs1[2].name, "population")
		unitTest:assertNil(attrs1[3])

		-- SELECT ONE ATTRIBUTE TO SHAPE
		data2.select = "dens_pop"
		layer:export(data2)
		local attrs2 = layer3:attributes()

		unitTest:assertEquals(attrs2[1].name, "FID")
		unitTest:assertEquals(attrs2[2].name, "dens_pop")
		unitTest:assertNil(attrs2[3])

		File(geojson):delete()
		File(shp):delete()
		proj.file:delete()
	end,
	simplify = function(unitTest)
		local projName = "layer_shape_basic.tview"

		local proj = Project {
			file = projName,
			clean = true
		}

		local filePath1 = filePath("test/rails.shp", "gis")
		local layerName1 = "ES_Rails"
		local layer1 = Layer{
			project = proj,
			name = layerName1,
			file = filePath1
		}

		local rails = "es_rails.shp"
		local data1 = {
			file = rails,
			overwrite = true,
			progress = false
		}

		layer1:export(data1)

		local layerName2 = "ES_Rails_CurrDir"
		local filePath2 = File(rails)

		local layer2 = Layer{
			project = proj,
			name = layerName2,
			file = filePath2
		}

		local outputName = "slp_"..layerName2
		local data2 = {
			output = outputName,
			tolerance = 500
		}

		layer2:simplify(data2)

		local layerName3 = "ES_Rails_Slp"
		local filePath3 = File(string.lower(outputName)..".shp")

		local layer3 = Layer{
			project = proj,
			name = layerName3,
			file = filePath3
		}

		local attrs = layer3:attributes()
		unitTest:assertEquals("FID", attrs[1].name)
		unitTest:assertEquals("OBSERVACAO", attrs[4].name)
		unitTest:assertEquals("PRODUTOS", attrs[7].name)
		unitTest:assertEquals("OPERADORA", attrs[10].name)
		unitTest:assertEquals("Bitola_Ext", attrs[13].name)
		unitTest:assertEquals("COD_PNV", attrs[15].name)

		filePath2:delete()
		filePath3:delete()
		proj.file:delete()
	end,
	polygonize = function(unitTest)
		local projFile = File("polygonize_basic_shp.tview")

		local proj = Project{
			file = projFile,
			clean = true,
		}

		local tifLayer = Layer{
			project = proj,
			name = "Tif",
			file = filePath("emas-accumulation.tif", "gis")
		}

		tifLayer:polygonize{file = File("polygonized.shp"), overwrite = true}

		local shpLayer = Layer{
			project = proj,
			name = "Shp",
			file = File("polygonized.shp")
		}

		local attrs = shpLayer:attributes()
		unitTest:assertEquals("FID", attrs[1].name)
		unitTest:assertEquals("id", attrs[2].name)
		unitTest:assertEquals("value", attrs[3].name)

		shpLayer:delete()
		proj.file:delete()
	end,
	check = function(unitTest)
		local proj = Project {
			file = "check_geom.qgs",
			clean = true
		}

		local defectFile = filePath("test/biomassa.shp", "gis")
		defectFile:copy(currentDir())

		local l1 = Layer{
			project = proj,
			name = "DefectBio",
			file = "biomassa.shp"
		}

		local checkWarn = function()
			unitTest:assert(not l1:check(true, false))
		end

		unitTest:assertWarning(checkWarn, [[The following problems were found in the geometries:
1. FID 404: Self-intersection (5502300.9611873, 8212207.8945397).
2. FID 448: Self-intersection (5499667.9683502, 8209876.5162455).
3. FID 607: Self-intersection (5495108.3147666, 8215278.0127216).
4. FID 640: Self-intersection (5494485.5853231, 8210317.9905857).
5. FID 763: Self-intersection (5488464.5058169, 8212262.4394308).]])

		unitTest:assert(l1:check(true, false))

		l1:delete()
		proj.file:delete()
	end
}

