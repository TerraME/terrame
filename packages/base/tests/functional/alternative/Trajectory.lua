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
	Trajectory = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			trajectory = Trajectory()
		end
		unitTest:assertError(error_func, tableArgumentMsg())

		error_func = function()
			trajectory = Trajectory(3)
		end
		unitTest:assertError(error_func, namedArgumentsMsg())

		local traj
		local warning_func = function()
			traj = Trajectory{
				target = cs,
				selection = function() return true end
			}
		end

		unitTest:assertWarning(warning_func, unnecessaryArgumentMsg("selection", "select"))
		unitTest:assertEquals(#traj, #cs)

		error_func = function()
			trajectory = Trajectory{}
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg("target"))

		error_func = function()
			trajectory = Trajectory{
				target = "cs"
			}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("target", "CellularSpace or Trajectory", "cs"))

		-- build
		error_func = function()
			trajectory = Trajectory{
				target = cs,
				build = "build"
			}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("build", "boolean", "build"))

		warning_func = function()
			traj = Trajectory{
				target = cs,
				build = true
			}
		end

		unitTest:assertWarning(warning_func, defaultValueMsg("build", true))
		unitTest:assertEquals(#traj, #cs)

		warning_func = function()
			traj = Trajectory{
				target = cs,
				random = false
			}
		end

		unitTest:assertWarning(warning_func, defaultValueMsg("random", false))
		unitTest:assertEquals(#traj, #cs)

		error_func = function()
			Trajectory{
				target = cs,
				random = true,
				greater = function() return true end
			}
		end
		unitTest:assertError(error_func, "It is not possible to use arguments 'greater' and 'random' at the same time.")

		-- greater
		error_func = function()
			trajectory = Trajectory{
				target = cs,
				greater = "func"
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("greater", "function", "func"))

		-- select
		error_func = function()
			trajectory = Trajectory{
				target = cs,
				select = "func"
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("select", "function", "func"))
	end,
	add = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		local trajectory = Trajectory{target = cs}

		local error_func = function()
			trajectory:add(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Cell", 2))

		error_func = function()
			trajectory:add(cs.cells[1])
		end
		unitTest:assertError(error_func, "Cell (0, 0) already belongs to the Trajectory.")
	end,
	filter = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		local trajectory = Trajectory{
			target = cs
		}

		local error_func = function()
			trajectory:filter("filter")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "function", "filter"))
	end,
	get = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		local trajectory = Trajectory{target = cs}

		local error_func = function()
			trajectory:get()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			trajectory:get(2)
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			trajectory:get("a")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "number", "a"))

		error_func = function()
			trajectory:get(1, "a")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "number", "a"))
	end,
	sort = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		local trajectory = Trajectory{target = cs}

		local error_func = function()
			trajectory:sort("func")
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "function", "func"))

		error_func = function()
			trajectory:sort()
		end

		unitTest:assertWarning(error_func, "Cannot sort the Trajectory because there is no previous function.")
	end
}

