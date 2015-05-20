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
			local Tube = Model{cs = CellularSpace{xdim = 10}}
		end
		unitTest:assertError(error_func, "Type CellularSpace (parameter 'cs') is not supported as argument of Model.")

		local error_func = function()
			local Tube = Model{abc = {cs = CellularSpace{xdim = 10}}}
		end
		unitTest:assertError(error_func, "Type CellularSpace (parameter 'abc.cs') is not supported as argument of Model.")

		local error_func = function()
			local Tube = Model{cs = {1, 2, 3, 4, 5}}
		end
		unitTest:assertError(error_func, "It is not possible to use a non-named table in a Model (parameter 'cs').")

		local error_func = function()
			local Tube = Model{finalTime = "2"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("finalTime", "number", "2"))

		local error_func = function()
			local Tube = Model{finalTime = Mandatory("table")}
		end
		unitTest:assertError(error_func, "finalTime can only be Mandatory('number'), got Mandatory('table').")

		local error_func = function()
			local Tube = Model{finalTime = Choice{"1", "2"}}
		end
		unitTest:assertError(error_func, "finalTime can only be a Choice with 'number' values, got 'string'.")

		local error_func = function()
			local Tube = Model{seed = "2"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("seed", "number", "2"))

		local error_func = function()
			local Tube = Model{seed = -2}
		end
		unitTest:assertError(error_func, positiveArgumentMsg("seed", -2, true))

		local error_func = function()
			local Tube = Model{seed = Mandatory("table")}
		end
		unitTest:assertError(error_func, "seed can only be Mandatory('number'), got Mandatory('table').")

		local error_func = function()
			local Tube = Model{seed = Choice{"1", "2"}}
		end
		unitTest:assertError(error_func, "seed can only be a Choice with 'number' values, got 'string'.")
	
		local error_func = function()
			local Tube = Model{seed = Choice{1, 2}}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("init"))
	
		local error_func = function()
			local Tube = Model{
				seed = Choice{1, 2},
				init = function() end,
				check = 2
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("check", "function", 2))

		local Tube = Model{
			init = function(model) end,
			finalTime = 10
		}

		local error_func = function()
			local m = Tube{}
		end
		unitTest:assertError(error_func, "The object does not have a Timer or an Environment with at least one Timer.")

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
		unitTest:assertError(error_func, "The object has two running objects: 't2' (Timer) and 't' (Timer).")

		error_func = function()
			local m = Tube{finalTime = "2"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("finalTime", "number", "2"))

		Tube = Model{
			init = function(model)
				model.t2 = Timer{}
			end,
			seed = 5,
			finalTime = 10
		}

		error_func = function()
			local m = Tube{2}
		end
		unitTest:assertError(error_func, "All the arguments must be named.")

		error_func = function()
			local m = Tube{seed = "2"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("seed", "number", "2"))

		error_func = function()
			local m = Tube{seed = -2}
		end
		unitTest:assertError(error_func, positiveArgumentMsg("seed", -2, true))

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
		unitTest:assertError(error_func, "The object has two running objects: 't' (Timer) and 'e' (Environment).")

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
		unitTest:assertError(error_func, "The object has two running objects: 't' (Environment) and 'e' (Timer).")

		Tube = Model{
			init = function(model)
				model.finalTime = "5"
				model.t2 = Timer{}
			end
		}

		error_func = function()
			local m = Tube{}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("finalTime", "number", "5"))

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
			init = function(model)
				verify(model.simulationSteps > 0, "Simulation steps should be greater than zero.")
				verify(model.initialWater > 0, "Initial water should be greater than zero.")
				model.timer = Timer{}
			end
		}

		local error_func = function()
			local m = Tube{flow = {a = 2}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("flow", "number", {a = 2}))

		error_func = function()
			local m = Tube{msleep = 40}
		end
		unitTest:assertError(error_func, "Argument 'msleep' should be less than or equal to 2.")

		error_func = function()
			local m = Tube{msleep = 0}
		end
		unitTest:assertError(error_func, "Argument 'msleep' should be greater than or equal to 1.")

		error_func = function()
			local m = Tube{msleep = 1.25}
		end
		unitTest:assertError(error_func, "Invalid value for argument 'msleep' (1.25).")

		error_func = function()
			local m = Tube{simulationSteps = 40}
		end
		unitTest:assertError(error_func, incompatibleValueMsg("simulationSteps", "one of {10, 20, 30}", 40))

		error_func = function()
			local m = Tube{simulationSteps = "40"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("simulationSteps", "number", "40"))

		error_func = function()
			local m = Tube{block = {level = 40}}
		end
		unitTest:assertError(error_func, incompatibleValueMsg("block.level", "one of {1, 2, 3}", 40))

		error_func = function()
			local m = Tube{block = {mblock = 40}}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("block.mblock"))

		error_func = function()
			local m = Tube{s = 3}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("s"))

		error_func = function()
			local m = Tube{checkZero = 3}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("checkZero", "boolean", 3))
	
		error_func = function()
			local m = Tube{initialWater = -5}
		end
		unitTest:assertError(error_func, "Initial water should be greater than zero.")

		error_func = function()
			local m = Tube{block = {xmix = 5}}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("block.xmix", "block.xmax"))

		error_func = function()
			local m = Tube{block = {xmin = false}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("block.xmin", "number", false))
			
		local Tube = Model{
			bb = Choice{min = 10, max = 20, step = 1},
			init = function() end
		}
		
		error_func = function()
			local T = Tube{bb = false}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("bb", "number", false))

		error_func = function()
			local T = Tube{bb = 10.5}
		end
		unitTest:assertError(error_func, "Invalid value for argument 'bb' (10.5).")
	
		error_func = function()
			local T = Tube{bb = 21.5}
		end
		unitTest:assertError(error_func, "Argument 'bb' should be less than or equal to 20.")

		error_func = function()
			local T = Tube{bb = 5}
		end
		unitTest:assertError(error_func, "Argument 'bb' should be greater than or equal to 10.")

		local Tube = Model{
			init = function() end
		}

		error_func = function()
			local T = Tube{}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("finalTime"))

		local M = Model{
			value = Mandatory("number"),
			init = function() end
		}

		error_func = function()
			local m = M{}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("value"))

		error_func = function()
			local m = M{value = false}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("value", "number", false))

		M = Model{
			v = {value = Mandatory("number")},
			init = function() end
		}

		error_func = function()
			local m = M{}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("v.value"))

		error_func = function()
			local m = M{v = {value = false}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("v.value", "number", false))

		M = Model{
			v = {value = Choice{min = 1, max = 10, step = 0.5}},
			init = function() end
		}

		error_func = function()
			local m = M{v = {value = 1.4}}
		end
		unitTest:assertError(error_func, "Invalid value for argument 'v.value' (1.4).")

		error_func = function()
			local m = M{v = {value = "1.4"}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("v.value", "number", "1.4"))
	
		error_func = function()
			local m = M{v = {value = 0}}
		end
		unitTest:assertError(error_func, "Argument 'v.value' should be greater than or equal to 1.")
	
		error_func = function()
			local m = M{v = {value = 11}}
		end
		unitTest:assertError(error_func, "Argument 'v.value' should be less than or equal to 10.")

		M = Model{
			v = {value = Choice{1, 2, 4}},
			init = function() end
		}

		error_func = function()
			local m = M{v = {value = "1.4"}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("v.value", "number", "1.4"))

		M = Model{
			file1 = "*.csv",
			file2 = "*.csv;*.lua",
			init = function(model)
				model.timer = Timer{Event{action = function() end}}
			end
		}

		error_func = function()
			local m = M{file1 = file("agents.csv", "base")}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("file2"))

		error_func = function()
			local m = M{file1 = "agents"}
		end
		unitTest:assertError(error_func, "No file extension for parameter 'file1'. It should be one of '*.csv'.")

		error_func = function()
			local m = M{file1 = file("brazil.gal", "base")}
		end
		unitTest:assertError(error_func, "Invalid file extension for parameter 'file1'. It should be one of '*.csv'.")

		error_func = function()
			local m = M{file1 = "agxd.csv"}
		end
		unitTest:assertError(error_func, resourceNotFoundMsg(toLabel("file1"), "agxd.csv"))

		M = Model{
			files = {
				file1 = "*.csv",
				file2 = "*.csv;*.lua"
			},
			init = function(model)
				model.timer = Timer{Event{action = function() end}}
			end
		}

		error_func = function()
			local m = M{files = {file1 = file("agents.csv", "base")}}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(toLabel("file2", "files")))

		error_func = function()
			local m = M{files = {file1 = 2}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("files.file1", "string", 2))

		error_func = function()
			local m = M{files = {file1 = "agents"}}
		end
		unitTest:assertError(error_func, "No file extension for parameter 'files.file1'. It should be one of '*.csv'.")

		error_func = function()
			local m = M{files = {file1 = file("brazil.gal", "base")}}
		end
		unitTest:assertError(error_func, "Invalid file extension for parameter 'files.file1'. It should be one of '*.csv'.")

		error_func = function()
			local m = M{files = {file1 = "agxd.csv"}}
		end
		unitTest:assertError(error_func, resourceNotFoundMsg(toLabel("file1", "files"), "agxd.csv"))
	end,
	interface = function(unitTest)
		local error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return 2 end
			}
		end
		unitTest:assertError(error_func, "The returning value of interface() should be a table, got number.")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {2} end
			}
		end
		unitTest:assertError(error_func, "There is an element in the interface() that is not a table.")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {{2}} end
			}
		end
		unitTest:assertError(error_func, "All the elements in each interface() vector should be string, got number.")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {{"number", "number"}} end
			}
		end
		unitTest:assertError(error_func, "Argument 'number' cannot be displayed twice in the interface().")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {{"number", "string"}} end
			}
		end
		unitTest:assertError(error_func, "There is no argument 'string' in the Model, although it is described in the interface().")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {{"number", "compulsory"}} end
			}
		end
		unitTest:assertError(error_func, "interface() element 'compulsory' is not an argument of the Model.")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {{"number", "aaa"}} end
			}
		end
		unitTest:assertError(error_func, "interface() element 'aaa' is not an argument of the Model.")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				aaa = 3,
				interface = function() return {{"number", "aaa"}} end
			}
		end
		unitTest:assertError(error_func, "interface() element 'aaa' is not a table in the Model.")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				aaa = {1, 2, 3},
				interface = function() return {{"number", "aaa"}} end
			}
		end
		unitTest:assertError(error_func, "interface() element 'aaa' is a non-named table in the Model.")

		error_func = function()
			local Tube = Model{
				simulationSteps = 10,
				finalTime = 5,
				aaa = {},
				interface = function() return {{"number", "aaa"}} end
			}
		end
		unitTest:assertError(error_func, "interface() element 'aaa' is empty in the Model.")
	end
}

