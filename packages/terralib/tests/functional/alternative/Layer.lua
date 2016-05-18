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
	Layer = function(unitTest)
		local noDataArguments = function()
			local cl = Layer()
		end

		local attrLayerNonString = function()
			local cl = Layer{project = "myproj.tview", name = false}
		end
		unitTest:assertError(attrLayerNonString, incompatibleTypeMsg("name", "string", false))

		if isFile("myproj.tview") then
			rmFile("myproj.tview")
		end

		local projNotExists = function()
			local cl = Layer{project = "myproj.tview", name = "cells"}
		end
		unitTest:assertError(projNotExists, "Project file '".."myproj.tview".."' does not exist.")		
		
		local projFile = "proj_celllayer.tview"
		
		local proj = Project{
			file = projFile,
			clean = true
		}
		
		local layerName = "any"
		local layerDoesNotExists = function()
			local cl = Layer{
				project = proj,
				name = layerName
			}
		end
		unitTest:assertError(layerDoesNotExists, "Layer '"..layerName.."' does not exist in the Project '"..projFile.."'.")
		
		unitTest:assertFile("proj_celllayer.tview")
	
		local projName = "amazonia2.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local noDataInLayer = function()
			Layer()
		end
		unitTest:assertError(noDataInLayer, tableArgumentMsg())

		local attrLayerNonString = function()
			Layer{
				project = proj,
				name = 123,
				file = "myfile.shp",
			}

		end
		unitTest:assertError(attrLayerNonString, incompatibleTypeMsg("name", "string", 123))

		local attrSourceNonString = function()
			Layer{
				project = proj,
				name = "layer",
				source = 123
			}

		end
		unitTest:assertError(attrSourceNonString, incompatibleTypeMsg("source", "string", 123))	
				
		local noFilePass = function()
			Layer{
				project = proj,
				name = "Linhares",
				source = "tif"
			}
		end
		unitTest:assertError(noFilePass, mandatoryArgumentMsg("file"))	
		
		local layerName = "Sampa"
		Layer{
			project = proj,
			name = layerName,
			file = filePath("sampa.shp", "terralib")			
		}
		
		local layerAlreadyExists = function()
			Layer{
				project = proj,
				name = layerName,
				file = filePath("sampa.shp", "terralib")	
			}			
		end
		unitTest:assertError(layerAlreadyExists, "Layer '"..layerName.."' already exists in the Project.")
	
		local sourceInvalid = function()
			Layer{
				project = proj,
				name = layerName,
				file = filePath("sampa.dbf", "terralib")	
			}			
		end
		unitTest:assertError(sourceInvalid, "Source 'dbf' is invalid.")
		
		local layerFile = "linhares.shp"
		local fileLayerNonExists = function()
			Layer{
				project = proj,
				name = "Linhares",
				file = layerFile	
			}			
		end
		unitTest:assertError(fileLayerNonExists, mandatoryArgumentMsg("source"))			
	
		local filePath0 = filePath("sampa.shp", "terralib")
		local source = "tif"
		local inconsistentExtension = function()
			Layer{
				project = proj,
				name = "Setores_New",
				file = filePath0,
				source = "tif"
			}			
		end
		unitTest:assertError(inconsistentExtension, "File '"..filePath0.."' does not match to source '"..source.."'.")			
		
		if isFile(projName) then
			rmFile(projName)
		end
		
		local projName = "amazonia.tview"

		local proj = Project{
			file = projName,
			clean = true
		}	

		local attrInputNonString = function()
			Layer{
				project = proj,
				input = 123,
				name = "cells",
				resolution = 5e4
			}
		end
		unitTest:assertError(attrInputNonString, incompatibleTypeMsg("input", "string", 123))

		local attrLayerNonString = function()
			Layer{
				project = proj,
				input = "amazonia-states",
				name = 123,
				resolution = 5e4
			}
		end
		unitTest:assertError(attrLayerNonString, incompatibleTypeMsg("name", "string", 123))

		local attrBoxNonBoolean = function()
			Layer{
				project = proj,
				input = "amazonia-states",
				name = "cells",
				resolution = 5e4,
				box = 123
			}
		end
		unitTest:assertError(attrBoxNonBoolean, incompatibleTypeMsg("box", "boolean", 123))

		local attrResolutionNonNumber = function()
			Layer{
				project = proj,
				input = "amazonia-states",
				name = "cells",
				resolution = false
			}
		end
		unitTest:assertError(attrResolutionNonNumber, incompatibleTypeMsg("resolution", "number", false))

		local attrResolutionNonPositive = function()
			Layer{
				project = proj,
				input = "amazonia-states",
				name = "cells",
				resolution = 0
			}
		end
		unitTest:assertError(attrResolutionNonPositive, positiveArgumentMsg("resolution", 0))

		local unnecessaryArgument = function()
			Layer{
				project = proj,
				input = "amazonia-states",
				name = "cells",
				resoltion = 200
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("resoltion", "resolution"))
		
		local noFilePass = function()
			Layer{
				project = proj,
				input = "amazonia-states",
				name = "cells",
				resolution = 0.7		
			}
		end
		unitTest:assertError(noFilePass, mandatoryArgumentMsg("source"))
		
		local attrSourceNonString = function()
			Layer{
				input = "amazonia-states",
				project = proj,
				name = "cells",
				resolution = 0.7,				
				name = "layer",
				file = "cells.shp",
				source = 123
			}
		end
		unitTest:assertError(attrSourceNonString, incompatibleTypeMsg("source", "string", 123))

		local layerName1 = "Sampa"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath("sampa.shp", "terralib")
		}
		
		local shp1 = "setores_cells.shp"
		
		if isFile(shp1) then
			rmFile(shp1)
		end
		
		local clName1 = "Setores_Cells"

		Layer{
			project = proj,
			input = layerName1,
			name = clName1,
			resolution = 0.7,
			file = shp1
		}
		
		local cellLayerAlreadyExists = function()
			Layer{
				project = proj,
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				file = "setores_cells_x.shp"
			}	
		end
		unitTest:assertError(cellLayerAlreadyExists, "Layer '"..clName1.."' already exists in the Project.")
		
		local cellLayerFileAlreadyExists = function()
			Layer{
				project = proj,
				input = layerName1,
				name = "CellLayerFileAlreadyExists",
				resolution = 0.7,
				file = shp1
			}	
		end
		unitTest:assertError(cellLayerFileAlreadyExists, "File '"..shp1.."' already exists. Please set clean = true or remove it manually.")
		
		local sourceInvalid = function()
			Layer{
				project = proj,
				input = layerName1,
				name = "cells",
				resolution = 0.7,
				file = filePath("sampa.dbf", "terralib")	
			}			
		end
		unitTest:assertError(sourceInvalid, "Source 'dbf' is invalid.")

		local filePath1 = filePath("sampa.shp", "terralib")
		local source = "tif"
		local inconsistentExtension = function()
			Layer{
				project = proj,
				input = layerName1,
				name = "cells",
				resolution = 0.7,
				file = filePath1,
				source = "tif"
			}			
		end
		unitTest:assertError(inconsistentExtension, "File '"..filePath1.."' not match to source '"..source.."'.")

		local inLayer = "no_exists"
		local inputNonExists = function()
			Layer{
				project = proj,
				input = inLayer,
				name = "cells",
				resolution = 0.7,
				file = "some.shp"
			}
		end
		unitTest:assertError(inputNonExists, "Input layer 'no_exists' was not found.")		
	
		local layer = Layer{
			project = proj,
			name = "cbers",
			file = filePath("cbers_rgb342_crop1.tif", "terralib")		
		}

		local invalidInput = function()
			Layer{
				project = proj,
				input = "cbers",
				name = "cells",
				resolution = 0.7,
				file = "some.shp"
			}
		end
		unitTest:assertError(invalidInput, "It is only possible to create a layer of cells from a layer with polygonal geometry, got raster.")

		if isFile(projName) then
			rmFile(projName)
		end		
		
		if isFile(shp1) then
			rmFile(shp1)
		end
	end,
	fill = function(unitTest)
		local projName = "cellular_layer_fillcells_alternative.tview"

		local proj = Project{
			file = projName,
			clean = true
		}		

		local layerName1 = "Setores_2000"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
		}	
		
		local clName1 = "setores_cells2"
		local filePath1 = clName1..".shp"

		if isFile(filePath1) then
			rmFile(filePath1)
		end			

		local cl = Layer{
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName1,
			resolution = 30000,
			file = filePath1
		}	
		
		local operationMandatory = function()
			cl:fill{
				attribute = "population",
				layer = "population"
			}
		end
		unitTest:assertError(operationMandatory, mandatoryArgumentMsg("operation"))

		local operationNotString = function()
			cl:fill{
				attribute = "distRoads",
				operation = 2,
				layer = "roads"
			}
		end
		unitTest:assertError(operationNotString, incompatibleTypeMsg("operation", "string", 2))

		local layerMandatory = function()
			cl:fill{
				attribute = "population",
				operation = "area"
			}
		end
		unitTest:assertError(layerMandatory, mandatoryArgumentMsg("layer"))

		local layerNotString = function()
			cl:fill{
				attribute = "distRoads",
				operation = "area",
				layer = 2
			}
		end
		unitTest:assertError(layerNotString, incompatibleTypeMsg("layer", "string", 2))
	
		local attributeMandatory = function()
			cl:fill{
				layer = "cells",
				operation = "area"
			}
		end
		unitTest:assertError(attributeMandatory, mandatoryArgumentMsg("attribute"))

		local attributeNotString = function()
			cl:fill{
				attribute = 2,
				operation = "area",
				layer = "cells"
			}
		end
		unitTest:assertError(attributeNotString, incompatibleTypeMsg("attribute", "string", 2))
		
		local outputMandatory = function()
			cl:fill{
				layer = "cells",
				operation = "area",
				attribute = "any"
			}
		end
		unitTest:assertError(outputMandatory, mandatoryArgumentMsg("output"))

		local outputNotString = function()
			cl:fill{
				attribute = "any",
				operation = "area",
				layer = "cells",
				output = 2
			}
		end
		unitTest:assertError(outputNotString, incompatibleTypeMsg("output", "string", 2))		
		
		local presenceLayerName = clName1.."_Presence"
		local layerNotExists = function()
			cl:fill{
				operation = "presence",
				layer = "LayerNotExists",
				attribute = "presence",
				output = presenceLayerName
			}
		end
		unitTest:assertError(layerNotExists, "The layer '".."LayerNotExists".."' does not exist.")
		
		local attrAlreadyExists = function()
			cl:fill{
				operation = "presence",
				layer = layerName1,
				attribute = "row",
				output = presenceLayerName
			}
		end
		unitTest:assertError(attrAlreadyExists, "The attribute '".."row".."' already exists in the Layer.")				

		local presenceSelectUnnecessary = function()
			cl:fill{
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
			cl:fill{
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
			cl:fill{
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
			cl:fill{
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
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = 2,
				clean = true,
				output = minValueLayerName
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local defaultNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = "row",
				clean = true,
				output = minValueLayerName,
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		local dummyNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = "row",
				clean = true,
				output = minValueLayerName,
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		local unnecessaryArgument = function()
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = "row",
				clean = true,
				output = minValueLayerName,
				dummy = 0,
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))
		
		local selected = "ITNOTEXISTS"
		local selectNotExists = function()
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = selected,
				clean = true,
				output = minValueLayerName
			}
		end
		unitTest:assertError(selectNotExists, "Selected attribute '"..selected.."' does not exist in layer '"..layerName1.."'.")

		local maxValueLayerName = clName1.."_Maximum"
		local selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = 2,
				clean = true,
				output = maxValueLayerName
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local defaultNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = maxValueLayerName,
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		local dummyNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = maxValueLayerName,
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		local unnecessaryArgument = function()
			cl:fill{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = maxValueLayerName,
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))
		
		local coverageLayerName = clName1.."_Percentage"
		local selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "coverage",
				layer = layerName1,
				select = 2,
				clean = true,
				output = coverageLayerName
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local defaultNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "coverage",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = coverageLayerName,
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		local dummyNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "coverage",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = coverageLayerName,
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		local unnecessaryArgument = function()
			cl:fill{
				attribute = "attr",
				operation = "coverage",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = coverageLayerName,
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))
		
		local stdevLayerName = clName1.."_Stdev"
		local selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "stdev",
				layer = layerName1,
				select = 2,
				clean = true,
				output = stdevLayerName
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local defaultNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "stdev",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = stdevLayerName,
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		local dummyNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "stdev",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = stdevLayerName,
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		local defaultNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "stdev",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = stdevLayerName,
				defaut = 3
			}
		end
		unitTest:assertError(defaultNotNumber, unnecessaryArgumentMsg("defaut", "default"))
		
		local averageLayerName = clName1.."_Average"
		local selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName1,
				select = 2,
				clean = true,
				output = averageLayerName
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local areaNotBoolean = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = averageLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaNotBoolean, incompatibleTypeMsg("area", "boolean", 2))

		local defaultNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = averageLayerName,
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		local dummyNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = averageLayerName,
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		local unnecessaryArgument = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = averageLayerName,
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))
		
		local modeLayerName = clName1.."_Majority"
		local selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "mode",
				layer = layerName1,
				select = 2,
				clean = true,
				output = modeLayerName
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local areaNotBoolean = function()
			cl:fill{
				attribute = "attr",
				operation = "mode",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = modeLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaNotBoolean, incompatibleTypeMsg("area", "boolean", 2))

		local defaultNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "mode",
				layer = layerName1,
				select = "FID",
				output = modeLayerName,
				clean = true,
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		local dummyNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "mode",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = modeLayerName,
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		local unnecessaryArgument = function()
			cl:fill{
				attribute = "attr",
				operation = "mode",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = modeLayerName,
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))
		
		local sumLayerName = clName1.."_Sum"
		local selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "sum",
				layer = layerName1,
				select = 2,
				clean = true,
				output = sumLayerName
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local areaNotBoolean = function()
			cl:fill{
				attribute = "attr",
				operation = "sum",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = sumLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaNotBoolean, incompatibleTypeMsg("area", "boolean", 2))

		local defaultNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "sum",
				layer = layerName1,
				select = "FID",
				output = sumLayerName,
				clean = true,
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		local dummyNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "sum",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = sumLayerName,
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		local unnecessaryArgument = function()
			cl:fill{
				attribute = "attr",
				operation = "sum",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = sumLayerName,
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))
		
		local normalizedNameWarning = function()
			cl:fill{
				attribute = "max10allowed",
				operation = "sum",
				layer = layerName1,
				select = "FID",
				clean = true,
				output = sumLayerName
			}		
		end
		unitTest:assertError(normalizedNameWarning,   "The 'attribute' lenght is more than 10 characters, it was changed to 'max10allow'.")

		local localidades = "Localidades"

		Layer{
			project = proj,
			name = localidades,
			file = filePath("Localidades_pt.shp", "terralib")
		}
		
		local presenceLayerName = clName1.."_Presence_2000"
		local filePath2 = presenceLayerName..".shp"

		if isFile(filePath2) then
			rmFile(filePath2)
		end	

		local cW = customWarning 
		customWarning = function(msg) return end

		cl:fill{
			operation = "presence",
			layer = localidades,
			attribute = "presence2000",
			output = presenceLayerName
		}	
		
		local presenceLayerName2 = clName1.."_Presence_2001"
		
		local normalizedTrucatedError = function()
			cl:fill{
				operation = "presence",
				layer = localidades,
				attribute = "presence2001",
				output = presenceLayerName2
			}
		end
		unitTest:assertError(normalizedTrucatedError, "The attribute 'presence20' already exists in the Layer.")
		
		customWarning = cW
		
		-- RASTER TESTS ----------------------------------------------------------------
		local layerName3 = "Desmatamento"

		Layer{
			project = proj,
			name = layerName3,
			file = filePath("Desmatamento_2000.tif", "terralib")
		}

		local raverageLayerName = clName1.."_Average"
		local areaUnnecessary = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName3,
				band = 0,
				output = raverageLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))
		
		local selectNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName3,
				band = "0",
				output = raverageLayerName
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("band", "number", "0"))		
		local bandNotExists = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName3,
				band = 9,
				output = raverageLayerName
			}
		end
		unitTest:assertError(bandNotExists, "Selected band '".."9".."' does not exist in layer '"..layerName3.."'.")	
		
		local bandNegative = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName3,
				band = -1,
				output = raverageLayerName
			}
		end
		unitTest:assertError(bandNegative, positiveArgumentMsg("band", -1, true))

		-- TODO: TERRALIB IS NOT VERIFY THIS (REPORT) 
		-- local layerNotIntersect = function()
			-- cl:fill{
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
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName3,
				band = 0,
				clean = true,
				output = rminLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))		
		
		local selectNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName3,
				clean = true,
				band = "0",
				output = rminLayerName
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("band", "number", "0"))	

		local rmaxLayerName = clName1.."_Maximum"
		local areaUnnecessary = function()
			cl:fill{
				attribute = "attr",
				operation = "maximum",
				layer = layerName3,
				band = 0,
				clean = true,
				output = rmaxLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))		
		
		local selectNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "maximum",
				layer = layerName3,
				band = "0",
				clean = true,
				output = rmaxLayerName
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("band", "number", "0"))

		local rpercentLayerName = clName1.."_Percentage"
		local areaUnnecessary = function()
			cl:fill{
				attribute = "attr",
				operation = "coverage",
				layer = layerName3,
				band = 0,
				clean = true,
				output = rpercentLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))		
		
		local selectNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "coverage",
				layer = layerName3,
				band = "0",
				clean = true,
				output = rpercentLayerName
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("band", "number", "0"))

		local rstdevLayerName = clName1.."_Stdev"
		local areaUnnecessary = function()
			cl:fill{
				attribute = "attr",
				operation = "stdev",
				layer = layerName3,
				band = 0,
				clean = true,
				output = rstdevLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))		
		
		local selectNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "stdev",
				layer = layerName3,
				band = "0",
				clean = true,
				output = rstdevLayerName
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("band", "number", "0"))
		
		local rsumLayerName = clName1.."_Sum"
		local areaUnnecessary = function()
			cl:fill{
				attribute = "attr",
				operation = "sum",
				layer = layerName3,
				band = 0,
				clean = true,
				output = rsumLayerName,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))		
		
		local selectNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "sum",
				layer = layerName3,
				band = "0",
				clean = true,
				output = rsumLayerName
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("band", "number", "0"))

		local op1NotAvailable = function()
			cl:fill{
				attribute = "attr",
				operation = "area",
				layer = layerName3,
				clean = true,
				output = rstdevLayerName
			}
		end
		unitTest:assertError(op1NotAvailable, "The operation 'area' is not available for layers with raster data.")	

		local op2NotAvailable = function()
			cl:fill{
				attribute = "attr",
				operation = "count",
				layer = layerName3,
				clean = true,
				output = rstdevLayerName
			}
		end
		unitTest:assertError(op2NotAvailable, "The operation 'count' is not available for layers with raster data.")	

		local op3NotAvailable = function()
			cl:fill{
				attribute = "attr",
				operation = "distance",
				layer = layerName3,
				clean = true,
				output = rstdevLayerName
			}
		end
		unitTest:assertError(op3NotAvailable, "The operation 'distance' is not available for layers with raster data.")	

		local op4NotAvailable = function()
			cl:fill{
				attribute = "attr",
				operation = "presence",
				layer = layerName3,
				clean = true,
				output = rstdevLayerName
			}
		end
		unitTest:assertError(op4NotAvailable, "The operation 'presence' is not available for layers with raster data.")	
		
		if isFile(projName) then
			rmFile(projName)
		end

		local tl = TerraLib{}
		tl:finalize()

		if isFile(filePath1) then rmFile(filePath1) end	
		if isFile(filePath2) then rmFile(filePath2) end	
 	end
}

