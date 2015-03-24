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
	TextScreen = function(unitTest)
		local world = Cell{
		    count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local c1 = TextScreen{subject = world}

		local world = Agent{
		    count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local c1 = TextScreen{subject = world}

		local c1 = TextScreen{
			subject = world,
			select = {"mcount"}
		}

		local soc = Society{
			instance = world,
			quantity = 3
		}

		local c1 = TextScreen{subject = soc}
		local c1 = TextScreen{subject = soc, select = "#"}

		local world = CellularSpace{
			xdim = 10,
		    count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local c1 = TextScreen{subject = world}
		local c1 = TextScreen{subject = world, select = "mcount"}

		unitTest:assert(true)
	end
}

