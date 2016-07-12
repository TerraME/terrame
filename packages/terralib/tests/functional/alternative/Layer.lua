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
		local attrLayerNonString = function()
			Layer{project = "myproj.tview", name = false}
		end
		unitTest:assertError(attrLayerNonString, incompatibleTypeMsg("name", "string", false))

		if isFile("myproj.tview") then
			rmFile("myproj.tview")
		end

		local projNotExists = function()
			Layer{project = "myproj.tview", name = "cells"}
		end
		unitTest:assertError(projNotExists, "Project file '".."myproj.tview".."' does not exist.")

		local projFile = "proj_celllayer.tview"

		local proj = Project{
			file = projFile,
			clean = true,
			deforestation = filePath("desmatamento_2000.tif", "terralib"),
		}

		local layerName = "any"
		local layerDoesNotExists = function()
			Layer{
				project = proj,
				name = layerName
			}
		end
		unitTest:assertError(layerDoesNotExists, "Layer '"..layerName.."' does not exist in Project '"..projFile.."'.")

		layerName = "defirestation"
		local layerDoesNotExistsSug = function()
			Layer{
				project = proj,
				name = layerName
			}
		end
		unitTest:assertError(layerDoesNotExistsSug, "Layer '"..layerName.."' does not exist in Project '"..projFile.."'. Do you mean 'deforestation'?")

		unitTest:assertFile("proj_celllayer.tview")

		local projName = "amazonia2.tview"

		proj = Project{
			file = projName,
			clean = true
		}

		local noDataInLayer = function()
			Layer()
		end
		unitTest:assertError(noDataInLayer, tableArgumentMsg())

		attrLayerNonString = function()
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

		layerName = "Sampa"
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
		
		projName = "amazonia.tview"

		proj = Project{
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

		attrLayerNonString = function()
			Layer{
				project = proj,
				input = "amazonia-states",
				name = 123,
				resolution = 5e4
			}
		end
		unitTest:assertError(attrLayerNonString, incompatibleTypeMsg("name", "string", 123))	

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

		noFilePass = function()
			Layer{
				project = proj,
				input = "amazonia-states",
				name = "cells",
				resolution = 0.7
			}
		end
		unitTest:assertError(noFilePass, mandatoryArgumentMsg("file"))

		attrSourceNonString = function()
			Layer{
				input = "amazonia-states",
				project = proj,
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

		sourceInvalid = function()
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
		source = "tif"
		inconsistentExtension = function()
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

		Layer{
			project = proj,
			name = "cbers",
			file = filePath("cbers_rgb342_crop1.tif", "terralib")
		}
		
		local attrBoxNonBoolean = function()
			Layer{
				project = proj,
				input = layerName1,
				name = "cells",
				resolution = 5e4,
				box = 123,
				file = "sampabox.shp"
			}
		end
		unitTest:assertError(attrBoxNonBoolean, incompatibleTypeMsg("box", "boolean", 123))
		
		local boxDefaultError = function()
			Layer{
				project = proj,
				input = layerName1,
				name = "cells",
				resolution = 5e4,
				box = false,
				file = "sampabox.shp"
			}
		end
		unitTest:assertError(boxDefaultError, defaultValueMsg("box", false))	

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
				output = "abc",
				operation = "area"
			}
		end
		unitTest:assertError(layerMandatory, mandatoryArgumentMsg("layer"))

		local layerNotString = function()
			cl:fill{
				attribute = "distRoads",
				output = "abc",
				operation = "area",
				layer = 2
			}
		end
		unitTest:assertError(layerNotString, incompatibleTypeMsg("layer", "Layer", 2))

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

	--[[ BUG:
		local attributeDoesNotExist = function()
			cl:fill{
				attribute = "def",
				operation = "area",
				layer = clName1
			}
		end
		unitTest:assertError(attributeDoesNotExist, "string") -- SKIP
		--]]

		local layerNotExists = function()
			cl:fill{
				operation = "presence",
				layer = "LayerNotExists",
				attribute = "presence"
			}
		end
		unitTest:assertError(layerNotExists, "Layer 'LayerNotExists' does not exist in Project '"..projName.."'.")

		local layerNotExistsSug = function()
			cl:fill{
				operation = "presence",
				layer = layerName1.."_",
				attribute = "presence"
			}
		end
		unitTest:assertError(layerNotExistsSug, "Layer '"..layerName1.."_' does not exist in Project '"..projName.."'. Do you mean '"..layerName1.."'?")

		local attrAlreadyExists = function()
			cl:fill{
				operation = "presence",
				layer = layerName1,
				attribute = "row"
			}
		end
		unitTest:assertError(attrAlreadyExists, "The attribute '".."row".."' already exists in the Layer.")

		local presenceSelectUnnecessary = function()
			cl:fill{
				operation = "presence",
				layer = layerName1,
				attribute = "presence",
				select = "FID"
			}
		end
		unitTest:assertError(presenceSelectUnnecessary, unnecessaryArgumentMsg("select"))

		local areaSelectUnnecessary = function()
			cl:fill{
				attribute = "attr",
				operation = "area",
				layer = layerName1,
				select = "FID"
			}
		end
		unitTest:assertError(areaSelectUnnecessary, unnecessaryArgumentMsg("select"))

		local countSelectUnnecessary = function()
			cl:fill{
				attribute = "attr",
				operation = "count",
				layer = layerName1,
				select = "FID"
			}
		end
		unitTest:assertError(countSelectUnnecessary, unnecessaryArgumentMsg("select"))

		local distanceSelectUnnecessary = function()
			cl:fill{
				attribute = "attr",
				operation = "distance",
				layer = layerName1,
				select = "FID"
			}
		end
		unitTest:assertError(distanceSelectUnnecessary, unnecessaryArgumentMsg("select"))

		local selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = 2
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local defaultNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = "row",
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
				select = selected
			}
		end
		unitTest:assertError(selectNotExists, "Selected attribute '"..selected.."' does not exist in layer '"..layerName1.."'.")

		selected = "populaco"
		local selectNotExistsSug = function()
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = selected
			}
		end
		unitTest:assertError(selectNotExistsSug, "Selected attribute '"..selected.."' does not exist in layer '"..layerName1.."'. Do you mean 'Populacao'?")

		local maxValueLayerName = clName1.."_Maximum"

		selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = 2
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		defaultNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = "FID",
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		dummyNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = "FID",
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		unnecessaryArgument = function()
			cl:fill{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = "FID",
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))

		selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "coverage",
				layer = layerName1,
				select = 2
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		defaultNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "coverage",
				layer = layerName1,
				select = "FID",
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		dummyNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "coverage",
				layer = layerName1,
				select = "FID",
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		unnecessaryArgument = function()
			cl:fill{
				attribute = "attr",
				operation = "coverage",
				layer = layerName1,
				select = "FID",
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))

		selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "stdev",
				layer = layerName1,
				select = 2
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		defaultNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "stdev",
				layer = layerName1,
				select = "FID",
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		dummyNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "stdev",
				layer = layerName1,
				select = "FID",
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		defaultNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "stdev",
				layer = layerName1,
				select = "FID",
				defaut = 3
			}
		end
		unitTest:assertError(defaultNotNumber, unnecessaryArgumentMsg("defaut", "default"))

		selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName1,
				select = 2
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local areaNotBoolean = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName1,
				select = "FID",
				area = 2
			}
		end
		unitTest:assertError(areaNotBoolean, incompatibleTypeMsg("area", "boolean", 2))

		defaultNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName1,
				select = "FID",
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		dummyNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName1,
				select = "FID",
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		unnecessaryArgument = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName1,
				select = "FID",
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))

		selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "mode",
				layer = layerName1,
				select = 2
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		areaNotBoolean = function()
			cl:fill{
				attribute = "attr",
				operation = "mode",
				layer = layerName1,
				select = "FID",
				area = 2
			}
		end
		unitTest:assertError(areaNotBoolean, incompatibleTypeMsg("area", "boolean", 2))

		defaultNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "mode",
				layer = layerName1,
				select = "FID",
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		dummyNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "mode",
				layer = layerName1,
				select = "FID",
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		unnecessaryArgument = function()
			cl:fill{
				attribute = "attr",
				operation = "mode",
				layer = layerName1,
				select = "FID",
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))

		selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "sum",
				layer = layerName1,
				select = 2
			}
		end
		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		areaNotBoolean = function()
			cl:fill{
				attribute = "attr",
				operation = "sum",
				layer = layerName1,
				select = "FID",
				area = 2
			}
		end
		unitTest:assertError(areaNotBoolean, incompatibleTypeMsg("area", "boolean", 2))

		defaultNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "sum",
				layer = layerName1,
				select = "FID",
				default = false
			}
		end
		unitTest:assertError(defaultNotNumber, incompatibleTypeMsg("default", "number", false))

		dummyNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "sum",
				layer = layerName1,
				select = "FID",
				dummy = false
			}
		end
		unitTest:assertError(dummyNotNumber, incompatibleTypeMsg("dummy", "number", false))

		unnecessaryArgument = function()
			cl:fill{
				attribute = "attr",
				operation = "sum",
				layer = layerName1,
				select = "FID",
				defaut = 3
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("defaut", "default"))

		local normalizedNameWarning = function()
			cl:fill{
				attribute = "max10allowed",
				operation = "sum",
				layer = layerName1,
				select = "FID"
			}
		end
		unitTest:assertError(normalizedNameWarning,   "The 'attribute' lenght is more than 10 characters, it was changed to 'max10allow'.")

		local localidades = "Localidades"

		Layer{
			project = proj,
			name = localidades,
			file = filePath("Localidades_pt.shp", "terralib")
		}
		
		local cW = customWarning 
		customWarning = function() return end

		cl:fill{
			operation = "presence",
			layer = localidades,
			attribute = "presence2000"
		}

		local normalizedTrucatedError = function()
			cl:fill{
				operation = "presence",
				layer = localidades,
				attribute = "presence2001"
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

		local areaUnnecessary = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName3,
				band = 0,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))

		local selectNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName3,
				band = "0"
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("band", "number", "0"))

		local bandNegative = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName3,
				band = -1
			}
		end
		unitTest:assertError(bandNegative, positiveArgumentMsg("band", -1, true))

		-- TODO: TERRALIB IS NOT VERIFY THIS (REPORT) 
		-- local layerNotIntersect = function()
			-- cl:fill{
				-- attribute = "attr",
				-- operation = "average",
				-- layer = layerName3,
				-- select = 0
			-- }
		-- end
		-- unitTest:assertError(layerNotIntersect, "The two layers do not intersect.") -- SKIP

		areaUnnecessary = function()
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName3,
				band = 0,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))

		selectNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName3,
				band = "0"
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("band", "number", "0"))

		areaUnnecessary = function()
			cl:fill{
				attribute = "attr",
				operation = "maximum",
				layer = layerName3,
				band = 0,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))

		selectNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "maximum",
				layer = layerName3,
				band = "0"
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("band", "number", "0"))

		areaUnnecessary = function()
			cl:fill{
				attribute = "attr",
				operation = "coverage",
				layer = layerName3,
				band = 0,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))

		selectNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "coverage",
				layer = layerName3,
				band = "0"
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("band", "number", "0"))

		areaUnnecessary = function()
			cl:fill{
				attribute = "attr",
				operation = "stdev",
				layer = layerName3,
				band = 0,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))

		selectNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "stdev",
				layer = layerName3,
				band = "0"
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("band", "number", "0"))

		areaUnnecessary = function()
			cl:fill{
				attribute = "attr",
				operation = "sum",
				layer = layerName3,
				band = 0,
				area = 2
			}
		end
		unitTest:assertError(areaUnnecessary, unnecessaryArgumentMsg("area"))

		selectNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "sum",
				layer = layerName3,
				band = "0"
			}
		end
		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("band", "number", "0"))

		local op1NotAvailable = function()
			cl:fill{
				attribute = "attr",
				operation = "area",
				layer = layerName3
			}
		end
		unitTest:assertError(op1NotAvailable, "The operation 'area' is not available for layers with raster data.")

		local op2NotAvailable = function()
			cl:fill{
				attribute = "attr",
				operation = "count",
				layer = layerName3
			}
		end
		unitTest:assertError(op2NotAvailable, "The operation 'count' is not available for layers with raster data.")

		local op3NotAvailable = function()
			cl:fill{
				attribute = "attr",
				operation = "distance",
				layer = layerName3
			}
		end
		unitTest:assertError(op3NotAvailable, "The operation 'distance' is not available for layers with raster data.")

		local op4NotAvailable = function()
			cl:fill{
				attribute = "attr",
				operation = "presence",
				layer = layerName3
			}
		end
		unitTest:assertError(op4NotAvailable, "The operation 'presence' is not available for layers with raster data.")

		if isFile(projName) then
			rmFile(projName)
		end

		if isFile(filePath1) then rmFile(filePath1) end
	end
}

