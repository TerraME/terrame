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
	Project = function(unitTest)
		local file = File("amazonia.tview")

		local proj1 = Project{
			file = tostring(file),
			clean = true,
			author = "Avancini",
			title = "The Amazonia"
		}
		
		unitTest:assertType(proj1, "Project")
		unitTest:assertEquals(proj1.file, file)
		
		local proj2 = Project{
			file = tostring(file)
		}		

		unitTest:assertEquals(proj1.author, proj2.author)
		unitTest:assertEquals(proj1.title, proj2.title)
		unitTest:assertEquals(proj1.file, proj2.file)

		local proj3 = Project{
			file = file:name()
		}

		unitTest:assertEquals(proj1.author, proj3.author)
		unitTest:assertEquals(proj1.title, proj3.title)
		unitTest:assertEquals(proj3.file, File("amazonia.tview"))

		local proj3clean = Project{
			file = file:name(),
			clean = true
		}

		unitTest:assertEquals(proj1.author, proj3clean.author)
		unitTest:assertEquals(proj1.title, proj3clean.title)
		unitTest:assertEquals(proj3clean.file, File("amazonia.tview"))
		-- unitTest:assertFile(file:name(true)) -- SKIP #TODO(#1242)

		file:deleteIfExists()

		file = File("notitlenoauthor.tview")
		file:deleteIfExists()

		local proj4 = Project{
			file = file:name(true)
		}

		unitTest:assertEquals(proj4.title, "No title")
		unitTest:assertEquals(proj4.author, "No author")
		unitTest:assertEquals(proj4.clean, false)
		unitTest:assertType(proj4.layers, "table")
		unitTest:assertEquals(getn(proj4.layers), 0)

		file:deleteIfExists()

		file = File("emas.tview")
		file:deleteIfExists()

		local proj5
	if sessionInfo().system ~= "mac" then -- TODO(#1448)
		proj5 = Project{
			file = file:name(true),
			clean = true,
			author = "Almeida, R.",
			title = "Emas database",
			firebreak = filePath("firebreak_lin.shp", "terralib"),
			cover = filePath("accumulation_Nov94May00.tif", "terralib"),
			river = filePath("River_lin.shp", "terralib"),
			limit = filePath("Limit_pol.shp", "terralib")
		}
	else
		proj5 = Project{
			file = file:name(true),
			clean = true,
			author = "Almeida, R.",
			title = "Emas database",
			firebreak = filePath("firebreak_lin.shp", "terralib"),
			river = filePath("River_lin.shp", "terralib"),
			limit = filePath("Limit_pol.shp", "terralib")
		}		
	end
		unitTest:assertType(proj5.firebreak, "Layer")
	if sessionInfo().system ~= "mac" then -- TODO(#1448)	
		unitTest:assertType(proj5.cover, "Layer") -- SKIP
	end
		unitTest:assertType(proj5.river, "Layer")
		unitTest:assertType(proj5.limit, "Layer")
		-- unitTest:assertFile(file:name(true)) -- SKIP #TODO(#1242)

		file:deleteIfExists()
	end,
	__tostring = function(unitTest)
		local file = File("tostring.tview")
		local proj1 = Project{
			file = file:name(),
			clean = true,
			author = "Avancini",
			title = "The Amazonia"
		}
		
		unitTest:assertEquals(tostring(proj1), [[author       string [Avancini]
clean        boolean [true]
description  string []
file         File
layers       vector of size 0
terralib     TerraLib
title        string [The Amazonia]
]])

		-- unitTest:assertFile("tostring.tview") -- SKIP #TODO(#1242)
		file:deleteIfExists()
	end
}
