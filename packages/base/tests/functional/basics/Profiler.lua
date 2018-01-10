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
	uptime = function(unitTest)
		local _, startTime = Profiler():uptime()
		local timeString, timeNumber = Profiler():uptime()
		unitTest:assertType(timeString, "string")
		unitTest:assertType(timeNumber, "number")
		unitTest:assert(table.pack(Profiler():uptime())[2] >= startTime)
	end,
	timeToString = function(unitTest)
		local t1 = 0
		unitTest:assertEquals(timeToString(t1), "less than one second")
		local t2 = 1
		unitTest:assertEquals(timeToString(t2), "1 second")
		local t3 = 2
		unitTest:assertEquals(timeToString(t3), "2 seconds")
		local t4 = 59
		unitTest:assertEquals(timeToString(t4), "59 seconds")
		local t5 = 60
		unitTest:assertEquals(timeToString(t5), "1 minute")
		local t6 = 61
		unitTest:assertEquals(timeToString(t6), "1 minute and 1 second")
		local t7 = 62
		unitTest:assertEquals(timeToString(t7), "1 minute and 2 seconds")
		local t8 = 300
		unitTest:assertEquals(timeToString(t8), "5 minutes")
		local t9 = 3599
		unitTest:assertEquals(timeToString(t9), "59 minutes and 59 seconds")
		local t10 = 3600
		unitTest:assertEquals(timeToString(t10), "1 hour")
		local t11 = 3601
		unitTest:assertEquals(timeToString(t11), "1 hour")
		local t12 = 3659
		unitTest:assertEquals(timeToString(t12), "1 hour")
		local t13 = 3660
		unitTest:assertEquals(timeToString(t13), "1 hour and 1 minute")
		local t14 = 3720
		unitTest:assertEquals(timeToString(t14), "1 hour and 2 minutes")
		local t15 = 7200
		unitTest:assertEquals(timeToString(t15), "2 hours")
		local t16 = 7259
		unitTest:assertEquals(timeToString(t16), "2 hours")
		local t17 = 7260
		unitTest:assertEquals(timeToString(t17), "2 hours and 1 minute")
		local t18 = 7320
		unitTest:assertEquals(timeToString(t18), "2 hours and 2 minutes")
		local t19 = 86399
		unitTest:assertEquals(timeToString(t19), "23 hours and 59 minutes")
		local t20 = 86400
		unitTest:assertEquals(timeToString(t20), "1 day")
		local t21 = 86401
		unitTest:assertEquals(timeToString(t21), "1 day")
		local t22 = 86460
		unitTest:assertEquals(timeToString(t22), "1 day")
		local t23 = 90000
		unitTest:assertEquals(timeToString(t23), "1 day and 1 hour")
		local t24 = 93600
		unitTest:assertEquals(timeToString(t24), "1 day and 2 hours")
		local t25 = 172800
		unitTest:assertEquals(timeToString(t25), "2 days")
		local t26 = 86465321
		unitTest:assertEquals(timeToString(t26), "1000 days and 18 hours")
	end
}