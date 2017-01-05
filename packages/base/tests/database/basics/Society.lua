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
	Society = function(unitTest)
		local nonFooAgent = Agent{
			init = function(self)
				self.immune = self.immune:lower():match("true")
			end
		}

		local soc = Society {
			instance = nonFooAgent,
			file = filePath("agents.csv", "base")
		}

		unitTest:assertEquals(4, #soc)

		local sum_age = 0
		local sum_wealth = 0
		local sum_vision = 0
		local sum_metabolism = 0
		local sum_immunes = 0
		forEachAgent(soc, function(ag)
			sum_age = sum_age + ag.age
			sum_wealth = sum_wealth + ag.wealth
			sum_vision = sum_vision + ag.vision
			sum_metabolism = sum_metabolism + ag.metabolism
			if ag.immune then
				sum_immunes = sum_immunes + 1
			end
		end)
		unitTest:assertEquals(105, sum_age)
		unitTest:assertEquals(1000, sum_wealth)
		unitTest:assertEquals(11, sum_vision)
		unitTest:assertEquals(6, sum_metabolism)
		unitTest:assertEquals(2, sum_immunes)

		nonFooAgent = Agent{}

		soc = Society{
			instance = nonFooAgent,
			file = filePath("brazilstates.shp", "base")
		}

		unitTest:assertEquals(#soc, 27)

		local valuesDefault = {
			2300000,  12600000, 2700000,  6700000,  5200000,
			16500000,  1900000,  5400000, 7400000,  3300000,
			8700000,  13300000, 2600000, 1300000, 300000,
			9600000, 4800000, 1600000, 33700000,  1000000,
			2700000, 2800000, 300000, 500000,  1700000,
			4300000,  2300000
		}

		for i = 1, 27 do
			unitTest:assertEquals(valuesDefault[i], soc.agents[i].POPUL)
		end
	end
}

