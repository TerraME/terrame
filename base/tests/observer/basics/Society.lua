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
	Society = function(unitTest)
		local ag = Agent{
		    height = 1,
			grow = function(self)
				self.height = self.height + 1
			end
		}

		local soc = Society{
			instance = ag,
			quantity = 10,
			value = 5
		}

		local c1 = Chart{subject = soc}
		unitTest:assert_type(c1, "Chart")

		local c2 = Chart{subject = soc, select = {"value", "height"}}
		unitTest:assert_type(c2, "Chart")

		soc:notify(0)

		local t = Timer{
		    Event{action = function(e)
				for i = 1, e:getTime() do
					soc:grow()
					soc:add()
					soc.value = soc.value + 1
				end
		        soc:notify(e)
		    end}
		}

		TextScreen{subject = soc}
--		LogFile{subject = soc} -- #215
		VisualTable{subject = soc}
		t:execute(30)
		unitTest:assert_snapshot(c1, "chart_society.bmp")
		unitTest:assert_snapshot(c2, "chart_society_select.bmp")
		unitTest:delay()
	end
}

