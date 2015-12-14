return {
	Project = function(unitTest)
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

		os.execute("rm -f "..proj1Info.file)

		local proj4 = Project {
			file = "amazonia.tview",
			create = true
		}
		local proj4Info = proj4:info()

		unitTest:assertEquals(proj4Info.title, "<no title>")
		unitTest:assertEquals(proj4Info.author, "<no author>")

		os.execute("rm -f "..proj4Info.file)
	end,

	addLayer = function(unitTest)
		unitTest:assert(true)
	-- proj:addLayer{
	-- 	layer = "cell_layer",
	-- 	file = "D:/temp/cell_layer.shp",
	-- 	type = "shp"
	-- }			
	end,

	addCellularLayer = function(unitTest)
		unitTest:assert(true)
	end,

	info = function(unitTest)
		-- this is being tested on Project constructor
		unitTest:assert(true)
	end
}