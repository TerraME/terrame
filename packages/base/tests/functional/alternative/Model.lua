-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

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

return{
	Model = function(unitTest)
		local error_func = function()
			Model{cs = CellularSpace{xdim = 10}}
		end
		unitTest:assertError(error_func, "Type CellularSpace (parameter 'cs') is not supported as argument of Model.")

		error_func = function()
			Model{abc = {cs = CellularSpace{xdim = 10}}}
		end
		unitTest:assertError(error_func, "Type CellularSpace (parameter 'abc.cs') is not supported as argument of Model.")

		error_func = function()
			Model{cs = {1, 2, 3, 4, 5}}
		end
		unitTest:assertError(error_func, "It is not possible to use a vector in a Model (parameter 'cs').")

		error_func = function()
			Model{cs = {{1, 2, 3, 4, 5}}}
		end
		unitTest:assertError(error_func, "It is not possible to use a vector in a Model (parameter 'cs').")

		error_func = function()
			Model{finalTime = "2"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("finalTime", "number", "2"))

		error_func = function()
			Model{finalTime = Mandatory("table")}
		end
		unitTest:assertError(error_func, "finalTime can only be Mandatory('number'), got Mandatory('table').")

		error_func = function()
			Model{finalTime = Choice{"1", "2"}}
		end
		unitTest:assertError(error_func, "finalTime can only be a Choice with 'number' values, got 'string'.")

		error_func = function()
			Model{random = 2}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("random", "boolean", 2))

		error_func = function()
			Model{random = false}
		end
		unitTest:assertError(error_func, defaultValueMsg("random", false))

		error_func = function()
			Model{
				title = "abc",
				init = function() end,
				finalTime = 10
			}
		end
		unitTest:assertError(error_func, "'title' cannot be an argument for a Model.")

		error_func = function()
			Model{
				getParameters = "abc",
				init = function() end,
				finalTime = 10
			}
		end
		unitTest:assertError(error_func, "'getParameters' cannot be an argument for a Model.")

		local Tube = Model{
			init = function() end,
			finalTime = 10
		}

		error_func = function()
			Tube{}
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
			Tube{}
		end
		unitTest:assertError(error_func, "The object has two running objects: 't2' (Timer) and 't' (Timer).")

		error_func = function()
			Tube{finalTime = "2"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("finalTime", "number", "2"))

		Tube = Model{
			init = function(model)
				model.t = Timer{}
				model.e = Environment{t2 = Timer{}}
			end,
			finalTime = 10
		}

		error_func = function()
			Tube{2}
		end
		unitTest:assertError(error_func, "All the arguments must be named.")


		error_func = function()
			Tube{}
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

		error_func = function()
			Tube{}
		end
		unitTest:assertError(error_func, "The object has two running objects: 't' (Environment) and 'e' (Timer).")

		Tube = Model{
			init = function(model)
				model.finalTime = "5"
				model.t2 = Timer{}
			end
		}

		error_func = function()
			Tube{}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("finalTime", "number", "5"))

		Tube = Model{
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

		error_func = function()
			Tube{flow = {a = 2}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("flow", "number", {a = 2}))

		error_func = function()
			Tube{msleep = 40}
		end
		unitTest:assertError(error_func, "Argument 'msleep' should be less than or equal to 2.")

		error_func = function()
			Tube{msleep = 0}
		end
		unitTest:assertError(error_func, "Argument 'msleep' should be greater than or equal to 1.")

		error_func = function()
			Tube{msleep = 1.25}
		end
		unitTest:assertError(error_func, "Invalid value for argument 'msleep' (1.25).")

		error_func = function()
			Tube{simulationSteps = 40}
		end
		unitTest:assertError(error_func, incompatibleValueMsg("simulationSteps", "one of {10, 20, 30}", 40))

		error_func = function()
			Tube{simulationSteps = "40"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("simulationSteps", "number", "40"))

		error_func = function()
			Tube{block = {level = 40}}
		end
		unitTest:assertError(error_func, incompatibleValueMsg("block.level", "one of {1, 2, 3}", 40))

		error_func = function()
			Tube{block = {mblock = 40}}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("block.mblock"))

		error_func = function()
			Tube{s = 3}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("s"))

		error_func = function()
			Tube{checkZero = 3}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("checkZero", "boolean", 3))

		error_func = function()
			Tube{initialWater = -5}
		end
		unitTest:assertError(error_func, "Initial water should be greater than zero.")

		error_func = function()
			Tube{block = {xmix = 5}}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("block.xmix", "block.xmax"))

		error_func = function()
			Tube{block = {xmin = false}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("block.xmin", "number", false))

		Tube = Model{
			bb = Choice{min = 10, max = 20, step = 1},
			init = function() end
		}

		error_func = function()
			Tube{bb = false}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("bb", "number", false))

		error_func = function()
			Tube{bb = 10.5}
		end
		unitTest:assertError(error_func, "Invalid value for argument 'bb' (10.5).")

		error_func = function()
			Tube{bb = 21.5}
		end
		unitTest:assertError(error_func, "Argument 'bb' should be less than or equal to 20.")

		error_func = function()
			Tube{bb = 5}
		end
		unitTest:assertError(error_func, "Argument 'bb' should be greater than or equal to 10.")

		Tube = Model{
			init = function() end
		}

		error_func = function()
			Tube{}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("finalTime"))

		local M = Model{
			value = Mandatory("number"),
			init = function() end
		}

		error_func = function()
			M{}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("value"))

		error_func = function()
			M{value = false}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("value", "number", false))

		M = Model{
			v = {value = Mandatory("number")},
			init = function() end
		}

		error_func = function()
			M{}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("v.value"))

		error_func = function()
			M{v = {value = false}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("v.value", "number", false))

		M = Model{
			v = {value = Choice{min = 1, max = 10, step = 0.5}},
			init = function() end
		}

		error_func = function()
			M{v = {value = 1.4}}
		end
		unitTest:assertError(error_func, "Invalid value for argument 'v.value' (1.4).")

		error_func = function()
			M{v = {value = "1.4"}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("v.value", "number", "1.4"))

		error_func = function()
			M{v = {value = 0}}
		end
		unitTest:assertError(error_func, "Argument 'v.value' should be greater than or equal to 1.")

		error_func = function()
			M{v = {value = 11}}
		end
		unitTest:assertError(error_func, "Argument 'v.value' should be less than or equal to 10.")

		M = Model{
			v = {value = Choice{1, 2, 4}},
			init = function() end
		}

		error_func = function()
			M{v = {value = "1.4"}}
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
			M{file1 = filePath("agents.csv", "base")}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("file2"))

		error_func = function()
			M{file1 = "agents"}
		end
		unitTest:assertError(error_func, "No file extension for parameter 'file1'. It should be one of '*.csv'.")

		error_func = function()
			M{file1 = filePath("test/brazil.gal", "base")}
		end
		unitTest:assertError(error_func, "Invalid file extension for parameter 'file1'. It should be one of '*.csv'.")

		error_func = function()
			M{file1 = "agxd.csv"}
		end
		unitTest:assertError(error_func, resourceNotFoundMsg(toLabel("file1"), File("agxd.csv")))

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
			M:exec()
		end
		unitTest:assertError(error_func, "It is not possible to call any function from a Model but run() or configure().")

		error_func = function()
			M{files = {file1 = filePath("agents.csv", "base")}}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(toLabel("file2", "files")))

		error_func = function()
			M{files = {file1 = 2}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("files.file1", "File", 2))

		error_func = function()
			M{files = {file1 = "agents"}}
		end
		unitTest:assertError(error_func, "No file extension for parameter 'files.file1'. It should be one of '*.csv'.")

		error_func = function()
			M{files = {file1 = filePath("test/brazil.gal", "base")}}
		end
		unitTest:assertError(error_func, "Invalid file extension for parameter 'files.file1'. It should be one of '*.csv'.")

		error_func = function()
			M{files = {file1 = "agxd.csv"}}
		end
		unitTest:assertError(error_func, resourceNotFoundMsg(toLabel("file1", "files"), File("agxd.csv")))

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

		error_func = function()
			M{quantity = func1}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("quantity", "string", func1))

		error_func = function()
			M{quantity = "c"}
		end
		unitTest:assertError(error_func, "Incompatible values. Argument 'quantity' expected one of {'a', 'b'}, got 'c'.")

		error_func = function()
			M{internal = {quantity = func1}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("quantity", "string", func1))

		error_func = function()
			M{internal = {quantity = "c"}}
		end
		unitTest:assertError(error_func, "Incompatible values. Argument 'quantity' expected one of {'a', 'b'}, got 'c'.")
	end,
	execute = function(unitTest)
		local error_func = function()
			Model{
				water = 20,
				flow = 1,
				finalTime = 20,
				execute = "2",
				init = function (model)
					model.chart = Chart{
						target = model,
						select = "water"
				}
				end
			}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("execute", "function", "2"))
	end,
	interface = function(unitTest)
		local error_func = function()
			Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return 2 end
			}
		end
		unitTest:assertError(error_func, "The returning value of interface() should be a table, got number.")

		error_func = function()
			Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {2} end
			}
		end
		unitTest:assertError(error_func, "There is an element in the interface() that is not a table.")

		error_func = function()
			Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {{2}} end
			}
		end
		unitTest:assertError(error_func, "All the elements in each interface() vector should be string, got number.")

		error_func = function()
			Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {{"number", "number"}} end
			}
		end
		unitTest:assertError(error_func, "Argument 'number' cannot be displayed twice in the interface().")

		error_func = function()
			Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {{"number", "string"}} end
			}
		end
		unitTest:assertError(error_func, "There is no argument 'string' in the Model, although it is described in the interface().")

		error_func = function()
			Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {{"number", "compulsory"}} end
			}
		end
		unitTest:assertError(error_func, "interface() element 'compulsory' is not an argument of the Model.")

		error_func = function()
			Model{
				simulationSteps = 10,
				finalTime = 5,
				interface = function() return {{"number", "aaa"}} end
			}
		end
		unitTest:assertError(error_func, "interface() element 'aaa' is not an argument of the Model.")

		error_func = function()
			Model{
				simulationSteps = 10,
				finalTime = 5,
				aaa = 3,
				interface = function() return {{"number", "aaa"}} end
			}
		end
		unitTest:assertError(error_func, "interface() element 'aaa' is not a table in the Model.")

		error_func = function()
			Model{
				simulationSteps = 10,
				finalTime = 5,
				aaa = {1, 2, 3},
				interface = function() return {{"number", "aaa"}} end
			}
		end
		unitTest:assertError(error_func, "interface() element 'aaa' is a vector in the Model.")

		error_func = function()
			Model{
				simulationSteps = 10,
				finalTime = 5,
				aaa = {},
				interface = function() return {{"number", "aaa"}} end
			}
		end
		unitTest:assertError(error_func, "interface() element 'aaa' is empty in the Model.")
	end
}

