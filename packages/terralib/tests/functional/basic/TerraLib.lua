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
	TerraLib = function(unitTest)
		local t1 = TerraLib{}
		local t2 = TerraLib{}
		
		unitTest:assertEquals(t1, t2)
	end,
	getVersion = function(unitTest)
		local tlib = TerraLib{}
		unitTest:assertEquals(tlib:getVersion(), "5.1.3")		
	end,
	openProject = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		if File(proj.file):exists() then
			rmFile(proj.file)
		end
		
		tl:createProject(proj, {})
		
		local proj2 = {}
		
		tl:openProject(proj2, proj.file)
		
		unitTest:assertEquals(proj2.file, proj.file)
		unitTest:assertEquals(proj2.title, proj.title)
		unitTest:assertEquals(proj2.author, proj.author)
		
		rmFile(proj.file)
	end
}

