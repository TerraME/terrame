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

return {
	forEachLayer = function(unitTest)
		if isFile("emas-count.tview") then
			rmFile("emas-count.tview")
		end	
	
		local project = Project{
			file = "emas-count.tview",
			clean = true,
			firebreak = filePath("firebreak_lin.shp", "terralib"),
			cover = filePath("accumulation_Nov94May00.tif", "terralib"),
			river = filePath("River_lin.shp", "terralib"),
			limit = filePath("Limit_pol.shp", "terralib")
		}

		local count = 0

		forEachLayer(project, function(layer)
			unitTest:assertType(layer, "Layer")
			count = count + 1
		end)

		unitTest:assertEquals(count, 4)
		
		rmFile("emas-count.tview")
	end,
	getFileNameWithExtension = function(unitTest)
		unitTest:assertEquals(getFileNameWithExtension("/my/path/file.txt"), "file.txt")
	end,
	removeFileExtension = function(unitTest)
		unitTest:assertEquals(removeFileExtension("file.txt"), "file")
	end,
	getFileName = function(unitTest)
		unitTest:assertEquals(getFileName("/my/path/file.txt"), "file")
	end,	
	getFilePathAndNameAndExtension = function(unitTest)
		local p, n, e = getFilePathAndNameAndExtension("/my/path/file.txt")
		unitTest:assertEquals(p, "/my/path/")
		unitTest:assertEquals(n, "file")
		unitTest:assertEquals(e, "txt")
	end,	
	getFileExtension = function(unitTest)
		local e = getFileExtension("/my/path/file.txt")
		unitTest:assertEquals(e, "txt")
	end,
	getFileDir = function(unitTest)
		local p = getFileDir("/my/path/file.txt")
		unitTest:assertEquals(p, "/my/path/")
	end
}

