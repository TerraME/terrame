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
-- Author: Pedro R. Andrade
-------------------------------------------------------------------------------------------

return{
 	Project = function(unitTest)
 		local noDataInContructor = function()
 			local proj = Project()
 		end
 		unitTest:assertError(noDataInContructor, tableArgumentMsg())

		local attrFileNonString = function()
			local proj = Project{file = 123, create = true}
		end
		unitTest:assertError(attrFileNonString, incompatibleTypeMsg("file", "string", 123))
		
		local invalidFileExtensionToCreate = function()
			local proj = Project{file = "project.xml", create = true}
		end
		unitTest:assertError(invalidFileExtensionToCreate, "Please, the file extension must be '.tview'.")
		
		local invalidFileExtensionToLoad = function()
			local proj = Project{file = file("Altimetria.xml", "fillcell")}
		end
		unitTest:assertError(invalidFileExtensionToLoad, "Please, the file extension must be '.tview'.")		
		
		local attrCreateNonBool = function()
			local proj = Project{file = "myproj.tview", create = 2}
		end
		unitTest:assertError(attrCreateNonBool, incompatibleTypeMsg("create", "boolean", 2))

		local attrTitleNonString = function()
			local proj = Project{file = "myproj.tview", title = 2}
		end
		unitTest:assertError(attrTitleNonString, incompatibleTypeMsg("title", "string", 2))		

		local attrAuthorNonString = function()
			local proj = Project{file = "myproj.tview", author = 2}
		end
		unitTest:assertError(attrAuthorNonString, incompatibleTypeMsg("author", "string", 2))				

		local fileMandatory = function()
			local proj = Project{create = true}
		end
		unitTest:assertError(fileMandatory, mandatoryArgumentMsg("file"))

		local unnecessaryArgument = function()
			local proj = Project{file = "myproj.tview", ceate = true}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("ceate", "create"))

		local projectNonExists = function()
			local proj = Project{
				file = "myproject123.tview"
			}
		end
 		unitTest:assertError(projectNonExists, "Project 'myproject123.tview' does not exist. Use 'create = true' to create a new Project.")

		local projName = "amazonia.tview"

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end

		local proj = Project {
			file = projName,
			create = true
		}

		local projAreadyExists = function()
			local proj = Project{
				file = projName,
				create = true
			}
		end
		unitTest:assertError(projAreadyExists, "Project '"..projName.."' already exists.")

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
 	end,
	addLayer = function(unitTest)
		local projName = "amazonia.tview"

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end

		local proj = Project{
			file = projName,
			create = true,
			author = "Avancini",
			title = "The Amazonia"
		}

		local noDataInLayer = function()
			proj:addLayer()
		end
		unitTest:assertError(noDataInLayer, tableArgumentMsg())

		local attrLayerNonString = function()
			proj:addLayer{
				layer = 123,
				file = "myfile.shp",
			}

		end
		unitTest:assertError(attrLayerNonString, incompatibleTypeMsg("layer", "string", 123))

		local attrSourceNonString = function()
			proj:addLayer{
				layer = "layer",
				source = 123
			}

		end
		unitTest:assertError(attrSourceNonString, incompatibleTypeMsg("source", "string", 123))	
		
		local fileMandatory = function()
			proj:addLayer{
				layer = "Linhares"
			}
		end
		unitTest:assertError(fileMandatory, mandatoryArgumentMsg("file"))
		
		local noFilePass = function()
			proj:addLayer{
				layer = "Linhares",
				source = "tif"
			}
		end
		unitTest:assertError(noFilePass, mandatoryArgumentMsg("file"))	
		
		local nLayer = "any"
		local layerNonExists = function()
			proj:infoLayer(nLayer)
		end
		unitTest:assertError(layerNonExists, "Layer '"..nLayer.."' not exists.")
		
		local layerName = "Setores_2000"
		proj:addLayer {
			layer = layerName,
			file = file("Setores_Censitarios_2000_pol.shp", "fillcell")			
		}
		
		local layerAlreadyExists = function()
			proj:addLayer {
				layer = layerName,
				file = file("Setores_Censitarios_2000_pol.shp", "fillcell")	
			}			
		end
		unitTest:assertError(layerAlreadyExists, "Layer '"..layerName.."' already exists in the Project.")
		
		local sourceInvalid = function()
			proj:addLayer {
				layer = layerName,
				file = file("amazonia.tview", "fillcell")	
			}			
		end
		unitTest:assertError(sourceInvalid, "The source'".."tview".."' is invalid.")
		
		local layerFile = "linhares.shp"
		local fileLayerNonExists = function()
			proj:addLayer {
				layer = "Linhares",
				file = layerFile	
			}			
		end
		unitTest:assertError(fileLayerNonExists, "The layer file'"..layerFile.."' not found.")			
	
		local filePath = file("Setores_Censitarios_2000_pol.shp", "fillcell")
		local source = "tif"
		local inconsistentExtension = function()
			proj:addLayer {
				layer = "Setores_New",
				file = filePath,
				source = "tif"
			}			
		end
		unitTest:assertError(inconsistentExtension, "File '"..filePath.."' not match to source '"..source.."'.")			
		
		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
		
		-- -- TODO: tests for postgis
	end, 	
	addCellularLayer = function(unitTest)
		local projName = "amazonia.tview"

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end

		local proj = Project{
			file = projName,
			create = true,
			author = "Avancini",
			title = "The Amazonia"
		}	

		local noDataArguments = function()
			proj:addCellularLayer()
		end
		unitTest:assertError(noDataArguments, tableArgumentMsg())

		local attrInputNonString = function()
			proj:addCellularLayer{
				input = 123,
				layer = "cells",
				resolution = 5e4
			}
		end
		unitTest:assertError(attrInputNonString, incompatibleTypeMsg("input", "string", 123))

		local attrLayerNonString = function()
			proj:addCellularLayer{
				input = "amazonia-states",
				layer = 123,
				resolution = 5e4
			}
		end
		unitTest:assertError(attrLayerNonString, incompatibleTypeMsg("layer", "string", 123))

		local attrBoxNonBoolean = function()
			proj:addCellularLayer{
				input = "amazonia-states",
				layer = "cells",
				resolution = 5e4,
				box = 123
			}
		end
		unitTest:assertError(attrBoxNonBoolean, incompatibleTypeMsg("box", "boolean", 123))

		local attrResolutionNonNumber = function()
			proj:addCellularLayer{
				input = "amazonia-states",
				layer = "cells",
				resolution = false
			}
		end
		unitTest:assertError(attrResolutionNonNumber, incompatibleTypeMsg("resolution", "number", false))

		local attrResolutionNonPositive = function()
			proj:addCellularLayer{
				input = "amazonia-states",
				layer = "cells",
				resolution = 0
			}
		end
		unitTest:assertError(attrResolutionNonPositive, positiveArgumentMsg("resolution", 0))


		local unnecessaryArgument = function()
			proj:addCellularLayer{
				input = "amazonia-states",
				layer = "cells",
				resoltion = 200
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("resoltion", "resolution")) -- SKIP
		
		local noFilePass = function()
			proj:addCellularLayer {
				input = "amazonia-states",
				layer = "cells",
				resolution = 10000		
			}
		end
		unitTest:assertError(noFilePass, mandatoryArgumentMsg("file")) -- SKIP
		
		local attrSourceNonString = function()
			proj:addCellularLayer{
				input = "amazonia-states",
				layer = "cells",
				resolution = 10000,				
				layer = "layer",
				file = "cells.shp",
				source = 123
			}
		end
		unitTest:assertError(attrSourceNonString, incompatibleTypeMsg("source", "string", 123))

		local layerName1 = "Setores_Censitarios_2000"
		proj:addLayer {
			layer = layerName1,
			file = file("Setores_Censitarios_2000_pol.shp", "fillcell")
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
		
		local cellLayerAlreadyExists = function()
			proj:addCellularLayer {
				input = layerName1,
				layer = clName1,
				resolution = 10000,
				file = filePath1
			}	
		end
		unitTest:assertError(cellLayerAlreadyExists, "Layer '"..clName1.."' already exists in the Project.")
		
		local sourceInvalid = function()
			proj:addCellularLayer{
				input = layerName1,
				layer = "cells",
				resolution = 10000,
				file = file("amazonia.tview", "fillcell")	
			}			
		end
		unitTest:assertError(sourceInvalid, "The source'".."tview".."' is invalid.")

		local filePath = file("Setores_Censitarios_2000_pol.shp", "fillcell")
		local source = "tif"
		local inconsistentExtension = function()
			proj:addCellularLayer{
				input = layerName1,
				layer = "cells",
				resolution = 10000,
				file = filePath,
				source = "tif"
			}			
		end
		unitTest:assertError(inconsistentExtension, "File '"..filePath.."' not match to source '"..source.."'.")

		local inLayer = "no_exists"
		local inputNonExists = function()
			proj:addCellularLayer{
				input = inLayer,
				layer = "cells",
				resolution = 10000,
				file = "some.shp"
			}
		end
		unitTest:assertError(inputNonExists, "The input layer '".."no_exists".."' not found.")		
		
		if isFile(projName) then
			os.execute("rm -f "..projName)
		end		
		
		for i = 1, #exts do
			local f = fn1..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end		

		-- -- TODO: check if the input layer contains polygons (?)
	end
}

