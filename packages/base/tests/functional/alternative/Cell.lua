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
	Cell = function(unitTest)
		local error_func = function()
			Cell(2)
		end
		unitTest:assertError(error_func, namedArgumentsMsg())

		error_func = function()
			Cell{x = "2.22", y = 0}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("x", "number", "2.22"))

		error_func = function()
			Cell{x = -2, y = "1"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("y", "number", "1"))

		error_func = function()
			Cell{x = 2.22, y = 0}
		end
		unitTest:assertError(error_func, integerArgumentMsg("x", 2.22))

		error_func = function()
			Cell{x = -2.3, y = 1}
		end
		unitTest:assertError(error_func, integerArgumentMsg("x", -2.3))

		error_func = function()
			Cell{x = 1, y = 2.22}
		end
		unitTest:assertError(error_func, integerArgumentMsg("y", 2.22))

		error_func = function()
			Cell{x = 1, y = -2.3}
		end
		unitTest:assertError(error_func, integerArgumentMsg("y", -2.3))

		error_func = function()
			Cell{id = 2.3}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("id", "string", 2.3))

	end,
	addNeighborhood = function(unitTest)
		local cell = Cell{x = 1, y = 1}
		local n = Neighborhood()

		local error_func = function()
			cell:addNeighborhood()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			cell:addNeighborhood(123)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Neighborhood", 123))

		error_func = function()
			cell:addNeighborhood(n, 123)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 123))
	end,
	distance = function(unitTest)
		local c = Cell{}

		local error_func = function()
			c:distance()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			c:distance(12345)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Cell", 12345))
	end,
	getAgent = function(unitTest)
		local c = Cell{}
		c.friends = 2

		local error_func = function()
			c:getAgent()
		end
		unitTest:assertError(error_func, "The Cell does not have a default placement. Please call Environment:createPlacement() first.")

		error_func = function()
			c:getAgent("abc123")
		end
		unitTest:assertError(error_func, "Placement 'abc123' does not exist. Please call Environment:createPlacement() first.")

		error_func = function()
			c:getAgent("friends")
		end
		unitTest:assertError(error_func, "Placement 'friends' should be a Group, got number.")
	end,
	getAgents = function(unitTest)
		local c = Cell{}
		c.friends = 2

		local error_func = function()
			c:getAgents()
		end
		unitTest:assertError(error_func, "The Cell does not have a default placement. Please call Environment:createPlacement() first.")

		error_func = function()
			c:getAgent("abc123")
		end
		unitTest:assertError(error_func, "Placement 'abc123' does not exist. Please call Environment:createPlacement() first.")


		error_func = function()
			c:getAgents("friends")
		end
		unitTest:assertError(error_func, "Placement 'friends' should be a Group, got number.")
	end,
	getNeighborhood = function(unitTest)
		local cell = Cell{x = 1, y = 1}
		local n = Neighborhood()
		cell:addNeighborhood(n, "name")

		local error_func = function()
			n1 = cell:getNeighborhood(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
	end,
	isEmpty = function(unitTest)
		local c = Cell{}
		c.friends = 2

		local error_func = function()
			c:isEmpty()
		end
		unitTest:assertError(error_func, "The Cell does not have a default placement. Please call Environment:createPlacement() first.")

		error_func = function()
			c:isEmpty("friends")
		end
		unitTest:assertError(error_func, "Placement 'friends' should be a Group, got number.")
	end,
	notify = function(unitTest)
		local cell = Cell{x = 1, y = 1}

		local error_func = function()
			cell:notify("not_int")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "number", "not_int"))

		error_func = function()
			cell:notify(-1)
		end
		unitTest:assertError(error_func, positiveArgumentMsg(1, -1, true))
	end,
	sample = function(unitTest)
		local c = Cell{}

		local error_func = function()
			c:sample()
		end
		unitTest:assertError(error_func, "Cell does not have a Neighborhood named '1'.")
	end
}

