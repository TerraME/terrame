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
-- FIXME: if the following lines were uncommented together with the next test, TerraME aborts
--[[
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
--]]

		-- FIXME: this observer does not draw the cells in the screen here.
		-- If one copies the script below to a separate file it works.
		-- FIXME: it also generates a warning: -- FIXED
		-- libpng warning: iCCP: known incorrect sRGB profile

	-- FIXME: because of this test, we get an internal error:
	-- libc++abi.dylib: Pure virtual function called! -> TODO - RAIAN: I was not able to reproduce this error
		local world = CellularSpace{
			xdim = 10
		}

		forEachCell(world, function(cell)
			if math.random() > 0.6 then
				cell.value = 1
			else
				cell.value = 0
			end
		end)

		local l = Legend{
            grouping = "equalsteps",
            colorBar = {
				{value = 0, color = "red"},
				{value = 1, color = "blue"}
			},
    	}

		Observer{
			type = "map",
			subject = world,
			attributes = {"value"},
			legends = {l}
		}

		world:notify()
		world:notify()
		world:notify()



--[[
		Map{
			subject = world,
			grouping = "uniquevalues",
			select  = "value",
			colors  = {{0, 0, 0}, {255, 255, 255}},
			values = {0, 1}
		}

		Map{
			subject = world,
			grouping = "uniquevalues",
			select  = "value",
			colors  = {"blue", "red"},
			values = {0, 1}
		}
--]]
--[[
		Map{
			subject = world,
			select  = "x",
			colors  = {"blue", "red"},
			min = 0,
			max = 10
		}
--]]
		--world:notify()
		unitTest:assert(true)
		unitTest:delay()
	end
}

