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
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		Profiler():start("test")
		unitTest:assertEquals(Profiler():current().name, "test")
		Profiler():start("test2")
		unitTest:assertEquals(Profiler():current().name, "test2")
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	count = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
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
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	current = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		local current = Profiler():current()
		Profiler():start("test")
		unitTest:assertEquals(Profiler():current().name, "test")
		Profiler():stop()
		unitTest:assertEquals(Profiler():current().name, current.name)
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	uptime = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
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
		unitTest:assertEquals(currentTime, stopTime)

		Profiler().blocks["test"].startTime = 0
		Profiler().blocks["test"].endTime = 3600
		timeString = Profiler():uptime("test")
		unitTest:assertEquals(timeString, "1 hour")
		Profiler().blocks["test"].endTime = 7250
		timeString = Profiler():uptime("test")
		unitTest:assertEquals(timeString, "2 hours")
		Profiler().blocks["test"].endTime = 86401
		timeString = Profiler():uptime("test")
		unitTest:assertEquals(timeString, "1 day")
		Profiler().blocks["test"].endTime = 86465321
		timeString = Profiler():uptime("test")
		unitTest:assertEquals(timeString, "1000 days and 18 hours")
		Profiler().blocks["test"].endTime = 60
		timeString = Profiler():uptime("test")
		unitTest:assertEquals(timeString, "1 minute")
		Profiler().blocks["test"].endTime = 125
		timeString = Profiler():uptime("test")
		unitTest:assertEquals(timeString, "2 minutes and 5 seconds")
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	stop = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		Profiler():start("test1")
		delay(0.1)
		Profiler():start("test2")
		local timeString, timeNumber = Profiler():stop("test1")
		unitTest:assertType(timeString, "string")
		unitTest:assertType(timeNumber, "number")
		unitTest:assert(timeNumber > table.pack(Profiler():stop("test2"))[2])
		unitTest:assertEquals(Profiler():current().name, "main")
		Profiler():start("test1")
		unitTest:assertEquals(Profiler():current().name, "test1")
		Profiler():start("test2")
		unitTest:assertEquals(Profiler():current().name, "test2")
		Profiler():stop()
		unitTest:assertEquals(Profiler():current().name, "test1")
		Profiler():stop()
		unitTest:assertEquals(Profiler():current().name, "main")
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	clean = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		Profiler():clean()
		unitTest:assertEquals(Profiler():current().name, "main")
		Profiler():clean()
		Profiler():clean()
		unitTest:assertEquals(Profiler():current().name, "main")
		Profiler():start("test")
		unitTest:assertEquals(Profiler():current().name, "test")
		Profiler():clean()
		unitTest:assertEquals(Profiler():current().name, "main")
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	report = function(unitTest)
		unitTest:assert(true)
	end,
	steps = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		Profiler():start("test1")
		Profiler():steps("test1", 5)
		unitTest:assertEquals(Profiler():current().steps, 5)
		Profiler():steps("test2", 5)
		unitTest:assertEquals(Profiler():current().steps, 5)
		Profiler():start("test2")
		unitTest:assertEquals(Profiler():current().steps, 5)
		Profiler():stop("test2")
		unitTest:assertEquals(Profiler().blocks["test2"].steps, 5)
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end,
	eta = function(unitTest)
		local oldStack = Profiler().stack
		local oldBlocks = Profiler().blocks
		Profiler().stack = {oldBlocks["main"]}
		Profiler().blocks = {main = oldBlocks["main"]}
		Profiler():steps("test", 1)
		Profiler():start("test")
		delay(0.1)
		Profiler():stop("test")
		local timeString, timeNumber = Profiler():eta("test")
		unitTest:assertType(timeString, "string")
		unitTest:assertType(timeNumber, "number")
		unitTest:assertEquals(timeNumber, 0.1, 0.1)
		Profiler().stack = oldStack
		Profiler().blocks = oldBlocks
	end
}
