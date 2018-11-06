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
	Project = function(unitTest)
		local noDataInContructor = function()
			Project()
		end

		unitTest:assertError(noDataInContructor, tableArgumentMsg())

		local attrFileNonString = function()
			Project{file = 123}
		end

		unitTest:assertError(attrFileNonString, incompatibleTypeMsg("file", "File", 123))

		local attrCreateNonBool = function()
			Project{file = "myproj.tview", clean = 2}
		end

		unitTest:assertError(attrCreateNonBool, incompatibleTypeMsg("clean", "boolean", 2))

		local attrTitleNonString = function()
			Project{file = "myproj.tview", title = 2}
		end

		unitTest:assertError(attrTitleNonString, incompatibleTypeMsg("title", "string", 2))

		local attrAuthorNonString = function()
			Project{file = "myproj.tview", author = 2}
		end

		unitTest:assertError(attrAuthorNonString, incompatibleTypeMsg("author", "string", 2))

		local fileMandatory = function()
			Project{clean = true}
		end

		unitTest:assertError(fileMandatory, mandatoryArgumentMsg("file"))

		local layerShouldBeString = function()
			Project{file = "myproj.tview", cean = true}
		end

		unitTest:assertError(layerShouldBeString, incompatibleTypeMsg("cean", "File", true))

		local notFile = function()
			Project{file = "myproj.tview", cean = "true.abc"}
		end

		unitTest:assertError(notFile, "Value of argument 'cean' ('/true.abc') is not a valid file name.", 3, true)

		local notFileSuggestion = function()
			Project{file = "myproj.tview", cean = filePath("amazonia-indigenous2.shp", "gis")}
		end

		unitTest:assertError(notFileSuggestion, "Value of argument 'cean' ('/true.abc') is not a valid file name. Do you mean 'amazonia-indigenous.shp'?", 3, true)

		local directoryNotString = function()
			Project{file = "myproj.tview", directory = 2}
		end

		unitTest:assertError(directoryNotString, incompatibleTypeMsg("directory", "Directory", 2))

		local notDirectory = function()
			Project{file = "myproj.tview", directory = tostring(filePath("emas.lua", "gis"))}
		end

		unitTest:assertError(notDirectory, "/emas.lua is a file, and not a directory.", 2, true)

		local extError = function()
			Project{file = "foo.xml"}
		end
		unitTest:assertError(extError, "Project file extension must be '.tview' or '.qgs'.")

		local patternFileError = function()
			Project{
			    file = "temporal.tview",
			    clean = true,
			    layer = packageInfo("gis").path.."/data/conservation.shp*",
			}
		end
		unitTest:assertError(patternFileError, "No results have been found to match the pattern '"..packageInfo("gis").path.."/data/conservation.shp*".."'.")

		patternFileError = function()
			Project{
			    file = "temporal.tview",
			    clean = true,
			    layer = packageInfo("gis").path.."/data/conservation.*",
			}
		end
		unitTest:assertError(patternFileError, "No results have been found to match the pattern '"..packageInfo("gis").path.."/data/conservation.*".."'.")

		patternFileError = function()
			Project{
			    file = "temporal.tview",
			    clean = true,
			    layer = packageInfo("gis").path.."/data*/conservation*",
			}
		end
		unitTest:assertError(patternFileError, "Directory path '"..packageInfo("gis").path.."/data*/".."' contains invalid character '*'.")

		local projTemporal
		patternFileError = function()
			projTemporal = Project{
			    file = "temporal.tview",
			    clean = true,
			    areas = packageInfo("gis").data.."conservation*Areas_1961.shp",
			}
		end

		unitTest:assertWarning(patternFileError, "Only one resut has been found to match the pattern '"..packageInfo("gis").data.."conservation*Areas_1961.shp'.")
		unitTest:assertEquals(projTemporal.areas.name, "areas")
		unitTest:assertType(projTemporal.areas, "Layer")
		unitTest:assertEquals(projTemporal.areas.source, "shp")
		File("temporal.tview"):deleteIfExists()
	end
}

