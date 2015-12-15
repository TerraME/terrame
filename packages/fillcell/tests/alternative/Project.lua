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
		
		local nLayer = "any"
		local layerNonExists = function()
			proj:infoLayer(nLayer)
		end
		unitTest:assertError(layerNonExists, "Layer '"..nLayer.."' not exists.")
		
		local layerName = "Setores_2000"
		proj:addLayer {
			layer = layerName,
			file = file("Setores_Censitarios_2000_pol.shp", "fillcell"),
			source = "shp"			
		}
		
		local layerAlreadyExists = function()
			proj:addLayer {
				layer = layerName,
				file = file("Setores_Censitarios_2000_pol.shp", "fillcell"),
				source = "shp"			
			}			
		end
		unitTest:assertError(layerAlreadyExists, "Layer '"..layerName.."' already exists in the Project.")
		
		
		if isFile(projName) then
			os.execute("rm -f "..projName)
		end


		-- TODO: check if a layer to be added already exists
		-- TODO: tests for shapefiles
		-- TODO: tests for postgis
		-- TODO: tests for tiff
	end, 	
-- 	addCellularLayer = function(unitTest)
-- 		local proj = Project{
-- 			file = file("amazonia.tview", "fillcell")
-- 		}

-- 		local error_func = function()
-- 			proj:addCellularLayer()
-- 		end
-- 		unitTest:assertError(error_func, tableArgumentMsg())

-- 		local error_func = function()
-- 			proj:addCellularLayer{
-- 				input = 123,
-- 				layer = "cells",
-- 				resolution = 5e4
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("input", "string", 123))

-- 		local error_func = function()
-- 			proj:addCellularLayer{
-- 				input = "amazonia-states",
-- 				layer = 123,
-- 				resolution = 5e4
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("layer", "string", 123))

-- 		local error_func = function()
-- 			proj:addCellularLayer{
-- 				input = "amazonia-states",
-- 				layer = "cells",
-- 				resolution = 5e4,
-- 				box = 123
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("box", "boolean", 123))

-- 		local error_func = function()
-- 			proj:addCellularLayer{
-- 				input = "amazonia-states",
-- 				layer = "cells",
-- 				resolution = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("resolution", "number", false))

-- 		error_func = function()
-- 			proj:addCellularLayer{
-- 				input = "amazonia-states",
-- 				layer = "cells",
-- 				resolution = 0
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, positiveArgumentMsg("resolution", 0))

-- 		error_func = function()
-- 			proj:addCellularLayer{
-- 				input = "amazonia-states",
-- 				layer = "cells",
-- 				resolution = 0
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, positiveArgumentMsg("resolution", 0))

-- 		error_func = function()
-- 			proj:addCellularLayer{
-- 				input = "amazonia-states",
-- 				layer = "cells",
-- 				resoltion = 200
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("resoltion", "resolution"))

-- 		-- TODO: check if the input layer contains polygons (?)
-- 		-- TODO: check if the input layer exists
-- 		-- TODO: check if a layer to be added already exists
-- 	end
}

