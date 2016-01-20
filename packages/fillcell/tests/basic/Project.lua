-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP.
--
-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.
--
-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or caonsequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Pedro R. Andrade (pedro.andrade@inpe.br)
--          Rodrigo Avancini
-------------------------------------------------------------------------------------------

return {
	Project = function(unitTest)
		local projName = "amazonia"
		
		if isFile(projName..".tview") then
			os.execute("rm -f "..projName..".tview")
		end
		-- ###################### 1 #############################
		local proj1 = Project {
			file = projName,
			create = true,
			author = "Avancini",
			title = "The Amazonia"
		}
		
		unitTest:assertType(proj1, "Project")
		unitTest:assert(isFile("amazonia.tview"))
		
		-- ###################### 2 #############################
		local proj1Info = proj1:info()
		
		local proj2 = Project {
			file = projName,
			create = false,
		}		
		local proj2Info = proj2:info()

		unitTest:assertEquals(proj1Info.author, proj2Info.author)
		unitTest:assertEquals(proj1Info.title, proj2Info.title)
		unitTest:assertEquals(proj1Info.file, proj2Info.file)

		local proj3 = Project {
			file = projName,
		}
		local proj3Info = proj3:info()

		unitTest:assertEquals(proj1Info.author, proj3Info.author)
		unitTest:assertEquals(proj1Info.title, proj3Info.title)
		unitTest:assertEquals(proj1Info.file, proj3Info.file)
		
		if isFile(proj1Info.file) then
			os.execute("rm -f "..proj1Info.file)
		end		
		
		-- ###################### 3 #############################
		local proj4Name = "notitlenoauthor.tview"
		
		if isFile(proj4Name) then
			os.execute("rm -f "..proj4Name)
		end
		
		local proj4 = Project {
			file = proj4Name,
			create = true
		}
		local proj4Info = proj4:info()

		unitTest:assertEquals(proj4Info.title, "<no title>")
		unitTest:assertEquals(proj4Info.author, "<no author>")

		if isFile(proj4Name) then
			os.execute("rm -f "..proj4Name)
		end
	end,
	addLayer = function(unitTest)
		local projName = "setores_2000.tview"

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
		
		-- ###################### 1 #############################
		local proj1 = Project {
			file = projName,
			create = true,
			author = "Avancini",
			title = "Setores"
		}		
		
		local layerName1 = "Setores_Censitarios_2000"
		proj1:addLayer {
			layer = layerName1,
			file = file("Setores_Censitarios_2000_pol.shp", "fillcell")
		}
		local layer1 = proj1:infoLayer(layerName1)
		unitTest:assertEquals(layer1.name, layerName1)
		
		-- ###################### 2 #############################
		local proj2 = Project {
			file = projName
		}
		local layer2 = proj2:infoLayer(layerName1)

		unitTest:assertEquals(layer2.name, layerName1)

		-- ###################### 3 #############################
		local layerName2 = "Localidades"
		proj2:addLayer {
			layer = layerName2,
			file = file("Localidades_pt.shp", "fillcell")
		}
		local layer1 = proj2:infoLayer(layerName1)
		local layer2 = proj2:infoLayer(layerName2)

		unitTest:assertEquals(layer1.name, layerName1)
		unitTest:assertEquals(layer2.name, layerName2)
		
		-- ###################### 3.1 #############################
		local layerName21 = "Another_Localidades"
		proj2:addLayer {
			layer = layerName21,
			file = file("Localidades_pt.shp", "fillcell")
		}
		local layer21 = proj2:infoLayer(layerName21)
		unitTest:assert(layer21.name ~= layer2.name)
		unitTest:assertEquals(layer21.sid, layer2.sid)		
		
		-- ###################### 4 #############################
		local layerName3 = "Altimetria"
		proj2:addLayer {
			layer = layerName3,
			file = file("altimetria.tif", "fillcell")		
		}		
		local layer3 = proj2:infoLayer(layerName3)
		
		unitTest:assertEquals(layer3.name, layerName3)
		
		-- ###################### 5 #############################
		local layerName4 = "Another_Altimetria"
		proj2:addLayer {
			layer = layerName4,
			file = file("altimetria.tif", "fillcell")		
		}		
		local layer4 = proj2:infoLayer(layerName4)
		unitTest:assert(layer4.name ~= layer3.name)
		unitTest:assertEquals(layer4.sid, layer3.sid)		
		
		-- ###################### END #############################
		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
		
		-- local terralib = TerraLib{}
		-- terralib:finalize()			
	end,
	addCellularLayer = function(unitTest)
		local projName = "cells_setores_2000.tview"

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
		
		-- ###################### 1 #############################
		local proj = Project {
			file = projName,
			create = true,
			author = "Avancini",
			title = "Setores"
		}		

		local layerName1 = "Setores_Censitarios_2000"
		proj:addLayer {
			layer = layerName1,
			file = file("Setores_Censitarios_2000_pol.shp", "fillcell")
		}
		
		local layerName2 = "Localidades"
		proj:addLayer {
			layer = layerName2,
			file = file("Localidades_pt.shp", "fillcell")	
		}

		local layerName3 = "Altimetria"
		proj:addLayer {
			layer = layerName3,
			file = file("altimetria.tif", "fillcell")		
		}		
		
		local testDir = _Gtme.makePathCompatibleToAllOS(currentDir())
		local shp1 = "setores_cells.shp"
		local filePath1 = testDir.."/"..shp1	
		local fn1 = getFileName(filePath1)
		fn1 = testDir.."/"..fn1	

		local exts = {".dbf", ".prj", ".shp", ".shx"}
		
		for i = 1, #exts do
			local f = fn1..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end	
		
		local clName1 = "Setores_Cells"
		proj:addCellularLayer {
			input = layerName1,
			layer = clName1,
			resolution = 10000,
			file = filePath1
		}
		local l1Info = proj:infoLayer(clName1)
		
		unitTest:assertEquals(l1Info.name, clName1)
		
		-- ###################### 2 #############################
		local shp2 = "localidades_cells.shp"
		local filePath2 = testDir.."/"..shp2	
		local fn2 = getFileName(filePath2)
		fn2 = testDir.."/"..fn2	
		
		for i = 1, #exts do
			local f = fn2..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end			
		
		local clName2 = "Localidades_Cells"
		proj:addCellularLayer {
			input = layerName2,
			layer = clName2,
			resolution = 10000,
			file = filePath2		
		}
		local l2Info = proj:infoLayer(clName2)
		
		unitTest:assertEquals(l2Info.name, clName2)
		
		-- ###################### 3 #############################
		local shp3 = "another_localidades_cells.shp"
		local filePath3 = testDir.."/"..shp3	
		local fn3 = getFileName(filePath3)
		fn3 = testDir.."/"..fn3	
		
		for i = 1, #exts do
			local f = fn3..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end			
		
		local clName3 = "Another_Localidades_Cells"
		proj:addCellularLayer {
			input = layerName2,
			layer = clName3,
			resolution = 10000,
			file = filePath3		
		}
		local l3Info = proj:infoLayer(clName3)
		
		unitTest:assertEquals(l3Info.name, clName3)	

		-- ###################### END #############################
		if isFile(projName) then
			os.execute("rm -f "..projName)
		end		
		
		for i = 1, #exts do
			local f1 = fn1..exts[i]
			local f2 = fn2..exts[i]
			local f3 = fn3..exts[i]
			if isFile(f1) then
				os.execute("rm -f "..f1)
			end
			if isFile(f2) then
				os.execute("rm -f "..f2)
			end
			if isFile(f3) then
				os.execute("rm -f "..f3)
			end				
		end		
	end,
	info = function(unitTest)
		-- this is being tested on Project constructor
		unitTest:assert(true)
	end,
	infoLayer = function(unitTest)
		-- this is being tested on Project constructor
		unitTest:assert(true)
	end	
}