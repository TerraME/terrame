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
-- Authors: Pedro R. Andrade (pedro.andrade@inpe.br)
-------------------------------------------------------------------------------------------

return{
	Model = function(unitTest)
		local error_func = function()
			local Tube = Model{finalTime = "2"}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("finalTime", "number", "2"))

		local error_func = function()
			local Tube = Model{finalTime = mandatory("table")}
		end
		unitTest:assert_error(error_func, "finalTime can only be mandatory('number'), got mandatory('table').")

		local error_func = function()
			local Tube = Model{finalTime = Choice{"1", "2"}}
		end
		unitTest:assert_error(error_func, "finalTime can only be a Choice with 'number' values, got 'string'.")

		local error_func = function()
			local Tube = Model{seed = "2"}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("seed", "number", "2"))

		local error_func = function()
			local Tube = Model{seed = -2}
		end
		unitTest:assert_error(error_func, "Argument 'seed' should be positive, got -2.")

		local error_func = function()
			local Tube = Model{seed = mandatory("table")}
		end
		unitTest:assert_error(error_func, "seed can only be mandatory('number'), got mandatory('table').")

		local error_func = function()
			local Tube = Model{seed = Choice{"1", "2"}}
		end
		unitTest:assert_error(error_func, "seed can only be a Choice with 'number' values, got 'string'.")
	
		local Tube = Model{
			init = function(model) end,
			finalTime = 10
		}

		local error_func = function()
			local m = Tube{}
		end
		unitTest:assert_error(error_func, "The object does not have a Timer or an Environment with at least one Timer.")

		Tube = Model{
			init = function(model)
				model.t = Timer{}
				model.t2 = Timer{}
			end,
			finalTime = 10
		}

		error_func = function()
			local m = Tube{}
		end
		unitTest:assert_error(error_func, "The object has two running objects: 't2' (Timer) and 't' (Timer).")

		error_func = function()
			local m = Tube{finalTime = "2"}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("finalTime", "number", "2"))

		Tube = Model{
			init = function(model)
				model.t2 = Timer{}
			end,
			seed = 5,
			finalTime = 10
		}

		error_func = function()
			local m = Tube{seed = "2"}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("seed", "number", "2"))

		error_func = function()
			local m = Tube{seed = -2}
		end
		unitTest:assert_error(error_func, "Argument 'seed' should be positive, got -2.")

		Tube = Model{
			init = function(model)
				model.t = Timer{}
				model.e = Environment{t2 = Timer{}}
			end,
			finalTime = 10
		}

		error_func = function()
			local m = Tube{}
		end
		unitTest:assert_error(error_func, "The object has two running objects: 't' (Timer) and 'e' (Environment).")

		-- this test is necessary because it changes the searching order between the Timer and the Environment
		Tube = Model{
			init = function(model)
				model.e = Timer{}
				model.t = Environment{t2 = Timer{}}
			end,
			finalTime = 10
		}

		local error_func = function()
			local m = Tube{}
		end
		unitTest:assert_error(error_func, "The object has two running objects: 't' (Environment) and 'e' (Timer).")

		local Tube = Model{
			simulationSteps = Choice{10, 20, 30},
			msleep = Choice{min = 1, max = 2, step = 0.5, default = 2},
			mvalue = Choice{min = 5},
			initialWater    = 200,
			flow            = 20,
			observingStep   = 1,
			finalTime       = 10,
			checkZero       = false,
			block = {
				xmin = 0,
				xmax = math.huge,
				ymin = 0,
				ymax = math.huge,
				level = Choice{1, 2, 3},
				sleep = Choice{min = 1, max = 2, step = 0.5, default = 2}
			},
			init = function(model) model.timer = Timer{} end,
			check = function(model)
				verify(model.simulationSteps > 0, "Simulation steps should be greater than zero.")
				verify(model.initialWater > 0, "Initial water should be greater than zero.")
			end
		}

		local error_func = function()
			local m = Tube{flow = {a = 2}}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("flow", "number", {a = 2}))

		error_func = function()
			local m = Tube{msleep = 40}
		end
		unitTest:assert_error(error_func, "Argument 'msleep' should be less than or equal to 2.")

		error_func = function()
			local m = Tube{msleep = 0}
		end
		unitTest:assert_error(error_func, "Argument 'msleep' should be greater than or equal to 1.")

		error_func = function()
			local m = Tube{msleep = 1.25}
		end
		unitTest:assert_error(error_func, "Invalid value for argument 'msleep' (1.25).")

		error_func = function()
			local m = Tube{simulationSteps = 40}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("simulationSteps", "one of {10, 20, 30}", 40))

		error_func = function()
			local m = Tube{block = {level = 40}}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("block.level", "one of {1, 2, 3}", 40))

		error_func = function()
			local m = Tube{block = {mblock = 40}}
		end
		unitTest:assert_error(error_func, "Attribute 'block.mblock' does not exist in the Model.")

		error_func = function()
			local m = Tube{s = 3}
		end
		unitTest:assert_error(error_func, "Attribute 's' does not exist in the Model.")

		error_func = function()
			local m = Tube{checkZero = 3}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("checkZero", "boolean", 3))
	
		error_func = function()
			local m = Tube{initialWater = -5}
		end
		unitTest:assert_error(error_func, "Initial water should be greater than zero.")

		error_func = function()
			local m = Tube{block = {xmix = 5}}
		end
		unitTest:assert_error(error_func, "Attribute 'block.xmix' does not exist in the Model.")

		error_func = function()
			local m = Tube{block = {xmin = false}}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("block.xmin", "number", false))
			
		Tube = Model{
			simulationSteps = 10,
			check = function() end
		}

		error_func = function()
			local m = Tube{}
		end
		unitTest:assert_error(error_func, "Function 'init' was not implemented by the Model.")

		local Tube = Model{
			bb = Choice{min = 10, max = 20, step = 1},
			init = function() end
		}
		
		error_func = function()
			local T = Tube{bb = false}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("bb", "number", false))

		error_func = function()
			local T = Tube{bb = 10.5}
		end
		unitTest:assert_error(error_func, "Invalid value for argument 'bb' (10.5).")
	
		error_func = function()
			local T = Tube{bb = 21.5}
		end
		unitTest:assert_error(error_func, "Argument 'bb' should be less than or equal to 20.")

		error_func = function()
			local T = Tube{bb = 5}
		end
		unitTest:assert_error(error_func, "Argument 'bb' should be greater than or equal to 10.")

		local Tube = Model{
			init = function() end
		}

		error_func = function()
			local T = Tube{}
		end
		unitTest:assert_error(error_func, "The Model instance does not have attribute 'finalTime'.")
	end,
	mandatory = function(unitTest)
		local error_func = function()
			local c = mandatory(2)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "string", 2))

		error_func = function()
			local c = mandatory("string")
		end
		unitTest:assert_error(error_func, "Value 'string' cannot be a mandatory argument.")

		local M = Model{
			value = mandatory("number")
		}

		error_func = function()
			local m = M{}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("value"))

		error_func = function()
			local m = M{value = false}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("value", "number", false))

		M = Model{
			v = {value = mandatory("number")}
		}

		error_func = function()
			local m = M{}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("v.value"))

		error_func = function()
			local m = M{v = {value = false}}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("v.value", "number", false))
	end,
	interface = function(unitTest)
		local error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return 2 end
			}
		end
		unitTest:assert_error(error_func, "The returning value of interface() should be a table, got number.")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {2} end
			}
		end
		unitTest:assert_error(error_func, "There is an element in the interface() that is not a table.")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {{2}} end
			}
		end
		unitTest:assert_error(error_func, "All the elements in each interface() vector should be string, got number.")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {{"number", "number"}} end
			}
		end
		unitTest:assert_error(error_func, "Argument 'number' cannot be displayed twice in the interface().")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {{"number", "string"}} end
			}
		end
		unitTest:assert_error(error_func, "There is no argument 'string' in the Model, although it is described in the interface().")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {{"number", "compulsory"}} end
			}
		end
		unitTest:assert_error(error_func, "interface() element 'compulsory' is not an argument of the Model.")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {{"number", "aaa"}} end
			}
		end
		unitTest:assert_error(error_func, "interface() element 'aaa' is not an argument of the Model.")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				aaa = 3,
				interface = function() return {{"number", "aaa"}} end
			}
		end
		unitTest:assert_error(error_func, "interface() element 'aaa' is not a table in the Model.")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				aaa = {1, 2, 3},
				interface = function() return {{"number", "aaa"}} end
			}
		end
		unitTest:assert_error(error_func, "interface() element 'aaa' is a non-named table in the Model.")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				aaa = {},
				interface = function() return {{"number", "aaa"}} end
			}
		end
		unitTest:assert_error(error_func, "interface() element 'aaa' is empty in the Model.")
	end
}

