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
	belong2 = function(unitTest)
		local error_func = function()
			belong2("2", "2")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "table", "2"))
	end,
	call2 = function(unitTest)
		local error_func = function()
			call2(Cell{}, "sum")
		end
		unitTest:assertError(error_func, "Function 'sum' does not exist.")

		local error_func = function()
			belong2("2", "2")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "table", "2"))
	end,
	elapsedTime2 = function(unitTest)
		local error_func = function()
			elapsedTime2("2")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "number", "2"))
	end,
	forEachCellPair2 = function(unitTest)
		local cs1 = CellularSpace{xdim = 10}
		local cs2 = CellularSpace{xdim = 10}

		local error_func = function()
			forEachCellPair2()
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "CellularSpace"))

		error_func = function()
			forEachCellPair2(cs1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "CellularSpace"))

		error_func = function()
			forEachCellPair2(cs1, cs2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(3, "function"))
	end,	
	forEachElement2 = function(unitTest)
		local error_func = function()
			forEachElement2()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		local agent = Agent{w = 3, f = 5}

		error_func = function()
			forEachElement2(agent)
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			forEachElement2(agent, 12345)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function", 12345))
	end,
	forEachFile2 = function(unitTest)
		local error_func = function()
			forEachFile2()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		local error_func = function()
			forEachFile2(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", 2))

		error_func = function()
			forEachFile2(filePath("", "base"))
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(2))
	
		error_func = function()
			forEachFile2(filePath("", "base"), 2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function", 2))
	end,
	forEachOrderedElement2 = function(unitTest)
		local error_func = function()
			forEachOrderedElement2()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			forEachOrderedElement2({1, 2, 3})
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function"))

		error_func = function()
			forEachOrderedElement2({aaa = 2, aaA = 3}, function() end)
		end
		unitTest:assertError(error_func, "forEachOrderedElement() cannot work with two indexes having the same lower case.")
	end,
	forEachSocialNetwork2 = function(unitTest)
		local ag = Agent{}

		local error_func = function()
			forEachSocialNetwork2(nil, function() end)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Agent"))

		error_func = function()
			forEachSocialNetwork2(ag)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "function"))
	end,
	getExtension2 = function(unitTest)
		local error_func = function()
			getExtension2(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	getn2 = function(unitTest)
		local error_func = function()
			getn2("2")
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
	greaterByCoord2 = function(unitTest)
		local error_func = function()
			local gt = greaterByCoord2("==")
		end
		unitTest:assertError(error_func, incompatibleValueMsg(1, "<, >, <=, or >=", "=="))
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
	round2 = function(unitTest)
		local error_func = function()
			x = round2("a")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "number", "a"))

		error_func = function()
			x = round2(2.5, "a")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "number", "a"))
	end,
	switch2 = function(unitTest)
		local error_func = function()
			switch2("aaaab")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", "aaaab"))

		error_func = function()
			switch2({}, 2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))
	
		error_func = function()
			local data = {att = "abd"}
			switch2(data, "att"):caseof{
				abc = function() end
			}
		end
		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("abd", "att", "abc"))
	
		local options = {
			xxx = true
		}

		error_func = function()
			local data = {att = "abd"}
			switch2(data, "att"):caseof{
				xxx = function() end
			}
		end
		unitTest:assertError(error_func, switchInvalidArgumentMsg("abd", "att", options))
	
		error_func = function()
			local data = {att = "abd"}
			switch2(data, "att"):caseof(2)
		end
		unitTest:assertError(error_func, namedArgumentsMsg())

		error_func = function()
			local data = {att = "abd"}
			switch2(data, "att"):caseof{
				abd = 2
			}
		end
		unitTest:assertError(error_func, "Case 'abd' should be a function, got number.")
	end
}

