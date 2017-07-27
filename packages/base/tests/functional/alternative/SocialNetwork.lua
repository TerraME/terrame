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
	add = function(unitTest)
		local sn = SocialNetwork()
		local ag1 = Agent{}

		local error_func = function()
			sn:add()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			sn:add(112)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Agent", 112))

		error_func = function()
			sn:add(ag1, "not_number")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "number", "not_number"))

		error_func = function()
			sn:add(ag1)
		end

		unitTest:assertError(error_func, "Agent should have an id in order to be added to a SocialNetwork.")

		ag1 = Agent{id = "1"}
		sn:add(ag1)

		error_func = function()
			sn:add(ag1)
		end

		unitTest:assertError(error_func, "Agent '1' already belongs to the SocialNetwork.")
	end,
	getWeight = function(unitTest)
		local ag1 = Agent{id = "1"}
		local ag2 = Agent{}
		local sn = SocialNetwork()
		local cell = Cell{}

		local error_func = function()
			sn:getWeight()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			sn:getWeight(cell)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Agent", cell))

		error_func = function()
			sn:getWeight(ag2)
		end

		unitTest:assertError(error_func, "Agent does not belong to the SocialNetwork because it does not have an id.")

		error_func = function()
			sn:getWeight(ag1)
		end

		unitTest:assertError(error_func, "Agent '1' does not belong to the SocialNetwork.")
	end,
	isConnection = function(unitTest)
		local sn = SocialNetwork()

		local error_func = function()
			sn:isConnection()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			sn:isConnection(123)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Agent", 123))
	end,
	remove = function(unitTest)
		local sn = SocialNetwork()

		local error_func = function()
			sn:remove()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			sn:remove(123)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Agent", 123))
	end,
	sample = function(unitTest)
		local sn = SocialNetwork()

		local error_func = function()
			sn:sample()
		end

		unitTest:assertError(error_func, "It is not possible to sample the SocialNetwork because it is empty.")
	end,
	setWeight = function(unitTest)
		local ag1 = Agent{id = "1"}
		local ag2 = Agent{}
		local sn = SocialNetwork()
		local cell = Cell{}

		local error_func = function()
			sn:setWeight()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			sn:setWeight(cell)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Agent", cell))

		error_func = function()
			sn:setWeight(ag1)
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			sn:setWeight(ag1, "notnumber")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "number", "notnumber"))

		error_func = function()
			sn:setWeight(ag2, 0.5)
		end

		unitTest:assertError(error_func, "Agent does not belong to the SocialNetwork because it does not have an id.")

		error_func = function()
			sn:setWeight(ag1, 0.5)
		end

		unitTest:assertError(error_func, "Agent '1' does not belong to the SocialNetwork.")
	end
}

