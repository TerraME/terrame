-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP.
--
-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.
--
-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or caonsequential damages arising out of the use
-- of this library and its documentation.
--
-- Author: Rodrigo Avancini
-------------------------------------------------------------------------------------------

return {
	TerraLib = function(unitTest)
		local t1 = TerraLib{}
		local t2 = TerraLib{}
		
		unitTest:assertEquals(t1, t2)
	end,
	init = function(unitTest)
		unitTest:assert(true)
	end,
	finalize = function(unitTest)
		-- TODO: THIS TEST IS IMPORTANT
		unitTest:assert(true)
	end,
	createProject = function(unitTest)
		unitTest:assert(true)
	end,
	openProject = function(unitTest)
		unitTest:assert(true)
	end,
	-- getProjectInfo = function(unitTest)
		-- unitTest:assert(true) -- SKIP
	-- end,
	-- getLayersNames = function(unitTest)
		-- unitTest:assert(true) -- SKIP
	-- end,
	-- getLayerInfo = function(unitTest)
		-- unitTest:assert(true) -- SKIP
	-- end,
	addShpLayer = function(unitTest)
		unitTest:assert(true)
	end,
	addTifLayer = function(unitTest)
		unitTest:assert(true)
	end,
	layerExists = function(unitTest)
		unitTest:assert(true)
	end,	
	addShpCellSpaceLayer = function(unitTest)
		unitTest:assert(true)
	end
}