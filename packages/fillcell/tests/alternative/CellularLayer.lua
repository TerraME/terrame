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

return{
	CellularLayer = function(unitTest)
		local noDataArguments = function()
			local cl = CellularLayer()
		end
		unitTest:assertError(noDataArguments, tableArgumentMsg())
		
		local attrProjectNonStringOrProject = function()
			local cl = CellularLayer{project = 2, layer = "cells"}
		end
		unitTest:assertError(attrProjectNonStringOrProject, "The 'project' parameter must be a Project or a Project file path.")		

		local attrLayerNonString = function()
			local cl = CellularLayer{project = "myproj.tview", layer = false}
		end
		unitTest:assertError(attrLayerNonString, incompatibleTypeMsg("layer", "string", false))

		local unnecessaryArgument = function()
			local cl = CellularLayer{project = "myproj.tview", lauer = "cells"}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("lauer", "layer"))
		
		local projFile = "proj_celllayer.tview"
		
		if isFile(projFile) then
			os.execute("rm -f "..projFile)
		end
		
		local proj = Project{
			file = projFile,
			create = true,
			author = "Avancini",
			title = "CellLayer"
		}
		
		local layerName = "any"
		local layerDoesNotExists = function()
			local cl = CellularLayer {
				project = proj,
				layer = layerName
			}
		end
		unitTest:assertError(layerDoesNotExists, "Layer '"..layerName.."' does not exists in the Project '"..projFile.."'.")
		
		if isFile(projFile) then
			os.execute("rm -f "..projFile)
		end		

-- 		-- TODO: select a project that does not exist
-- 		-- TODO: open a cellularlayer that does not exist - with and without suggestion
	end,
	-- fillCells = function(unitTest)
		-- local cl = CellularLayer{project = "amazonia.tview", layer = "cells"}

		-- local operationMandatoryArgument = function()
			-- cl:fillCells{
				-- attribute = "population",
				-- layer = "population"
			-- }
		-- end
		-- unitTest:assertError(operationMandatoryArgument, mandatoryArgumentMsg("operation")) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "distRoads",
-- 				operation = 2,
-- 				layer = "roads"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("operation", "string", 2)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "population",
-- 				operation = "area"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, mandatoryArgumentMsg("layer")) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "distRoads",
-- 				operation = "area",
-- 				layer = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("layer", "string", 2)) -- SKIP
	
-- 		error_func = function()
-- 			cl:fillCells{
-- 				layer = "cells",
-- 				operation = "area"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, mandatoryArgumentMsg("attribute")) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = 2,
-- 				operation = "area",
-- 				layer = "cells"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("attribute", "string", 2)) -- SKIP

-- 		-- area
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "area",
-- 				layer = "cover",
-- 				select = "cover2010"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("select")) -- SKIP

-- 		-- average
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "average",
-- 				layer = "cover",
-- 				select = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 2)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "average",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				area = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("area", "boolean", 2)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "average",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				default = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("default", "number", false)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "average",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				dummy = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("dummy", "number", false)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "average",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				defaut = 3
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("defaut", "default")) -- SKIP

-- 		-- count
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "count",
-- 				layer = "cover",
-- 				select = "cover2010"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("select")) -- SKIP

-- 		-- distance
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "distance",
-- 				layer = "cover",
-- 				select = "cover2010"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("select")) -- SKIP

-- 		-- length
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "length",
-- 				layer = "cover",
-- 				select = "cover2010"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("select")) -- SKIP

-- 		-- majority
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "majority",
-- 				layer = "cover",
-- 				select = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 2)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "majority",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				default = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("default", "number", false)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "majority",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				dummy = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("dummy", "number", false)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "majority",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				defaut = 3
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("defaut", "default")) -- SKIP

-- 		-- maximum
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "maximum",
-- 				layer = "cover",
-- 				select = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 2)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "maximum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				default = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("default", "number", false)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "maximum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				dummy = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("dummy", "number", false)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "maximum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				defaut = 3
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("defaut", "default")) -- SKIP

-- 		-- minimum
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "minimum",
-- 				layer = "cover",
-- 				select = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 2)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "minimum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				default = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("default", "number", false)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "minimum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				dummy = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("dummy", "number", false)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "minimum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				defaut = 3
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("defaut", "default")) -- SKIP

-- 		-- percentage
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "percentage",
-- 				layer = "cover",
-- 				select = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 2)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "percentage",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				default = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("default", "number", false)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "percentage",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				dummy = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("dummy", "number", false)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "percentage",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				defaut = 3
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("defaut", "default")) -- SKIP

-- 		-- presence
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "presence",
-- 				layer = "cover",
-- 				select = "cover2010"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("select")) -- SKIP

-- 		-- stdev
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "stdev",
-- 				layer = "cover",
-- 				select = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 2)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "stdev",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				default = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("default", "number", false)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "stdev",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				dummy = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("dummy", "number", false)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "stdev",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				defaut = 3
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("defaut", "default")) -- SKIP

-- 		-- sum
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "sum",
-- 				layer = "cover",
-- 				select = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 2)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "sum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				area = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("area", "boolean", 2)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "sum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				default = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("default", "number", false)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "sum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				dummy = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("dummy", "number", false)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "sum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				defaut = 3
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("defaut", "default")) -- SKIP

-- 		-- value
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "value",
-- 				layer = "cover",
-- 				select = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 2)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "value",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				area = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("area", "boolean", 2)) -- SKIP

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "value",
-- 				layer = "cover",
-- 				selec = "cover2010"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("selec", "select")) -- SKIP

-- 		-- TODO: match geometries with the available strategies
-- 		-- (first table of the documentation)
-- 		-- check if terralib already does this (but the test must exist anyway)

-- 		-- TODO: try to create an attribute that already exists (I dont know if TerraLib
-- 		-- will stop with an error or it is up to us to check this.)
-- 		-- TODO: try to fillCells using a `layer` that does not exist.

 	-- end
}

