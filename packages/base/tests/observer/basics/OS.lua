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
	sessionInfo = function(unitTest)
		sessionInfo().graphics = false

		local c = Chart{
		    target = {value = 2}
		}

		unitTest:assertType(c, "Chart")
		unitTest:assertNil(c.parent)
		c:update()

		local error_func = function()
			c:save("abc.png")
		end
		unitTest:assertError(error_func, "It is not possible to call 'save' with graphics disabled.")

		local cs = CellularSpace{xdim = 10}

		local m = Map{
			target = cs
		}

		unitTest:assertType(m, "Map")
		unitTest:assertNil(m.parent)
		m:update()

		error_func = function()
			m:save("abc.png")
		end
		unitTest:assertError(error_func, "It is not possible to call 'save' with graphics disabled.")

		local timer

		timer = Timer{
			ev1 = Event{action = function() timer:notify() end},
		}

		c = Clock{target = timer}

		unitTest:assertType(c, "Clock")
		unitTest:assertNil(c.parent)
		c:update()

		error_func = function()
			c:save("abc.png")
		end
		unitTest:assertError(error_func, "It is not possible to call 'save' with graphics disabled.")

		local world = Cell{
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local ts = TextScreen{target = world}

		unitTest:assertType(ts, "TextScreen")
		unitTest:assertNil(ts.parent)
		ts:update()

		error_func = function()
			ts:save("abc.png")
		end
		unitTest:assertError(error_func, "It is not possible to call 'save' with graphics disabled.")

		world = Cell{
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local vt1 = VisualTable{target = world}

		unitTest:assertType(vt1, "VisualTable")
		unitTest:assertNil(vt1.parent)
		vt1:update()

		error_func = function()
			vt1:save("abc.png")
		end
		unitTest:assertError(error_func, "It is not possible to call 'save' with graphics disabled.")

		sessionInfo().graphics = true

		c = Chart{
		    target = DataFrame{value = {2}}
		}

		unitTest:assertSnapshot(c, "enable_graphics_chart.png", 0.05)

		cs = CellularSpace{xdim = 10}

		Map{
			target = cs
		}

		unitTest:assertSnapshot(c, "enable_graphics_map.png", 0.05)

		timer = Timer{
			ev1 = Event{action = function() timer:notify() end},
		}

		c = Clock{target = timer}

		unitTest:assertSnapshot(c, "enable_graphics_clock.png", 0.45)

		world = Cell{
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		ts = TextScreen{target = world}

		unitTest:assertSnapshot(ts, "enable_graphics_textscreen.png", 0.05)

		world = Cell{
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		vt1 = VisualTable{target = world}

		unitTest:assertSnapshot(vt1, "enable_graphics_visualtable.png", 0.2)
	end
}

