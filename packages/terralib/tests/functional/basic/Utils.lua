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

return {
	forEachLayer = function(unitTest)
		local tview = File("emas-count.tview")
		tview:deleteIfExists()

		local project = Project{
			file = tview,
			clean = true,
			firebreak = filePath("emas-firebreak.shp", "terralib"),
			river = filePath("emas-river.shp", "terralib"),
			limit = filePath("emas-limit.shp", "terralib")
		}

		local count = 0
		local layers = {"firebreak", "limit", "river"}

		local each = forEachLayer(project, function(layer, name)
			count = count + 1
			unitTest:assertType(layer, "Layer")
			unitTest:assertEquals(name, layers[count])
		end)

		unitTest:assertEquals(count, 3)
		unitTest:assertEquals(each , true)

		count = 0
		each = forEachLayer(project, function(layer, name)
			count = count + 1
			unitTest:assertType(layer, "Layer")
			unitTest:assertEquals(name, layers[count])

			if count == 2 then return false end
		end)

		unitTest:assertEquals(count, 2)
		unitTest:assertEquals(each , false)
		tview:deleteIfExists()
	end
}
