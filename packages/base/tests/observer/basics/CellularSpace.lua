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

return{
	CellularSpace = function(unitTest)
		local basicTests = function()
			local cs = CellularSpace{
				xdim = 10,
				value = function() return 3 end
			}

			local r = Random()

			forEachCell(cs, function(cell)
				cell.value = r:number()
			end)

			Chart{target = cs, select = "value"}

			local m = Map{
				target = cs,
				select = "value",
				min = 0,
				max = 1,
				slices = 10,
				color = "Blues"
			}

			unitTest:assertType(m, "Map")

			cs:notify()
			unitTest:assertSnapshot(m, "map_slices.bmp", 0.95)

			local e = Event{action = function() end}[1]

			cs:notify(e)
			cs:notify()

			local unit = Cell{
				count = 0
			}

			local world = CellularSpace{
				xdim = 10,
				value = 10,
				instance = unit
			}

			local c = Chart{target = world}

			unitTest:assertType(c, "Chart")

			world:notify(0)

			local t = Timer{
				Event{action = function(event)
					world.value = world.value + 99
					forEachCell(world, function(cell)
						cell.count = cell.count + 1
					end)
					world:notify(event)
				end}
			}

			local ts = TextScreen{target = world}
			Log{target = world, file = "cellularspace.csv"}
			local vt = VisualTable{target = world}

			t:run(30)

			unitTest:assertFile("cellularspace.csv")

			world:notify()

			-- the call to notify() above creates the file again.
			-- remove the line below after refactoring observer.
			File("cellularspace.csv"):deleteIfExists()

			unitTest:assertSnapshot(vt, "cellularspace_visualtable.bmp", 0.23)

			unitTest:assertSnapshot(ts, "textscreen_cs_value.bmp", 0.1)

			world = CellularSpace{
				xdim = 10
			}

			forEachCell(world, function(cell)
				if math.random() > 0.6 then
					cell.value = 1
				else
					cell.value = 0
				end
			end)

			Map{
				target = world,
				select  = "value",
				color  = {{0, 0, 0}, {255, 255, 255}},
				min = 0,
				max = 1,
				slices = 2,
			}

			Map{
				target = world,
				select  = "value",
				color  = {"blue", "red"},
				min = 0,
				max = 1,
				slices = 2,
			}

			Map{
				target = world,
				select  = "value",
				color  = {"blue", "red"},
				min = 0,
				slices = 10,
				max = 1
			}

			world:notify()
			world:notify()

			local projName = File("cellspace_basic_observer.tview")

			projName:deleteIfExists()

			local author = "Avancini"
			local title = "Cellular Space"

			local gis = getPackage("gis")

			local proj = gis.Project{
				file = projName:name(true),
				clean = true,
				author = author,
				title = title
			}

			local layerName1 = "Sampa"
			gis.Layer{
				project = proj,
				name = layerName1,
				file = filePath("test/sampa.shp", "gis")
			}

			local shp1 = "sampa_cells.shp"
			local filePath1 = currentDir()..shp1

			File(filePath1):deleteIfExists()

			local clName1 = "Sampa_Cells"
			gis.Layer{
				project = proj,
				input = layerName1,
				name = clName1,
				resolution = 1,
				file = filePath1
			}

			cs = CellularSpace{
				project = projName:name(true),
				layer = clName1
			}

			r = Random()

			forEachCell(cs, function(cell)
				cell.value = r:number()
			end)

			local map = Map{
				target = cs,
				select = "value",
				min = 0,
				max = 1,
				slices = 10,
				color = "Red"
			}

			cs:notify()

			unitTest:assertSnapshot(map, "cellspace_map_project.bmp", 0.68)

			t = Timer{
				Event{action = function(event)
					forEachCell(cs, function(cell)
						cell.count = cell.value + 1
					end)
					cs:notify(event)
				end}
			}

			ts = TextScreen{target = cs}
			vt = VisualTable{target = cs}

			t:run(30)

			cs:notify()

			unitTest:assertSnapshot(vt, "cellspace_visualtable_project.bmp", 0.27)
			unitTest:assertSnapshot(ts, "cellspace_textscreen_project.bmp", 0.15)
			-- unitTest:assertFile(projName:name(true)) -- SKIP #TODO(#1242)

			projName:deleteIfExists()
			File(filePath1):deleteIfExists()

			cs = CellularSpace{
				xdim = 10,
				ydim = 20,
			}

			forEachCell(cs, function(cell)
				cell.value = cell.x
			end)

			unitTest:assertEquals(cs.source, "virtual")
			unitTest:assertEquals(cs.xMax, cs.xdim - 1)
			unitTest:assertEquals(cs.yMax, cs.ydim - 1)
			unitTest:assertEquals(#cs, cs.xdim * cs.ydim)

			map = Map{
				target = cs,
				select = "value",
				min = 0,
				max = 10,
				color = "Blues",
				slices = 11
			}

			cs:notify()
			unitTest:assertType(map, "Map")
			unitTest:assertSnapshot(map, "map_virtual.bmp", 0.05)
		end

		local creatingFromTif = function()
			local cs = CellularSpace{
				file = filePath("cabecadeboi-elevation.tif", "gis")
			}

			unitTest:assertEquals(#cs, 10000)

			local map = Map{
				target = cs,
				select = "b0",
				min = 0,
				max = 260,
				slices = 20,
				color = "Grays"
			}

			unitTest:assertSnapshot(map, "cellspace_map_tif_basic.png")
		end

		local creatingFromAsc = function()
			local cs = CellularSpace{
				file = filePath("test/biomassa-manaus.asc", "gis")
			}

			unitTest:assertEquals(#cs, 9964)

			local map = Map{
				target = cs,
				select = "b0",
				min = 0,
				max = 30000,
				slices = 20,
				color = "Grays"
			}

			unitTest:assertSnapshot(map, "cellspace_map_asc_basic.png")
		end

		local creatingFromNc = function()
			local cs = CellularSpace{
				file = filePath("test/vegtype_2000.nc", "gis")
			}

			unitTest:assertEquals(#cs, 8904) -- SKIP

			local map = Map{
				target = cs,
				select = "b0",
				min = 0,
				max = 10,
				slices = 10,
				color = "Grays"
			}

			unitTest:assertSnapshot(map, "cellspace_map_nc_basic.png") -- SKIP
		end

		unitTest:assert(basicTests)
		unitTest:assert(creatingFromTif)
		unitTest:assert(creatingFromAsc)
		if _Gtme.sessionInfo().system == "windows" then
			unitTest:assert(creatingFromNc) -- SKIP
		end
	end,
	notify = function(unitTest)
		local r = Random()

		local c = Cell{
			mvalue = function()
				return r:number()
			end
		}

		local cs = CellularSpace{
			xdim = 5,
			instance = c
		}

		Map{
			target = cs,
			select = "mvalue",
			min = 0,
			max = 1,
			slices = 10,
			color = "Blues"
		}

		cs:notify()
		cs:notify()
		unitTest:assert(true)
	end
}

