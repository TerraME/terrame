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
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "table", "2"))
	end,
	forEachAgent = function(unitTest)
		local a = Agent{value = 2}
		local soc = Society{instance = a, quantity = 10}

		local error_func = function()
			forEachAgent(nil, function() end)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "Society, Group, or Cell"))

		error_func = function()
			forEachAgent(soc)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "function"))
	end,
	forEachCell = function(unitTest)
		local error_func = function()
			forEachCell()
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "CellularSpace, Trajectory, or Agent"))

		error_func = function()
			forEachCell(CellularSpace{xdim = 5})
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "function"))
	end,
	forEachCellPair = function(unitTest)
		local cs1 = CellularSpace{xdim = 10}
		local cs2 = CellularSpace{xdim = 10}

		local error_func = function()
			forEachCellPair()
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "CellularSpace"))

		error_func = function()
			forEachCellPair(cs1)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "CellularSpace"))

		error_func = function()
			forEachCellPair(cs1, cs2)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(3, "function"))
	end,	
	forEachConnection = function(unitTest)
		local a = Agent{value = 2}
		local soc = Society{instance = a, quantity = 10}

		soc:createSocialNetwork{probability = 0.8}

		local error_func = function()
			forEachConnection(nil, function() end)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "Agent"))

		error_func = function()
			forEachConnection(soc.agents[1])
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "function or string"))

		error_func = function()
			forEachConnection(soc.agents[1], "1")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(3, "function"))

		error_func = function()
			forEachConnection(soc.agents[1], "2", function() end)
		end
		unitTest:assert_error(error_func, "Agent does not have a SocialNetwork named '2'.")
	end,
	forEachElement = function(unitTest)
		local error_func = function()
			forEachElement()
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg(1))

		local agent = Agent{w = 3, f = 5}

		error_func = function()
			forEachElement(agent)
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			forEachElement(agent, 12345)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "function", 12345))
	end,
	forEachNeighbor = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		cs:createNeighborhood()
		local cell = cs:sample()

		local error_func = function()
			forEachNeighbor(nil, function() end)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "Cell"))

		error_func = function()
			forEachNeighbor(cell)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "function or string"))

		error_func = function()
			forEachNeighbor(cell, "1")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(3, "function"))

		error_func = function()
			forEachNeighbor(cell, "2", function() end)
		end
		unitTest:assert_error(error_func, "Neighborhood '2' does not exist.")
	end,
	forEachNeighborhood = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			forEachNeighborhood(nil, function() end)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "Cell"))

		error_func = function()
			forEachNeighborhood(cs:sample())
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "function"))
	end,
	forEachOrderedElement = function(unitTest)
		local error_func = function()
			forEachOrderedElement()
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			forEachOrderedElement({1, 2, 3})
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "function"))
	end,
	getn = function(unitTest)
		local error_func = function()
			getn("2")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "table", "2"))
	end,
	greaterByAttribute = function(unitTest)
		local error_func = function()
			local gt = greaterByAttribute(2)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "string", 2))

		error_func = function()
			local gt = greaterByAttribute("cover", "==")
		end
		unitTest:assert_error(error_func, incompatibleValueMsg(2, "<, >, <=, or >=", "=="))
	end,
	greaterByCoord = function(unitTest)
		local error_func = function()
			local gt = greaterByCoord("==")
		end
		unitTest:assert_error(error_func, incompatibleValueMsg(1, "<, >, <=, or >=", "=="))
	end,
	levenshtein = function(unitTest)
		local error_func = function()
			local gt = levenshtein(2)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "string", 2))
	
		error_func = function()
			local gt = levenshtein("abc", 2)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "string", 2))
	end,
	round = function(unitTest)
		local error_func = function()
			x = round("a")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "number", "a"))

		error_func = function()
			x = round(2.5, "a")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "number", "a"))
	end
	-- TODO: implement forEachSocialNetwork
}

