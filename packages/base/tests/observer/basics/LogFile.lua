-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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
	LogFile = function(unitTest)
		local world = Cell{
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local log = LogFile{target = world}

		unitTest:assertType(log, "LogFile")

		world:notify()
		world:notify()

		unitTest:assertFile("result.csv")

		local world2 = Cell{
			count = 2
		}

		local log2 = LogFile{target = world2, overwrite = false, file = "logfile-1.csv"}

		unitTest:assertType(log2, "LogFile")

		world2:notify()

		local log2 = LogFile{target = world2, overwrite = false, file = "logfile-1.csv"}
		world2:notify()
		world2:notify()

		unitTest:assertFile("logfile-1.csv")

		local world = Agent{
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local log = LogFile{
			target = world,
			file = "logfile-2.csv",
			separator = ";",
			overwrite = false
		}

		world:notify()
		world:notify()

		unitTest:assertFile("logfile-2.csv")

		local world = Agent{
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local log = LogFile{
			target = world,
			select = {"mcount"},
			file = "logfile-3.csv"
		}

		world:notify()
		unitTest:assertFile("logfile-3.csv")

		local soc = Society{
			instance = world,
			quantity = 3
		}

		local log = LogFile{
			target = soc,
			file = "logfile-4.csv"
		}

		soc:notify()
		unitTest:assertFile("logfile-4.csv")

		local log = LogFile{
			target = soc,
			select = "#",
			file = "logfile-5.csv"
		}

		soc:notify()
		unitTest:assertFile("logfile-5.csv")

		local soc = Society{
			instance = Agent{},
			quantity = 3,
			total = 10
		}

		local log = LogFile{
			target = soc,
			file = "logfile-6.csv"
		}

		soc:notify()
		unitTest:assertFile("logfile-6.csv")

		local world = CellularSpace{
			xdim = 10,
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local log = LogFile{
			target = world,
			file = "logfile-7.csv"
		}

		local log = LogFile{
			target = world,
			file = "logfile-8.csv",
			select = "mcount"
		}

		world:notify()
		unitTest:assertFile("logfile-7.csv")
		unitTest:assertFile("logfile-8.csv")
	end
}

