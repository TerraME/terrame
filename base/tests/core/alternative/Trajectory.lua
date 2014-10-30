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

		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "Cell", 2))
	end,
	addCell = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		local trajectory = Trajectory{target = cs}

		local error_func = function()
			trajectory:addCell()
		end

		unitTest:assert_error(error_func, deprecatedFunctionMsg("addCell", "add"))
	end,
	filter = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		local trajectory = Trajectory{
			target = cs
		}
		local error_func = function()
			trajectory:filter("filter")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "function or nil", "filter"))
	end,
	getCell = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		local trajectory = Trajectory{target = cs}

		local error_func = function()
			trajectory:getCell()
		end

		unitTest:assert_error(error_func, deprecatedFunctionMsg("getCell", "get"))
	end,
	sort = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		local trajectory = Trajectory{target = cs}

		local error_func = function()
			trajectory:sort("func")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "function or nil", "func"))
	end,
	Trajectory = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			trajectory = Trajectory()
		end
		unitTest:assert_error(error_func, tableParameterMsg())

		local error_func = function()
			trajectory = Trajectory(3)
		end
		unitTest:assert_error(error_func, namedParametersMsg())

		error_func = function()
 			local traj = Trajectory{
 				target = cs,
 				selection = function() return true end
 			}
 		end
		unitTest:assert_error(error_func, unnecessaryParameterMsg("selection"))

		local error_func = function()
			trajectory = Trajectory{}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("target"))

		error_func = function()
			trajectory = Trajectory{
				target = "cs"
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("target", "CellularSpace or Trajectory", "cs"))

		-- build
		error_func = function()
			trajectory = Trajectory{
				target = cs,
				build = "build"
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("build", "boolean", "build"))

		error_func = function()
			local traj = Trajectory{
				target = cs,
				build = true
			}
		end
		unitTest:assert_error(error_func, defaultValueMsg("build", true))

		-- greater
		error_func = function()
			trajectory = Trajectory{
				target = cs,
				greater = "func"
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("greater", "function or nil", "func"))

		-- select
		error_func = function()
			trajectory = Trajectory{
				target = cs,
				select = "func"
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("select", "function or nil", "func"))
	end
}

