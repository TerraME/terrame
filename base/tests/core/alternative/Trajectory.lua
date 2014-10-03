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
	add = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		local trajectory = Trajectory{target = cs}

		local error_func = function()
			trajectory:add(2)
		end

		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#2' expected Cell, got number.")
	end,
	addCell = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		local trajectory = Trajectory{target = cs}

		local error_func = function()
			trajectory:addCell()
		end

		unitTest:assert_error(error_func, "Error: Function 'addCell' is deprecated. Use 'add' instead.")
	end,
	filter = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		local trajectory = Trajectory{
			target = cs
		}
		local error_func = function()
			trajectory:filter("filter")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected function or nil, got string.")
	end,
	getCell = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		local trajectory = Trajectory{target = cs}

		local error_func = function()
			trajectory:getCell()
		end

		unitTest:assert_error(error_func, "Error: Function 'getCell' is deprecated. Use 'get' instead.")
	end,
	sort = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		local trajectory = Trajectory{target = cs}

		local error_func = function()
			trajectory:sort("func")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected function or nil, got string.")
	end,
	Trajectory = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			trajectory = Trajectory()
		end
		unitTest:assert_error(error_func, "Error: Parameter must be a table.")

		local error_func = function()
			trajectory = Trajectory(3)
		end
		unitTest:assert_error(error_func, "Error: Parameters must be named.")

		error_func = function()
 			local traj = Trajectory{
 				target = cs,
 				selection = function() return true end
 			}
 		end
		unitTest:assert_error(error_func, "Error: Parameter 'selection' is unnecessary.")

		local error_func = function()
			trajectory = Trajectory{}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'target' is mandatory.")

		error_func = function()
			trajectory = Trajectory{
				target = "cs"
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'target' expected CellularSpace or Trajectory, got string.")

		-- build
		error_func = function()
			trajectory = Trajectory{
				target = cs,
				build = "build"
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'build' expected boolean, got string.")

		error_func = function()
			local traj = Trajectory{
				target = cs,
				build = true
			}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'build' could be removed as it is the default value (true).")

		-- greater
		error_func = function()
			trajectory = Trajectory{
				target = cs,
				greater = "func"
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'greater' expected function or nil, got string.")

		-- select
		error_func = function()
			trajectory = Trajectory{
				target = cs,
				select = "func"
			}
		end
		unitTest:assert_error(error_func,"Error: Incompatible types. Parameter 'select' expected function or nil, got string.")
	end
}

