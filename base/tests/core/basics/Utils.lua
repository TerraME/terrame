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

return{
	integrate = function(unitTest)
		unitTest:assert(true)
	end,
	suggest = function(unitTest)
		unitTest:assert(true)
	end,
	switch = function(unitTest)
		unitTest:assert(true)
	end,
	INTEGRATION_METHOD = function(unitTest)
		unitTest:assert(true)
	end,
	belong = function(unitTest)
		local mvector = {"a", "b", "c", "d"}

		unitTest:assert(belong("b", mvector))
		unitTest:assert(not belong("e", mvector))
	end,
	checkUnnecessaryParameters = function(unitTest)
		local error_func = function(unitTest)
			checkUnnecessaryParameters({aaa = "aaa"}, {"abc", "acd", "aab"}, 2)
		end
		unitTest:assert_error(error_func, "Error: Parameter 'aaa' is unnecessary.")
	end,
	customError = function(unitTest)
		local error_func = function()
			customError("test.", 2)
		end
		unitTest:assert_error(error_func, "Error: test.")
	end,
	customWarning = function(unitTest)
		local error_func = function()
			customWarning("test.", 2)
		end
		unitTest:assert_error(error_func, "Error: test.")
	end,
	defaultValueWarning = function(unitTest)
		local error_func = function()
			defaultValueWarning(2)
		end
		unitTest:assert_error(error_func, "Error: #1 should be a string.")
	end,
	delay = function(unitTest)
		local t1 = os.time()
		delay(1)
		local t2 = os.time()

		unitTest:assert(t2 - t1 >= 1)
	end,
	deprecatedFunctionWarning = function(unitTest)
		local error_func = function()
			deprecatedFunctionWarning("abc", "def", 2)
		end
		unitTest:assert_error(error_func, "Error: Function 'abc' is deprecated. Use 'def' instead.")
	end,
	incompatibleFileExtensionError = function(unitTest)
		local error_func = function()
			incompatibleFileExtensionError("file", ".txt", 2)
		end
		unitTest:assert_error(error_func, "Error: Parameter 'file' does not support '.txt'.")
	end,
	incompatibleTypeError = function(unitTest)
		local error_func = function()
			incompatibleTypeError("cell", "Cell", "Agent", 2)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'cell' expected Cell, got Agent.")
	end,
	incompatibleValueError = function(unitTest)
		local error_func = function()
			incompatibleValueError("position", "1, 2, or 3", "4", 2)
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'position' expected 1, 2, or 3, got '4'.")
	end,
	resourceNotFoundError = function(unitTest)
		local error_func = function()
			resourceNotFoundError("file", "/usr/local/file.txt", 2)
		end
		unitTest:assert_error(error_func, "Error: Resource '/usr/local/file.txt' not found for parameter 'file'.")
	end,
	levenshtein = function(unitTest)
		unitTest:assert_equal(levenshtein("abv", "abc"), 1)
		unitTest:assert_equal(levenshtein("abvaacc", "abcaacac"), 2)
		unitTest:assert_equal(levenshtein("abvxwtaacc", "abcaacac"), 5)
	end,
	mandatoryArgumentError = function(unitTest)
		local error_func = function()
			mandatoryArgumentError("neighborhood", 2)
		end
		unitTest:assert_error(error_func, "Error: Parameter 'neighborhood' is mandatory.")
	end,
	namedParametersError = function(unitTest)
		local error_func = function()
			namedParametersError("CellularSpace", 2)
		end
		unitTest:assert_error(error_func, "Error: Parameters for 'CellularSpace' must be named.")
	end,
	tableParameterError = function(unitTest)
		local error_func = function()
			tableParameterError("CellularSpace", 2)
		end
		unitTest:assert_error(error_func, "Error: Parameter for 'CellularSpace' must be a table.")
	end,
	valueNotFoundError = function(unitTest)
		local error_func = function()
			valueNotFoundError("1", "neighborhood", 2)
		end
		unitTest:assert_error(error_func, "Error: Value 'neighborhood' not found for parameter '1'.")
	end,
	verify = function(unitTest)
		local error_func = function(unitTest)
			verify(false, "error")
		end
		unitTest:assert_error(error_func, "Error: error")
	end,
	forEachAgent = function(unitTest)
		local a = Agent{value = 2}
		local soc = Society{instance = a, quantity = 10}

		local count = 0
		forEachAgent(soc, function(ag)
			unitTest:assert_equal(ag.value, 2)
			count = count + 1
		end)
		unitTest:assert_equal(count, 10)

		local g = Group{target = soc}

		count = 0
		forEachAgent(g, function(ag)
			unitTest:assert_equal(ag.value, 2)
			count = count + 1
		end)
		unitTest:assert_equal(count, 10)

		local cs = CellularSpace{xdim = 1, ydim = 1}
		local e = Environment{soc, cs}

		e:createPlacement()

		count = 0
		forEachAgent(cs:sample(), function(ag)
			unitTest:assert_equal(ag.value, 2)
			count = count + 1
		end)
		unitTest:assert_equal(count, 10)
	end,
	forEachCell = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		forEachCell(cs, function(cell) unitTest:assert_type(cell, "Cell") end)

		forEachCell(cs, function(cell) cell.value = 2 end)
		forEachCell(cs, function(cell) unitTest:assert_equal(cell.value, 2) end)

		local t = Trajectory{target = cs}
		forEachCell(t, function(cell) cell.value = 4 end)
		forEachCell(cs, function(cell) unitTest:assert_equal(cell.value, 4) end)

		local a = Agent{}
		local env = Environment{cs, a}

		env:createPlacement{strategy = "void"}

		a.placement:add(cs:sample())
		a.placement:add(cs:sample())
		a.placement:add(cs:sample())

		forEachCell(a, function(cell) unitTest:assert_equal(cell.value, 4) end)
	end,
	forEachCellPair = function(unitTest)
		local cs1 = CellularSpace{xdim = 10}
		local cs2 = CellularSpace{xdim = 10}

		local count = 0
		forEachCellPair(cs1, cs2, function()
			count = count + 1
		end)

		unitTest:assert_equal(count, 100)
	end,
	forEachConnection = function(unitTest)
		local a = Agent{value = 2}
		local soc = Society{instance = a, quantity = 10}

		soc:createSocialNetwork{quantity = 3}

		local cont = 0
		local s = soc:sample()
		forEachConnection(s, function(ag1, ag2, w)
			unitTest:assert_type(ag2, "Agent")
			unitTest:assert_equal(ag1, s)
			unitTest:assert_type(w, "number")
			cont = cont + 1
		end)

		unitTest:assert_equal(cont, 3)
	end,
	forEachElement = function(unitTest)
		local mvector = {a = "a", b = "b", c = "c", d = "d"}

		local count = 0
		forEachElement(mvector, function(idx, value, mtype)
			unitTest:assert_type(idx, "string")
			unitTest:assert_type(value, "string")
			unitTest:assert_equal(mtype, "string")
			count = count + 1
		end)
		unitTest:assert_equal(count, 4)

		mvector = {1, 2, 3, 4, 5}
		count = 0
		forEachElement(mvector, function(idx, value, mtype)
			unitTest:assert_type(idx, "number")
			unitTest:assert_type(value, "number")
			unitTest:assert_equal(mtype, "number")
			count = count + 1
		end)
		unitTest:assert_equal(count, 5)
	end,
	forEachNeighbor = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		cs:createNeighborhood()

		local count = 0
		local c = cs.cells[1]
		forEachNeighbor(c, function(cell1, cell2, w)
			unitTest:assert_type(cell2, "Cell")
			unitTest:assert_equal(cell1, c)
			unitTest:assert_type(w, "number")
			count = count + 1
		end)
		unitTest:assert_equal(count, 3)
	end,
	-- TODO: for each forEach, implement a test where there is a return false and thus it does not processes all the elements.
	forEachNeighborhood = function(unitTest)
		local c1 = Cell{}
		local c2 = Cell{}
		local c3 = Cell{}

		local n1 = Neighborhood()
		n1:add(c2)
		n1:add(c3)

		local n2 = Neighborhood()
		n2:add(c2)
		n2:add(c3)

		c1:addNeighborhood(n1, "1")
		c1:addNeighborhood(n2, "2")

		local count = 0
		forEachNeighborhood(c1, function()
			count = count + 1
		end)
		unitTest:assert_equal(count, 2)
	end,
	forEachOrderedElement = function(unitTest)
		local result = {"a", "b", "c"}
		local list = {a = "a", b = "b", c = "c"}

		local cont = 0
		forEachOrderedElement(list, function(idx, value, mtype)
			cont = cont + 1
			unitTest:assert_equal(mtype, "string")

			unitTest:assert_equal(idx, result[cont])
			unitTest:assert_equal(value, result[cont])
		end)
		unitTest:assert_equal(cont, 3)
	end,
	getn = function(unitTest)
		local mvector = {"a", "b", "c", "d"}

		unitTest:assert_equal(getn(mvector), 4)

		mvector = {a = "a", b = "b", c = "c", d = "d"}
		unitTest:assert_equal(getn(mvector), 4)

		mvector = {a = "a", b = "b", "c", "d"}
		unitTest:assert_equal(getn(mvector), 4)

		mvector = {}
		unitTest:assert_equal(getn(mvector), 0)
	end,
	round = function(unitTest)
		unitTest:assert_equal(round(5.22), 5)
		unitTest:assert_equal(round(5.2235, 3), 5.224)
	end,
	greaterByAttribute = function(unitTest)
		local gt = greaterByAttribute("cover")
		unitTest:assert_type(gt, "function")

		gt = greaterByAttribute("cover", ">")
		unitTest:assert_type(gt, "function")
	end,
	greaterByCoord = function(unitTest)
		local gt = greaterByCoord()
		unitTest:assert_type(gt, "function")

		gt = greaterByCoord(">")
		unitTest:assert_type(gt, "function")
	end,
	integrationEuler = function(unitTest)
		local f = function(x) return x^3 end

		local method = integrationEuler

		local v = method(f, 0, 0, 3, 0.1)
		unitTest:assert_equal(16.48360, v, 0.0001)

		v = method(f, 0, 0, 3, 0.01)
		unitTest:assert_equal(20.11522, v, 0.0001)

		v = method(f, 0, 0, 3, 0.001)
		unitTest:assert_equal(20.23650, v, 0.0001)

		v = method(f, 0, 0, 3, 0.0001)
		unitTest:assert_equal(20.24595, v, 0.0001)
	end,
	integrationRungeKutta = function(unitTest)
		local method = integrationRungeKutta
		local f = function(x) return x^3 end
		local v = method(f, 0, 0, 3, 0.1)
		unitTest:assert_equal(17.682025, v, 0.0001)

		v = method(f, 0, 0, 3, 0.01)
		unitTest:assert_equal(20.25, v, 0.0001)

		v = method(f, 0, 0, 3, 0.001)
		unitTest:assert_equal(20.25, v, 0.0001)

		v = method(f, 0, 0, 3, 0.0001)
		unitTest:assert_equal(20.24730, v, 0.0001)
	end,
	integrationHeun = function(unitTest)
		local method = integrationHeun
		local f = function(x) return x^3 end
		local v = method(f, 0, 0, 3, 0.1)
		unitTest:assert_equal(17.70305, v, 0.0001)

		v = method(f, 0, 0, 3, 0.01)
		unitTest:assert_equal(20.250225, v, 0.0001)

		v = method(f, 0, 0, 3, 0.001)
		unitTest:assert_equal(20.25, v, 0.0001)

		v = method(f, 0, 0, 3, 0.0001)
		unitTest:assert_equal(20.24730, v, 0.0001)
	end,
	d = function(unitTest)
		INTEGRATION_METHOD = integrationHeun
		local df = function(x, y) return y - x^2+1 end
		local a = 0
		local b = 2
		local init = 0.5
		local delta = 0.2
		local x = 0
		local y = 0

		local result1 = integrationHeun(df, init, a, b, delta)
		a = 0
		b = 2
		init = 0.5
		delta = 0.2
		x = 0
		y = 0
		local result2 = d{df, init, a, b, delta}
		unitTest:assert_equal(5.23305, result1, 0.0001)
		unitTest:assert_equal(result1, result2)
	end,
	elapsedTime = function(unitTest)
		unitTest:assert_type(elapsedTime(50), "string")
	end
--	tostring = function(unitTest)
	--	cs1 = CellularSpace{ xdim = 10 }
	--	cs1:createNeighborhood()
	-- TODO: colocar o print do Observer nos testes de observer
--    print("########## OBSERVER\n")
--    local obs1 = Observer{ subject = auxC }
--    auxC:notify()
--    print(obs1)
--    obs1:kill()
--[[
		local leg1 = Legend{}
		unitTest:assert_equal(tostring(leg1), [[colorBar      string [255,255,255;0;0;?;#0,0,0;100;100;?;#]
font          string [Symbol]
fontSize      number [12]
grouping      number [0]
maximum       number [100]
minimum       number [0]
precision     number [4]
slices        number [2]
stdDeviation  number [-1]
style         number [1]
symbol        string [®]
type          number [1]
width         number [2]
] ])
--]]
--	end
}

