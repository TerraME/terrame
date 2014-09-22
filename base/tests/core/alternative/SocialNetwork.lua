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
-- indirect, special, incidental, or caonsequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Pedro R. Andrade
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

return{
	add = function(unitTest)
		local sn = SocialNetwork()
		local ag1 = Agent{}
		local ag2 = Agent{id = "2"}

		local error_func = function()
			sn:add()
		end
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")

		error_func = function()
			sn:add(112)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Agent, got number.")

		error_func = function()
			sn:add(ag1, "not_number")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#2' expected positive number, got string.")

		error_func = function()
			sn:add(ag1, -1)
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter '#2' expected positive number, got -1.")

		local error_func = function()
			sn:add(ag1)
		end
		unitTest:assert_error(error_func, "Error: Agent should have an id in order to be added to a SocialNetwork.")

		local error_func = function()
			sn:add(ag2)
			sn:add(ag2)
		end
		unitTest:assert_error(error_func, "Error: Agent '2' already belongs to the SocialNetwork.")
	end,
	getWeight = function(unitTest)
		local ag1 = Agent{id = "1"}
		local ag2 = Agent{}
		local sn = SocialNetwork()
		local cell = Cell{}

		local error_func = function()
			sn:getWeight()
		end
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")

		error_func = function()
			sn:getWeight(cell)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Agent, got Cell.")

		error_func = function()
			sn:getWeight(ag2)
		end
		unitTest:assert_error(error_func, "Error: Agent does not belong to the SocialNetwork because it does not have an id.")

		error_func = function()
			sn:getWeight(ag1)
		end
		unitTest:assert_error(error_func, "Error: Agent '1' does not belong to the SocialNetwork.")
	end,
	isConnection = function(unitTest)
		local ag1 = Agent{id = "1"}
		local sn = SocialNetwork()

		local error_func = function()
			sn:isConnection()
		end
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")
		
		error_func = function()
			sn:isConnection(123)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Agent, got number.")
	end,
	remove = function(unitTest)
		local ag1 = Agent{id = "1"}
		local sn = SocialNetwork()

		local error_func = function()
			sn:remove()
		end
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")

		error_func = function()
			sn:remove(123)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Agent, got number.")

		error_func = function()
			sn:remove(123)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Agent, got number.")

		local error_func = function()
			sn:remove(ag1)
		end
		unitTest:assert_error(error_func, "Error: Trying to remove an Agent that does not belong to the SocialNetwork.")
	end,
	sample = function(unitTest)
		local sn = SocialNetwork()
		local a = Agent{id = "1"}

		local error_func = function()
			sn:sample()
		end
		unitTest:assert_error(error_func, "Error: It is not possible to sample the SocialNetwork because it is empty.")

		sn:add(a)
		error_func = function()
			sn:sample(2)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Random or nil, got number.")
	end,
	setWeight = function(unitTest)
		local ag1 = Agent{id = "1"}
		local ag2 = Agent{}
		local sn = SocialNetwork()
		local cell = Cell{}

		local error_func = function()
			sn:setWeight()
		end
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")

		error_func = function()
			sn:setWeight(cell)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Agent, got Cell.")

		error_func = function()
			sn:setWeight(ag1)
		end
		unitTest:assert_error(error_func, "Error: Parameter '#2' is mandatory.")

		error_func = function()
			sn:setWeight(ag1, "notnumber")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#2' expected positive number, got string.")

		error_func = function()
			sn:setWeight(ag1, -1)
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter '#2' expected positive number, got -1.")

		error_func = function()
			sn:setWeight(ag2, 0.5)
		end
		unitTest:assert_error(error_func, "Error: Agent does not belong to the SocialNetwork because it does not have an id.")

		error_func = function()
			sn:setWeight(ag1, 0.5)
		end
		unitTest:assert_error(error_func, "Error: Agent '1' does not belong to the SocialNetwork.")
	end,
	SocialNetwork = function(unitTest)
		local error_func = function()
			sn = SocialNetwork(2)
		end
		-- TODO: melhorar este erro abaixo
		unitTest:assert_error(error_func, "Error: Parameters for 'SocialNetwork' must be named.")

		local error_func = function()
			sn = SocialNetwork{id = "3"}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'id' is unnecessary.")
	end
}

