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

		local mytable = CSVread("result.csv")
		unitTest:assertEquals(#mytable, 1)
		unitTest:assertEquals(getn(mytable[1]), 1)
		unitTest:assertEquals(mytable[1].count, 0)

		world:notify()

		local mytable = CSVread("result.csv")
		unitTest:assertEquals(#mytable, 2)
		unitTest:assertEquals(getn(mytable[2]), 1)
		unitTest:assertEquals(mytable[2].count, 0)

		local world2 = Cell{
			count = 2
		}

		local log2 = LogFile{target = world2, overwrite = false}

		unitTest:assertType(log2, "LogFile")

		world2:notify()

		local mytable = CSVread("result.csv")
		unitTest:assertEquals(#mytable, 3)
		unitTest:assertEquals(getn(mytable[3]), 1)
		unitTest:assertEquals(mytable[3].count, 2)

		unitTest:assertFile("result.csv")

		local world = Agent{
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local log = LogFile{
			target = world,
			file = "file2.csv",
			separator = ";",
			overwrite = false
		}

		world:notify()
		world:notify()

		local mytable = CSVread("file2.csv", ";")
		unitTest:assertEquals(#mytable, 2)
		unitTest:assertEquals(getn(mytable[1]), 1)
		unitTest:assertEquals(mytable[1].count, 0)

		unitTest:assertFile("file2.csv")

		local world = Agent{
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local log = LogFile{
			target = world,
			select = {"mcount"}
		}
		world:notify()
		unitTest:assertFile("result.csv")

		local soc = Society{
			instance = world,
			quantity = 3
		}

		local log = LogFile{target = soc}
		soc:notify()
		unitTest:assertFile("result.csv")

		local log = LogFile{target = soc, select = "#"}
		soc:notify()
		unitTest:assertFile("result.csv")

		local soc = Society{
			instance = Agent{},
			quantity = 3,
			total = 10
		}

		local log = LogFile{target = soc}
		soc:notify()
		unitTest:assertFile("result.csv")

		local world = CellularSpace{
			xdim = 10,
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local log = LogFile{target = world, file = "abc.csv"}
		local log = LogFile{target = world, select = "mcount"}

		world:notify()
		unitTest:assertFile("abc.csv")
		unitTest:assertFile("result.csv")
	end
}

