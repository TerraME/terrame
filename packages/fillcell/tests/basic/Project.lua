return {
	Project = function(unitTest)
		local projName = "amazonia.tview"

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end

		local proj1 = Project {
			file = "amazonia.tview",
			create = true,
			author = "Avancini",
			title = "The Amazonia"
		}
		
		unitTest:assertType(proj1, "Project")
		unitTest:assert(isFile("amazonia.tview"))
		
		local proj1Info = proj1:info()

		local proj2 = Project {
			file = "amazonia.tview",
			create = false,
		}		
		local proj2Info = proj2:info()

		unitTest:assertEquals(proj1Info.author, proj2Info.author)
		unitTest:assertEquals(proj1Info.title, proj2Info.title)
		unitTest:assertEquals(proj1Info.file, proj2Info.file)

		local proj3 = Project {
			file = "amazonia.tview",
		}
		local proj3Info = proj3:info()

		unitTest:assertEquals(proj1Info.author, proj3Info.author)
		unitTest:assertEquals(proj1Info.title, proj3Info.title)
		unitTest:assertEquals(proj1Info.file, proj3Info.file)

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end

		local proj4 = Project {
			file = "amazonia.tview",
			create = true
		}
		local proj4Info = proj4:info()

		unitTest:assertEquals(proj4Info.title, "<no title>")
		unitTest:assertEquals(proj4Info.author, "<no author>")

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
	end,
	addLayer = function(unitTest)
		local projName = "setores_2000.tview"

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end

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

		local proj2 = Project {
			file = projName
		}
		local layer = proj2:infoLayer(layerName1)

		unitTest:assertEquals(layer.name, layerName1)
		
		local layerName2 = "Localidades"
		proj2:addLayer {
			layer = layerName2,
			file = file("Localidades_pt.shp", "fillcell")	
		}
		
		local layer1 = proj2:infoLayer(layerName1)
		local layer2 = proj2:infoLayer(layerName2)

		unitTest:assertEquals(layer1.name, layerName1)
		unitTest:assertEquals(layer2.name, layerName2)

		local layerName3 = "Altimetria"
		proj2:addLayer {
			layer = layerName3,
			file = file("altimetria.tif", "fillcell")		
		}		
		
		local layer3 = proj2:infoLayer(layerName3)
		
		unitTest:assertEquals(layer3.name, layerName3)
		
		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
	end,
	addCellularLayer = function(unitTest)
		local projName = "cells_setores_2000.tview"

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end

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
		local lInfo = proj:infoLayer(clName1)
		
		unitTest:assertEquals(lInfo.name, clName1)
		
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

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end	
			
		-- It is necessary for remove files because the TerraLib
		-- that create and manager them.
		local terralib = TerraLib{}
		terralib:finalize()
		
		for i = 1, #exts do
			local f = fn1..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end
		
		for i = 1, #exts do
			local f = fn2..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
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