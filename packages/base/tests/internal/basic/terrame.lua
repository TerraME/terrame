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
	insert = function(unitTest)
		local t = {}

		table.insert(t, 2)
		table.insert(t, 3)
		table.insert(t, 4)

		unitTest:assertEquals(#t, 3)
		unitTest:assertEquals(t[1], 2)
		unitTest:assertEquals(t[2], 3)
		unitTest:assertEquals(t[3], 4)

		t = {}

		table.insert(t, 2)
		table.insert(t, 1, 3)
		table.insert(t, 1, 4)
		table.insert(t, 2, 5)

		unitTest:assertEquals(#t, 4)
		unitTest:assertEquals(t[1], 4)
		unitTest:assertEquals(t[2], 5)
		unitTest:assertEquals(t[3], 3)
		unitTest:assertEquals(t[4], 2)
	end,
	verifyVersionDependency = function(unitTest)
		unitTest:assert(    _Gtme.verifyVersionDependency("0.1", ">=", "0.0.3"))
		unitTest:assert(not _Gtme.verifyVersionDependency("0.1", ">=", "0.3"))
		unitTest:assert(not _Gtme.verifyVersionDependency("0.0.3.1", ">=", "0.1.3"))
		unitTest:assert(    _Gtme.verifyVersionDependency("0.1.4", ">=", "0.1.3"))
		unitTest:assert(not _Gtme.verifyVersionDependency("0.0.3.0", ">=", "0.0.3.1"))

		unitTest:assert(not _Gtme.verifyVersionDependency("0.1", "<=", "0.0.3"))
		unitTest:assert(not _Gtme.verifyVersionDependency("0.0.3.1", "<=", "0.0.3"))
		unitTest:assert(    _Gtme.verifyVersionDependency("0.0.3.1", "<=", "0.0.3.1"))

		unitTest:assert(not _Gtme.verifyVersionDependency("0.1", "==", "0.0.3"))
		unitTest:assert(not _Gtme.verifyVersionDependency("0.0.3.1", "==", "0.0.3"))
		unitTest:assert(    _Gtme.verifyVersionDependency("0.0.3.1", "==", "0.0.3.1"))
	end,
	getVersion = function(unitTest)
		local version = _Gtme.getVersion("10.100.1000")
		unitTest:assertEquals(#version, 3)
		unitTest:assertEquals(version[1], 10)
		unitTest:assertEquals(version[2], 100)
		unitTest:assertEquals(version[3], 1000)
	end
}

