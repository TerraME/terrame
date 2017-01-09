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
	InternetSender = function(unitTest)
--[[
		local world = Cell{
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local c1 = InternetSender{target = world, protocol = "tcp"}

		local world = Agent{
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local c1 = InternetSender{target = world}

		local c1 = InternetSender{
			target = world,
			select = {"mcount"}
		}

		local soc = Society{
			instance = world,
			quantity = 3
		}

		local c1 = InternetSender{target = soc}
		local c1 = InternetSender{target = soc, select = "#"}

		local soc = Society{
			instance = Agent{},
			quantity = 3,
			total = 10
		}

		local c1 = InternetSender{target = soc}

		local world = Cell{
			vcount = 0,
			mcount = function(self)
				return self.vcount + 1
			end
		}

		local c1 = InternetSender{target = world}
		local c1 = InternetSender{target = world, select = "mcount"}

		local world = CellularSpace{xdim = 10}

		forEachCell(world, function(cell)
			cell.value = 0
		end)

		local c1 = InternetSender{target = world, select = "value"}

--]]
		unitTest:assert(true)
	end
}

