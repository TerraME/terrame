-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

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

		File("myproj.tview"):deleteIfExists()

		local projNotExists = function()
			Layer{project = "myproj.tview", name = "cells"}
		end

		unitTest:assertError(projNotExists, "Project file '"..File("myproj.tview").."' does not exist.")

		local noProj = function()
			Layer{file = "myfile.shp", name = "name"}
		end

		unitTest:assertError(noProj, mandatoryArgumentMsg("project"))

		local projFile = File("proj_celllayer.tview")

		projFile:deleteIfExists()

		local proj

		proj = Project{
			file = projFile:name(true),
			clean = true,
			deforestation = filePath("itaituba-deforestation.tif", "gis"),
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

		projFile:deleteIfExists()

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
			file = filePath("test/sampa.shp", "gis")
		}

		local layerAlreadyExists = function()
			Layer{
				project = proj,
				name = layerName,
				file = filePath("test/sampa.shp", "gis")
			}
		end

		unitTest:assertError(layerAlreadyExists, "Layer '"..layerName.."' already exists in the Project.")

		local sourceInvalid = function()
			Layer{
				project = proj,
				name = layerName,
				file = filePath("test/sampa.dbf", "gis")
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

		unitTest:assertError(fileLayerNonExists, "File '"..File("linhares.shp").."' does not exist.")

		local filePath0 = filePath("test/sampa.shp", "gis")
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

		File(projName):deleteIfExists()

		projName = "amazonia.tview"

		proj = Project{
			file = projName,
			limit = filePath("amazonia-limit.shp", "gis"),
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
				input = "limit",
				name = 123,
				resolution = 5e4
			}
		end

		unitTest:assertError(attrLayerNonString, incompatibleTypeMsg("name", "string", 123))

		local attrResolutionNonNumber = function()
			Layer{
				project = proj,
				input = "limit",
				name = "cells",
				resolution = false
			}
		end

		unitTest:assertError(attrResolutionNonNumber, incompatibleTypeMsg("resolution", "number", false))

		local attrResolutionNonPositive = function()
			Layer{
				project = proj,
				input = "limit",
				name = "cells",
				resolution = 0
			}
		end

		unitTest:assertError(attrResolutionNonPositive, positiveArgumentMsg("resolution", 0))

		noFilePass = function()
			Layer{
				project = proj,
				input = "limit",
				name = "cells",
				resolution = 0.7
			}
		end

		unitTest:assertError(noFilePass, "At least one of the following arguments must be used: 'file', 'source', or 'database'.")

		attrSourceNonString = function()
			Layer{
				input = "limit",
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
			file = filePath("test/sampa.shp", "gis")
		}

		local shp1 = "setores_cells.shp"

		File(shp1):deleteIfExists()

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

		unitTest:assertError(cellLayerFileAlreadyExists, "File 'setores_cells.shp' already exists. Please set clean = true or remove it manually.")

		sourceInvalid = function()
			Layer{
				project = proj,
				input = layerName1,
				name = "cells",
				resolution = 0.7,
				file = filePath("test/sampa.dbf", "gis")
			}
		end

		unitTest:assertError(sourceInvalid, "Source 'dbf' is invalid.")

		local filePath1 = filePath("test/sampa.shp", "gis")
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
			file = filePath("test/cbers_rgb342_crop1.tif", "gis")
		}

		local attrBoxNonBoolean = function()
			Layer{
				project = proj,
				input = layerName1,
				name = "cells2",
				resolution = 5e4,
				box = 123,
				file = "sampabox.shp"
			}
		end

		unitTest:assertError(attrBoxNonBoolean, incompatibleTypeMsg("box", "boolean", 123))

		local invalidLayerName = function()
			Layer{
				project = proj,
				name = "My Layer",
				file = filePath("test/sampa.shp", "gis")
			}
		end

		unitTest:assertError(invalidLayerName, "'My Layer' is not a valid Layer name. Please check special characters or spaces.")

		invalidLayerName = function()
			Layer{
				project = proj,
				name = "Samp*a",
				file = filePath("test/sampa.shp", "gis")
			}
		end

		unitTest:assertError(invalidLayerName, "'Samp*a' is not a valid Layer name. Please check special characters or spaces.")

		invalidLayerName = function()
			Layer{
				project = proj,
				name = "$ampa",
				file = filePath("test/sampa.shp", "gis")
			}
		end

		unitTest:assertError(invalidLayerName, "'$ampa' is not a valid Layer name. Please check special characters or spaces.")

		invalidLayerName = function()
			Layer{
				project = proj,
				name = "SãoPaulo",
				file = filePath("test/sampa.shp", "gis")
			}
		end

		unitTest:assertError(invalidLayerName, "'SãoPaulo' is not a valid Layer name. Please check special characters or spaces.")

		local invalidSridType = function()
			Layer{
				project = proj,
				name = "SampaSrid",
				file = filePath("test/sampa.shp", "gis"),
				epsg = true
			}
		end

		unitTest:assertError(invalidSridType, "Incompatible types. Argument 'epsg' expected number, got boolean.")

		local invalidEncoding = function()
			Layer{
				project = proj,
				name = "SampaSrid",
				file = filePath("test/sampa.shp", "gis"),
				encoding = "utf16"
			}
		end

		unitTest:assertError(invalidEncoding, "Encoding 'utf16' is invalid.")

		File(projName):deleteIfExists()
		File(shp1):deleteIfExists()

		local projTemporal = Project{
		    file = "temporal.tview",
		    clean = true,
		}

		local patternFileError = function()
			Layer{
			    project = projTemporal,
			    file = packageInfo("gis").data.."conservationAreas*.shp",
			}
		end
		unitTest:assertError(patternFileError, mandatoryArgumentMsg("name"))

		patternFileError = function()
			Layer{
			    project = projTemporal,
			    file = packageInfo("gis").data.."conservation.shp*",
			    name = "conservation"
			}
		end
		unitTest:assertError(patternFileError, "No results have been found to match the pattern '"..packageInfo("gis").data.."conservation.shp*".."'.")

		patternFileError = function()
			Layer{
			    project = projTemporal,
			    file = packageInfo("gis").data.."conservation.*",
			    name = "conservation"
			}
		end
		unitTest:assertError(patternFileError, "No results have been found to match the pattern '"..packageInfo("gis").data.."conservation.*".."'.")

		patternFileError = function()
			Layer{
			    project = projTemporal,
			    file = packageInfo("gis").path.."/data*/conservation*",
			    name = "conservation"
			}
		end
		unitTest:assertError(patternFileError, "Directory path '"..packageInfo("gis").path.."/data*/".."' contains invalid character '*'.")

		patternFileError = function()
			Layer{
			    project = projTemporal,
			    file = packageInfo("gis").data.."conservationAreas*.shp",
			    name = "conservation",
			    times = 1961
			}
		end
		unitTest:assertError(patternFileError, incompatibleTypeMsg("times", "table", 1961))

		patternFileError = function()
			Layer{
			    project = projTemporal,
			    file = packageInfo("gis").data.."conservationAreas*.shp",
			    name = "conservation",
			    times = {1961, 1523}
			}
		end
		unitTest:assertError(patternFileError, "File '"..packageInfo("gis").data.."conservationAreas_1523.shp' does not exist.")

		patternFileError = function()
			Layer{
			    project = projTemporal,
			    file = packageInfo("gis").data.."conservation.shp*",
			    name = "conservation",
			    times = {1961, 1974}
			}
		end
		unitTest:assertError(patternFileError, "File '"..packageInfo("gis").data.."conservation.shp_1961' does not exist.")

		patternFileError = function()
			Layer{
			    project = projTemporal,
			    file = packageInfo("gis").data.."conservation.*",
			    name = "conservation",
			    times = {1961, 1974}
			}
		end
		unitTest:assertError(patternFileError, "File '"..packageInfo("gis").data.."conservation._1961".."' does not exist.")

		patternFileError = function()
			Layer{
			    project = projTemporal,
			    file = packageInfo("gis").path.."/data*/conservation*",
			    name = "conservation",
			    times = {1961, 1974}
			}
		end
		unitTest:assertError(patternFileError, "Directory path '"..packageInfo("gis").path.."/data*/".."' contains invalid character '*'.")

		local patternWarning = function()
			Layer{
				project = projTemporal,
				file = packageInfo("gis").data.."conservation*Areas_1961.shp",
				name = "areas"
			}
		end

		unitTest:assertWarning(patternWarning, "Only one resut has been found to match the pattern '"..packageInfo("gis").data.."conservation*Areas_1961.shp'.")
		unitTest:assertEquals(projTemporal.areas.name, "areas")
		unitTest:assertType(projTemporal.areas, "Layer")
		unitTest:assertEquals(projTemporal.areas.source, "shp")

		projTemporal = Project{
		    file = "temporal.tview",
		    clean = true,
		}

		local timesWarning = function()
			Layer{
				project = projTemporal,
				file = packageInfo("gis").data.."conservationAreas*.shp",
				name = "conservation",
				times = {1979}
			}
		end

		unitTest:assertWarning(timesWarning, "Only one resut has been found to match the pattern '"..packageInfo("gis").data.."conservationAreas_1979.shp'.")
		unitTest:assertNil(projTemporal.conservation_1961)
		unitTest:assertNil(projTemporal.conservation_1974)
		unitTest:assertEquals(projTemporal.conservation_1979.name, "conservation_1979")
		unitTest:assertType(projTemporal.conservation_1979, "Layer")
		unitTest:assertEquals(projTemporal.conservation_1979.source, "shp")
		File("temporal.tview"):deleteIfExists()
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
			file = filePath("itaituba-census.shp", "gis")
		}

		local clName1 = "setores_cells2"
		local filePath1 = clName1..".shp"

		File(filePath1):deleteIfExists()

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

		local invalidAttribName = function()
			cl:fill{
				attribute = "área",
				operation = "area",
				layer = "cells"
			}
		end

		unitTest:assertError(invalidAttribName, "Attribute name 'área' is not a valid name. Invalid symbol.")

		invalidAttribName = function()
			cl:fill{
				attribute = "a$ea",
				operation = "area",
				layer = "cells"
			}
		end

		unitTest:assertError(invalidAttribName, "Attribute name 'a$ea' is not a valid name. Invalid symbol: '$'.")

		invalidAttribName = function()
			cl:fill{
				attribute = "Cell Area",
				operation = "area",
				layer = "cells"
			}
		end

		unitTest:assertError(invalidAttribName, "Attribute name 'Cell Area' is not a valid name. Invalid character: blank space.")

		invalidAttribName = function()
			cl:fill{
				attribute = "Are*s",
				operation = "area",
				layer = "cells"
			}
		end

		unitTest:assertError(invalidAttribName, "Attribute name 'Are*s' is not a valid name. Invalid character: mathematical symbol '*'.")

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

		unitTest:assertError(layerNotExists, "Layer 'LayerNotExists' does not exist in Project '"..File(projName).."'.")

		local layerNotExistsSug = function()
			cl:fill{
				operation = "presence",
				layer = layerName1.."_",
				attribute = "presence"
			}
		end

		unitTest:assertError(layerNotExistsSug, "Layer '"..layerName1.."_' does not exist in Project '"..File(projName).."'. Do you mean '"..layerName1.."'?")

		local attrAlreadyExists = function()
			cl:fill{
				operation = "presence",
				layer = layerName1,
				attribute = "row"
			}
		end

		unitTest:assertError(attrAlreadyExists, "The attribute '".."row".."' already exists in the Layer.")

		local selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = 2
			}
		end

		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		local missingNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = "row",
				missing = false
			}
		end

		unitTest:assertError(missingNotNumber, incompatibleTypeMsg("missing", "number", false))

		local selected = "ITNOTEXISTS"
		local selectNotExists = function()
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = selected
			}
		end

		unitTest:assertError(selectNotExists, "Selected attribute '"..selected.."' does not exist in Layer '"..layerName1.."'. The available attributes are: 'FID', 'population', 'dens_pop'.")

		selected = "populaco"
		local selectNotExistsSug = function()
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName1,
				select = selected
			}
		end

		unitTest:assertError(selectNotExistsSug, "Selected attribute '"..selected.."' does not exist in Layer '"..layerName1.."'. Do you mean 'population'?")

		selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = 2
			}
		end

		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		missingNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "maximum",
				layer = layerName1,
				select = "FID",
				missing = false
			}
		end

		unitTest:assertError(missingNotNumber, incompatibleTypeMsg("missing", "number", false))

		selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "coverage",
				layer = layerName1,
				select = 2
			}
		end

		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		missingNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "coverage",
				layer = layerName1,
				select = "FID",
				missing = false
			}
		end

		unitTest:assertError(missingNotNumber, incompatibleTypeMsg("missing", "number", false))

		selectNotString = function()
			cl:fill{
				attribute = "attr",
				operation = "stdev",
				layer = layerName1,
				select = 2
			}
		end

		unitTest:assertError(selectNotString, incompatibleTypeMsg("select", "string", 2))

		missingNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "stdev",
				layer = layerName1,
				select = "FID",
				missing = false
			}
		end

		unitTest:assertError(missingNotNumber, incompatibleTypeMsg("missing", "number", false))

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

		missingNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "average",
				layer = layerName1,
				select = "FID",
				missing = false
			}
		end

		unitTest:assertError(missingNotNumber, incompatibleTypeMsg("missing", "number", false))

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

		missingNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "mode",
				layer = layerName1,
				select = "FID",
				missing = false
			}
		end

		unitTest:assertError(missingNotNumber, incompatibleTypeMsg("missing", "number", false))

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

		missingNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "sum",
				layer = layerName1,
				select = "FID",
				missing = false
			}
		end

		unitTest:assertError(missingNotNumber, incompatibleTypeMsg("missing", "number", false))

		local localidades = "Localidades"

		Layer{
			project = proj,
			name = localidades,
			file = filePath("itaituba-localities.shp", "gis")
		}

		cl:fill{
			operation = "presence",
			layer = localidades,
			attribute = "presence20"
		}

		local normalizedTrucatedError = function()
			cl:fill{
				operation = "presence",
				layer = localidades,
				attribute = "presence20"
			}
		end

		unitTest:assertError(normalizedTrucatedError, "The attribute 'presence20' already exists in the Layer.")

		-- RASTER TESTS ----------------------------------------------------------------
		local layerName3 = "Desmatamento"
		Layer{
			project = proj,
			name = layerName3,
			epsg = 29191,
			file = filePath("itaituba-deforestation.tif", "gis")
		}

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

		selectNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "minimum",
				layer = layerName3,
				band = "0"
			}
		end

		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("band", "number", "0"))

		selectNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "maximum",
				layer = layerName3,
				band = "0"
			}
		end

		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("band", "number", "0"))

		selectNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "coverage",
				layer = layerName3,
				band = "0"
			}
		end

		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("band", "number", "0"))

		selectNotNumber = function()
			cl:fill{
				attribute = "attr",
				operation = "stdev",
				layer = layerName3,
				band = "0"
			}
		end

		unitTest:assertError(selectNotNumber, incompatibleTypeMsg("band", "number", "0"))

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

		File(projName):delete()
		File(filePath1):delete()

		local projTemporal = Project{
		    file = "temporal.tview",
		    clean = true,
		    conservation = packageInfo("gis").data.."conservationAreas*.shp",
		    hidro = packageInfo("gis").data.."hidroeletricPlants*.shp",
		}

		cl = Layer{
			file = filePath1,
			project = projTemporal,
			source = "shp",
			input = "hidro_1970",
			name = "layer",
			resolution = 30000
		}

		local temporalAttributeError = function()
			cl:fill{
				attribute = "conservation",
				operation = "area",
				layer = "conservation*",
			}
		end

		unitTest:assertError(temporalAttributeError, "The attribute 'conservation_1961' to be created has more than 10 characters. Please shorten the attribute name.")

		temporalAttributeError = function()
			cl:fill{
				attribute = "conservation",
				operation = "area",
				layer = "test*",
			}
		end

		unitTest:assertError(temporalAttributeError, "No results have been found to match the pattern 'test*'.")

		temporalAttributeError = function()
			cl:fill{
				attribute = "con",
				operation = "area",
				layer = "conservation*1961",
			}
		end

		unitTest:assertWarning(temporalAttributeError, "Only one resut has been found to match the pattern 'conservation*1961'.")
		local temporalSplitError = function()
			cl:fill{
				attribute = "con",
				operation = "area",
				layer = "conservation*",
				split = "true"
			}
		end

		unitTest:assertError(temporalSplitError, incompatibleTypeMsg("split", "boolean", "string"))
		local temporalSplitAlreadyExistError = function()
			cl:fill{
				attribute = "con",
				operation = "area",
				layer = "conservation*",
				split = true
			}

			cl:fill{
				attribute = "con",
				operation = "area",
				layer = "conservation*",
				split = true
			}
		end

		unitTest:assertError(temporalSplitAlreadyExistError, "The attribute 'con' already exists in the Layer.")
		File(filePath1):deleteIfExists()
		File("layer_1961.shp"):deleteIfExists()
		File("layer_1974.shp"):deleteIfExists()
		File("layer_1979.shp"):deleteIfExists()
		File("temporal.tview"):deleteIfExists()
	end,
	simplify = function(unitTest)
		local projName = "layer_func_alt.tview"

		local proj = Project {
			file = projName,
			clean = true
		}

		local filePath1 = filePath("test/rails.shp", "gis")
		local layerName1 = "ES_Rails"
		local layer1 = Layer{
			project = proj,
			name = layerName1,
			file = filePath1
		}

		local mandatoryOut = function()
			layer1:simplify{tolerance = 500}
		end

		unitTest:assertError(mandatoryOut, mandatoryArgumentMsg("output"))

		local mandatoryTolerance = function()
			layer1:simplify{output = "simplify"}
		end

		unitTest:assertError(mandatoryTolerance, mandatoryArgumentMsg("tolerance"))

		local positiveTolerance = function()
			layer1:simplify{output = "simplify", tolerance = 0}
		end

		unitTest:assertError(positiveTolerance, positiveArgumentMsg("tolerance", 0))

		local layer2 = Layer{
			project = proj,
			name = "Tif",
			file = filePath("test/prodes_polyc_10k.tif", "gis")
		}

		local reprError = function()
			layer2:simplify{output = "simplify", tolerance = 500}
		end

		unitTest:assertError(reprError, "Layer representation 'raster' cannot be simplified.")

		proj.file:delete()
	end,
	polygonize = function(unitTest)
		local projFile = File("polygonize_func_alt.tview")

		local proj = Project{
			file = projFile,
			clean = true,
		}

		local tifLayer = Layer{
			project = proj,
			name = "Tif",
			file = filePath("emas-accumulation.tif", "gis")
		}

		local shpLayer = Layer{
			project = proj,
			name = "Shp",
			file = filePath("emas-limit.shp", "gis")
		}

		local outData = {
			file = File("polygonized.shp")
		}

		local invalidInput = function()
			shpLayer:polygonize(outData)
		end

		unitTest:assertError(invalidInput,  "Function polygonize only works from a raster Layer.")

		outData.band = 1

		local bandNoExists = function()
			tifLayer:polygonize(outData)
		end

		unitTest:assertError(bandNoExists, "Band '1' does not exist. The only available band is '0'.")

		outData.file = File("polygonize.shx")
		outData.band = nil

		local invalidOutFileExtension = function()
			tifLayer:polygonize(outData)
		end

		unitTest:assertError(invalidOutFileExtension, "Argument 'file' does not support extension 'shx'.")

		outData.file = 5432
		outData.band = nil

		local invalidFileType = function()
			tifLayer:polygonize(outData)
		end

		unitTest:assertError(invalidFileType, "Type of 'file' argument must be either a File or string.")

		outData = {
			source = "mydatabase"
		}

		local invalidDatabase = function()
			tifLayer:polygonize(outData)
		end

		unitTest:assertError(invalidDatabase, "The only supported database is 'postgis'. Please, set source = \"postgis\".")

		outData = {
			source = "postgis",
			password = "postgres",
			database = "postgis_22_sample",
			table = "polygonized",
			encoding = "latin2"
		}

		local invalidEncoding = function()
			tifLayer:polygonize(outData)
		end

		unitTest:assertError(invalidEncoding, "Encoding 'latin2' is invalid.")

		proj.file:delete()
	end,
	split = function(unitTest)
		local proj = Project{
			file = "temporal.tview",
			conservation = packageInfo("gis").data.."conservationAreas*.shp",
			clean = true,
		}

		local notTemporal = function()
			proj.conservation_1961:split()
		end

		unitTest:assertError(notTemporal, "No temporal attribute has been found.")

		File("temporal.tview"):deleteIfExists()
	end,
	merge = function(unitTest)
		local proj = Project{
			file = "temporal.tview",
			notTemporalLayer = packageInfo("gis").data.."conservationAreas_1961.shp",
			conservation = packageInfo("gis").data.."conservationAreas*.shp",
			clean = true,
		}

		local notTemporal = function()
			proj.notTemporalLayer:merge()
		end

		unitTest:assertError(notTemporal, "Layer 'notTemporalLayer' is not a temporal layer.")

		local notCompatible = function()
			proj.conservation_1961:merge()
		end

		unitTest:assertError(notCompatible, "Layer 'conservation_1961' cannot be merged with 'conservation_1974' because they have different numbers of objects.")

		File("temporal.tview"):deleteIfExists()
	end
}

