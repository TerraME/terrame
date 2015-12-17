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
		unitTest:assert(true)
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