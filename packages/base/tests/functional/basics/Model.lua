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
	interface = function()
		return {{"number"}}
	end,
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

		local t
		local warning_func = function()
			t = Tube{filter = function() end, block = {xmix = 5}}
		end

		unitTest:assertWarning(warning_func, unnecessaryArgumentMsg("block.xmix", "block.xmax"))
		unitTest:assertType(t, "Tube")

		unitTest:assertEquals(t.simulationSteps, 10)
		unitTest:assertEquals(t.observingStep, 1)
		unitTest:assertEquals(t.initialWater, 200)
		unitTest:assertEquals(t.subwater, 4)
		unitTest:assertEquals(t.block.xmin, 0)
		unitTest:assertEquals(t.block.level, 1)
		unitTest:assertType(t.filter, "function")

		unitTest:assertEquals(tostring(Tube), [[block            named table of size 6
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

		unitTest:assertEquals(tostring(t), [[block            named table of size 6
cObj_            userdata
checkZero        boolean [false]
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
title            function
type_            string [Tube]
water            number [200]
]])
		warning_func = function()
			t = Tube{
				simulationSteps = 20,
				observingStep = 0.7,
				block = {xmin = 2, xmax = 10},
				checkZero = true,
				finalTime = 5,
				filter = function() end,
				s = 3
			}
		end
		unitTest:assertWarning(warning_func, unnecessaryArgumentMsg("s"))
		unitTest:assertEquals(t.simulationSteps, 20)
		unitTest:assertEquals(t.block.xmin, 2)
		unitTest:assertEquals(t.block.xmax, 10)
		unitTest:assertEquals(t.block.level, 1)
		unitTest:assertEquals(t.block.sleep, 2)
		unitTest:assertEquals(t.observingStep, 0.7)
		unitTest:assertEquals(t.finalTime, 5)
		unitTest:assert(t.checkZero)

		warning_func = function()
			t = Tube{
				simulationSteps = 20,
				observingStep = 0.7,
				block = {xmin = 2, xmax = 10, mblock = 40},
				checkZero = true,
				finalTime = 5,
				filter = function() end
			}
		end
		unitTest:assertWarning(warning_func, unnecessaryArgumentMsg("block.mblock"))
		unitTest:assertEquals(t.simulationSteps, 20)
		unitTest:assertEquals(t.block.xmin, 2)
		unitTest:assertEquals(t.block.xmax, 10)
		unitTest:assertEquals(t.block.level, 1)
		unitTest:assertEquals(t.block.sleep, 2)
		unitTest:assertEquals(t.observingStep, 0.7)
		unitTest:assertEquals(t.finalTime, 5)
		unitTest:assert(t.checkZero)

		local defaultValue = function()
			t = Tube{
				simulationSteps = 20,
				observingStep = 0.7,
				block = {xmin = 2, xmax = 10},
				checkZero = true,
				finalTime = 5,
				filter = function() end,
				random = false
			}
		end

		unitTest:assertWarning(defaultValue, unnecessaryArgumentMsg("random"))
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

		Tube3{tube = t}

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

		local func1 = function() return 1 end
		local func2 = function() return 2 end

		M = Model{
			quantity = Choice{a = func1, b = func2},
			internal = {
				quantity = Choice{a = func1, b = func2}
			},
			finalTime = 20,
			init = function(model)
				model.timer = Timer{Event{action = function() end}}
			end
		}

		m = M{}
		unitTest:assertEquals(m.quantity, func1)
		unitTest:assertEquals(m.internal.quantity, func1)

		m = M{quantity = "b", internal = {quantity = "b"}}
		unitTest:assertEquals(m.quantity, func2)
		unitTest:assertEquals(m.internal.quantity, func2)
	end,
	execute = function(unitTest)
		local Tube3 = Model{
			water = 20,
			flow = 1,
			finalTime = 20,
			execute = function(model)
				model.water = model.water - model.flow
			end,
			init = function (model)
				model.chart = Chart{
					target = model,
					select = "water"
			}
			end
		}

		local t = Tube3{}

		t:run()

		unitTest:assertEquals(t.water, 0)
	end,
	isRandom = function(unitTest)
		unitTest:assert(not Tube:isRandom())

		local RandomModel = Model{
			init = function(model)
				model.t2 = Timer{}
			end,
			random = true,
			finalTime = 10
		}

		unitTest:assert(RandomModel:isRandom())
	end,
	interface = function(unitTest)
		unitTest:assertNil(Tube:interface())

		local interf = Tube2:interface()

		unitTest:assertType(interf, "table")
		unitTest:assertEquals(#interf, 1)
		unitTest:assertEquals(#interf[1], 1)

		local model

		local warning_func = function()
			model = Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {{"number", "string"}} end,
				init = function() end
			}
		end

		unitTest:assertWarning(warning_func, "There is no argument 'string' in the Model, although it is described in the interface().")

		interf = model:interface()
		unitTest:assertType(interf, "table")
		unitTest:assertEquals(#interf, 1)
		unitTest:assertEquals(#interf[1], 2)
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
	end,
	title = function(unitTest)
		local MyTube = Model{
			initialWater = 200,
			sun = Choice{min = 0, default = 10},
			finalTime = 100,
			init = function(model)
				model.timer = Timer{
					Event{action = function()
						model.initialWater = model.initialWater + 1
						model.sun = model.sun + 1
					end}
				}
			end
		}

		local scenario0 = MyTube{}
		unitTest:assertEquals("Default", scenario0:title())
		scenario0:run()
		unitTest:assertEquals("Default", scenario0:title())

		local scenario1 = MyTube{initialWater = 100}
		unitTest:assertEquals("Initial Water = 100", scenario1:title())
		scenario1:run()
		unitTest:assertEquals("Initial Water = 100", scenario1:title())

		local scenario2 = MyTube{initialWater = 100, sun = 5}
		unitTest:assertEquals("Initial Water = 100, Sun = 5", scenario2:title())
		scenario2:run()
		unitTest:assertEquals("Initial Water = 100, Sun = 5", scenario2:title())

		local scenario3 = MyTube{initialWater = 100, sun = 10}
		unitTest:assertEquals("Initial Water = 100", scenario3:title())
		scenario3:run()
		unitTest:assertEquals("Initial Water = 100", scenario3:title())

		local scenario4 = MyTube{initialWater = 100, finalTime = 50}
		unitTest:assertEquals("Initial Water = 100", scenario4:title())
		scenario4:run()
		unitTest:assertEquals("Initial Water = 100", scenario4:title())
	end
}

