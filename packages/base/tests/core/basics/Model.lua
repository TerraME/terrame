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
	soilCap         = Choice{min = 4},
	soilInf         = Choice{max = 5},
	observingStep   = Choice{min = 0, max = 1, step = 0.1, default = 1},
	checkZero       = false,
	filter          = Mandatory("function"),
	block = {
		xmin = Choice{min = 0},
		xmax = Choice{max = math.huge},
		ymin = 0,
		ymax = math.huge,
		level = Choice{1, 2, 3},
		sleep = Choice{min = 1, max = 2, step = 0.5, default = 2}
	},
	init = function(model)
		verify(model.simulationSteps > 0, "Simulation steps should be greater than zero.")
		verify(model.initialWater > 0, "Initial water should be greater than zero.")
		model.water = model.initialWater
		model.timer = Timer{
			Event{action = function()
				model.water = model.water + 1
			end}
		}
	end
}

local Tube2 = Model{
	initialWater    = 0,
	finalTime       = 10,
	init = function(model)
		model.water = model.initialWater
		model.aenv = Environment{} -- this line is necessary because TerraME must see that
		                           -- it does not have a Timer so it will not run.
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
		unitTest:assertType(Tube, "Model")
		local t = Tube{filter = function() end}
		unitTest:assertType(t, "Tube")

		unitTest:assertEquals(t.simulationSteps, 10)
		unitTest:assertEquals(t.observingStep, 1)
		unitTest:assertEquals(t.initialWater, 200)
		unitTest:assertEquals(t.subwater, 4)
		unitTest:assertEquals(t.block.xmin, 0)
		unitTest:assertEquals(t.block.level, 1)
		unitTest:assertType(t.filter, "function")

		unitTest:assertEquals(tostring(Tube), [[block            table of size 0
checkZero        boolean [false]
filter           Mandatory
finalTime        number [10]
flow             number [20]
init             function
initialWater     number [200]
observingStep    Choice
simulationSteps  Choice
soilCap          Choice
soilInf          Choice
subwater         Choice
]])

		unitTest:assertEquals(tostring(t), [[block            table of size 0
checkZero        boolean [false]
cObj_            userdata
filter           function
finalTime        number [10]
flow             number [20]
init             function
initialWater     number [200]
notify           function
observingStep    number [1]
parent           Model
run              function
simulationSteps  number [10]
soilCap          number [4]
soilInf          number [5]
subwater         number [4]
timer            Timer
type_            string [Tube]
water            number [200]
]])

		t = Tube{
			simulationSteps = 20,
			observingStep = 0.7,
			block = {xmin = 2, xmax = 10},
			checkZero = true,
			finalTime = 5,
			filter = function() end
		}

		unitTest:assertEquals(t.simulationSteps, 20)
		unitTest:assertEquals(t.block.xmin, 2)
		unitTest:assertEquals(t.block.xmax, 10)
		unitTest:assertEquals(t.block.level, 1)
		unitTest:assertEquals(t.block.sleep, 2)
		unitTest:assertEquals(t.observingStep, 0.7)
		unitTest:assertEquals(t.finalTime, 5)
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

		local M = Model{
			file0 = "def",
			files = {
				file1 = "*.csv",
				file2 = "*.csv;*.lua",
				file3 = "abc"
			},
			init = function(model)
				model.finalTime = 3
				model.timer = Timer{Event{action = function() end}}
			end
		}

		local m = M{
			files = {
				file1 = filePath("agents.csv", "base"),
				file2 = filePath("agents.csv", "base")
			}
		}

		unitTest:assertEquals(m.file0, "def")
		unitTest:assertEquals(m.files.file3, "abc")
	end,
	run = function(unitTest)
		local t = Tube{block = {level = 2}, filter = function() end}

		unitTest:assertEquals(t.block.xmin, 0)
		unitTest:assertEquals(t.block.level, 2)

		unitTest:assertEquals(t.water, 200)
		t:run()
		unitTest:assertEquals(t.water, 210)

		t = Tube2{}
		t:run()
		unitTest:assertEquals(t.water, 10)

		local Tube3 = Model{
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

		local t3 = Tube3:run()

		unitTest:assertEquals(t3.water, 10)
	end,
	getParameters = function(unitTest)
		local t = Tube:getParameters()

		unitTest:assertType(t, "table")
		unitTest:assertType(t.simulationSteps, "Choice")
		unitTest:assertType(t.filter, "Mandatory")
		unitTest:assertNil(t.init)
		unitTest:assertEquals(getn(t), 11)
	end,
	init = function(unitTest)
		unitTest:assert(true)
	end,
	configure = function(unitTest)
		unitTest:assert(true)
	end
}

