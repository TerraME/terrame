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
	Society = function(unitTest)
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
			money = 100,
			init = function(self)
				self.charge = 0
			end,
			age = Choice{min = 0, max = 10, step = 1},
			gender = Choice{"male", "female"},
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

		unitTest:assertNull(nonFooAgent.charge)

		local nonFooSociety = Society{
			instance = nonFooAgent,
			quantity = 50
		}

		unitTest:assertType(nonFooSociety, "Society")
		unitTest:assertEquals(50, #nonFooSociety)
		unitTest:assertEquals(nonFooSociety:gender().male, 26)
		unitTest:assertEquals(nonFooSociety:sample().money, 100)
		unitTest:assertEquals(nonFooSociety:money(), 100 * #nonFooSociety)

		local sum = 0
		forEachAgent(nonFooSociety, function(ag)
			sum = sum + ag.age
		end)

		unitTest:assertEquals(nonFooSociety:age(), sum)

		local cs = CellularSpace{xdim = 20}

		cs:createNeighborhood{}

		local env = Environment{nonFooSociety, cs, singleFooAgent}

		env:createPlacement{max = 1}

		local t = Timer{
			Event {action = nonFooSociety},
		}

		t:execute(50)

		unitTest:assertEquals(4, findCounter)

		local count1 = 0
		local count2 = 0
		forEachCell(cs, function(cell)
			count1 = count1 + #cell.placement
			if not cell:isEmpty() then count2 = count2 + 1 end
		end)
		unitTest:assertEquals(51, count1)
		unitTest:assertEquals(47, count2)

		local agent1 = Agent{}

		local soc1 = Society{
			instance = agent1,
			quantity = 10
		}
		unitTest:assertEquals(10, #soc1)

		local counter = 1
		forEachAgent(soc1, function(a)
			if counter >= 6 then
				a.gender = "male"
			else
				a.gender = "female"
			end
			counter = counter + 1
			unitTest:assertType(a, "Agent")
		end)

		local groups = soc1:split("gender")
		unitTest:assertEquals(5, #groups.male)
		unitTest:assertEquals(5, #groups.female)

		local ag = soc1:sample()
		unitTest:assertType(ag, "Agent")
		local ev = Event{}
		ag:execute(ev)

		ag:die()
		unitTest:assertEquals(9, #soc1)

		local ag = Agent{
			age = 0,
			human = true,
			gender = "male"
		}

		local soc = Society{
			instance = ag,
			quantity = 10
		}

		unitTest:assertEquals(soc:age(), 0)
		unitTest:assertEquals(soc:human(), 10)
		unitTest:assertEquals(soc:gender().male, 10)
	end,
	__len = function(unitTest)
		local sc1 = Society{
			instance = Agent{},
			quantity = 10
		}

		unitTest:assertEquals(10, #sc1)
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
		unitTest:assertEquals(tostring(soc1), [[age            function
agents         table of size 2
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
		unitTest:assertEquals(tostring(aa), [[age             number [8]
cObj_           userdata
id              string [2]
parent          Society
socialnetworks  table of size 0
state_          userdata
]])
	end,
	add = function(unitTest)
		local ag1 = Agent{}

		local sc1 = Society{
			instance = ag1,
			quantity = 20
		}

		unitTest:assertEquals(20, #sc1)
		local agent = sc1:add()
		unitTest:assertEquals(21, #sc1)
		unitTest:assertType(agent, "Agent")
		unitTest:assertEquals(agent.id, "21")

		local cs = CellularSpace{xdim = 10}
		local e = Environment{cs, sc1}

		e:createPlacement{}
		local ag2 = Agent{}

		local agent = sc1:add(ag2)
		unitTest:assertEquals(22, #sc1)
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
			unitTest:assertNull(ag:getSocialNetwork())
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

		unitTest:assertEquals(5046,  count_prob)
		unitTest:assertEquals(100,   count_quant)
		unitTest:assertEquals(10000, count_all)

		local cs = CellularSpace{xdim = 5}
		cs:createNeighborhood()

		local env = Environment{cs, predators}
		env:createPlacement()

		predators:createSocialNetwork{strategy = "cell", name = "c"}
		predators:createSocialNetwork{strategy = "neighbor", name = "n"}

		local count_c = 0
		local count_n = 0
		forEachAgent(predators, function(ag)
			count_c  = count_c + #ag:getSocialNetwork("c")
			count_n  = count_n + #ag:getSocialNetwork("n")
		end)

		unitTest:assertEquals(370, count_c)
		unitTest:assertEquals(2356, count_n)

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
		unitTest:assertEquals(0, #sc:sample():getSocialNetwork("void"))

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

		predators:createSocialNetwork{probability = 0.5, name = "friends", inmemory = false}
		predators:createSocialNetwork{quantity = 1, name = "boss", inmemory = false}
		predators:createSocialNetwork{filter = function() return true end, name = "all", inmemory = false}

		local count_prob = 0
		local count_quant = 0
		local count_all = 0

		forEachAgent(predators, function(ag)
			count_prob  = count_prob  + #ag:getSocialNetwork("friends")
			count_quant = count_quant + #ag:getSocialNetwork("boss")
			count_all   = count_all   + #ag:getSocialNetwork("all")
		end)

		unitTest:assertEquals(4943,  count_prob)
		unitTest:assertEquals(100,   count_quant)
		unitTest:assertEquals(10000, count_all)

		local count_prob = 0
		local count_quant = 0
		local count_all = 0

		forEachAgent(predators, function(ag)
			count_prob  = count_prob  + #ag:getSocialNetwork("friends")
			count_quant = count_quant + #ag:getSocialNetwork("boss")
			count_all   = count_all   + #ag:getSocialNetwork("all")
		end)

		unitTest:assertEquals(5019,  count_prob)
		unitTest:assertEquals(100,   count_quant)
		unitTest:assertEquals(10000, count_all)

		local cs = CellularSpace{xdim = 5}
		cs:createNeighborhood()

		local env = Environment{cs, predators}
		env:createPlacement()

		predators:createSocialNetwork{strategy = "cell", name = "c", inmemory = false}
		predators:createSocialNetwork{strategy = "neighbor", name = "n", inmemory = false}

		local count_c = 0
		local count_n = 0
		forEachAgent(predators, function(ag)
			count_c  = count_c + #ag:getSocialNetwork("c")
			count_n  = count_n + #ag:getSocialNetwork("n")
		end)

		unitTest:assertEquals(384, count_c)
		unitTest:assertEquals(2168, count_n)

		predators:sample():die()

		local count_c = 0
		local count_n = 0
		forEachAgent(predators, function(ag)
			count_c  = count_c + #ag:getSocialNetwork("c")
			count_n  = count_n + #ag:getSocialNetwork("n")
		end)


		unitTest:assertEquals(380, count_c)
		unitTest:assertEquals(2094, count_n)
	end,
	clear = function(unitTest)
		local agent1 = Agent{}

		local soc1 = Society{
			instance = agent1,
			quantity = 10
		}

		soc1:clear()
		unitTest:assertEquals(0, #soc1)
	end,
	get = function(unitTest)
		local nonFooAgent = Agent{}

		local soc = Society{
			instance = nonFooAgent,
			quantity = 10
		}

		unitTest:assertType(soc:get(1), "Agent")

		unitTest:assertNull(soc.idindex)
		
		local ag = soc:get(1)
		unitTest:assertEquals(soc:get(ag.id), ag)
		unitTest:assertEquals(getn(soc.idindex), 10)

		ag = soc:add()

		unitTest:assertEquals(getn(soc.idindex), 10)
		unitTest:assertEquals(soc:get(ag.id), ag)
		unitTest:assertEquals(getn(soc.idindex), 11)
	end,
	remove = function(unitTest)
		local agent1 = Agent{}

		local soc1 = Society{
			instance = agent1,
			quantity = 10
		}

		soc1:remove(soc1:sample())
		unitTest:assertEquals(9, #soc1)

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

		unitTest:assertEquals(9, #soc1)
	end,
	sample = function(unitTest)
		local agent1 = Agent{}

		local soc1 = Society{
			instance = agent1,
			quantity = 10
		}

		local ag = soc1:sample()
		unitTest:assertType(ag, "Agent")
	end,
	synchronize = function(unitTest)
		local randomObj = Random{}
		randomObj:reSeed(0)

		local received = 0
		local sugar = 0
		local nonFooAgent = Agent{
			init = function(self)
				self.age = randomObj:integer(10)
			end,
			execute = function(self)
				self.age = self.age + 1
			end,
			on_message = function(m)
				received = received + 1
			end,
			on_sugar = function(m)
				sugar = sugar + 1
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

		unitTest:assertEquals(3, #soc)

		local friends = SocialNetwork()
		friends:add(john)
		friends:add(mary)

		myself:addSocialNetwork(friends) -- adding two connections to myself
		unitTest:assertEquals(2, #myself:getSocialNetwork())

		local sum = 0
		forEachConnection(myself, function(self, friend)
			sum = sum + friend.age
		end)

		unitTest:assertEquals(12, sum)

		forEachConnection(myself, function(self, friend)
			myself:message{receiver = friend}
		end)
		unitTest:assertEquals(2, received)

		forEachConnection(myself, function(self, friend)
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{receiver = friend, delay = randomObj:integer(1, 10)}
			myself:message{subject = "sugar", receiver = friend, delay = 10}
		end)

		--[[
		-- to verify the delayed messages
		forEachElement(soc.messages, function(_, mes)
			print(tostring(mes.subject))
			print(tostring(mes.delay))
		end)
		--]]

		soc:synchronize()
		unitTest:assertEquals(5, received)

		local t = Timer{
			Event{period = 4, action = soc}
		}

		t:execute(8)
		unitTest:assertEquals(14, received)
		unitTest:assertEquals(0, sugar)

		soc:synchronize(1.1)

		unitTest:assertEquals(16, received)

		soc:synchronize(20)
		unitTest:assertEquals(16, received)
		unitTest:assertEquals(2, sugar)
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

		unitTest:assertEquals(4,#g.foo)
		unitTest:assertEquals(10,#g.foo + #g.nonfoo)

		local g3 = soc:split(function(ag)
			if ag.age < 3 then return 1
			elseif ag.age < 7 then return 2
			else return 3
			end
		end)

		unitTest:assertEquals(4, #g3[2])
		unitTest:assertEquals(10, #g3[1] + #g3[2] + #g3[3])
	end
}

