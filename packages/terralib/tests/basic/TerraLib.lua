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
-- Authors: Pedro R. Andrade (pedro.andrade@inpe.br)
--          Rodrigo Avancini
-------------------------------------------------------------------------------------------

return {
	TerraLib = function(unitTest)
		local t1 = TerraLib{}
		local t2 = TerraLib{}
		
		unitTest:assertEquals(t1, t2)
		
		t1:finalize()
	end,
	init = function(unitTest)
		unitTest:assert(true)
	end,
	finalize = function(unitTest)
		local tlib = TerraLib{}
		tlib:finalize()
		unitTest:assert(true)
	end,
	createProject = function(unitTest)
		unitTest:assert(true)
	end,
	openProject = function(unitTest)
		unitTest:assert(true)
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
	layerExists = function(unitTest)
		unitTest:assert(true)
	end,
	dropPgTable = function(unitTest)
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