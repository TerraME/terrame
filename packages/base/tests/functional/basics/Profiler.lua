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
	Profiler = function(unitTest)
		unitTest:assertType(Profiler(), "Profiler")
		local prof = Profiler()
		unitTest:assertEquals(prof, Profiler())
	end,
	start = function(unitTest)
		Profiler():start("test")
		unitTest:assertEquals(Profiler():current().name, "test")
		Profiler():stop("test")
		Profiler().blocks["test"] = nil
	end,
	count = function(unitTest)
		Profiler():start("test1")
		unitTest:assertEquals(Profiler():count("test1"), 1)
		Profiler():stop("test1")
		Profiler():start("test2")
		unitTest:assertEquals(Profiler():count("test1"), 1)
		unitTest:assertEquals(Profiler():count("test2"), 1)
		Profiler():stop("test2")
		Profiler():start("test2")
		unitTest:assertEquals(Profiler():count("test2"), 2)
		Profiler():stop("test2")
		Profiler().blocks["test1"] = nil
		Profiler().blocks["test2"] = nil
	end,
	uptime = function(unitTest)
		local timeString, timeNumber = Profiler():uptime("main")
		unitTest:assertType(timeString, "string")
		unitTest:assertType(timeNumber, "number")
		Profiler():start("test")
		local _, startTime = Profiler():uptime()
		delay(0.1)
		local _, currentTime = Profiler():uptime()
		unitTest:assert(startTime < currentTime)
		delay(0.1)
		Profiler():stop("test")
		local _, stopTime = Profiler():uptime("test")
		unitTest:assert(currentTime < stopTime)
		delay(0.1)
		_, currentTime = Profiler():uptime("test")
		unitTest:assert(currentTime == stopTime)
		Profiler().blocks["test"] = nil
	end,
	stop = function(unitTest)
		Profiler():start("test1")
		delay(0.1)
		Profiler():start("test2")
		local timeString, timeNumber = Profiler():stop("test1")
		unitTest:assertType(timeString, "string")
		unitTest:assertType(timeNumber, "number")
		unitTest:assert(timeNumber > table.pack(Profiler():stop("test2"))[2])
		unitTest:assertEquals(Profiler():current().name, "main")
		Profiler().blocks["test1"] = nil
		Profiler().blocks["test2"] = nil
	end
}
