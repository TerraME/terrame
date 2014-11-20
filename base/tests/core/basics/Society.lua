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
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

return {
	__len = function(unitTest)
		local sc1 = Society{
			instance = Agent{},
			quantity = 10
		}

		unitTest:assert_equal(10, #sc1)
	end,
	add = function(unitTest)
		local ag1 = Agent{}

		local sc1 = Society{
			instance = ag1,
			quantity = 20
		}

		unitTest:assert_equal(20, #sc1)
		local agent = sc1:add()
		unitTest:assert_equal(21, #sc1)
		unitTest:assert_type(agent, "Agent")
		unitTest:assert_equal(agent.id, "21")
	end,
	clear = function(unitTest)
		local agent1 = Agent{}

		local soc1 = Society{
			instance = agent1,
			quantity = 10
		}

		soc1:clear()
		unitTest:assert_equal(0, #soc1)
	end,
	remove = function(unitTest)
		local agent1 = Agent{}

		local soc1 = Society{
			instance = agent1,
			quantity = 10
		}

		soc1:remove(soc1:sample())
		unitTest:assert_equal(9, #soc1)

		local ag1 = Agent{
			name = "nonfoo",
			init = function(self)
				self.age = Random():integer(10)
			end
		}

		local sc = Society{
			instance = ag1,
			quantity = 10
		}

		sc:remove(function(ag)
			return ag.age > 5
		end)

		unitTest:assert_equal(9, #soc1)
	end,
	sample = function(unitTest)
		local agent1 = Agent{}

		local soc1 = Society{
			instance = agent1,
			quantity = 10
		}

		local ag = soc1:sample()
		unitTest:assert_type(ag, "Agent")
	end,
	Society = function(unitTest)
		Random{seed = 0}

		local singleFooAgent = Agent{
			size = 10,
			name = "foo",
			execute = function(self)
				self.size = self.size + 1
				self:walk()
			end
		}
		
		local findCounter = 0
		local nonFooAgent = Agent{
			name = "nonfoo",
			init = function(self)
				self.age = Random():integer(10)
			end,
			execute = function(self)
				self.age = self.age + 1
				self:walk()
				forEachAgent(self:getCell(), function(agent)
					if agent.name == "foo" then
						findCounter = findCounter + 1
					end
				end)
			end
		}

		unitTest:assert_nil(nonFooAgent.age)

		local nonFooSociety = Society{
			instance = nonFooAgent,
			quantity = 50
		}

		unitTest:assert_type(nonFooSociety, "Society")
		unitTest:assert_equal(50, #nonFooSociety)

		local sum = 0
		forEachAgent(nonFooSociety, function(ag)
			sum = sum + ag.age
		end)

		unitTest:assert_equal(239, sum)

		local cs = CellularSpace{xdim = 20}

		cs:createNeighborhood{}

		local env = Environment{nonFooSociety, cs, singleFooAgent}

		env:createPlacement{strategy = "random", max = 1}

		local t = Timer{
			Event {action = nonFooSociety},
		}

		t:execute(50)

		unitTest:assert_equal(5, findCounter)

		local count1 = 0
		local count2 = 0
		forEachCell(cs, function(cell)
			count1 = count1 + #cell.placement
			if not cell:isEmpty() then count2 = count2 + 1 end
		end)
		unitTest:assert_equal(51, count1)
		unitTest:assert_equal(47, count2)

		local agent1 = Agent{}

		local soc1 = Society{
			instance = agent1,
			quantity = 10
		}
		unitTest:assert_equal(10, #soc1)

		local counter = 1
		forEachAgent(soc1, function(a)
			if counter >= 6 then
				a.gender = "male"
			else
				a.gender = "female"
			end
			counter = counter + 1
			unitTest:assert_type(a, "Agent")
		end)

		local groups = soc1:split("gender")
		unitTest:assert_equal(5, #groups.male)
		unitTest:assert_equal(5, #groups.female)

		local ag = soc1:sample()
		unitTest:assert_type(ag, "Agent")
		local ev = Event{}
		ag:execute(ev)

		ag:die()
		unitTest:assert_equal(9, #soc1)

		local ag = Agent{
			age = 0,
			human = true,
			gender = "male"
		}

		local soc = Society{
			instance = ag,
			quantity = 10
		}

		unitTest:assert_equal(soc:age(), 0)
		unitTest:assert_equal(soc:human(), 10)
		unitTest:assert_equal(soc:gender().male, 10)
	end,
	synchronize = function(unitTest)
		local randomObj = Random{}
		randomObj:reSeed(0)

		local received = 0
		local nonFooAgent = Agent{
			init = function(self)
				self.age = randomObj:integer(10)
			end,
			execute = function(self)
				self.age = self.age + 1
			end,
			on_message = function(m)
				received = received + 1
			end
		}

		local soc = Society{
			instance = nonFooAgent,
			quantity = 3
		}

		local ags = soc.agents
		local john = ags[1] -- get a randomize agent from the society
		john.name = "john"
		local mary = ags[2]
		mary.name = "mary"
		local myself = ags[3]

		unitTest:assert_equal(3, #soc)

		local friends = SocialNetwork()
		friends:add(john)
		friends:add(mary)

		myself:addSocialNetwork(friends) -- adding two connections to myself
		unitTest:assert_equal(2, #myself:getSocialNetwork())

		local sum = 0
		forEachConnection(myself, function(self, friend)
			sum = sum + friend.age
		end)

		unitTest:assert_equal(12, sum)

		forEachConnection(myself, function(self, friend)
			myself:message{receiver = friend}
		end)
		unitTest:assert_equal(2, received)

		forEachConnection(myself, function(self, friend)
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
		end)

		--[[
		-- to verify the delayed messages
		forEachElement(soc.messages, function(_, mes)
		forEachElement(mes, print)
		end)
		--]]

		soc:synchronize()
		unitTest:assert_equal(5, received)

		local t = Timer{
			Event{period = 4, action = soc}
		}

		t:execute(8)
		unitTest:assert_equal(14, received)

		soc:synchronize(1.1)

		unitTest:assert_equal(16, received)

		soc:synchronize(20)
		unitTest:assert_equal(16, received)
	end,
	createSocialNetwork = function(unitTest)
		Random{seed = 12345}

		local predator = Agent{
			energy = 40,
			name = "predator",
			execute = function(self)
				new_cell = self:getCell("house"):getNeighborhood():sample(randomObj)
				self:move(new_cell, "house")
				self:walk("stay")
			end
		}

		local predators = Society{
			instance = predator,
			quantity = 100
		}
	
		forEachAgent(predators, function(ag)
			unitTest:assert_nil(ag:getSocialNetwork())
		end)

		predators:createSocialNetwork{probability = 0.5, name = "friends"}
		predators:createSocialNetwork{quantity = 1, name = "boss"}
		predators:createSocialNetwork{filter = function() return true end, name = "all"}

		local count_prob = 0
		local count_quant = 0
		local count_all = 0

		forEachAgent(predators, function(ag)
			count_prob  = count_prob  + #ag:getSocialNetwork("friends")
			count_quant = count_quant + #ag:getSocialNetwork("boss")
			count_all   = count_all   + #ag:getSocialNetwork("all")
		end)

		unitTest:assert_equal(5046,  count_prob)
		unitTest:assert_equal(100,   count_quant)
		unitTest:assert_equal(10000, count_all)

		local cs = CellularSpace{xdim = 5}
		cs:createNeighborhood()

		local env = Environment{cs, predators}
		env:createPlacement{strategy = "random"}

		predators:createSocialNetwork{strategy = "cell", name = "c"}
		predators:createSocialNetwork{strategy = "neighbor", name = "n"}

		local count_c = 0
		local count_n = 0
		forEachAgent(predators, function(ag)
			count_c  = count_c + #ag:getSocialNetwork("c")
			count_n  = count_n + #ag:getSocialNetwork("n")
		end)

		unitTest:assert_equal(370, count_c)
		unitTest:assert_equal(2356, count_n)

		local ag1 = Agent{
			name = "nonfoo",
			init = function(self)
				self.age = Random():integer(10)
			end,
			execute = function(self)
				self.age = self.age + 1
				self:walk()
				forEachAgent(self:getCell(), function(agent)
					if agent.name == "foo" then
						findCounter = findCounter + 1
					end
				end)
			end
		}

		local sc = Society{
			instance = ag1,
			quantity = 10
		}

		sc:createSocialNetwork{
			strategy = "void",
			name = "void"
		}
		unitTest:assert_equal(0, #sc:sample():getSocialNetwork("void"))

		-- on the fly social networks
		local predator = Agent{
			energy = 40,
			name = "predator",
			execute = function(self)
				new_cell = self:getCell("house"):getNeighborhood():sample(randomObj)
				self:move(new_cell, "house")
				self:walk("stay")
			end
		}

		local predators = Society{
			instance = predator,
			quantity = 100
		}

		predators:createSocialNetwork{probability = 0.5, name = "friends", onthefly = true}
		predators:createSocialNetwork{quantity = 1, name = "boss", onthefly = true}
		predators:createSocialNetwork{filter = function() return true end, name = "all", onthefly = true}

		local count_prob = 0
		local count_quant = 0
		local count_all = 0

		forEachAgent(predators, function(ag)
			count_prob  = count_prob  + #ag:getSocialNetwork("friends")
			count_quant = count_quant + #ag:getSocialNetwork("boss")
			count_all   = count_all   + #ag:getSocialNetwork("all")
		end)

		unitTest:assert_equal(4943,  count_prob)
		unitTest:assert_equal(100,   count_quant)
		unitTest:assert_equal(10000, count_all)

		local count_prob = 0
		local count_quant = 0
		local count_all = 0

		forEachAgent(predators, function(ag)
			count_prob  = count_prob  + #ag:getSocialNetwork("friends")
			count_quant = count_quant + #ag:getSocialNetwork("boss")
			count_all   = count_all   + #ag:getSocialNetwork("all")
		end)

		unitTest:assert_equal(5019,  count_prob)
		unitTest:assert_equal(100,   count_quant)
		unitTest:assert_equal(10000, count_all)

		local cs = CellularSpace{xdim = 5}
		cs:createNeighborhood()

		local env = Environment{cs, predators}
		env:createPlacement{strategy = "random"}

		predators:createSocialNetwork{strategy = "cell", name = "c", onthefly = true}
		predators:createSocialNetwork{strategy = "neighbor", name = "n", onthefly = true}

		local count_c = 0
		local count_n = 0
		forEachAgent(predators, function(ag)
			count_c  = count_c + #ag:getSocialNetwork("c")
			count_n  = count_n + #ag:getSocialNetwork("n")
		end)

		unitTest:assert_equal(384, count_c)
		unitTest:assert_equal(2168, count_n)

		predators:sample():die()

		local count_c = 0
		local count_n = 0
		forEachAgent(predators, function(ag)
			count_c  = count_c + #ag:getSocialNetwork("c")
			count_n  = count_n + #ag:getSocialNetwork("n")
		end)


		unitTest:assert_equal(380, count_c)
		unitTest:assert_equal(2094, count_n)
	end,
	split = function(unitTest)
		local randomObj = Random{}
		randomObj:reSeed(0)

		local received = 0
		local nonFooAgent = Agent{
			name = "nonfoo",
			init = function(self)
				self.age = randomObj:integer(10)
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

		local g = soc:split("name")

		unitTest:assert_equal(4,#g.foo)
		unitTest:assert_equal(10,#g.foo + #g.nonfoo)

		local g3 = soc:split(function(ag)
			if ag.age < 3 then return 1
			elseif ag.age < 7 then return 2
			else return 3
			end
		end)

		unitTest:assert_equal(4, #g3[2])
		unitTest:assert_equal(10, #g3[1] + #g3[2] + #g3[3])
	end,
	__tostring = function(unitTest)
		local ag1 = Agent{
			name = "nonfoo",
			init = function(unitTest)
				unitTest.age = 8
			end,
			execute = function(unitTest) end
		}

		local soc1 = Society{
			instance = ag1,
			quantity = 2
		}
		unitTest:assert_equal(tostring(soc1), [[agents         table of size 2
autoincrement  number [3]
cObj_          userdata
execute        function
init           function
instance       Agent
messages       table of size 0
name           function
observerId     number [-1]
placements     table of size 0
quantity       number [0]
]])

		local aa = soc1.agents[2]
		unitTest:assert_equal(tostring(aa), [[age             number [8]
cObj_           userdata
id              string [2]
parent          Society
socialnetworks  table of size 0
state_          userdata
]])
	end
}

