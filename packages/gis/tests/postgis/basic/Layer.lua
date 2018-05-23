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
		local twoLayersInTheSameDb = function()
			local projName = "layer_postgis_basic.tview"
			local proj1 = Project{
				file = projName,
				clean = true
			}

			local layerName1 = "Sampa"

			local layer1 = Layer{
				project = proj1,
				name = layerName1,
				file = filePath("test/sampa.shp", "gis")
			}

			unitTest:assertEquals(layer1.name, layerName1)

			local password = "postgres"
			local database = "postgis_22_sample"
			local tableName = "sampa"

			local pgData = {
				source = "postgis",
				--host = host,
				--port = port,
				password = password,
				database = database,
				overwrite = true
			}

			layer1:export(pgData, true)

			local layerName2 = "SampaDB"

			local layer2 = Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				-- host = host,
				-- port = port,
				password = password,
				database = database,
				table = tableName
			}

			unitTest:assertEquals(layer2.name, layerName2)

			local layerName3 = "Another_SampaDB"

			local layer3 = Layer{
				project = proj1,
				source = "postgis",
				name = layerName3,
				-- host = host,
				-- port = port,
				password = password,
				database = database,
				table = tableName
			}

			unitTest:assert(layer3.name ~= layer2.name)
			unitTest:assertEquals(layer3.epsg, layer2.epsg)

			pgData.host = "localhost"
			pgData.port = 5432

			File(projName):deleteIfExists()
			layer3:delete()
		end

		local creatingCellSpaceFromShp = function()
			local projName = "cells_setores_2000.tview"
			local proj = Project{
				file = projName,
				clean = true
			}

			local layerName1 = "Sampa"
			Layer{
				project = proj,
				name = layerName1,
				file = filePath("test/sampa.shp", "gis")
			}

			local clName1 = "Sampa_Cells"
			local tName1 = "add_cellslayer_basic"

			local host = "localhost"
			local port = "5432"
			local password = "postgres"
			local database = "postgis_22_sample"

			local pgData = {
				type = "POSTGIS",
				host = host,
				port = port,
				password = password,
				database = database,
				table = tName1,
				user = "postgres"
			}

			local cl1 = Layer{
				project = proj,
				source = "postgis",
				clean = true,
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				password = password,
				database = database,
				table = tName1
			}

			unitTest:assertEquals(cl1.name, clName1)

			local clName2 = "Another_Sampa_Cells"
			local tName2 = "add_cellslayer_basic_another"

			pgData.table = tName2

			local cl2 = Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				clean = true,
				name = clName2,
				resolution = 0.7,
				password = password,
				database = database,
				table = tName2
			}

			unitTest:assertEquals(cl2.name, clName2)

			local clName3 = "Other_Sampa_Cells"
			local tName3 = "add_cellslayer_basic_from_db"

			pgData.table = tName3

			local cl3 = Layer{
				project = proj,
				source = "postgis",
				input = clName2,
				name = clName3,
				clean = true,
				resolution = 0.7,
				password = password,
				database = database,
				table = tName3
			}

			unitTest:assertEquals(cl3.name, clName3)

			local newDbName = "new_pg_db_30032017"
			pgData.database = newDbName
			TerraLib().dropPgDatabase(pgData)

			local clName4 = "New_Sampa_Cells"

			local cl4 = Layer{
				project = proj,
				source = "postgis",
				input = clName2,
				name = clName4,
				resolution = 0.7,
				password = password,
				database = newDbName
			}

			unitTest:assertEquals(cl4.source, "postgis")
			unitTest:assertEquals(cl4.host, host)
			unitTest:assertEquals(cl4.port, port)
			unitTest:assertEquals(cl4.user, "postgres")
			unitTest:assertEquals(cl4.password, password)
			unitTest:assertEquals(cl4.database, newDbName)
			unitTest:assertEquals(cl4.table, string.lower(clName4))

			-- BOX TEST
			local clSetSize = TerraLib().getLayerSize(proj, clName1)
			unitTest:assertEquals(clSetSize, 68)

			local clName5 = clName1.."_Box"
			local cl5
			local unnecessaryArgument = function()
				cl5 = Layer{
					project = proj,
					source = "postgis",
					input = layerName1,
					clean = true,
					name = clName5,
					resolution = 0.7,
					box = true,
					password = password,
					database = database,
					file = filePath("test/sampa.shp", "gis")
				}
			end
			unitTest:assertWarning(unnecessaryArgument, unnecessaryArgumentMsg("file"))
			clSetSize = TerraLib().getLayerSize(proj, clName5)
			unitTest:assertEquals(clSetSize, 104)

			-- CHANGE EPSG
			local clName6 = "SampaDBNewSrid"
			local cl6
			local indexUnnecessary = function()
				cl6 = Layer{
					project = proj,
					source = "postgis",
					name = clName6,
					-- host = host,
					-- port = port,
					password = password,
					database = database,
					table = tName1,
					epsg = 29901,
					index = true
				}
			end
			unitTest:assertWarning(indexUnnecessary, unnecessaryArgumentMsg("index"))
			unitTest:assertEquals(cl6.epsg, 29901.0)
			unitTest:assert(cl6.epsg ~= cl4.epsg)

			-- DEFAULT TABLE NAME
			local clName7 = "DefaultTableName"
			local cl7
			local defaultTableName = function()
				cl7 = Layer{
					project = proj,
					source = "postgis",
					name = clName7,
					password = password,
					database = database,
					table = clName7,
					resolution = 0.7,
					input = layerName1,
					clean = true
				}
			end
			unitTest:assertWarning(defaultTableName, defaultValueMsg("table", string.lower(clName7)))
			unitTest:assertEquals(cl7.name, clName7)
			unitTest:assertEquals(cl7.table, string.lower(clName7))

			local cl8
			defaultTableName = function()
				cl8 = Layer{
					project = proj,
					source = "postgis",
					name = tName1,
					password = password,
					database = database,
					table = tName1,
					epsg = 29901
				}
			end
			unitTest:assertWarning(defaultTableName, defaultValueMsg("table", tName1))
			unitTest:assertEquals(cl8.name, tName1)
			unitTest:assertEquals(cl8.table, tName1)

			local cl9 = Layer{
				project = proj,
				source = "postgis",
				name = tName3,
				password = password,
				database = database,
				epsg = 29901
			}

			unitTest:assertEquals(cl9.name, tName3)
			unitTest:assertEquals(cl9.table, tName3)
			--// DEFAULT TABLE NAME

			cl1:delete()
			cl2:delete()
			cl3:delete()
			cl4:delete()
			cl4:drop()
			cl5:delete()
			cl6:delete()
			cl7:delete()
			proj.file:delete()
		end

		local creatingCellSpaceFromTif = function()
			local projName = "pg_layer_basic.tview"
			local proj = Project{
				file = projName,
				clean = true
			}

			local layerName1 = "Amz"
			Layer{
				project = proj,
				name = layerName1,
				epsg = 29191,
				file = filePath("amazonia-prodes.tif", "gis")
			}

			local host = "localhost"
			local port = "5432"
			local password = "postgres"
			local database = "postgis_22_sample"
			local tableName = "prodes_pg_cells"

			local clName = "ProdesPg"
			local cl = Layer{
				project = proj,
				source = "postgis",
				clean = true,
				input = layerName1,
				name = clName,
				resolution = 30e3,
				password = password,
				database = database,
				table = tableName
			}

			unitTest:assertEquals(cl.source, "postgis")
			unitTest:assertEquals(cl.host, host)
			unitTest:assertEquals(cl.port, port)
			unitTest:assertEquals(cl.user, "postgres")
			unitTest:assertEquals(cl.password, password)
			unitTest:assertEquals(cl.database, database)
			unitTest:assertEquals(cl.table, tableName)

			cl:delete()
			proj.file:delete()
		end

		local creatingCellSpaceWithoutTableName = function()
			local projName = "cells_pg_basic.tview"
			local proj = Project{
				file = projName,
				clean = true
			}

			local layerName1 = "Sampa"
			Layer{
				project = proj,
				name = layerName1,
				file = filePath("test/sampa.shp", "gis")
			}

			local clName1 = "Sampa_Cells"
			local password = "postgres"
			local database = "postgis_22_sample"

			local cl = Layer{
				project = proj,
				source = "postgis",
				clean = true,
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				password = password,
				database = database
			}

			unitTest:assertEquals(cl.table, string.lower(clName1))

			cl:delete()
			proj.file:delete()
		end

		unitTest:assert(twoLayersInTheSameDb)
		unitTest:assert(creatingCellSpaceFromShp)
		unitTest:assert(creatingCellSpaceFromTif)
		unitTest:assert(creatingCellSpaceWithoutTableName)
	end,
	delete = function(unitTest)
		local projName = "layer_delete_pgis.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local layerName1 = "Setores"

		Layer{
			project = proj,
			name = layerName1,
			file = filePath("itaituba-census.shp", "gis")
		}

		local password = "postgres"
		local database = "postgis_del"

		local pgConnInfo = {
			host = "localhost",
			port = "5432",
			user = "postgres",
			password = password,
			database = database
		}
		TerraLib().dropPgDatabase(pgConnInfo)

		local clName1 = "Setores_Cells"
		local layer = Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			name = clName1,
			resolution = 5e3,
			clean = true,
			password = password,
			database = database
		}

		unitTest:assert(true)

		proj.file:delete()
		layer:delete()
		layer:drop()
	end,
	fill = function(unitTest)
		local projName = "cellular_layer_fill_pgis.tview"
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

		local password = "postgres"
		local database = "postgis_fill"

		local pgConnInfo = {
			host = "localhost",
			port = "5432",
			user = "postgres",
			password = password,
			database = database
		}

		TerraLib().dropPgDatabase(pgConnInfo)

		local clName1 = "Setores_Cells"

		local cl = Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			name = clName1,
			resolution = 70000,
			clean = true,
			password = password,
			database = database
		}

		local clamaz = Layer{
			project = proj,
			source = "postgis",
			input = amaz,
			name = "CellsAmaz",
			resolution = 200000,
			clean = true,
			password = password,
			database = database
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

		unitTest:assertSnapshot(map, "polygons-mode-pg.png")

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

		unitTest:assertSnapshot(map, "polygons-mode-2-pg.png")

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

		unitTest:assertSnapshot(map, "polygons-area-pg.png", 0.05)

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

		unitTest:assertSnapshot(map, "lines-distance-pg.png")

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

		unitTest:assertSnapshot(map, "polygons-distance-pg.png")

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

		unitTest:assertSnapshot(map, "points-distance-pg.png")

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

		unitTest:assertSnapshot(map, "lines-presence-pg.png")

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

		unitTest:assertSnapshot(map, "polygons-presence-pg.png")

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

		unitTest:assertSnapshot(map, "points-presence-pg.png")

		-- COUNT
		local clName2 = "cells_large"

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

		unitTest:assertSnapshot(map, "points-count-pg.png")

		local cl2 = Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			name = clName2,
			resolution = 100000,
			clean = true,
			password = password,
			database = database
		}

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

		unitTest:assertSnapshot(map, "lines-count-pg.png")

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

		unitTest:assertSnapshot(map, "polygons-count-pg.png")

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

		unitTest:assertSnapshot(map, "polygons-maximum-pg.png")

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

		unitTest:assertSnapshot(map, "polygons-minimum-pg.png")

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

		unitTest:assertSnapshot(map, "polygons-average-pg.png")

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

		unitTest:assertSnapshot(map, "polygons-stdev-pg.png")

		-- SUM
		proj.file:delete()

		proj = Project {
			file = "sum_wba.tview",
			clean = true,
			setores = filePath("test/municipiosAML_ok.shp", "gis")
		}

		clName1 = "cells_set"

		cl = Layer{
			project = proj,
			source = "postgis",
			input = "setores",
			name = clName1,
			resolution = 300000,
			clean = true,
			password = password,
			database = database
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

		unitTest:assertSnapshot(map, "polygons-sum-area-pg.png")

		-- AVERAGE (area = true)
		proj.file:delete()

		projName = "cellular_layer_fill_avg_area.tview"

		proj = Project {
			file = projName,
			clean = true,
			setores = filePath("itaituba-census.shp", "gis")
		}

		clName1 = "cells_avg_area"

		cl = Layer{
			project = proj,
			source = "postgis",
			input = "setores",
			name = clName1,
			resolution = 10000,
			clean = true,
			password = password,
			database = database
		}

		cl:fill{
			operation = "average",
			layer = "setores",
			attribute = "polavg",
			select = "dens_pop",
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

		unitTest:assertSnapshot(map, "polygons-average-area-pg.png")

		proj.file:delete()

		proj = Project{
			file = "municipiosAML.tview",
			clean = true,
			cities = filePath("test/municipiosAML_ok.shp", "gis")
		}

		cl = Layer{
			project = proj,
			source = "postgis",
			input = "cities",
			name = "cells",
			resolution = 200000,
			clean = true,
			password = password,
			database = database,
			table = "cs200km"
		}

		cl:fill{
			operation = "coverage",
			layer = "cities",
			select = "CODMESO",
			attribute = "meso"
		}

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

		unitTest:assertSnapshot(map, "polygons-coverage-1-pg.png", 0.1)

		map = Map{
			target = cs,
			select = "meso_3",
			color = "RdPu",
			slices = 5
		}

		unitTest:assertSnapshot(map, "polygons-coverage-2-pg.png", 0.1)

		proj.file:delete()

		-- TIFF
		projName = "layer_fill_tif.tview"

		proj = Project{
			file = projName,
			clean = true
		}

		layerName1 = "limiteitaituba"
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
		Layer{
			project = proj,
			name = altimetria,
			file = filePath("itaituba-elevation.tif", "gis"),
			epsg = l1.epsg
		}

		clName1 = "CellsTif"

		cl = Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			name = clName1,
			resolution = 10000,
			clean = true,
			password = password,
			database = database
		}

		-- MODE

		cl:fill{
			operation = "mode",
			attribute = "prod_mode",
			layer = prodes
		}

		cs = CellularSpace{
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

		map = Map{
			target = cs,
			select = "prod_mode",
			value = {"7", "87", "167", "255"},
			color = {"red", "green", "blue", "orange"}
		}

		unitTest:assertSnapshot(map, "tiff-mode-pg.png")

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

		unitTest:assertSnapshot(map, "tiff-min-pg.png")

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

		unitTest:assertSnapshot(map, "tiff-max-pg.png")

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

		unitTest:assertSnapshot(map, "tiff-sum-pg.png")

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
				max = 1,
				slices = 10,
				color = "RdPu"
			}

			unitTest:assertSnapshot(mmap, "tiff-cov-"..cov[i].."-pg.png", 0.1)
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

		unitTest:assertSnapshot(map, "tiff-average-pg.png")

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

		unitTest:assertSnapshot(map, "tiff-std-pg.png")

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

		unitTest:assertSnapshot(map, "tiff-average-nodata-pg.png")

		File(projName):delete()
		cl:drop()
	end,
	projection = function(unitTest)
		local projName = "layer_basic.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local layerName1 = "Setores"

		local layer1 = Layer{
			project = proj,
			name = layerName1,
			file = filePath("itaituba-census.shp", "gis")
		}

		unitTest:assertEquals(layer1.name, layerName1)

		local password = "postgres"
		local database = "postgis_22_sample"

		local clName1 = "Setores_Cells"
		local layer = Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			name = clName1,
			resolution = 5e3,
			clean = true,
			password = password,
			database = database
		}

		unitTest:assertEquals(layer:projection(), "'SAD69 / UTM zone 21S', with EPSG: 29191 (PROJ4: '+proj=utm +zone=21 +south +ellps=aust_SA +towgs84=-66.87,4.37,-38.52,0,0,0,0 +units=m +no_defs ')")

		proj.file:delete()
		layer:delete()
	end,
	attributes = function(unitTest)
		local projName = "layer_basic.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local layerName1 = "Setores"

		local layer1 = Layer{
			project = proj,
			name = layerName1,
			file = filePath("itaituba-census.shp", "gis")
		}

		unitTest:assertEquals(layer1.name, layerName1)

		local password = "postgres"
		local database = "postgis_22_sample"

		local clName1 = "Setores_Cells"
		local layer = Layer{
			project = proj,
			input = layerName1,
			name = clName1,
			resolution = 5e3,
			clean = true,
			password = password,
			database = database
		}

		local propInfos = layer:attributes()

		unitTest:assertEquals(#propInfos, 3)
		unitTest:assertEquals(propInfos[1].name, "id")
		unitTest:assertEquals(propInfos[1].type, "string")
		unitTest:assertEquals(propInfos[2].name, "col")
		unitTest:assertEquals(propInfos[2].type, "integer 32")
		unitTest:assertEquals(propInfos[3].name, "row")
		unitTest:assertEquals(propInfos[3].type, "integer 32")

		proj.file:delete()
		layer:delete()
	end,
	export = function(unitTest)
		local projName = "layer_postgis_basic.tview"

		local proj = Project {
			file = projName,
			clean = true
		}

		local filePath1 = filePath("test/MG_cities.shp", "gis")

		local layerName1 = "mg"
		local layer1 = Layer{
			project = proj,
			name = layerName1,
			file = filePath1
		}

		local overwrite = true

		local password = getConfig().password
		local database = "postgis_22_sample"
		local tableName = "mg"

		local pgData = {
			source = "postgis",
			password = password,
			database = database,
			overwrite = overwrite,
			epsg = 4036
		}

		layer1:export(pgData)

		local layerName2 = "mgpg"
		local layer2 = Layer{
			project = proj,
			source = "postgis",
			name = layerName2,
			password = password,
			database = database,
			table = tableName
		}

		local geojson = "mg.geojson"
		local data1 = {
			file = geojson,
			overwrite = overwrite
		}

		layer2:export(data1)
		unitTest:assert(File(geojson):exists())

		-- OVERWRITE AND CHANGE EPSG
		data1.epsg = 4326
		layer2:export(data1)

		local layerName3 = "GJ"
		local layer3 = Layer{
			project = proj,
			name = layerName3,
			file = geojson
		}

		unitTest:assertEquals(layer3.epsg, data1.epsg)
		unitTest:assert(layer2.epsg ~= data1.epsg)

		local shp = "mg.shp"
		local data2 = {
			file = shp,
			overwrite = overwrite
		}

		layer2:export(data2)
		unitTest:assert(File(shp):exists())

		-- OVERWRITE AND CHANGE EPSG
		data2.epsg = 4326
		layer2:export(data2)

		local layerName4 = "SHP"
		local layer4 = Layer{
			project = proj,
			name = layerName4,
			file = shp
		}

		unitTest:assertEquals(layer4.epsg, data2.epsg)
		unitTest:assert(layer2.epsg ~= data2.epsg)

		-- SELECT ONE ATTRIBUTE TO GEOJSON
		data1.select = {"populaca"}
		layer2:export(data1)
		local attrs1 = layer3:attributes()

		unitTest:assertEquals(attrs1[1].name, "FID")
		unitTest:assertEquals(attrs1[2].name, "populaca")
		unitTest:assertNil(attrs1[3])

		-- SELECT TWO ATTRIBUTES TO SHAPE
		data2.select = {"populaca", "nomemeso"}
		layer2:export(data2)
		local attrs2 = layer4:attributes()

		unitTest:assertEquals(attrs2[1].name, "FID")
		unitTest:assertEquals(attrs2[2].name, "populaca")
		unitTest:assertEquals(attrs2[3].name, "nomemeso")
		unitTest:assertNil(attrs2[4])

		File(geojson):delete()
		File(shp):delete()
		layer2:delete()
		proj.file:delete()
	end,
	simplify = function(unitTest)
		local projName = "layer_postgis_basic.tview"

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

		local password = getConfig().password
		local database = "postgis_22_sample"
		local tableName = string.lower(layerName1)

		local pgData = {
			source = "postgis",
			password = password,
			database = database,
			overwrite = true,
			epsg = 4036
		}

		layer1:export(pgData)

		local layerName2 = "ES_Rails_Pg"
		local layer2 = Layer{
			project = proj,
			source = "postgis",
			name = layerName2,
			password = password,
			database = database,
			table = tableName
		}

		local outputName = "spl_"..tableName
		local data = {
			output = outputName,
			tolerance = 500
		}

		layer2:simplify(data)

		local layerName3 = "ES_Rails_Spl"
		local layer3 = Layer{
			project = proj,
			source = "postgis",
			name = layerName3,
			password = password,
			database = database,
			table = outputName
		}

		local attrs = layer3:attributes()
		unitTest:assertEquals("fid", attrs[1].name)
		unitTest:assertEquals("observacao", attrs[4].name)
		unitTest:assertEquals("produtos", attrs[7].name)
		unitTest:assertEquals("operadora", attrs[10].name)
		unitTest:assertEquals("bitola_ext", attrs[13].name)
		unitTest:assertEquals("cod_pnv", attrs[15].name)

		layer2:delete()
		layer3:delete()
		proj.file:delete()
	end,
	polygonize = function(unitTest)
		local projFile = File("polygonize_basic_postgis.tview")

		local proj = Project{
			file = projFile,
			clean = true,
		}

		local tifLayer = Layer{
			project = proj,
			name = "Tif",
			file = filePath("emas-accumulation.tif", "gis"),
			epsg = 29192
		}

		local outInfo = {
			source = "postgis",
			password = "postgres",
			database = "postgis_22_sample",
			table = "polygonized",
			overwrite = true
		}

		tifLayer:polygonize(outInfo)

		local pgLayer = Layer{
			project = proj,
			name = "Postgis",
			source = outInfo.source,
			password = outInfo.password,
			database = outInfo.database,
			table = outInfo.table
		}

		local attrs = pgLayer:attributes()
		unitTest:assertEquals("id", attrs[1].name)
		unitTest:assertEquals("value", attrs[2].name)

		pgLayer:delete()
		proj.file:delete()
	end,
	drop = function(unitTest)
		local proj = Project{
			file = "drop_pg_basic.tview",
			clean = true
		}

		local l1 = Layer{
			project = proj,
			name = "Sampa",
			file = filePath("test/sampa.shp", "gis")
		}

		local cl1 = Layer{
			project = proj,
			source = "postgis",
			clean = true,
			input = l1.name,
			name = "SampaCells",
			resolution = 0.7,
			password = "postgres",
			database = "drop_pg_test"
		}

		cl1:drop()

		local checkDrop = function()
			Layer{
				project = proj,
				source = "postgis",
				name = "SPDrop",
				password = "postgres",
				database = "drop_pg_test",
				table = cl1.table
			}
		end

		unitTest:assertError(checkDrop, "It was not possible to create a connection to the given data source due to the following error: FATAL:  database \"drop_pg_test\" does not exist\n.")
		proj.file:delete()
	end
}

