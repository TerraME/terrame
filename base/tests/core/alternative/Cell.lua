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
	Cell = function(unitTest)
		local cell = Cell{y = 0}
		unitTest:assert_equal(0, cell.x)

		local error_func = function()
			cell = Cell{x = 2.22, y = 0}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'x' expected positive integer number, got 2.22.")

		error_func = function()
			cell = Cell{x = -2, y = 1}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'x' expected positive integer number, got -2.")

		cell = Cell{x = 1}
		unitTest:assert_equal(0, cell.y)

		error_func = function()
			cell = Cell{x = 1, y = 2.22}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'y' expected positive integer number, got 2.22.")

		error_func = function()
			cell = Cell{x = 1, y = -2}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'y' expected positive integer number, got -2.")
	end,
	addNeighborhood = function(unitTest)
		local cell = Cell{x = 1, y = 1}
		local n = Neighborhood()

		local error_func = function()
			unitTest:assert_false(cell:addNeighborhood())
		end
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")

		error_func = function()
			unitTest:assert_false(cell:addNeighborhood(123))
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Neighborhood, got number.")

		error_func = function()
			cell:addNeighborhood(n, 123)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#2' expected string, got number.")
	end,
	distance = function(unitTest)
	end,
	getAgent = function(unitTest)
		local c = Cell{}
		c.friends = 2

		local error_func = function()
			c:getAgent()
		end
		unitTest:assert_error(error_func, "Error: Placement 'placement' does not exist. Use Environment:createPlacement first.")

		local error_func = function()
			c:getAgent("friends")
		end
		unitTest:assert_error(error_func, "Error: Placement 'friends' should be a Group, got number.")
	end,			
	getAgents = function(unitTest)
		local c = Cell{}
		c.friends = 2

		local error_func = function()
			c:getAgents()
		end
		unitTest:assert_error(error_func, "Error: Placement 'placement' does not exist. Use Environment:createPlacement first.")

		local error_func = function()
			c:getAgents("friends")
		end
		unitTest:assert_error(error_func, "Error: Placement 'friends' should be a Group, got number.")
	end,
	distance = function(unitTest)
		local c = Cell{}

		local error_func = function()
			c:distance()
		end
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")

		local error_func = function()
			c:distance(12345)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Cell, got number.")
	end,
	isEmpty = function(unitTest)
		local c = Cell{}
		c.friends = 2

		local error_func = function()
			c:isEmpty()
		end
		unitTest:assert_error(error_func, "Error: Placement 'placement' does not exist. Use Environment:createPlacement first.")

		local error_func = function()
			c:isEmpty("friends")
		end
		unitTest:assert_error(error_func, "Error: Placement 'friends' should be a Group, got number.")
	end,
	sample = function(unitTest)
		local c = Cell{}

		local error_func = function()
			c:sample()
		end
		unitTest:assert_error(error_func, "Error: Cell does not have a Neighborhood named '1'.")
	end,
	size = function(unitTest)
		local c = Cell{}

		local error_func = function()
			c:size()
		end
		unitTest:assert_error(error_func, "Error: Function 'size' is deprecated. Use 'operator #' instead.")
	end,
	getNeighborhood = function(unitTest)
		local cell = Cell{x = 1, y = 1}
		local n = Neighborhood()
		cell:addNeighborhood(n, "name")

		local error_func = function()
			n1 = cell:getNeighborhood(1)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected string, got number.")
	end,
	notify = function(unitTest)
		local cell = Cell{x = 1, y = 1}

		local error_func = function()
			cell:notify("not_int")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Event or positive number, got string.")

		error_func = function()
			cell:notify(-1)
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter '#1' expected Event or positive number, got -1.")
	end
}

