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
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

return{
	add = function(unitTest)
		local neigh = Neighborhood()
		local cell1 = Cell{}
		local cell2 = Cell{x = 0, y = 1}

		local error_func = function()
			neigh:add()
		end
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")

		error_func = function()
			neigh:add(112)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Cell, got number.")

		error_func = function()
			neigh:add(cell1, "not_number")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#2' expected number, got string.")

		local error_func = function()
			neigh:add(cell2)
			neigh:add(cell2)
		end
		unitTest:assert_error(error_func, "Error: Cell (0,1) already belongs to the Neighborhood.")
	end,
	getWeight = function(unitTest)
		local cell1 = Cell{x = 0, y = 0}
		local cell2 = Cell{x = 0, y = 1}
		local neigh = Neighborhood()

		local error_func = function()
			neigh:getWeight()
		end
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")

		error_func = function()
			neigh:getWeight(12345)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Cell, got number.")

		error_func = function()
			neigh:getWeight(cell1)
		end
		unitTest:assert_error(error_func, "Error: Cell (0,0) does not belong to the Neighborhood.")
	end,
	isNeighbor = function(unitTest)
		local cell1 = Cell{}
		local neigh = Neighborhood()

		local error_func = function()
			neigh:isNeighbor()
		end
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")
		
		error_func = function()
			neigh:isNeighbor(123)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Cell, got number.")
	end,
	Neighborhood = function(unitTest)
		local error_func = function()
			neigh = Neighborhood(2)
		end
		unitTest:assert_error(error_func, "Error: Parameters for 'Neighborhood' must be named.")

		local error_func = function()
			neigh = Neighborhood{id = "1"}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'id' is unnecessary.")
	end,
	remove = function(unitTest)
		local cell1 = Cell{}
		local neigh = Neighborhood()

		local error_func = function()
			neigh:remove()
		end
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")

		error_func = function()
			neigh:remove(123)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Cell, got number.")

		error_func = function()
			neigh:remove(123)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Cell, got number.")

		local error_func = function()
			neigh:remove(cell1)
		end
		unitTest:assert_error(error_func, "Error: Trying to remove a Cell that does not belong to the Neighborhood.")
	end,
	sample = function(unitTest)
		local neigh = Neighborhood()
		local c = Cell{}

		local error_func = function()
			neigh:sample()
		end
		unitTest:assert_error(error_func, "Error: It is not possible to sample the Neighborhood because it is empty.")

		neigh:add(c)

		error_func = function()
			neigh:sample(2)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Random or nil, got number.")
	end,
	setWeight = function(unitTest)
		local cell1 = Cell{}
		local cell2 = Cell{}
		local neigh = Neighborhood()

		local error_func = function()
			neigh:setWeight()
		end
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")

		error_func = function()
			neigh:setWeight(12345)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Cell, got number.")

		error_func = function()
			neigh:setWeight(cell1)
		end
		unitTest:assert_error(error_func, "Error: Parameter '#2' is mandatory.")

		error_func = function()
			neigh:setWeight(cell1, "notnumber")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#2' expected number, got string.")

		error_func = function()
			neigh:setWeight(cell1, 0.5)
		end
		unitTest:assert_error(error_func, "Error: Cell (0,0) does not belong to the Neighborhood.")

	end
}

