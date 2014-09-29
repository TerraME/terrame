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
-------------------------------------------------------------------------------------------

return{
	CellularSpace = function(unitTest)
		local unit = Cell{
			count = 0
		}

		local world = CellularSpace{
			xdim = 10,
			value = 10,
			instance = unit
		}

		local c = Chart{subject = world}

		unitTest:assert_type(c, "number")

		world:notify(0)

		local t = Timer{
			Event{action = function(e)
				world.value = world.value + 99
				forEachCell(world, function(cell)
					cell.count = cell.count + 1
				end)
				world:notify(e)
			end}
		}

		t:execute(30)
	--[[
		world = CellularSpace{
			xdim = 10
		}

		Map{
			subject = world,
			select  = "x",
			colors  = "Blues",
			values  = {0, 10}
		}

		world:notify()
	end
	--]]
		unitTest:delay()
	end
}

