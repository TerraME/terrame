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
		
		local projNotExists = function()
			local cl = CellularLayer{project = "myproj.tview", layer = "cells"}
		end
		unitTest:assertError(projNotExists, "The Project '".."myproj.tview".."'not found.")		
		
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
			author = author,
			title = title
		}		

		local layerName1 = "Setores_2000"
		proj:addLayer {
			layer = layerName1,
			file = filePath("Setores_Censitarios_2000_pol.shp", "fillcell")
		}	
		
		local testDir = _Gtme.makePathCompatibleToAllOS(currentDir())
		
		local clName1 = "Setores_Cells"
		
		local shp1 = clName1..".shp"
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

		proj:addCellularLayer {
			source = "shp",
			input = layerName1,
			layer = clName1,
			resolution = 30000,
			file = filePath1
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
		unitTest:assertError(attrAlreadyExists, "The attribute '".."row".."' already exists in the CellularLayer.\nPlease set another name.")				

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
		
		local areaLayerName = clName1.."_Area"
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
		
		local selected = "ITNOTEXISTS"
		local selectNotExists = function()
			cl:fillCells{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = selected,
				output = minValueLayerName
			}
		end
		unitTest:assertError(selectNotExists, "The attribute selected '"..selected.."' not exists in layer '"..layerName1.."'.")			
		
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
				operation = "percentage",
				layer = layerName1,
				select = 2,
				output = percentageLayerName
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local defaultNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "percentage",
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
				operation = "percentage",
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
				operation = "percentage",
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
		
		local averageLayerName = clName1.."_Average"
		local selectNotString = function()
			cl:fillCells{
				attribute = "attr",
				operation = "average",
				layer = layerName1,
				select = 2,
				output = averageLayerName
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local areaNotBoolean = function()
			cl:fillCells{
				attribute = "attr",
				operation = "average",
				layer = layerName1,
				select = "FID",
				output = averageLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaNotBoolean, incompatibleTypeMsg("area", "boolean", 2))

		local defaultNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "average",
				layer = layerName1,
				select = "FID",
				output = averageLayerName,
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		local dummyNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "average",
				layer = layerName1,
				select = "FID",
				output = averageLayerName,
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		local unnecessaryArgument = function()
			cl:fillCells{
				attribute = "attr",
				operation = "average",
				layer = layerName1,
				select = "FID",
				output = averageLayerName,
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))
		
		local majorityLayerName = clName1.."_Majority"
		local selectNotString = function()
			cl:fillCells{
				attribute = "attr",
				operation = "majority",
				layer = layerName1,
				select = 2,
				output = majorityLayerName
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local areaNotBoolean = function()
			cl:fillCells{
				attribute = "attr",
				operation = "majority",
				layer = layerName1,
				select = "FID",
				output = majorityLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaNotBoolean, incompatibleTypeMsg("area", "boolean", 2))

		local defaultNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "majority",
				layer = layerName1,
				select = "FID",
				output = majorityLayerName,
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		local dummyNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "majority",
				layer = layerName1,
				select = "FID",
				output = majorityLayerName,
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		local unnecessaryArgument = function()
			cl:fillCells{
				attribute = "attr",
				operation = "majority",
				layer = layerName1,
				select = "FID",
				output = majorityLayerName,
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))
		
		local sumLayerName = clName1.."_Sum"
		local selectNotString = function()
			cl:fillCells{
				attribute = "attr",
				operation = "sum",
				layer = layerName1,
				select = 2,
				output = sumLayerName
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local areaNotBoolean = function()
			cl:fillCells{
				attribute = "attr",
				operation = "sum",
				layer = layerName1,
				select = "FID",
				output = sumLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaNotBoolean, incompatibleTypeMsg("area", "boolean", 2))

		local defaultNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "sum",
				layer = layerName1,
				select = "FID",
				output = sumLayerName,
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		local dummyNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "sum",
				layer = layerName1,
				select = "FID",
				output = sumLayerName,
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		local unnecessaryArgument = function()
			cl:fillCells{
				attribute = "attr",
				operation = "sum",
				layer = layerName1,
				select = "FID",
				output = sumLayerName,
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))
		
		local normalizedNameWarning = function()
			cl:fillCells{
				attribute = "max10allowed",
				operation = "sum",
				layer = layerName1,
				select = "FID",
				output = sumLayerName
			}		
		end
		unitTest:assertError(normalizedNameWarning,   "The 'attribute' lenght is more than 10 characters, it was changed to 'max10allow'.")

		local localidades = "Localidades"
		proj:addLayer {
			layer = localidades,
			file = filePath("Localidades_pt.shp", "fillcell")	
		}
		
		local presenceLayerName = clName1.."_Presence_2000"
		local shp2 = presenceLayerName..".shp"
		local filePath2 = testDir.."/"..shp2	
		local fn2 = getFileName(filePath2)
		fn2 = testDir.."/"..fn2	
		
		local exts = {".dbf", ".prj", ".shp", ".shx"}
		
		for i = 1, #exts do
			local f = fn2..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end	

		local cW = customWarning 
		customWarning = function(msg) return end

		cl:fillCells{
			operation = "presence",
			layer = localidades,
			attribute = "presence2000",
			output = presenceLayerName
		}	
		
		local presenceLayerName2 = clName1.."_Presence_2001"
		
		local normalizedTrucatedError = function()
			cl:fillCells{
				operation = "presence",
				layer = localidades,
				attribute = "presence2001",
				output = presenceLayerName2
			}
		end
		unitTest:assertError(normalizedTrucatedError, "The attribute 'presence20' already exists in the CellularLayer.\nPlease set another name.")
		
		customWarning = cW
		
		-- RASTER TESTS ----------------------------------------------------------------
		local layerName3 = "Desmatamento"
		proj:addLayer {
			layer = layerName3,
			file = filePath("Desmatamento_2000.tif", "fillcell")		
		}	

		local raverageLayerName = clName1.."_Average"
		local areaUnnecessary = function()
			cl:fillCells{
				attribute = "attr",
				operation = "average",
				layer = layerName3,
				select = 0,
				output = raverageLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))
		
		local selectNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "average",
				layer = layerName3,
				select = "0",
				output = raverageLayerName
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("select", "number", "0"))		
		
		local bandNotExists = function()
			cl:fillCells{
				attribute = "attr",
				operation = "average",
				layer = layerName3,
				select = 9,
				output = raverageLayerName
			}
		end
		unitTest:assertError(bandNotExists, "The attribute selected '".."9".."' not exists in layer '"..layerName3.."'.")	
		
		local bandNegative = function()
			cl:fillCells{
				attribute = "attr",
				operation = "average",
				layer = layerName3,
				select = -1,
				output = raverageLayerName
			}
		end
		unitTest:assertError(bandNegative, "The attribute selected must be '>=' 0.")	

		-- TODO: TERRALIB IS NOT VERIFY THIS (REPORT) 
		-- local layerNotIntersect = function()
			-- cl:fillCells{
				-- attribute = "attr",
				-- operation = "average",
				-- layer = layerName3,
				-- select = 0,
				-- output = raverageLayerName
			-- }
		-- end
		-- unitTest:assertError(layerNotIntersect, "The two layers do not intersect.") -- SKIP			
		
		local rminLayerName = clName1.."_Minimum"
		local areaUnnecessary = function()
			cl:fillCells{
				attribute = "attr",
				operation = "minimum",
				layer = layerName3,
				select = 0,
				output = rminLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))		
		
		local selectNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "minimum",
				layer = layerName3,
				select = "0",
				output = rminLayerName
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("select", "number", "0"))		

		local rmaxLayerName = clName1.."_Maximum"
		local areaUnnecessary = function()
			cl:fillCells{
				attribute = "attr",
				operation = "maximum",
				layer = layerName3,
				select = 0,
				output = rmaxLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))		
		
		local selectNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "maximum",
				layer = layerName3,
				select = "0",
				output = rmaxLayerName
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("select", "number", "0"))		

		local rpercentLayerName = clName1.."_Percentage"
		local areaUnnecessary = function()
			cl:fillCells{
				attribute = "attr",
				operation = "percentage",
				layer = layerName3,
				select = 0,
				output = rpercentLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))		
		
		local selectNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "percentage",
				layer = layerName3,
				select = "0",
				output = rpercentLayerName
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("select", "number", "0"))		

		local rstdevLayerName = clName1.."_Stdev"
		local areaUnnecessary = function()
			cl:fillCells{
				attribute = "attr",
				operation = "stdev",
				layer = layerName3,
				select = 0,
				output = rstdevLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))		
		
		local selectNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "stdev",
				layer = layerName3,
				select = "0",
				output = rstdevLayerName
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("select", "number", "0"))
		
		local rsumLayerName = clName1.."_Sum"
		local areaUnnecessary = function()
			cl:fillCells{
				attribute = "attr",
				operation = "sum",
				layer = layerName3,
				select = 0,
				output = rsumLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))		
		
		local selectNotNumber = function()
			cl:fillCells{
				attribute = "attr",
				operation = "sum",
				layer = layerName3,
				select = "0",
				output = rsumLayerName
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("select", "number", "0"))		

		local op1NotAvailable = function()
			cl:fillCells{
				attribute = "attr",
				operation = "area",
				layer = layerName3,
				output = rstdevLayerName
			}
		end
		unitTest:assertError(op1NotAvailable, "The operation '".."area".."' is not available to raster layer.")	

		local op2NotAvailable = function()
			cl:fillCells{
				attribute = "attr",
				operation = "count",
				layer = layerName3,
				output = rstdevLayerName
			}
		end
		unitTest:assertError(op2NotAvailable, "The operation '".."count".."' is not available to raster layer.")

		local op3NotAvailable = function()
			cl:fillCells{
				attribute = "attr",
				operation = "distance",
				layer = layerName3,
				output = rstdevLayerName
			}
		end
		unitTest:assertError(op3NotAvailable, "The operation '".."distance".."' is not available to raster layer.")	

		local op4NotAvailable = function()
			cl:fillCells{
				attribute = "attr",
				operation = "majority",
				layer = layerName3,
				output = rstdevLayerName
			}
		end
		unitTest:assertError(op4NotAvailable, "The operation '".."majority".."' is not available to raster layer.")	

		local op5NotAvailable = function()
			cl:fillCells{
				attribute = "attr",
				operation = "presence",
				layer = layerName3,
				output = rstdevLayerName
			}
		end
		unitTest:assertError(op5NotAvailable, "The operation '".."presence".."' is not available to raster layer.")		

		-- ###################### END #############################
		local tl = TerraLib{}
		tl:finalize()			
		
		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
		
		for i = 1, #exts do
			local f = fn1..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end			
			local f = fn2..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end
 	end
}

