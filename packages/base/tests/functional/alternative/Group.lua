-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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
	Group = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local boi = Agent{
			energy = 20,
			init = function(self)
				self.money = Random():integer(100)
			end
		}

		local sc1 = Society{
			instance = boi,
			quantity = 20
		}

		local error_func = function()
			group1 = Group()
		end
		unitTest:assertError(error_func, tableArgumentMsg())

		error_func = function()
			group1 = Group(3)
		end
		unitTest:assertError(error_func, namedArgumentsMsg())

		error_func = function()
 			Group{
 				target = sc1,
 				selection = function() return true end
 			}
 		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("selection", "select"))

		error_func = function()
			group1 = Group{
				target = cs,
				select = function(ag1)
					return ag1.money > 90
				end,
				greater = function(ag1, ag2)
					return ag1.money > ag2.money 
				end
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("target", "Society, Group, or nil", cs))

		error_func = function()
			group1 = Group{
				target = sc1,
				build = 15
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("build", "boolean", 15))

		error_func = function()
			group1 = Group{
				target = sc1,
				build = true
			}
		end
		unitTest:assertError(error_func, defaultValueMsg("build", true))

		error_func = function()
			group1 = Group{
				target = sc1,
				random = false
			}
		end
		unitTest:assertError(error_func, defaultValueMsg("random", false))

		error_func = function()
			group1 = Group{
				target = sc1,
				random = true,
				greater = function() return true end
			}
		end
		unitTest:assertError(error_func, "It is not possible to use arguments 'greater' and 'random' at the same time.")

		error_func = function()
			group1 = Group{
				target = sc1,
				select = 12,
				greater = function(a, b)
					return a.money > b.money 
				end
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("select", "function", 12))

		error_func = function()
			group1 = Group{
				target = sc1,
				select = function(ag1)
					return ag1.money > 90
				end,
				greater = 12
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("greater", "function", 12))
	end,
	add = function(unitTest)
		local group = Group{}

		local error_func = function()
			group:add()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			group:add("wrongType")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Agent", "wrongType"))
	end,
	filter = function(unitTest)
		local group = Group{}
		local error_func = function()
			group:filter("notFunction")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "function", "notFunction"))

		error_func = function()
			group:filter(function() return true end)
		end
		unitTest:assertError(error_func, "It is not possible to filter a Group without a parent.")
	end,
	sort = function(unitTest)
		local group = Group{}
		local error_func = function()
			group:sort("notFunction")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "function", "notFunction"))

		error_func = function()
			group:sort()
		end
		unitTest:assertError(error_func, "Cannot sort the Group because there is no previous function.")
	end
}

