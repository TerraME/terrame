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
		unitTest:assert_error(error_func, "Error: Parameter for 'Group' must be a table.")

		error_func = function()
			group1 = Group(3)
		end
		unitTest:assert_error(error_func, "Error: Parameters for 'Group' must be named.")

		error_func = function()
 			local gr = Group{
 				target = sc1,
 				selection = function() return true end
 			}
 		end
		unitTest:assert_error(error_func, "Error: Parameter 'selection' is unnecessary.")

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
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'target' expected Society, Group, or nil, got CellularSpace.")

		error_func = function()
			group1 = Group{
				target = sc1,
				build = 15
			}
		end
		unitTest:assert_error(error_func,"Error: Incompatible types. Parameter 'build' expected boolean, got number.")

		error_func = function()
			group1 = Group{
				target = sc1,
				build = true
			}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'build' could be removed as it is the default value (true).")

		error_func = function()
			group1 = Group{
				target = sc1,
				select = 12,
				greater = function(a, b)
					return a.money > b.money 
				end
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'select' expected function or nil, got number.")

		error_func = function()
			group1 = Group{
				target = sc1,
				select = function(ag1)
					return ag1.money > 90
				end,
				greater = 12
			}
		end
		unitTest:assert_error(error_func,"Error: Incompatible types. Parameter 'greater' expected function or nil, got number.")
	end,
	add = function(unitTest)
		local group = Group{}

		local error_func = function()
			group:add()
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Agent, got nil.")

		error_func = function()
			group:add("wrongType")
		end
		unitTest:assert_error(error_func,"Error: Incompatible types. Parameter '#1' expected Agent, got string.")
	end,
	filter = function(unitTest)
		local group = Group{}
		local error_func = function()
			group:filter("notFunction")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected function or nil, got string.")

		error_func = function()
			group:filter(function() return true end)
		end
		unitTest:assert_error(error_func, "Error: It is not possible to filter a Group without a parent.")
	end,
	sort = function(unitTest)
		local group = Group{}
		local error_func = function()
			group:sort("notFunction")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected function or nil, got string.")
	end
}

