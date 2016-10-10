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
	getConfig = function(unitTest)
		local cf = getConfig()
		unitTest:assertNil(cf.qwertyuiop)

		local cd = currentDir()

		packageInfo().data:setCurrentDir()

		local cf2 = getConfig()
		unitTest:assertEquals(cf, cf2)

		cd:setCurrentDir()
	end,
	["table.load"] = function(unitTest)
		local filename = "dump.lua"
		local expected = {
			{age = 1, wealth = 10, vision = 2},
			{age = 3, wealth =  8, vision = 1},
			{age = 3, wealth = 15, vision = 2}
		}

		table.save(expected, filename)
		local actual = table.load(filename)

		unitTest:assertEquals(#actual, #expected)

		for i, tab1 in pairs(actual) do
			local tab2 = expected[i]

			unitTest:assertEquals(tab1.age, tab2.age)
			unitTest:assertEquals(tab1.wealth, tab2.wealth)
			unitTest:assertEquals(tab1.vision, tab2.vision)
		end

		File(filename):deleteIfExists()
	end,
	["table.save"] = function(unitTest)
		local filename = "dump.lua"
		local expected = {
			{age = 1, wealth = 10, vision = 2},
			{age = 3, wealth =  8, vision = 1},
			{age = 3, wealth = 15, vision = 2}
		}

		table.save(expected, filename)

		unitTest:assertFile(filename)
	end
}

