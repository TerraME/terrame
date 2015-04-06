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
	simulationSteps = Choice{10, 20, 30},
	subwater        = Choice{1, 2, 4, 5, default = 4},
	initialWater    = 200,
	finalTime       = 10,
	flow            = 20,
	observingStep   = Choice{min = 0, max = 1, step = 0.1, default = 1},
	checkZero       = false,
	filter          = Mandatory("function"),
	block = {
		xmin = 0,
		xmax = math.huge,
		ymin = 0,
		ymax = math.huge,
		level = Choice{1, 2, 3},
		sleep = Choice{min = 1, max = 2, step = 0.5, default = 2}
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

local Tube2 = Model{
	initialWater    = 0,
	finalTime       = 10,
	init = function(model)
		model.water = model.initialWater
		model.env = Environment{
			timer = Timer{
				Event{action = function()
					model.water = model.water + 1
				end}
			}
		}
	end
}

return{
	Model = function(unitTest)
		unitTest:assert_type(Tube, "Model")
		local t = Tube{filter = function() end}
		unitTest:assert_type(t, "Tube")

		unitTest:assert_equal(t.simulationSteps, 10)
		unitTest:assert_equal(t.observingStep, 1)
		unitTest:assert_equal(t.initialWater, 200)
		unitTest:assert_equal(t.subwater, 4)
		unitTest:assert_equal(t.block.xmin, 0)
		unitTest:assert_equal(t.block.level, 1)
		unitTest:assert_type(t.filter, "function")

		t = Tube{
			simulationSteps = 20,
			observingStep = 0.7,
			block = {xmax = 10},
			checkZero = true,
			finalTime = 5,
			filter = function() end
		}

		unitTest:assert_equal(t.simulationSteps, 20)
		unitTest:assert_equal(t.block.xmin, 0)
		unitTest:assert_equal(t.block.xmax, 10)
		unitTest:assert_equal(t.block.level, 1)
		unitTest:assert_equal(t.block.sleep, 2)
		unitTest:assert_equal(t.observingStep, 0.7)
		unitTest:assert_equal(t.finalTime, 5)
		unitTest:assert(t.checkZero)

		local Tube3 = Model{
			initialWater    = 0,
			finalTime       = 10,
			tube            = Mandatory("Tube"),
			init = function(model)
				model.water = model.initialWater
				model.env = Environment{
					timer = Timer{
						Event{action = function()
							model.water = model.water + 1
						end}
					}
				}
			end
		}

		local t3 = Tube3{tube = t}

		t = Tube()

		unitTest:assert_type(t, "table")
		unitTest:assert_type(t.simulationSteps, "Choice")
		unitTest:assert_type(t.filter, "Mandatory")
	end,
	check = function(unitTest)
		unitTest:assert(true)
	end,
	init = function(unitTest)
		unitTest:assert(true)
	end,
	execute = function(unitTest)
		local t = Tube{block = {level = 2}, filter = function() end}

		unitTest:assert_equal(t.block.xmin, 0)
		unitTest:assert_equal(t.block.level, 2)

		unitTest:assert_equal(t.water, 200)
		t:execute()
		unitTest:assert_equal(t.water, 210)

		t = Tube2{}
		t:execute()
		unitTest:assert_equal(t.water, 10)
	end
}

