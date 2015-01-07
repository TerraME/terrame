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
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--          Pedro R. Andrade (pedro.andrade@inpe.br)
-------------------------------------------------------------------------------------------

local Tube = Model{
	simulationSteps = {10, 20, 30},
	initialWater    = 200,
	flow            = 20,
	observingStep   = 1,
	checkZero       = false,
	block = {xmin = 0, xmax = math.huge, ymin = 0, ymax = math.huge, level = {1, 2, 3}},
	setup = function(model)
		model.water = model.initialWater
		model.timer = Timer{
			Event{action = function()
				model.water = model.water + 1
			end}
		}
	end,
	check = function(model)
		verify(model.simulationSteps > 0, "Simulation steps should be greater than zero.")
		verify(model.initialWater > 0, "Initial water should be greater than zero.")
	end
}

return{
	Model = function(unitTest)
		local t = Tube{}

		unitTest:assert_equal(t.simulationSteps, 10)
		unitTest:assert_equal(t.initialWater, 200)
		unitTest:assert_equal(t.block.xmin, 0)
		unitTest:assert_equal(t.block.level, 1)

		t = Tube{simulationSteps = 20, block = {xmax = 10}, checkZero = true}

		unitTest:assert_equal(t.simulationSteps, 20)
		unitTest:assert_equal(t.block.xmin, 0)
		unitTest:assert_equal(t.block.xmax, 10)
		unitTest:assert_equal(t.block.level, 1)
		unitTest:assert(t.checkZero)
	end,
	check = function(unitTest)
		unitTest:assert(true)
	end,
	setup = function(unitTest)
		unitTest:assert(true)
	end,
	execute = function(unitTest)
		local t = Tube{block = {level = 2}}

		unitTest:assert_equal(t.block.xmin, 0)
		unitTest:assert_equal(t.block.level, 2)

		unitTest:assert_equal(t.water, 200)
		t:execute(10)
		unitTest:assert_equal(t.water, 210)
	end
}

