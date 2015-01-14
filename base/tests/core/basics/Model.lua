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
	simulationSteps = choice{10, 20, 30},
	initialWater    = 200,
	flow            = 20,
	observingStep   = choice{min = 0, max = 1, step = 0.1, default = 1},
	checkZero       = false,
	filter          = mandatory("function"),
	block = {
		xmin = 0,
		xmax = math.huge,
		ymin = 0,
		ymax = math.huge,
		level = choice{1, 2, 3},
		sleep = choice{min = 1, max = 2, step = 0.5, default = 2}
	},
	init = function(model)
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
		local t = Tube{filter = function() end}

		unitTest:assert_equal(t.simulationSteps, 10)
		unitTest:assert_equal(t.observingStep, 1)
		unitTest:assert_equal(t.initialWater, 200)
		unitTest:assert_equal(t.block.xmin, 0)
		unitTest:assert_equal(t.block.level, 1)
		unitTest:assert_type(t.filter, "function")

		t = Tube{
			simulationSteps = 20,
			observingStep = 0.7,
			block = {xmax = 10},
			checkZero = true,
			filter = function() end
		}

		unitTest:assert_equal(t.simulationSteps, 20)
		unitTest:assert_equal(t.block.xmin, 0)
		unitTest:assert_equal(t.block.xmax, 10)
		unitTest:assert_equal(t.block.level, 1)
		unitTest:assert_equal(t.block.sleep, 2)
		unitTest:assert_equal(t.observingStep, 0.7)
		unitTest:assert(t.checkZero)

		t = Tube()

		unitTest:assert_type(t, "table")
		unitTest:assert_type(t.simulationSteps, "choice")
		unitTest:assert_type(t.filter, "mandatory")
	end,
	check = function(unitTest)
		unitTest:assert(true)
	end,
	choice = function(unitTest)
		local c = choice{1, 2, 3}

		unitTest:assert_type(c, "choice")
		unitTest:assert_equal(#c.values, 3)

		c = choice{min = 2, max = 3, step = 0.1}
		unitTest:assert_type(c, "choice")
		unitTest:assert_equal(c.min, 2)
		unitTest:assert_equal(c.max, 3)
		unitTest:assert_equal(c.default, 2)
		unitTest:assert_equal(c.step, 0.1)

		c = choice{min = 5, default = 7}
		unitTest:assert_type(c, "choice")
		unitTest:assert_equal(c.min, 5)
		unitTest:assert_equal(c.default, 7)
	end,
	mandatory = function(unitTest)
		local c = mandatory("number")
		unitTest:assert_type(c, "mandatory")
		unitTest:assert_equal(c.value, "number")
	end,
	init = function(unitTest)
		unitTest:assert(true)
	end,
	execute = function(unitTest)
		local t = Tube{block = {level = 2}, filter = function() end}

		unitTest:assert_equal(t.block.xmin, 0)
		unitTest:assert_equal(t.block.level, 2)

		unitTest:assert_equal(t.water, 200)
		t:execute(10)
		unitTest:assert_equal(t.water, 210)
	end
}

