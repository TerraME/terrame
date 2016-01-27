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
		unitTest:assert(true)
	end,
	fillCells = function(unitTest)
		local projName = "cellular_layer_fillcells_alternative.tview"

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
		
		local author = "Avancini"
		local title = "Cellular Layer"
	
		local proj = Project {
			file = projName,
			create = true,
			author = "Avancini",
			title = "Cellular Layer"
		}		

		local layerName1 = "Sampa"
		proj:addLayer {
			layer = layerName1,
			file = file("sampa.shp", "fillcell")
		}	
		
		local clName1 = "Sampa_Cells_DB"
		local tName1 = "sampa_cells"
		
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
		local database = "postgis_22_sample"
		local encoding = "CP1252"
		local tableName = tName1	
		
		local pgData = {
			type = "POSTGIS",
			host = host,
			port = port,
			user = user,
			password = password,
			database = database,
			table = tName1,
			encoding = encoding
		}
		
		local tl = TerraLib{}
		tl:dropPgTable(pgData)
		
		proj:addCellularLayer {
			source = "postgis",
			input = layerName1,
			layer = clName1,
			resolution = 0.9,
			user = user,
			password = password,
			database = database,
			table = tName1
		}	
		
		local cl = CellularLayer{
			project = proj,
			layer = clName1
		}

		local operationMandatory = function()
			cl:fillCells{
				attribute = "population",
				layer = "population"
			}
		end
		unitTest:assertError(operationMandatory, mandatoryArgumentMsg("operation"))

		local operationNotString = function()
			cl:fillCells{
				attribute = "distRoads",
				operation = 2,
				layer = "roads"
			}
		end
		unitTest:assertError(operationNotString, incompatibleTypeMsg("operation", "string", 2))

		local layerMandatory = function()
			cl:fillCells{
				attribute = "population",
				operation = "area"
			}
		end
		unitTest:assertError(layerMandatory, mandatoryArgumentMsg("layer"))

		local layerNotString = function()
			cl:fillCells{
				attribute = "distRoads",
				operation = "area",
				layer = 2
			}
		end
		unitTest:assertError(layerNotString, incompatibleTypeMsg("layer", "string", 2))
	
		local attributeMandatory = function()
			cl:fillCells{
				layer = "cells",
				operation = "area"
			}
		end
		unitTest:assertError(attributeMandatory, mandatoryArgumentMsg("attribute"))

		local attributeNotString = function()
			cl:fillCells{
				attribute = 2,
				operation = "area",
				layer = "cells"
			}
		end
		unitTest:assertError(attributeNotString, incompatibleTypeMsg("attribute", "string", 2))
		
		local outputMandatory = function()
			cl:fillCells{
				layer = "cells",
				operation = "area",
				attribute = "any"
			}
		end
		unitTest:assertError(outputMandatory, mandatoryArgumentMsg("output"))

		local outputNotString = function()
			cl:fillCells{
				attribute = "any",
				operation = "area",
				layer = "cells",
				output = 2
			}
		end
		unitTest:assertError(outputNotString, incompatibleTypeMsg("output", "string", 2))		
		
		local presenceLayerName = clName1.."_Presence"
		local layerNotExists = function()
			cl:fillCells{
				operation = "presence",
				layer = "LayerNotExists",
				attribute = "presence",
				output = presenceLayerName
			}
		end
		unitTest:assertError(layerNotExists, "The layer '".."LayerNotExists".."' not exists.")
		
		local attrAlreadyExists = function()
			cl:fillCells{
				operation = "presence",
				layer = layerName1,
				attribute = "row",
				output = presenceLayerName
			}
		end
		unitTest:assertError(attrAlreadyExists, "The attribute '".."row".."' already exists in layer '"..clName1.."'.")				

		local presenceSelectUnnecessary = function()
			cl:fillCells{
				operation = "presence",
				layer = layerName1,
				attribute = "presence",
				select = "FID",
				output = presenceLayerName
			}
		end
		unitTest:assertError(presenceSelectUnnecessary, unnecessaryArgumentMsg("select"))		
		
		local areaLayerName = clName1.."_Presence"
		local areaSelectUnnecessary = function()
			cl:fillCells{
				attribute = "attr",
				operation = "area",
				layer = layerName1,
				select = "FID",
				output = areaLayerName
			}
		end
		unitTest:assertError(areaSelectUnnecessary, unnecessaryArgumentMsg("select"))
		
		local countLayerName = clName1.."_Count"
		local countSelectUnnecessary = function()
			cl:fillCells{
				attribute = "attr",
				operation = "count",
				layer = layerName1,
				select = "FID",
				output = countLayerName
			}
		end
		unitTest:assertError(countSelectUnnecessary, unnecessaryArgumentMsg("select"))	
		
		local distanceLayerName = clName1.."_Distance"
		local distanceSelectUnnecessary = function()
			cl:fillCells{
				attribute = "attr",
				operation = "distance",
				layer = layerName1,
				select = "FID",
				output = distanceLayerName
			}
		end
		unitTest:assertError(distanceSelectUnnecessary, unnecessaryArgumentMsg("select"))
		
		local minValueLayerName = clName1.."_Minimum"
		local selectNotString = function()
			cl:fillCells{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = 2,
				output = minValueLayerName
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local defaultNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = "row",
				output = minValueLayerName,
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		local dummyNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = "row",
				output = minValueLayerName,
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		local unnecessaryArgument = function()
			cl:fillCells{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = "row",
				output = minValueLayerName,
				dummy = 0,
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))	
		
		local maxValueLayerName = clName1.."_Maximum"
		local selectNotString = function()
			cl:fillCells{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = 2,
				output = maxValueLayerName
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local defaultNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = "FID",
				output = maxValueLayerName,
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		local dummyNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = "FID",
				output = maxValueLayerName,
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		local unnecessaryArgument = function()
			cl:fillCells{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = "FID",
				output = maxValueLayerName,
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))
		
		local percentageLayerName = clName1.."_Percentage"
		local selectNotString = function()
			cl:fillCells{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = 2,
				output = percentageLayerName
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local defaultNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = "FID",
				output = percentageLayerName,
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		local dummyNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = "FID",
				output = percentageLayerName,
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		local unnecessaryArgument = function()
			cl:fillCells{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = "FID",
				output = percentageLayerName,
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))
		
		local stdevLayerName = clName1.."_Stdev"
		local selectNotString = function()
			cl:fillCells{
				attribute = "attr",
				operation = "stdev",
				layer = layerName1,
				select = 2,
				output = stdevLayerName
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local defaultNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "stdev",
				layer = layerName1,
				select = "FID",
				output = stdevLayerName,
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		local dummyNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "stdev",
				layer = layerName1,
				select = "FID",
				output = stdevLayerName,
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		local defaultNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "stdev",
				layer = layerName1,
				select = "FID",
				output = stdevLayerName,
				defaut = 3
			}
		end
		unitTest:assertError(defaultNotNumber, unnecessaryArgumentMsg("defaut", "default"))

		-- local selectValuesNotNumber = function()
			-- cl:fillCells{
				-- attribute = "attr",
				-- operation = "stdev",
				-- layer = layerName1,
				-- select = "NM_MICRO",
				-- output = stdevLayerName
			-- }
		-- end
		-- unitTest:assertError(selectValuesNotNumber, unnecessaryArgumentMsg("defaut", "default"))		
	
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

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
		
		tl:dropPgTable(pgData)
		
		tl = TerraLib{}
		tl:finalize()
	end
}

