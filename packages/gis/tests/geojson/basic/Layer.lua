-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.3 of the License, or (at your option) any later version.

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
		local creatingCellSpaceFromRaster = function()
			local projName = "layer_basic_geojson.tview"

			local proj = Project{
				file = projName,
				clean = true
			}

			local l1
			local indexUnnecessary = function()
				l1 = Layer{
					project = proj,
					name = "Prodes",
					file = filePath("amazonia-prodes.tif", "gis"),
					index = true
				}
			end
			unitTest:assertWarning(indexUnnecessary, unnecessaryArgumentMsg("index"))

			local cl1 = Layer{
				project = proj,
				input = l1.name,
				clean = true,
				name = "Prodes-Cells",
				resolution = 60e3,
				file = "prodes_cells.geojson",
				progress = false
			}

			unitTest:assertEquals(cl1.source, "geojson")
			unitTest:assert(File(cl1.file):exists())

			local cs1 = CellularSpace{
				project = proj,
				layer = cl1.name
			}

			unitTest:assertEquals(#cs1, 2640)

			-- CLEAN TEST
			local cl2 = Layer{
				project = proj,
				input = l1.name,
				clean = true,
				name = "Prodes-Cells-2",
				resolution = 60e3,
				file = "prodes_cells.geojson",
				progress = false
			}

			unitTest:assertEquals(cl1.source, "geojson")
			unitTest:assert(File(cl1.file):exists())

			local cs2 = CellularSpace{
				project = proj,
				layer = cl2.name
			}

			unitTest:assertEquals(#cs2, 2640)

			File(cl1.file):delete()
			proj.file:delete()
		end

		unitTest:assert(creatingCellSpaceFromRaster)
	end,
	polygonize = function(unitTest)
		local projFile = File("polygonize_basic_geojson.tview")

		local proj = Project{
			file = projFile,
			clean = true,
		}

		local tifLayer = Layer{
			project = proj,
			name = "Tif",
			file = filePath("emas-accumulation.tif", "gis")
		}

		tifLayer:polygonize{file = "polygonized.geojson", overwrite = true}

		local gjsonLayer = Layer{
			project = proj,
			name = "GeoJson",
			file = "polygonized.geojson"
		}

		local attrs = gjsonLayer:attributes()
		unitTest:assertEquals("FID", attrs[1].name)
		unitTest:assertEquals("id", attrs[2].name)
		unitTest:assertEquals("value", attrs[3].name)

		gjsonLayer:delete()
		proj.file:delete()
	end,
	fill = function(unitTest)
		local allSupportedOperation = function()
			local proj = Project{
				file = "fill_geojson_basic.tview",
				clean = true,
			}

			local counties = Layer{
				project = proj,
				name = "Counties",
				file = filePath("test/municipiosAML_ok.shp", "gis")
			}

			local files = {}

			local countiesFileGjson = "municipiosAML_ok.geojson"
			table.insert(files, countiesFileGjson)
			counties:export{file = countiesFileGjson, overwrite = true, progress = false}

			local paLimit = Layer{
				project = proj,
				name = "PA-Limit",
				file = filePath("test/limitePA_polyc_pol.shp", "gis")
			}

			local paLimitFileGjson = "limitePA_polyc_pol.geojson"
			table.insert(files, paLimitFileGjson)
			paLimit:export{file = paLimitFileGjson, overwrite = true, progress = false}

			local countiesGjson = Layer{
				project = proj,
				name = counties.name.."-GJson",
				file = countiesFileGjson
			}

			local paLimitGjson = Layer{
				project = proj,
				name = paLimit.name.."-GJson",
				file = paLimitFileGjson
			}

			local cl1Name = "csPA"
			local cl1File = cl1Name..".geojson"
			table.insert(files, cl1File)

			local cl1 = Layer{
				project = proj,
				clean = true,
				input = paLimitGjson.name,
				name = cl1Name,
				resolution = 70000,
				file = files[3],
				progress = false
			}

			-- MODE
			-- TODO(#2327)
			-- cl1:fill{
				-- operation = "mode",
				-- layer = countiesGjson.name,
				-- attribute = "polmode",
				-- select = "POPULACAO_",
				-- progress = false
			-- }

			-- local cs = CellularSpace{
				-- project = proj,
				-- layer = cl1.name
			-- }

			-- local map = Map{
				-- target = cs,
				-- select = "polmode",
				-- value = {"0", "53217", "37086", "14302"},
				-- color = {"red", "green", "blue", "yellow"}
			-- }

			-- unitTest:assertSnapshot(map, "polygons-mode-geojson.png", 0.01) --SKIP

			-- -- MODE (area = true)
			-- cl1:fill{
				-- operation = "mode",
				-- layer = countiesGjson.name,
				-- attribute = "polmode2",
				-- select = "POPULACAO_",
				-- area = true,
				-- progress = false
			-- }

			-- cs = CellularSpace{
				-- project = proj,
				-- layer = cl1.name
			-- }

			-- map = Map{
				-- target = cs,
				-- select = "polmode2",
				-- min = 0,
				-- max = 1410000,
				-- slices = 8,
				-- color = {"red", "green"}
			-- }

			-- unitTest:assertSnapshot(map, "polygons-mode-2-geojson.png") --SKIP

			local protect = Layer{
				project = proj,
				name = "Protect-Area",
				file = filePath("test/BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "gis")
			}

			local protectFileGjson = "BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.geojson"
			protect:export{file = protectFileGjson, overwrite = true, progress = false}
			table.insert(files, protectFileGjson)

			local protectGjson = Layer{
				project = proj,
				name = protect.name.."-GJson",
				file = protectFileGjson
			}

			-- AREA
			cl1:fill{
				operation = "area",
				layer = protectGjson,
				attribute = "marea",
				progress = false
			}

			cs = CellularSpace{
				project = proj,
				layer = cl1.name
			}

			map = Map{
				target = cs,
				select = "marea",
				min = 0,
				max = 1,
				slices = 8,
				color = {"red", "green"}
			}

			unitTest:assertSnapshot(map, "polygons-area-geojson.png", 0.02)

			local roads = Layer{
				project = proj,
				name = "Roads",
				file = filePath("test/BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "gis")
			}

			local roadsFileGjson = "BCIM_Trecho_RodoviarioLine_PA_polyc_lin.geojson"
			roads:export{file = roadsFileGjson, overwrite = true, progress = false}
			table.insert(files, roadsFileGjson)

			local roadsGjson = Layer{
				project = proj,
				name = roads.name.."-GJson",
				file = roadsFileGjson
			}

			-- DISTANCE
			cl1:fill{
				operation = "distance",
				layer = roadsGjson,
				attribute = "lindist",
				progress = false
			}

			cs = CellularSpace{
				project = proj,
				layer = cl1.name
			}

			map = Map{
				target = cs,
				select = "lindist",
				min = 0,
				max = 200000,
				slices = 8,
				color = {"green", "red"}
			}

			unitTest:assertSnapshot(map, "lines-distance-geojson.png")

			cl1:fill{
				operation = "distance",
				layer = protectGjson,
				attribute = "poldist",
				progress = false
			}

			cs = CellularSpace{
				project = proj,
				layer = cl1.name
			}

			map = Map{
				target = cs,
				select = "poldist",
				min = 0,
				max = 370000,
				slices = 8,
				color = {"green", "red"}
			}

			unitTest:assertSnapshot(map, "polygons-distance-geojson.png")

			-- PRESENCE
			cl1:fill{
				operation = "presence",
				layer = roadsGjson,
				attribute = "linpres",
				progress = false
			}

			cs = CellularSpace{
				project = proj,
				layer = cl1.name
			}

			map = Map{
				target = cs,
				select = "linpres",
				value = {0, 1},
				color = {"green", "red"}
			}

			unitTest:assertSnapshot(map, "lines-presence-geojson.png")

			cl1:fill{
				operation = "presence",
				layer = protectGjson,
				attribute = "polpres",
				progress = false
			}

			cs = CellularSpace{
				project = proj,
				layer = cl1.name
			}

			map = Map{
				target = cs,
				select = "polpres",
				value = {0, 1},
				color = {"green", "red"}
			}

			unitTest:assertSnapshot(map, "polygons-presence-geojson.png")

			local cl2Name = "csPALarge"
			local cl2File = cl2Name..".geojson"
			table.insert(files, cl2File)
			local cl2 = Layer{
				project = proj,
				clean = true,
				input = paLimitGjson.name,
				name = cl2Name,
				resolution = 100000,
				file = cl2File,
				progress = false
			}

			-- COUNT
			cl2:fill{
				operation = "count",
				layer = roadsGjson,
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

			unitTest:assertSnapshot(map, "lines-count-geojson.png")

			cl2:fill{
				operation = "count",
				layer = protectGjson,
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

			unitTest:assertSnapshot(map, "polygons-count-geojson.png")

			-- MAXIMUM
			cl1:fill{
				operation = "maximum",
				layer = countiesGjson,
				attribute = "polmax",
				select = "POPULACAO_",
				progress = false
			}

			cs = CellularSpace{
				project = proj,
				layer = cl1.name
			}

			map = Map{
				target = cs,
				select = "polmax",
				min = 0,
				max = 1450000,
				slices = 8,
				color = {"red", "green"}
			}

			unitTest:assertSnapshot(map, "polygons-maximum-geojson.png")

			-- MINIMUM
			cl1:fill{
				operation = "minimum",
				layer = countiesGjson,
				attribute = "polmin",
				select = "POPULACAO_",
				progress = false
			}

			cs = CellularSpace{
				project = proj,
				layer = cl1.name
			}

			map = Map{
				target = cs,
				select = "polmin",
				min = 0,
				max = 275000,
				slices = 8,
				color = {"red", "green"}
			}

			unitTest:assertSnapshot(map, "polygons-minimum-geojson.png")

			-- AVERAGE
			cl1:fill{
				operation = "average",
				layer = countiesGjson,
				attribute = "polavrg",
				select = "POPULACAO_",
				progress = false
			}

			cs = CellularSpace{
				project = proj,
				layer = cl1.name
			}

			map = Map{
				target = cs,
				select = "polavrg",
				min = 0,
				max = 311000,
				slices = 8,
				color = {"red", "green"}
			}

			unitTest:assertSnapshot(map, "polygons-average-geojson.png", 0.005)

			-- STDEV
			cl1:fill{
				operation = "stdev",
				layer = countiesGjson,
				attribute = "stdev",
				select = "POPULACAO_",
				progress = false
			}

			cs = CellularSpace{
				project = proj,
				layer = cl1.name
			}

			map = Map{
				target = cs,
				select = "stdev",
				min = 0,
				max = 550000,
				slices = 8,
				color = {"red", "green"}
			}

			unitTest:assertSnapshot(map, "polygons-stdev-geojson.png")

			local cl3Name = "CellsSet"
			local cl3File = cl3Name..".geojson"
			table.insert(files, cl3File)
			local cl3 = Layer{
				project = proj,
				clean = true,
				input = countiesGjson.name,
				name = cl3Name,
				resolution = 300000,
				file = cl3File,
				progress = false
			}

			-- SUM
			cl3:fill{
				operation = "sum",
				layer = countiesGjson,
				attribute = "polsuma",
				select = "POPULACAO_",
				area = true,
				progress = false
			}

			cs = CellularSpace{
				project = proj,
				layer = countiesGjson.name
			}

			local sum1 = 0
			forEachCell(cs, function(cell)
				sum1 = sum1 + cell.POPULACAO_
			end)

			cs = CellularSpace{
				project = proj,
				layer = cl3.name
			}

			local sum2 = 0
			forEachCell(cs, function(cell)
				sum2 = sum2 + cell.polsuma
			end)

			-- unitTest:assertEquals(sum1, sum2, 1e-4) -- SKIP TODO(#2225)

			map = Map{
				target = cs,
				select = "polsuma",
				min = 0,
				max = 4000000,
				slices = 20,
				color = {"red", "green"}
			}

			unitTest:assertSnapshot(map, "polygons-sum-area-geojson.png", 0.01)

			local sectors = Layer{
				project = proj,
				name = "Sectors",
				file = filePath("itaituba-census.shp", "gis")
			}

			local sectorsFileGjson = "itaituba-census.geojson"
			sectors:export{file = sectorsFileGjson, overwrite = true, progress = false}
			table.insert(files, sectorsFileGjson)

			local sectorsGjson = Layer{
				project = proj,
				name = sectors.name.."-GJson",
				file = sectorsFileGjson
			}

			local cl4Name = "CellsAvg"
			local cl4File= cl4Name..".geojson"
			table.insert(files, cl4File)
			local cl4 = Layer{
				project = proj,
				clean = true,
				input = sectorsGjson.name,
				name = cl4Name,
				resolution = 10000,
				file = cl4File,
				progress = false
			}

			-- AVERAGE (area = true)
			cl4:fill{
				operation = "average",
				layer = sectorsGjson,
				attribute = "polavg",
				select = "dens_pop",
				area = true,
				progress = false
			}

			cs = CellularSpace{
				project = proj,
				layer = cl4.name
			}

			map = Map{
				target = cs,
				select = "polavg",
				min = 0,
				max = 36,
				slices = 8,
				color = {"red", "green"}
			}

			unitTest:assertSnapshot(map, "polygons-average-area-geojson.png")

			local cl5 = Layer{
				project = proj,
				resolution = 200000,
				clean = true,
				file = "CountiesCells.geojson",
				name = "CountiesCells",
				input = countiesGjson.name,
				progress = false
			}

			table.insert(files, cl5.file)

			local warn = function()
				cl5:fill{
					operation = "coverage",
					layer = countiesGjson,
					dummy = -1,
					select = "CODMESO",
					attribute = "meso",
					progress = false
				}
			end

			unitTest:assertWarning(warn, unnecessaryArgumentMsg("dummy"))

			cs = CellularSpace{
				project = proj,
				layer = cl5.name
			}

			map = Map{
				target = cs,
				select = "meso_2",
				color = "RdPu",
				slices = 5
			}

			unitTest:assertSnapshot(map, "polygons-coverage-1-geojson.png")

			map = Map{
				target = cs,
				select = "meso_3",
				color = "RdPu",
				slices = 5
			}

			unitTest:assertSnapshot(map, "polygons-coverage-2-geojson.png", 0.005)

			local amz = Layer{
				project = proj,
				name = "Amazonia",
				file = filePath("amazonia-limit.shp", "gis")
			}

			local amzFileGjson = "amazonia-limit.geojson"
			amz:export{file = amzFileGjson, overwrite = true, progress = false}
			table.insert(files, amzFileGjson)

			local amzGjson = Layer{
				project = proj,
				name = amz.name.."-GJson",
				file = amzFileGjson
			}

			local cl6 = Layer{
				project = proj,
				clean = true,
				input = amzGjson.name,
				name = "CellsAmaz",
				resolution = 200000,
				file = "CellsAmaz.geojson",
				progress = false
			}

			table.insert(files, cl6.file)

			local ports = Layer{
				project = proj,
				name = "Ports",
				file = filePath("amazonia-ports.shp", "gis")
			}

			local portsFileGjson = "amazonia-ports.geojson"
			ports:export{file = portsFileGjson, overwrite = true, progress = false}
			table.insert(files, portsFileGjson)

			local portsGjson = Layer{
				project = proj,
				name = ports.name.."-GJson",
				file = portsFileGjson
			}

			-- DISTANCE
			cl6:fill{
				operation = "distance",
				layer = portsGjson,
				attribute = "pointdist",
				progress = false
			}

			cs = CellularSpace{
				project = proj,
				layer = cl6.name
			}

			map = Map{
				target = cs,
				select = "pointdist",
				min = 0,
				max = 2000000,
				slices = 8,
				color = {"green", "red"}
			}

			unitTest:assertSnapshot(map, "points-distance-geojson.png")

			-- PRESENCE
			cl6:fill{
				operation = "presence",
				layer = portsGjson,
				attribute = "pointpres",
				progress = false
			}

			cs = CellularSpace{
				project = proj,
				layer = cl6.name
			}

			map = Map{
				target = cs,
				select = "pointpres",
				value = {0, 1},
				color = {"green", "red"}
			}

			unitTest:assertSnapshot(map, "points-presence-geojson.png")

			-- COUNT
			cl6:fill{
				operation = "count",
				layer = portsGjson,
				attribute = "pointcount",
				progress = false
			}

			cs = CellularSpace{
				project = proj,
				layer = cl6.name
			}

			map = Map{
				target = cs,
				select = "pointcount",
				value = {0, 1, 2},
				color = {"green", "red", "blue"}
			}

			unitTest:assertSnapshot(map, "points-count-geojson.png")

			for i = 1, #files do
				File(files[i]):delete()
			end

			proj.file:delete()
		end

		unitTest:assert(allSupportedOperation)
	end
}
