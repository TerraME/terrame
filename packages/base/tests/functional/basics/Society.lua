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
		local singleFooAgent = Agent{}

		local nonFooSociety = Society{
			instance = singleFooAgent,
			quantity = 0
		}

		unitTest:assertType(nonFooSociety, "Society")
		unitTest:assertEquals(0, #nonFooSociety)

		singleFooAgent = Agent{
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
				unitTest:assertType(self.parent, "Society")
				self.male = true
			end,
			age = Random{min = 0, max = 10, step = 1},
			gender = Random{"male", "female"},
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

		unitTest:assertNil(nonFooAgent.charge)

		local warning_func = function()
			nonFooSociety = Society{
				instance = nonFooAgent,
				quantity = 50,
				male = 5
			}
		end
		unitTest:assertWarning(warning_func, "Attribute 'male' will not be replaced by a summary function.")
		unitTest:assertType(nonFooSociety, "Society")
		unitTest:assertEquals(50, #nonFooSociety)
		unitTest:assertEquals(nonFooSociety:gender().male, 24)
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

		env:createPlacement{}

		local t = Timer{
			Event {action = nonFooSociety},
		}

		t:run(50)

		unitTest:assertEquals(5, findCounter)

		local count1 = 0
		local count2 = 0
		forEachCell(cs, function(cell)
			count1 = count1 + #cell.placement
			if not cell:isEmpty() then count2 = count2 + 1 end
		end)
		unitTest:assertEquals(51, count1)
		unitTest:assertEquals(50, count2)

		local agent1 = Agent{set = function() end}

		local soc1

		warning_func = function()
			soc1 = Society{
				instance = agent1,
				quantity = 10,
				set = 5
			}
		end
		unitTest:assertWarning(warning_func, "Attribute 'set' will not be replaced by a summary function.")
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
		local ev = Event{action = function() end}
		ag:execute(ev)

		ag:die()
		unitTest:assertEquals(9, #soc1)

		ag = Agent{
			age = 0,
			human = true,
			gender = "male",
			getOld = function(self)
				if self.age > 0 then
					return false
				end

				self.age = self.age + 1
			end,
			value = 4,
			male = true
		}

		local soc

		warning_func = function()
			soc = Society{
				instance = ag,
				quantity = 10,
				value = 5
			}
		end
		unitTest:assertWarning(warning_func, "Attribute 'value' will not be replaced by a summary function.")
		unitTest:assertEquals(soc:age(), 0)
		unitTest:assertEquals(soc:human(), 10)
		unitTest:assertEquals(soc:gender().male, 10)

		unitTest:assert(soc:getOld())
		unitTest:assertEquals(soc:age(), 10)
		unitTest:assert(not soc:getOld())
		unitTest:assertEquals(soc:age(), 10)

		ag = Agent{
			age = 0,
			human = true,
			gender = "male",
			getOld = function(self)
				if self.age > 0 then
					return false
				end

				self.age = self.age + 1
			end,
			male = true
		}

		warning_func = function()
			soc = Society{
				instance = ag,
				quantity = 10,
				male = 5
			}
		end
		unitTest:assertWarning(warning_func, "Attribute 'male' will not be replaced by a summary function.")
		unitTest:assertEquals(soc:age(), 0)
		unitTest:assertEquals(soc:human(), 10)
		unitTest:assertEquals(soc:gender().male, 10)

		unitTest:assert(soc:getOld())
		unitTest:assertEquals(soc:age(), 10)
		unitTest:assert(not soc:getOld())
		unitTest:assertEquals(soc:age(), 10)

		ag = Agent{
			age = 0,
			human = true,
			gender = "male",
			getOld = function(self)
				if self.age > 0 then
					return false
				end

				self.age = self.age + 1
			end,
			status = "alive"
		}

		warning_func = function()
			soc = Society{
				instance = ag,
				quantity = 10,
				status = 5
			}
		end
		unitTest:assertWarning(warning_func, "Attribute 'status' will not be replaced by a summary function.")
		unitTest:assertEquals(soc:age(), 0)
		unitTest:assertEquals(soc:human(), 10)
		unitTest:assertEquals(soc:gender().male, 10)

		unitTest:assert(soc:getOld())
		unitTest:assertEquals(soc:age(), 10)
		unitTest:assert(not soc:getOld())
		unitTest:assertEquals(soc:age(), 10)

		ag = Agent{
			age = 0,
			human = true,
			gender = "male",
			getOld = function(self)
				if self.age > 0 then
					return false
				end

				self.age = self.age + 1
			end,
			enter = function() end
		}

		warning_func = function()
			soc = Society{
				instance = ag,
				quantity = 10
			}
		end
		unitTest:assertWarning(warning_func, "Function 'enter()' is replaced in the instance.")
		unitTest:assertEquals(soc:age(), 0)
		unitTest:assertEquals(soc:human(), 10)
		unitTest:assertEquals(soc:gender().male, 10)

		unitTest:assert(soc:getOld())
		unitTest:assertEquals(soc:age(), 10)
		unitTest:assert(not soc:getOld())
		unitTest:assertEquals(soc:age(), 10)

		ag = Agent{
			age = 0,
			human = true,
			gender = "male",
			getOld = function(self)
				if self.age > 0 then
					return false
				end

				self.age = self.age + 1
			end,
			instance = function() end
		}

		warning_func = function()
			soc = Society{
				instance = ag,
				quantity = 10
			}
		end

		unitTest:assertWarning(warning_func, "Attribute 'instance' belongs to both Society and Agent.")
		unitTest:assertEquals(soc:age(), 0)
		unitTest:assertEquals(soc:human(), 10)
		unitTest:assertEquals(soc:gender().male, 10)

		unitTest:assert(soc:getOld())
		unitTest:assertEquals(soc:age(), 10)
		unitTest:assert(not soc:getOld())
		unitTest:assertEquals(soc:age(), 10)

		-- inheritance
		local Ag1 = Agent{
			value1 = 0,
			rand1 = Random{min = 0,   max = 100},
			copy = 3
		}

		local Ag2 = Ag1{
			value2 = 5,
			rand2 = Random{min = 100, max = 200},
			copy = 5
		}

		local Ag3 = Ag2{
			value3 = 4,
			rand3 = Random{min = 200, max = 300}
		}

		warning_func = function()
			soc = Society{
				instance = Ag3,
				quantity = 5
			}
		end

		unitTest:assertWarning(warning_func, "Attribute 'copy' is replaced in the instance.")

		ag = soc:sample()

		unitTest:assertEquals(ag.value1, 0)
		unitTest:assertEquals(ag.value2, 5)
		unitTest:assertEquals(ag.value3, 4)
		unitTest:assertType(ag.rand1, "number")
		unitTest:assertType(ag.rand2, "number")
		unitTest:assertType(ag.rand3, "number")
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
			init = function(ag)
				ag.age = 8
			end,
			execute = function() end
		}

		local soc1 = Society{
			instance = ag1,
			quantity = 2
		}
		unitTest:assertEquals(tostring(soc1), [[addSocialNetwork     function
age                  function
agents               vector of size 2
autoincrement        number [3]
cObj_                userdata
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
instance             Agent
leave                function
message              function
messages             vector of size 0
move                 function
name                 function
on_message           function
placements           vector of size 0
reproduce            function
setTrajectoryStatus  function
walk                 function
walkIfEmpty          function
walkToEmpty          function
]])

		local aa = soc1.agents[2]
		unitTest:assertEquals(tostring(aa), [[age             number [8]
cObj_           userdata
id              string [2]
parent          Society
socialnetworks  vector of size 0
state_          State
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

		agent = sc1:add(ag2)
		unitTest:assertType(agent, "Agent")
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
			quantity = 20
		}

		forEachAgent(predators, function(ag)
			unitTest:assertNil(ag:getSocialNetwork())
		end)

		local warning_func = function()
			predators:createSocialNetwork{strategy = "probability", probability = 0.5, name = "friends"}
		end

		unitTest:assertWarning(warning_func, defaultValueMsg("strategy", "probability"))

		predators:createSocialNetwork{quantity = 1, name = "boss"}

		warning_func = function()
			predators:createSocialNetwork{filter = function() return true end, name = "all", abc = true}
		end

		unitTest:assertWarning(warning_func, unnecessaryArgumentMsg("abc"))

		local count_prob = 0
		local count_quant = 0
		local count_all = 0

		forEachAgent(predators, function(ag)
			count_prob  = count_prob  + #ag:getSocialNetwork("friends")
			count_quant = count_quant + #ag:getSocialNetwork("boss")
			count_all   = count_all   + #ag:getSocialNetwork("all")
		end)

		unitTest:assertEquals(252, count_prob)
		unitTest:assertEquals(20,  count_quant)
		unitTest:assertEquals(400, count_all)

		local cs = CellularSpace{xdim = 5}
		cs:createNeighborhood()
		cs:createNeighborhood{name = "2"}

		local env = Environment{cs, predators}
		env:createPlacement{max = 5}

		warning_func = function()
			predators:createSocialNetwork{strategy = "cell", name = "c", quantity = 1}
		end
		unitTest:assertWarning(warning_func, unnecessaryArgumentMsg("quantity"))

		warning_func = function()
			predators:createSocialNetwork{strategy = "neighbor", name = "n", quantity = 1}
		end
		unitTest:assertWarning(warning_func, unnecessaryArgumentMsg("quantity"))

		predators:createSocialNetwork{neighborhood = "2", name = "n2"}

		local count_c = 0
		local count_n = 0
		local count_n2 = 0
		forEachAgent(predators, function(ag)
			count_c  = count_c  + #ag:getSocialNetwork("c")
			count_n  = count_n  + #ag:getSocialNetwork("n")
			count_n2 = count_n2 + #ag:getSocialNetwork("n2")
		end)

		unitTest:assertEquals(80, count_c)
		unitTest:assertEquals(50, count_n)
		unitTest:assertEquals(50, count_n2)

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

		warning_func = function()
			sc:createSocialNetwork{
				strategy = "void",
				name = "void",
				probability = 0.5
			}
		end
		unitTest:assertWarning(warning_func, unnecessaryArgumentMsg("probability"))
		unitTest:assertEquals(0, #sc:sample():getSocialNetwork("void"))

		ag1 = sc:sample()
		local ag2 = sc:sample()

		ag1:getSocialNetwork("void"):add(ag2)

		unitTest:assertEquals(1, #ag1:getSocialNetwork("void"))

		-- on the fly social networks
		predator = Agent{
			energy = 40,
			name = "predator",
			execute = function(self)
				new_cell = self:getCell("house"):getNeighborhood():sample(randomObj)
				self:move(new_cell, "house")
				self:walk("stay")
			end
		}

		predators = Society{
			instance = predator,
			quantity = 20
		}

		predators:createSocialNetwork{probability = 0.5, name = "friends", inmemory = false}
		predators:createSocialNetwork{quantity = 1, name = "boss", inmemory = false}
		predators:createSocialNetwork{filter = function() return true end, name = "all", inmemory = false}

		count_prob = 0
		count_quant = 0
		count_all = 0

		forEachAgent(predators, function(ag)
			count_prob  = count_prob  + #ag:getSocialNetwork("friends")
			count_quant = count_quant + #ag:getSocialNetwork("boss")
			count_all   = count_all   + #ag:getSocialNetwork("all")
		end)

		unitTest:assertEquals(258, count_prob)
		unitTest:assertEquals(20,  count_quant)
		unitTest:assertEquals(400, count_all)

		count_prob = 0
		count_quant = 0
		count_all = 0

		forEachAgent(predators, function(ag)
			count_prob  = count_prob  + #ag:getSocialNetwork("friends")
			count_quant = count_quant + #ag:getSocialNetwork("boss")
			count_all   = count_all   + #ag:getSocialNetwork("all")
		end)

		unitTest:assertEquals(242, count_prob)
		unitTest:assertEquals(20,  count_quant)
		unitTest:assertEquals(400, count_all)

		cs = CellularSpace{xdim = 5}
		cs:createNeighborhood()

		env = Environment{cs, predators}
		env:createPlacement{max = 4}

		predators:createSocialNetwork{strategy = "cell", name = "c", inmemory = false}
		predators:createSocialNetwork{strategy = "neighbor", name = "n", inmemory = false}

		count_c = 0
		count_n = 0
		forEachAgent(predators, function(ag)
			count_c  = count_c + #ag:getSocialNetwork("c")
			count_n  = count_n + #ag:getSocialNetwork("n")
		end)

		unitTest:assertEquals(60, count_c)
		unitTest:assertEquals(64, count_n)

		predators:sample():die()

		count_c = 0
		count_n = 0
		forEachAgent(predators, function(ag)
			count_c  = count_c + #ag:getSocialNetwork("c")
			count_n  = count_n + #ag:getSocialNetwork("n")
		end)

		unitTest:assertEquals(54, count_c)
		unitTest:assertEquals(56, count_n)

		predator = Agent{
			energy = 40,
			execute = function() end
		}

		predators = Society{
			instance = predator,
			quantity = 20
		}

		predators:createSocialNetwork{probability = 0.05, name = "friends", symmetric = true}
		predators:createSocialNetwork{quantity = 1, name = "boss", symmetric = true}

		count_prob = 0
		count_quant = 0

		forEachAgent(predators, function(ag)
			count_prob  = count_prob  + #ag:getSocialNetwork("friends")
			count_quant = count_quant + #ag:getSocialNetwork("boss")
		end)

		unitTest:assertEquals(44, count_prob)
		unitTest:assertEquals(40, count_quant)

		-- social networks that must be "in memory"
		predator = Agent{
			energy = 40,
			execute = function() end
		}

		predators = Society{
			instance = predator,
			quantity = 20
		}

		warning_func = function()
			predators:createSocialNetwork{strategy = "erdos", quantity = 40, name = "erdos", abc = false}
		end
		unitTest:assertWarning(warning_func, unnecessaryArgumentMsg("abc"))

		warning_func = function()
			predators:createSocialNetwork{strategy = "barabasi", start = 10, quantity = 2, name = "barabasi", abc = true}
		end
		unitTest:assertWarning(warning_func, unnecessaryArgumentMsg("abc"))

		warning_func = function()
			predators:createSocialNetwork{strategy = "watts", probability = 0.1, quantity = 2, name = "watts", abc = true}
		end
		unitTest:assertWarning(warning_func, unnecessaryArgumentMsg("abc"))

		local count_barabasi = 0
		local count_erdos = 0
		local count_watts = 0

		forEachAgent(predators, function(ag)
			count_barabasi = count_barabasi + #ag:getSocialNetwork("barabasi")
			count_erdos    = count_erdos    + #ag:getSocialNetwork("erdos")
			count_watts    = count_watts    + #ag:getSocialNetwork("watts")
		end)

		unitTest:assertEquals(40, count_barabasi)
		unitTest:assertEquals(80,  count_erdos)
		unitTest:assertEquals(80,  count_watts)
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

		unitTest:assertNil(soc.idindex)

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
		local received = 0
		local sugar = 0
		local nonFooAgent = Agent{
			init = function(self)
				self.age = Random():integer(10)
			end,
			execute = function(self)
				self.age = self.age + 1
			end,
			on_message = function()
				received = received + 1
			end,
			on_sugar = function()
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
		forEachConnection(myself, function(friend)
			sum = sum + friend.age
		end)

		unitTest:assertEquals(15, sum)

		forEachConnection(myself, function(friend)
			myself:message{receiver = friend}
		end)
		unitTest:assertEquals(2, received)

		forEachConnection(myself, function(friend)
			myself:message{receiver = friend, delay = Random():integer(1, 10)}
			myself:message{receiver = friend, delay = Random():integer(1, 10)}
			myself:message{receiver = friend, delay = Random():integer(1, 10)}
			myself:message{receiver = friend, delay = Random():integer(1, 10)}
			myself:message{receiver = friend, delay = Random():integer(1, 10)}
			myself:message{receiver = friend, delay = Random():integer(1, 10)}
			myself:message{receiver = friend, delay = Random():integer(1, 10)}
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
		unitTest:assertEquals(4, received)

		local t = Timer{
			Event{period = 4, action = soc}
		}

		t:run(8)
		unitTest:assertEquals(14, received)
		unitTest:assertEquals(0, sugar)

		soc:synchronize(1.1)

		unitTest:assertEquals(16, received)

		soc:synchronize(20)
		unitTest:assertEquals(16, received)
		unitTest:assertEquals(2, sugar)
	end,
	split = function(unitTest)
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

		local ag = Agent{
			gender = Random{"male", "female"},
			age = Random{min = 1, max = 80, step = 1}
		}

		soc = Society{
			instance = ag,
			quantity = 10
		}

		local groups = soc:split("gender")
		unitTest:assertEquals(#groups.male, 2)
		unitTest:assertEquals(#groups.female, 8)

		forEachAgent(soc, function(magent)
			magent.gender = "male"
		end)

		groups.male:rebuild()
		groups.female:filter()

		unitTest:assertEquals(#groups.male, 10)
		unitTest:assertEquals(#groups.female, 0)
	end
}

