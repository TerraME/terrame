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

return{
	CellularSpace = function(unitTest)
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
		unitTest:assertSnapshot(m, "map_slices.bmp")

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
		if File("cellularspace.csv"):exists() then File("cellularspace.csv"):delete() end

		unitTest:assertSnapshot(vt, "cellularspace_visualtable.bmp", 0.23)

		unitTest:assertSnapshot(ts, "textscreen_cs_value.bmp", 0.1)

		unitTest:clear()

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

		if projName:exists() then projName:delete() end
		
		local author = "Avancini"
		local title = "Cellular Space"

        local terralib = getPackage("terralib")

		local proj = terralib.Project{
			file = projName:name(true),
			clean = true,
			author = author,
			title = title
		}		

		local layerName1 = "Sampa"
		terralib.Layer{
			project = proj,
			name = layerName1,
			file = filePath("test/sampa.shp", "terralib")
		}		
		
		local testDir = _Gtme.makePathCompatibleToAllOS(currentDir())
		local shp1 = "sampa_cells.shp"
		local filePath1 = testDir.."/"..shp1
		local fn1 = File(filePath1):name()
		fn1 = testDir.."/"..fn1			
		
		local exts = {".dbf", ".prj", ".shp", ".shx"}
		for i = 1, #exts do
			local f = fn1..exts[i]
			if File(f):exists() then
				File(f):delete()
			end
		end			
		
		local clName1 = "Sampa_Cells"
		terralib.Layer{
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
		unitTest:assertSnapshot(map, "cellspace_map_project.bmp")		
		
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
    
		unitTest:assertSnapshot(vt, "cellspace_visualtable_project.bmp", 0.25)
		unitTest:assertSnapshot(ts, "cellspace_textscreen_project.bmp", 0.09)		
		unitTest:assertFile(projName:name(true))
		if projName:exists() then projName:delete() end

		for i = 1, #exts do
			local f = fn1..exts[i]
			if File(f):exists() then
				File(f):delete()
			end
		end

		cs = CellularSpace{
			xdim = 10,
			ydim = 20,
		}

		forEachCell(cs, function(cell)
			cell.value = cell.x
		end)

		unitTest:assertEquals(cs.source, "virtual")
		unitTest:assertEquals(cs.xMax, cs.ydim - 1)
		unitTest:assertEquals(cs.yMax, cs.xdim - 1)
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

