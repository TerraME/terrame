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
	getLayerInfo = function(unitTest)
		unitTest:assert(true)
	end,
	addShpLayer = function(unitTest)
		unitTest:assert(true)
	end,
	addTifLayer = function(unitTest)
		unitTest:assert(true)
	end,
	addPgLayer = function(unitTest)
		unitTest:assert(true)
	end,
	dropPgTable = function(unitTest)
		unitTest:assert(true)
	end,
	dropPgDatabase = function(unitTest)
		unitTest:assert(true)
	end,	
	copyLayer = function(unitTest)
		unitTest:assert(true)
	end,
	addShpCellSpaceLayer = function(unitTest)
		unitTest:assert(true)
	end,
	addPgCellSpaceLayer = function(unitTest)
		unitTest:assert(true)
	end,	
	attributeFill = function(unitTest)
		unitTest:assert(true)
	end,
	getDataSet = function(unitTest)
		unitTest:assert(true)
	end,
	saveDataSet = function(unitTest)
		unitTest:assert(true)
	end,
	getShpByFilePath = function(unitTest)
		unitTest:assert(true)
	end	
}