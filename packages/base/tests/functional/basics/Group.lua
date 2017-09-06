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
-- Authors: Pedro R. Andrade (pedro.andrade@inpe.br)
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

return{
	Group = function(unitTest)
		local group1 = Group{}
		unitTest:assertType(group1, "Group")

		local nonFooAgent = Agent{
			init = function(self)
				self.age = Random():integer(10)
			end,
			w = 3,
			p = 5,
			execute = function(self)
				self.age = self.age + 1
			end
		}

		local nonFooSociety = Society{
			instance = nonFooAgent,
			quantity = 10
		}

		local g
		local warning_func = function()
			g = Group{
				target = nonFooSociety,
				random = false
			}
		end

		unitTest:assertWarning(warning_func, defaultValueMsg("random", false))
		unitTest:assertType(g, "Group")
		unitTest:assertEquals(#g, #nonFooSociety)
		unitTest:assertEquals(g.agents[1], nonFooSociety.agents[1])
		unitTest:assertNil(g.select)
		unitTest:assertNil(g.greater)
		unitTest:assertEquals(g:w(), 30)
		unitTest:assertEquals(g:p(), 50)

		warning_func = function()
			g = Group{
				target = nonFooSociety,
				build = true
			}
		end

		unitTest:assertWarning(warning_func, defaultValueMsg("build", true))
		unitTest:assertType(g, "Group")
		unitTest:assertEquals(#g, #nonFooSociety)
		unitTest:assertEquals(g.agents[1], nonFooSociety.agents[1])
		unitTest:assertNil(g.select)
		unitTest:assertNil(g.greater)
		unitTest:assertEquals(g:w(), 30)
		unitTest:assertEquals(g:p(), 50)

		warning_func = function()
			g = Group{
				target = nonFooSociety,
				selection = function() return true end
			}
		end

		unitTest:assertWarning(warning_func, unnecessaryArgumentMsg("selection", "select"))
		unitTest:assertType(g, "Group")
		unitTest:assertEquals(#g, #nonFooSociety)
		unitTest:assertEquals(g.agents[1], nonFooSociety.agents[1])
		unitTest:assertNil(g.select)
		unitTest:assertNil(g.greater)
		unitTest:assertEquals(g:w(), 30)
		unitTest:assertEquals(g:p(), 50)

		g = Group{
			target = nonFooSociety,
			build = false
		}
		unitTest:assertEquals(0, #g)

		g:rebuild()
		unitTest:assertEquals(#nonFooSociety, #g)

		g = Group{
			target = nonFooSociety,
			select = function(ag)
				return ag.age > 5
			end
		}

		unitTest:assertEquals(6, #g)
		local sum = 0
		forEachAgent(g, function(ag)
			sum = sum + ag.age
		end)

		unitTest:assertEquals(46, sum)

		local g2 = Group{
			target = g,
			select = function(ag)
				return ag.age < 8
			end
		}

		unitTest:assertEquals(#g2, 2)

		g = Group{
			target = nonFooSociety,
			greater = function(a, b)
				return a.age > b.age
			end
		}

		unitTest:assertEquals(10, #g)
		unitTest:assertEquals(9, g.agents[1].age)
		unitTest:assertEquals(0, g.agents[10].age)
	end,
	__len = function(unitTest)
		local ag1 = Agent{age = 8}
		local soc1 = Society{
			instance = ag1,
			quantity = 2
		}

		local g1 = Group{
			target = soc1,
			select = function(ag) return ag.age > 5 end
		}

		unitTest:assert(#g1 == 2)
	end,
	__tostring = function(unitTest)
		local ag1 = Agent{age = 8}
		local soc1 = Society{
			instance = ag1,
			quantity = 2
		}

		local g1 = Group{
			target = soc1,
			select = function(ag) return ag.age > 5 end
		}

		unitTest:assertEquals(tostring(g1), [[addSocialNetwork     function
age                  function
agents               vector of size 2
die                  function
emptyNeighbor        function
enter                function
execute              function
getCell              function
getCells             function
getLatency           function
getSocialNetwork     function
getStateName         function
getTrajectoryStatus  function
init                 function
leave                function
message              function
move                 function
on_message           function
parent               Society
random               boolean [false]
reproduce            function
select               function
setTrajectoryStatus  function
walk                 function
walkIfEmpty          function
walkToEmpty          function
]])
	end,
	add = function(unitTest)
		local nonFooAgent = Agent{}

		local soc = Society{
			instance = nonFooAgent,
			quantity = 10
		}

		local g = Group{
			target = soc,
			build = false
		}

		g:add(soc.agents[1])
		g:add(soc.agents[2])
		g:add(soc.agents[3])

		unitTest:assertEquals(#g, 3)
	end,
	clone = function(unitTest)
		local nonFooAgent = Agent{
			name = "nonfoo",
			init = function(self)
				self.age = Random():integer(10)
				if self.age < 5 then
					self.name = "foo"
				end
			end,
			execute = function(self)
				self.age = self.age + 1
			end
		}

		local soc = Society{
			instance = nonFooAgent,
			quantity = 10
		}

		local g = Group{
			target = soc,
			select = function(ag) return ag.age > 5 end
		}

		unitTest:assertType(g, "Group")
		unitTest:assertEquals(4, #g)

		local g2 = g:clone()
		unitTest:assertType(g2, "Group")
		unitTest:assertEquals(#g, #g2)
		unitTest:assert(g.select == g2.select)
		unitTest:assert(g.greater == g2.greater)
		unitTest:assert(g.parent == g2.parent)
		unitTest:assert(g.agents[1] == g2.agents[1])
	end,
	filter = function(unitTest)
		local count = 0
		local nonFooAgent = Agent{
			init = function(self)
				self.age = count
				count = count + 1
			end,
			execute = function(self)
				self.age = self.age + 1
			end
		}

		local nonFooSociety = Society{
			instance = nonFooAgent,
			quantity = 10
		}

		local g = Group{target = nonFooSociety, select = function(ag)
			return ag.age > 5 and ag.age < 8
		end}

		forEachAgent(g, function(agent)
			unitTest:assert(agent.age > 5 and agent.age < 8)
		end)

		local g1 = #g
		g:execute()

		g:filter()

		forEachAgent(g, function(agent)
			unitTest:assert(agent.age > 5 and agent.age < 8)
		end)

		unitTest:assert(#g <= g1)
	end,
	randomize = function(unitTest)
		local nonFooAgent = Agent{
			init = function(self)
				self.age = Random():integer(10)
			end,
			execute = function(self)
				self.age = self.age + 1
			end
		}

		local nonFooSociety = Society{
			instance = nonFooAgent,
			quantity = 10
		}

		local g = Group{
			target = nonFooSociety,
			select = function(ag)
				return ag.age < 5
			end
		}

		unitTest:assertEquals(#g, 5)
		g:randomize()
		unitTest:assertEquals(#g, 5)
		unitTest:assertEquals(4, g.agents[1].age)
	end,
	rebuild = function(unitTest)
		local nonFooAgent = Agent{
			init = function(self)
				self.age = Random():integer(10)
			end,
			execute = function(self)
				self.age = self.age + 1
			end
		}

		local nonFooSociety = Society{
			instance = nonFooAgent,
			quantity = 10
		}

		local g = Group{
			target = nonFooSociety,
			select = function(ag)
				return ag.age < 8
			end,
			greater = function(a, b)
				return a.age < b.age
			end
		}

		unitTest:assertEquals(0, g.agents[1].age)
		unitTest:assertEquals(3, g.agents[6].age)

		nonFooSociety:execute()
		g:rebuild()

		unitTest:assertEquals(7, #g)
		g:execute()
		g:execute()
		g:execute()
		g:rebuild()

		unitTest:assertEquals(6, #g)
		unitTest:assertEquals(4, g.agents[1].age)

		nonFooAgent = Agent{
			init = function(self)
				self.age = Random():integer(10)
			end,
			execute = function(self)
				self.age = self.age + 1
			end
		}

		nonFooSociety = Society{
			instance = nonFooAgent,
			quantity = 20
		}

		g = Group{
			target = nonFooSociety,
			random = true,
			select = function(ag)
				return ag.age < 8
			end
		}

		unitTest:assertEquals(#g, 17)

		g:rebuild()
		unitTest:assertEquals(#g, 17)
		unitTest:assertEquals(7, g.agents[1].age)

		g:rebuild()
		unitTest:assertEquals(4, g.agents[1].age)

		g:rebuild()
		unitTest:assertEquals(4, g.agents[1].age)

		g.agents[1]:die()

		g:rebuild()
		unitTest:assertEquals(#g, 16)
		unitTest:assertEquals(5, g.agents[1].age)
	end,
	sort = function(unitTest)
		local count = 0
		local nonFooAgent = Agent{
			init = function(self)
				self.age = count
				count = count + 1
			end,
			execute = function(self)
				self.age = self.age + 1
			end
		}

		local nonFooSociety = Society{
			instance = nonFooAgent,
			quantity = 10
		}

		local g = Group{target = nonFooSociety, greater = function(ag1, ag2)
			return ag1.age < ag2.age
		end}

		local lastAge = 0
		forEachAgent(g, function(agent)
			unitTest:assert(agent.age >= lastAge)
			lastAge = agent.age
		end)

		g:sort()

		lastAge = 0
		forEachAgent(g, function(agent)
			unitTest:assert(agent.age >= lastAge)
			lastAge = agent.age
		end)
	end
}

