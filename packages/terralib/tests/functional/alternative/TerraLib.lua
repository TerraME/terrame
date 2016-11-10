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
	createProject = function(unitTest)
		local tl = TerraLib{}
		
		local proj = {}
		proj.file = "file.xml"
		local mandatoryExt = function()
			tl:createProject(proj, {})
		end
		unitTest:assertError(mandatoryExt, "Please, the file extension must be '.tview'.")
	end,
	openProject = function(unitTest)
		local tl = TerraLib{}
		
		local proj = {}
		local mandatoryExt = function()
			tl:openProject(proj, "file.xml")
		end
		unitTest:assertError(mandatoryExt, "Please, the file extension must be '.tview'.")
	end,
	getArea = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		File(proj.file):deleteIfExists()
		
		tl:createProject(proj, {})
		
		local layerName1 = "PA"
		local layerFile1 = filePath("Localidades_pt.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)	

		local dSet = tl:getDataSet(proj, layerName1)
		
		local areaError = function()
			tl:getArea(dSet[0].OGR_GEOMETRY)
		end
		unitTest:assertError(areaError, "Geometry should be a polygon to get the area.")
		
		proj.file:deleteIfExists()
	end
}
