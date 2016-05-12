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

		local c = Chart{target = cs, select = "value"}

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
			Event{action = function(e)
				world.value = world.value + 99
				forEachCell(world, function(cell)
					cell.count = cell.count + 1
				end)
				world:notify(e)
			end}
		}

		local ts = TextScreen{target = world}
		LogFile{target = world, file = "cellularspace.csv"}
		local vt = VisualTable{target = world}

		t:run(30)

		unitTest:assertFile("cellularspace.csv")

		world:notify()
    
		unitTest:assertSnapshot(vt, "cellularspace_visualtable.bmp", 0.059)

		unitTest:assertSnapshot(ts, "textscreen_cs_value.bmp", 0.06)

		unitTest:clear()

		local world = CellularSpace{
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
		
		local projName = "cellspace_basic_observer.tview"

		if isFile(projName) then
			rmFile(projName)
		end
		
		local author = "Avancini"
		local title = "Cellular Space"

		local proj = _Gtme.getTerraLib().Project{
			file = projName,
			clean = true,
			author = author,
			title = title
		}		

		local layerName1 = "Sampa"
		_Gtme.getTerraLib().Layer{
			project = proj,
			name = layerName1,
			file = filePath("sampa.shp", "terralib")
		}		
		
		local testDir = _Gtme.makePathCompatibleToAllOS(currentDir())
		local shp1 = "sampa_cells.shp"
		local filePath1 = testDir.."/"..shp1	
		local fn1 = getFileName(filePath1)
		fn1 = testDir.."/"..fn1			
		
		local exts = {".dbf", ".prj", ".shp", ".shx"}
		for i = 1, #exts do
			local f = fn1..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end			
		
		local clName1 = "Sampa_Cells"
		_Gtme.getTerraLib().Layer{
			project = proj,
			input = layerName1,
			name = clName1,
			resolution = 1,
			file = filePath1
		}
		
		local cs = CellularSpace{
			project = projName,
			layer = clName1
		}
		
		local r = Random()
		
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
		
		local t = Timer{
			Event{action = function(e)
				forEachCell(cs, function(cell)
					cell.count = cell.value + 1
				end)
				cs:notify(e)
			end}
		}		
		
		local ts = TextScreen{target = cs}
		local vt = VisualTable{target = cs}

		t:run(30)

		cs:notify()
    
		unitTest:assertSnapshot(vt, "cellspace_visualtable_project.bmp", 0.059)
		unitTest:assertSnapshot(ts, "cellspace_textscreen_project.bmp", 0.09)		
		unitTest:assertFile(projName)
		
		for i = 1, #exts do
			local f = fn1..exts[i]
			if isFile(f) then
				rmFile(f)
			end
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

		local m = Map{
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

