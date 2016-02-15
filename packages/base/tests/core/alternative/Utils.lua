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
	belong = function(unitTest)
		local error_func = function()
			belong("2", "2")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "table", "2"))
	end,
	call = function(unitTest)
		local error_func = function()
			call(Cell{}, 2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))

		local error_func = function()
			call("value", "sum")
		end
		unitTest:assertError(error_func, "Cannot access elements from an object of type 'string'.")
	
		local error_func = function()
			call(Cell{}, "sum")
		end
		unitTest:assertError(error_func, "Function 'sum' does not exist.")
	end,
	clone = function(unitTest)
		local error_func = function()
			clone(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", 2))
	end,
	d = function(unitTest)
		local error_func = function()
			local gt = d()
		end
		unitTest:assertError(error_func, [[Error: bad arguments in diferential equation constructor "d{arguments}". TerraME has found 0 arguments.
 - the first attribute of a differential equantion must be a function which return a number. It can also be a table of functions like that,
 - the second one must be the initial condition value. It can also be a table of initial conditions,
 - the third one must be the lower integration limit value,
 - the fourth one must be the upper integration limit value, and
 - the fifth, OPTIONAL, must be the integration increment value (default = 0.2).
]])


		local myf = function() end

		error_func = function()
			local gt = d{{myf, myf}, {1}, 0, 0, 10} 
		end
		unitTest:assertError(error_func, "You should provide the same number of differential equations and initial conditions.")
	end,
	elapsedTime = function(unitTest)
		local error_func = function()
			elapsedTime("2")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "number", "2"))
	end,
	forEachAgent = function(unitTest)
		local a = Agent{value = 2}
		local soc = Society{instance = a, quantity = 10}
		local c = Cell{}

		local error_func = function()
			forEachAgent(nil, function() end)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Society, Group, or Cell"))

		error_func = function()
			forEachAgent(soc)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function"))

		error_func = function()
			forEachAgent(c, function() end)
		end
		unitTest:assertError(error_func, "Could not get agents from the Cell.")
	end,
	forEachCell = function(unitTest)
		local error_func = function()
			forEachCell()
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "CellularSpace, Trajectory, or Agent"))

		error_func = function()
			forEachCell(CellularSpace{xdim = 5})
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function"))
	end,
	forEachCellPair = function(unitTest)
		local cs1 = CellularSpace{xdim = 10}
		local cs2 = CellularSpace{xdim = 10}

		local error_func = function()
			forEachCellPair()
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "CellularSpace"))

		error_func = function()
			forEachCellPair(cs1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "CellularSpace"))

		error_func = function()
			forEachCellPair(cs1, cs2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(3, "function"))
	end,	
	forEachConnection = function(unitTest)
		local a = Agent{value = 2}
		local soc = Society{instance = a, quantity = 10}

		soc:createSocialNetwork{probability = 0.8}

		local error_func = function()
			forEachConnection(nil, function() end)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Agent"))

		error_func = function()
			forEachConnection(soc.agents[1])
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function or string"))

		error_func = function()
			forEachConnection(soc.agents[1], "1")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(3, "function"))

		error_func = function()
			forEachConnection(soc.agents[1], "2", function() end)
		end
		unitTest:assertError(error_func, "Agent does not have a SocialNetwork named '2'.")
	end,
	forEachElement = function(unitTest)
		local error_func = function()
			forEachElement()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		local agent = Agent{w = 3, f = 5}

		error_func = function()
			forEachElement(agent)
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			forEachElement(agent, 12345)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function", 12345))

		error_func = function()
			forEachElement("abc", function() end)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", "abc"))
	end,
	forEachFile = function(unitTest)
		local error_func = function()
			forEachFile()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		local error_func = function()
			forEachFile(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", 2))

		if not _Gtme.isWindowsOS() then		
			error_func = function()
				forEachFile(filePath("", "base"))
			end
			unitTest:assertError(error_func, mandatoryArgumentMsg(2)) -- SKIP
		
			error_func = function()
				forEachFile(filePath("", "base"), 2)
			end
			unitTest:assertError(error_func, incompatibleTypeMsg(2, "function", 2)) -- SKIP
		else
			unitTest:assert(true) -- SKIP
		end
	end,
	forEachNeighbor = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		cs:createNeighborhood()
		local cell = cs:sample()

		local error_func = function()
			forEachNeighbor(nil, function() end)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Cell"))

		error_func = function()
			forEachNeighbor(cell)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function or string"))

		error_func = function()
			forEachNeighbor(cell, "1")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(3, "function"))

		error_func = function()
			forEachNeighbor(cell, "2", function() end)
		end
		unitTest:assertError(error_func, "Neighborhood '2' does not exist.")
	end,
	forEachNeighborhood = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			forEachNeighborhood(nil, function() end)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Cell"))

		error_func = function()
			forEachNeighborhood(cs:sample())
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function"))
	end,
	forEachOrderedElement = function(unitTest)
		local error_func = function()
			forEachOrderedElement()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			forEachOrderedElement({1, 2, 3})
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function"))

		error_func = function()
			forEachOrderedElement("abc", function() end)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", "abc"))
	end,
	forEachSocialNetwork = function(unitTest)
		local ag = Agent{}

		local error_func = function()
			forEachSocialNetwork(nil, function() end)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Agent"))

		error_func = function()
			forEachSocialNetwork(ag)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function"))
	end,
	getExtension = function(unitTest)
		local error_func = function()
			getExtension(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	getn = function(unitTest)
		local error_func = function()
			getn("2")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", "2"))
	end,
	greaterByAttribute = function(unitTest)
		local error_func = function()
			local gt = greaterByAttribute(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))

		error_func = function()
			local gt = greaterByAttribute("cover", "==")
		end
		unitTest:assertError(error_func, incompatibleValueMsg(2, "<, >, <=, or >=", "=="))
	end,
	greaterByCoord = function(unitTest)
		local error_func = function()
			local gt = greaterByCoord("==")
		end
		unitTest:assertError(error_func, incompatibleValueMsg(1, "<, >, <=, or >=", "=="))
	end,
	integrate = function(unitTest)
		local error_func = function()
			local gt = integrate()
		end
		unitTest:assertError(error_func, tableArgumentMsg())

		local error_func = function()
			local gt = integrate{step = "a", equation = function() end, initial = 0}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("step", "number", "a"))

		local error_func = function()
			local gt = integrate{step = -0.5, equation = function() end, initial = 0}
		end
		unitTest:assertError(error_func, positiveArgumentMsg("step", -0.5))
	
		local error_func = function()
			local gt = integrate{step = 0.1, method = "euler", equation = function() end, initial = 0}
		end
		unitTest:assertError(error_func, defaultValueMsg("method", "euler"))
	
		local error_func = function()
			local gt = integrate{step = 0.1, method = "eler", equation = function() end, initial = 0}
		end
		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("eler", "method", "euler"))

		local error_func = function()
			local gt = integrate{equation = 0.1}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("equation", "table", 0.1))

		local error_func = function()
			local gt = integrate{equation = function() end, initial = "aaa"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("initial", "table", "aaa"))

		local error_func = function()
			local gt = integrate{equation = {function() end, 2}}
		end
		unitTest:assertError(error_func, "Table 'equation' should contain only functions, got number.")

		local error_func = function()
			local gt = integrate{equation = {function() end, function() end}, initial = {1, "b"}}
		end
		unitTest:assertError(error_func, "Table 'initial' should contain only numbers, got string.")

		local error_func = function()
			local gt = integrate{equation = {function() end, function() end}, initial = {1, 2, 3}}
		end
		unitTest:assertError(error_func, "Tables equation and initial shoud have the same size.")

		local error_func = function()
			local gt = integrate{equation = function() end, initial = 1, step = 5, metod = 3}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("metod", "method"))

		local event = Event{start = 0.5, period = 2, priority = 1, action = function(event) end}

		local error_func = function()
			local gt = integrate{equation = function() end, initial = 1, event = event, a = 2}
		end
		unitTest:assertError(error_func, "Argument 'a' should not be used together with argument 'event'.")

		local error_func = function()
			local gt = integrate{equation = function() end, initial = 1, event = event, b = 2}
		end
		unitTest:assertError(error_func, "Argument 'b' should not be used together with argument 'event'.")
	end,
	levenshtein = function(unitTest)
		local error_func = function()
			local gt = levenshtein(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))
	
		error_func = function()
			local gt = levenshtein("abc", 2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))
	end,
	makeDataTable = function(unitTest)
		local error_func = function()
			x = makeDataTable()
		end
		unitTest:assertError(error_func, tableArgumentMsg())

		local error_func = function()
			x = makeDataTable{first = "a"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("first", "number", "a"))

		local error_func = function()
			x = makeDataTable{
				first = 2000,
				step = "a"
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("step", "number", "a"))

		local error_func = function()
			x = makeDataTable{
				first = 2000,
				step = 10,
				demand = "a"
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("demand", "table", "a"))

		local error_func = function()
			x = makeDataTable{
				first = 2000,
				step = 10,
				last = 2025
			}
		end
		unitTest:assertError(error_func, "Invalid 'last' value (2025). It could be 2020 or 2030.")

		local error_func = function()
			x = makeDataTable{
				first = 2000,
				step = 10
			}
		end
		unitTest:assertError(error_func, "It is not possible to create a table without any data.")

		local error_func = function()
			x = makeDataTable{
				first = 2000,
				step = 10,
				last = 2030,
				demand = {7, 8, 9}
			}
		end
		unitTest:assertError(error_func, "Argument 'demand' should have 4 elements, got 3.")

		local error_func = function()
			x = makeDataTable{
				first = 2000,
				step = 10,
				demand = {7, 8, 9, 10},
				limit = {0.1, 0.04, 0.3}
			}
		end
		unitTest:assertError(error_func, "Argument 'limit' should have 4 elements, got 3.")
	end,
	round = function(unitTest)
		local error_func = function()
			x = round("a")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "number", "a"))

		error_func = function()
			x = round(2.5, "a")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "number", "a"))
	end,
	toLabel = function(unitTest)
		local error_func = function()
			x = toLabel(false)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", false))

		error_func = function()
			x = toLabel("abc", false)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", false))
	end,
	switch = function(unitTest)
		local error_func = function()
			switch("aaaab")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", "aaaab"))

		error_func = function()
			switch({}, 2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))
	
		error_func = function()
			local data = {att = "abd"}
			switch(data, "att"):caseof{
				abc = function() end
			}
		end
		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("abd", "att", "abc"))
	
		local options = {
			xxx = true
		}

		error_func = function()
			local data = {att = "abd"}
			switch(data, "att"):caseof{
				xxx = function() end
			}
		end
		unitTest:assertError(error_func, switchInvalidArgumentMsg("abd", "att", options))
	
		error_func = function()
			local data = {att = "abd"}
			switch(data, "att"):caseof(2)
		end
		unitTest:assertError(error_func, namedArgumentsMsg())

		error_func = function()
			local data = {att = "abd"}
			switch(data, "att"):caseof{
				abd = 2
			}
		end
		unitTest:assertError(error_func, "Case 'abd' should be a function, got number.")
	end
}

