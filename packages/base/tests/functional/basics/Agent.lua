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

return{
	Agent = function(unitTest)
		local singleFooAgent = Agent{
			id = "singleFoo",
			size = 10,
			execute = function(self)
				self.size = self.size + 1
				self:walk()
			end}

		unitTest:assertType(singleFooAgent, "Agent")
		unitTest:assertEquals(10, singleFooAgent.size)
		unitTest:assertEquals("singleFoo", singleFooAgent.id)

		local cs = CellularSpace{xdim = 10}

		cs:createNeighborhood()

		local e = Environment{
			cs,
			singleFooAgent
		}

		e:createPlacement()
		unitTest:assertType(singleFooAgent:getCell(), "Cell")
		unitTest:assertEquals(1, #singleFooAgent:getCell().placement)

		local t = Timer{
			Event{action = singleFooAgent}
		}

		t:run(10)
		unitTest:assertEquals(20, singleFooAgent.size)

		unitTest:assertType(singleFooAgent:getCell(), "Cell")
		unitTest:assertEquals(1, #singleFooAgent:getCell().placement)

		local count = 0
		forEachCell(cs, function(cell)
			count = count + #cell.placement
		end)
		unitTest:assertEquals(1, count)
	end,
	__call = function(unitTest)
		local BasicAgent = Agent{
			value = 0,
			add = function(self)
				self.value = self.value + 1
			end
		}

		local instance = BasicAgent{}

		unitTest:assertType(instance, "Agent")
		unitTest:assertEquals(instance.value, 0)
		instance:add()
		unitTest:assertEquals(instance.value, 1)

		local Ag1 = Agent{value = 0}
		local Ag2 = Ag1{value2 = 5}
		local Ag3 = Ag2{value3 = 4}

		unitTest:assertEquals(Ag3.value, 0)
		unitTest:assertEquals(Ag3.value2, 5)
		unitTest:assertEquals(Ag3.value3, 4)
	end,
	__tostring = function(unitTest)
		local ag1 = Agent{
			name = "nonfoo",
			init = function() end,
			execute = function() end
		}
		unitTest:assertEquals(tostring(ag1), [[cObj_           userdata
execute         function
init            function
name            string [nonfoo]
socialnetworks  vector of size 0
]])

		local predator = Agent{
			energy = 40,
			name = "predator",
			execute = function(self) return self.energy end
		}

		local predators = Society{
			instance = predator,
			quantity = 5
		}

		local cs = CellularSpace{xdim = 5}

		local e = Environment{predators, cs}
		e:createPlacement()

		unitTest:assertEquals(tostring(predators:sample()), [[cObj_           userdata
cell            Cell
cells           vector of size 1
id              string [4]
parent          Society
placement       Trajectory
socialnetworks  vector of size 0
state_          State
]])
	end,
	add = function(unitTest)
		local ag = Agent{}
		local cs = CellularSpace{xdim = 5}
		local traj = Trajectory{target = cs}

		ag:add(traj)

		unitTest:assert(true)
	end,
	addSocialNetwork = function(unitTest)
		local ag1 = Agent{}
		unitTest:assertNil(ag1:getSocialNetwork("notfriends"))

		local sn = SocialNetwork()
		ag1:addSocialNetwork(sn)
		unitTest:assertType(ag1:getSocialNetwork(), "SocialNetwork")
		unitTest:assertEquals(#ag1:getSocialNetwork(), 0)

		local ag = Agent{}

		local sc = Society{instance = ag, quantity = 5}

		sn = SocialNetwork()
		forEachAgent(sc, function(agent)
			sn:add(agent)
		end)

		ag:addSocialNetwork(sn)
		unitTest:assert(#ag:getSocialNetwork() == 5)
	end,
	die = function(unitTest)
		local predator = Agent{
			energy = 40,
			name = "predator",
			execute = function(self) return self.energy end
		}

		local predators = Society{
			instance = predator,
			quantity = 5
		}

		local cs = CellularSpace{xdim = 5}

		local e = Environment{predators, cs}
		e:createPlacement()

		unitTest:assertEquals(5, #predators)
		local dead = predators.agents[2]
		dead:die()

		unitTest:assertType(dead, "<Dead Agent>")
		unitTest:assertEquals(4, #predators)

		local warning_function = function()
			dead:execute()
		end
		unitTest:assertWarning(warning_function, "Trying to execute a dead agent.")
	end,
	emptyNeighbor = function(unitTest)
		local ag = Agent{}
		local cs = CellularSpace{xdim = 2}
		cs:createNeighborhood()
		local soc = Society{instance = ag, quantity = 4}
		Environment{soc, cs}:createPlacement{}

		unitTest:assertNil(soc:sample():emptyNeighbor())

		cs = CellularSpace{xdim = 2}
		cs:createNeighborhood{}
		ag = Agent{}
		soc = Society{instance = ag, quantity = 3}
		Environment{soc, cs}:createPlacement{}

		for _ = 1, 20 do
			unitTest:assertType(soc:sample():emptyNeighbor(), "Cell")
		end
	end,
	execute = function(unitTest)
		local count = 0
		local ag = Agent{
			State{
				id = "first",
				Flow{function() count = count + 1 end}
			}
		}

		local t = Timer{
			Event{action = function(ev)
				ag:execute(ev)
			end}
		}
		t:run(1)
		unitTest:assertEquals(count, 1)
	end,
	getCell = function(unitTest)
		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3}
		cs:createNeighborhood()
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{}

		unitTest:assertType(ag1:getCell(), "Cell")
	end,
	getCells = function(unitTest)
		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3}
		cs:createNeighborhood()
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{}

		unitTest:assertType(ag1:getCells(), "table")
		unitTest:assertType(ag1:getCells()[1], "Cell")
	end,
	getLatency = function(unitTest)
		local jumps = 0
		local flows = 0
		local a = Agent{
			x = 3,
			State{
				id = "stop",
				Jump{
					function(ev, self)
						jumps = jumps + 1
						if self.x > 5 then
							unitTest:assertEquals(6, self.x)
							unitTest:assertEquals(3, ev:getTime())
							unitTest:assertEquals(0, self:getLatency())
							return true
						end
					end,
					target = "go"
				},
				Flow{function(_, self)
					flows = flows + 1
					self.x = self.x + 1
				end}
			},
			State{
				id = "go",
				Jump{
					function(ev, self)
						jumps = jumps + 1
						if self.x < 3 then
							unitTest:assertEquals(7, ev:getTime())
							unitTest:assertEquals(2, self.x)
							unitTest:assertEquals(3, self:getLatency())
							return true
						end
					end,
					target = "stop"
				},
				Jump{
					function()
						jumps = jumps + 1
						return false
					end,
					target = "stop"
				},
				Flow{function(_, self)
					flows = flows + 1
					self.x = self.x - 1
				end},
				Flow{function()
					flows = flows + 1
				end}
			}
		}

		unitTest:assertEquals(0, a:getLatency())

		a:execute(Event{action = function() end})
		unitTest:assertEquals(0, a:getLatency())
		unitTest:assertEquals(4, a.x)

		local t = Timer{
			Event{action = function(ev)
				a:execute(ev)
			end}
		}

		t:run(10)

		unitTest:assertEquals(6, a.x)
		unitTest:assertEquals(7, a:getLatency())

		unitTest:assertEquals(15, flows)
		unitTest:assertEquals(17, jumps)
	end,
	getSocialNetwork = function(unitTest)
		local ag1 = Agent{}
		local sn = SocialNetwork()
		ag1:addSocialNetwork(sn)
		local sn2 = ag1:getSocialNetwork()
		unitTest:assertEquals(sn2, sn)

		local predator = Agent{}

		local predators = Society{
			instance = predator,
			quantity = 10
		}

		predators:createSocialNetwork{probability = 0.5, inmemory = false}

		sn2 = predators:sample():getSocialNetwork()
		unitTest:assertType(sn2, "SocialNetwork")
	end,
	getStateName = function(unitTest)
		local a = Agent{
			x = 3,
			State{
				id = "stop",
				Jump{
					function(ev, self)
						if self.x > 5 then
							unitTest:assertEquals(6, self.x)
							unitTest:assertEquals(3, ev:getTime())
							unitTest:assertEquals(0, self:getLatency())
							return true
						end
					end,
					target = "go"
				},
				Flow{function(_, self)
					self.x = self.x + 1
				end}
			},
			State{
				id = "go",
				Jump{
					function(ev, self)
						if self.x < 3 then
							unitTest:assertEquals(7, ev:getTime())
							unitTest:assertEquals(2, self.x)
							unitTest:assertEquals(3, self:getLatency())
							return true
						end
					end,
					target = "stop"
				},
				Flow{function(_, self)
					self.x = self.x - 1
				end}
			}
		}

		unitTest:assertEquals("stop", a:getStateName())

		a:execute(Event{action = function() end})
		unitTest:assertEquals("stop", a:getStateName())

		local t = Timer{
			Event{action = function(ev)
				a:execute(ev)
			end}
		}

		t:run(5)
		unitTest:assertEquals("go", a:getStateName())
		t:run(10)
		unitTest:assertEquals("stop", a:getStateName())
	end,
	getTrajectoryStatus = function(unitTest)
		local cs = CellularSpace{xdim = 2}

		local ag1 = Agent{
			it = Trajectory{target = cs},
			cont = 0,
			State{
				id = "first",
				Jump{
					function(_, agent)
						cont = cont + 1
						if agent.cont < 10 then
							agent.cont = agent.cont + 1
							return true
						end
						if agent.cont == 10 then agent.cont = 0 end
						return false
					end,
					target = "second"
				}
			},
			State{
				id = "second",
				Jump{
					function(_, agent)
						cont = cont + 1
						if agent.cont < 10 then
							agent.cont = agent.cont + 1
							return true
						end
						if agent.cont == 10 then agent.cont = 0 end
						return false
					end,
					target = "first"
				}
			}
		}

		unitTest:assert(not ag1:getTrajectoryStatus())

		ag1:setTrajectoryStatus(true)
		unitTest:assert(ag1:getTrajectoryStatus())

		ag1:setTrajectoryStatus()
		unitTest:assert(not ag1:getTrajectoryStatus())

		ag1:setTrajectoryStatus(false)
		unitTest:assert(not ag1:getTrajectoryStatus())
	end,
	init = function(unitTest)
		local ag1 = Agent{
			init = function(self)
				self.value = 2
			end
		}

		unitTest:assertNil(ag1.value)
		ag1:init()
		unitTest:assertEquals(2, ag1.value)
	end,
	leave = function(unitTest)
		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3}
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void"}
		local cell = cs.cells[1]
		ag1:enter(cell, "placement")
		ag1:leave(nil, "placement")

		unitTest:assertNil(ag1:getCell("placement"))

		ag1 = Agent{}
		cs = CellularSpace{xdim = 3}
		myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void"}
		cell = cs.cells[1]
		ag1:enter(cell, "placement")
		ag1:leave("placement")

		unitTest:assertNil(ag1:getCell("placement"))
	end,
	message = function(unitTest)
		local ag = Agent{
			money = 0,
			on_message = function(self,	m)
				self.money = self.money + m.value
			end
		}

		local sc = Society{instance = ag, quantity = 2}
		local ag1 = sc.agents[1]
		local ag2 = sc.agents[2]

		ag1:message{
			receiver = ag2,
			value = 5
		}

		unitTest:assert(ag2.money == 5)
	end,
	on_message = function(unitTest)
		local ag = Agent{
			money = 0,
			on_message = function(self,	m)
				self.money = self.money + m.value
			end
		}

		local sc = Society{instance = ag, quantity = 2}
		local ag1 = sc.agents[1]
		local ag2 = sc.agents[2]

		ag1:message{
			receiver = ag2,
			delay = 1.5,
			value = 5
		}

		unitTest:assert(ag2.money == 0)
		sc:synchronize(0.5)
		unitTest:assert(ag2.money == 0)
		sc:synchronize(1)
		unitTest:assert(ag2.money == 5)
	end,
	reproduce = function(unitTest)
		local predator = Agent{
			energy = 40,
			name = "predator",
			execute = function(self) return self.energy end
		}

		local predators = Society{
			instance = predator,
			quantity = 5
		}

		local cs = CellularSpace{xdim = 10}

		local env = Environment{predators, cs}

		env:createPlacement{}
		env:createPlacement{name = "house"}

		predators.agents[2]:die()

		predators.agents[4]:reproduce()

		predators.agents[4]:reproduce{age = 0}
		unitTest:assertEquals(6, #predators)

		local cont = 3
		local sum = 0
		forEachAgent(predators, function(agent)
			sum = sum + agent:execute()
			if cont == 3 then predators.agents[3]:die() end
			if cont == 1 then predators.agents[4]:die() end
			cont = cont - 1
		end)
		unitTest:assertEquals(160, sum)
		unitTest:assertEquals(4, #predators)

		forEachAgent(predators, function(agent)
			agent:reproduce{age = 0}
		end)
		unitTest:assertEquals(8, #predators)
	end,
	sample = function(unitTest)
		local ag = Agent{}
		local sc = Society{instance = ag, quantity = 5}

		local sn = SocialNetwork()
		forEachAgent(sc, function(agent)
			sn:add(agent)
		end)

		ag:addSocialNetwork(sn)
		unitTest:assertType(ag:sample(), "Agent")
	end,
	setTrajectoryStatus = function(unitTest)
		local cs = CellularSpace{xdim = 2}
		local cont = 0

		local ag1 = Agent{
			it = Trajectory{target = cs},
			cont = 0,
			State{
				id = "first",
				Jump{
					function(_, agent)
						cont = cont + 1
						if agent.cont < 10 then
							agent.cont = agent.cont + 1
							return true
						end
						if agent.cont == 10 then agent.cont = 0 end
						return false
					end,
					target = "second"
				}
			},
			State{
				id = "second",
				Jump{
					function(_, agent)
						cont = cont + 1
						if agent.cont < 10 then
							agent.cont = agent.cont + 1
							return true
						end
						if agent.cont == 10 then agent.cont = 0 end
						return false
					end,
					target = "first"
				}
			}
		}

		local ev = Event{action = function() end}

		ag1:setTrajectoryStatus(false)
		ag1.it.greater = function(a, b) return a.x > b.x end
		ag1.it:sort()
		cont = 0
		ag1:execute(ev)
		unitTest:assertEquals(11, cont)

		ag1:setTrajectoryStatus(true)
		ag1.it.greater = function(a, b) return a.x > b.x end
		ag1.it:sort()
		cont = 0
		ag1:execute(ev)
		unitTest:assertEquals(44, cont)


		ag1.it.greater = greaterByCoord(">")
		ag1.it:sort()
		cont = 0
		ag1:execute(ev)
		unitTest:assertEquals(44, cont)

		ag1.it.select = function(cell) return cell.x ~= 1 end
		ag1.it:filter()
		cont = 0
		ag1:execute(ev)
		unitTest:assertEquals(22, cont)

		ag1.it.select = function() return true end
		ag1.it:rebuild()
		cont = 0
		ag1:execute(ev)
		unitTest:assertEquals(44, cont)

		ag1.it:rebuild()
		cont = 0
		ag1:execute(ev)
		unitTest:assertEquals(44, cont)
	end,
	walk = function(unitTest)
		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3}
		cs:createNeighborhood()
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void"}
		local c1 = cs.cells[1]
		ag1:enter(c1,"placement")

		ag1:walk()
		unitTest:assertType(ag1:getCell(), "Cell")
	end,
	walkIfEmpty = function(unitTest)
		local ag = Agent{}
		local cs = CellularSpace{xdim = 2}
		cs:createNeighborhood()
		local soc = Society{instance = ag, quantity = 4}
		Environment{soc, cs}:createPlacement{}

		unitTest:assert(not soc:sample():walkIfEmpty())

		cs = CellularSpace{xdim = 2}
		cs:createNeighborhood{}
		ag = Agent{}
		soc = Society{instance = ag, quantity = 3}
		Environment{soc, cs}:createPlacement{}

		local quant = 0

		for _ = 1, 100 do
			if soc:sample():walkIfEmpty() then
				quant = quant + 1
			end
		end

		unitTest:assertEquals(quant, 33)
	end,
	walkToEmpty = function(unitTest)
		local ag = Agent{}
		local cs = CellularSpace{xdim = 2}
		cs:createNeighborhood()
		local soc = Society{instance = ag, quantity = 4}
		Environment{soc, cs}:createPlacement{}

		unitTest:assert(not soc:sample():walkToEmpty())

		cs = CellularSpace{xdim = 2}
		cs:createNeighborhood{}
		ag = Agent{}
		soc = Society{instance = ag, quantity = 3}
		Environment{soc, cs}:createPlacement{}

		for _ = 1, 20 do
			unitTest:assert(soc:sample():walkToEmpty())
		end
	end,
	enter = function(unitTest)
		local predator = Agent{}

		local predators = Society{
			instance = predator,
			quantity = 5
		}

		local cs = CellularSpace{xdim = 5}

		local e = Environment{predators, cs}
		e:createPlacement()

		local c = cs:sample()

		local warning_func = function()
			predators:sample():enter(c)
		end
		unitTest:assertWarning(warning_func, "Agent is already inside of a Cell. Use Agent:move() instead.")
	end,
}

