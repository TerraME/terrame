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
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--          Pedro R. Andrade (pedro.andrade@inpe.br)
-------------------------------------------------------------------------------------------

return{
	createPlacement = function(unitTest)
		Random():reSeed(12345)
		local predator = Agent{
			energy = 40,
			name = "predator",
			execute = function(self)
				self:move(self:getCell():getNeighborhood():sample())
			end
		}

		local predators = Society{
			instance = predator,
			quantity = 10
		}

		local ag = Agent{}

		local cs = CellularSpace{xdim = 5}
		cs:createNeighborhood()

		local env = Environment{cs, predators = predators, zag = ag}
		env:createPlacement{max = 1}

		local cont = 0
		forEachCell(cs, function(cell)
			cont = cont + #cell.placement
		end)
		unitTest:assert_equal(11, cont)

		cont = 0
		forEachAgent(predators, function(agent)
			cont = cont + #agent.placement
		end)
		unitTest:assert_equal(10, cont)

		forEachAgent(predators, function(ag)
			ag:reproduce{age = 0}
		end)

		predators:execute()
		predators:execute()

		cont = 0
		forEachCell(cs, function(cell)
			cont = cont + #cell.placement
		end)
		unitTest:assert_equal(21, cont)

		cont = 0
		forEachAgent(predators, function(agent)
			cont = cont + #agent.placement
		end)
		unitTest:assert_equal(20, cont)

		local predator = Agent{name = "predator"}
		local ag = Agent{name = "ag"}

		local predators = Society{
			instance = predator,
			quantity = 199
		}

		local cs = CellularSpace{xdim = 10}

		local env = Environment{cs, pred = predators, zag = ag}
		env:createPlacement{strategy = "uniform"}

		unitTest:assert_equal(#cs.cells[1]:getAgents(), 2)
		unitTest:assert_equal(#cs.cells[2]:getAgents(), 2)
		unitTest:assert_equal(#cs.cells[100]:getAgents(), 2)

		unitTest:assert_equal(cs.cells[100]:getAgents()[1].name, "predator")
		unitTest:assert_equal(cs.cells[100]:getAgents()[2].name, "ag")

		Random():reSeed(12345)

		local predator = Agent{
			energy = 40,
			name = "predator",
			execute = function(self)
				local new_cell = self:getCell("house"):getNeighborhood():sample()
				self:move(new_cell, "house")
				self:walk("stay")
			end
		}

		local predators = Society{
			instance = predator,
			quantity = 100
		}

		local cs = CellularSpace{xdim = 20}
		cs:createNeighborhood()

		local env = Environment{cs, predators}
		env:createPlacement{max = 1, name = "house"}
		env:createPlacement{strategy = "uniform", name = "stay"}
		env:createPlacement{strategy = "void", name = "workingplace"}
			
		local count_house = 0
		local count_stay = 0
		local count_wplace = 0
		forEachCell(cs, function(cell)
			count_house  = count_house  + #cell.house
			count_stay   = count_stay   + #cell.stay
			count_wplace = count_wplace + #cell.workingplace
		end)
		unitTest:assert_equal(100, count_house)
		unitTest:assert_equal(100, count_stay)
		unitTest:assert_equal(0,   count_wplace)

		local max = 0
		forEachCell(cs, function(cell)
			if max < #cell.house then
				max = #cell.house
			end
		end)
		unitTest:assert_equal(1, max)
		unitTest:assert_equal(1, #cs.cells[100].stay)
		unitTest:assert_equal(0, #cs.cells[101].stay)

		predators:execute()
		predators:sample():die()

		count_house = 0
		count_stay = 0
		count_wplace = 0
		forEachCell(cs, function(cell)
			count_house  = count_house  + #cell.house
			count_stay   = count_stay   + #cell.stay
			count_wplace = count_wplace + #cell.workingplace
		end)
		unitTest:assert_equal(99, count_house)
		unitTest:assert_equal(99, count_stay)
		unitTest:assert_equal(0,  count_wplace)

		local predator = Agent{name = "predator"}

		local predators = Society{
			instance = predator,
			quantity = 10
		}

		local cs = CellularSpace{xdim = 10}

		local env = Environment{cs.cells[1], predators}
		env:createPlacement()

		unitTest:assert_equal(#cs.cells[1]:getAgents(), #predators)
	end,
	Environment = function(self)
		local cs = CellularSpace{xdim = 10}

		local a = Agent{
			id = "ag1",
			class = "undefined",
			x = 3,
			State{
				id = "stop",
				Jump{function(ev, self)
						return false
					end,
					target = "stop"
				},
				Flow{function(ev, self)
					self.x = self.x + 1
				end}
			},
		}

		local t = Timer{
			Event{action = function(ev)
				a:execute(ev)
			end}
		}

		local env = Environment{cs, a, t}
		env:execute(10)
		self:assert_equal(13, a.x)

		env = Environment{}

		env:add(cs)
		env:add(a)
		env:add(t)

		env:execute(10)
		--assert_equal(11, env:getTime() ) -- #195
		self:assert_equal(13, a.x)

		local cellCont = 0
		self:assert_equal(cellCont, 0)
		local cs = CellularSpace{xdim = 2}
		forEachCell(cs, function(cell)
			cell.soilType = 0
			cellCont = cellCont + 1
		end)
		self:assert_equal(cellCont, 4)

		forEachCell(cs, function(cell, idx)
			self:assert_equal(cell.soilType, 0)
		end)

		local cont = 0

		local ag1 = Agent{
			it = Trajectory{target = cs},
			cont  = 0,

			State{
				id = "first",
				Jump{
					function(event, agent, cell)
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
					function(event, agent, cell)
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

		local at1 = Automaton{
			it = Trajectory{target = cs},
			cont  = 0,
			State{
				id = "first",
				Jump{
					function(event, agent, cell)
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
					function(event, agent, cell)
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

		local env = Environment{
			cs, at1, ag1
		}

		local ev = Event{time = 0}
		at1:setTrajectoryStatus(true)
		at1:execute(ev)
		self:assert_equal(44, cont)

		ev = Event{time = 0}
		ag1:setTrajectoryStatus(true)
		ag1:execute(ev)
		self:assert_equal(88, cont)
	end,
	execute = function(self)
		local orderToken = 0 -- Priority test token (position reserved to the Event for this timeslice)
		local timeMemory = 0   -- memory of time test variable 
		self:assert_equal(orderToken, 0)

		local env = Environment{
			clock1 = Timer{
				Event{time = 0, action = function(event) 
					if event:getTime() == timeMemory then 
						self:assert(orderToken <= 1)
					end
					timeMemory = event:getTime()
					orderToken = 1
				end},
				Event{priority = 1, action = function(event)
					timeMemory = event:getTime()
					self:assert(1 <= orderToken)
					orderToken = 2
				end}
			},
			clock2 = Timer{
				Event{time = 0, period = 2 , priority = 2, action = function(event) 
					timeMemory = event:getTime()	
					self:assert(orderToken <= 2)
					orderToken = 3
				end},
				Event{priority = 3, action = function(event) 
					self:assert(orderToken <= 4)
					self:assert_equal(event:getTime(), timeMemory)
					orderToken = 0
				end}
			}
		}
		env:execute(6)

		local orderToken = 0 -- Priority test token (position reserved to the Event for this timeslice)
		local timeMemory = 0 -- memory of time test variable 

		local env = Environment{
			firstEnv = Environment{
				clock1 = Timer{
					Event{time = 0, action = function(event) 
						if event:getTime() == timeMemory then 
							self:assert(1 >= orderToken)
						end
						timeMemory = event:getTime()
						orderToken = 1
					end},
					Event{priority = 1, action = function(event) 
						timeMemory = event:getTime()

						self:assert(1 >= orderToken)
						orderToken = 2
					end}
				}
			},
			secondEnv = Environment{
				clock2 = Timer{
					Event{time = 0, period = 2, priority = 2, action = function(event) 
						self:assert(2 >= orderToken)
						orderToken = 3
					end},
					Event{priority = 3, action = function(event) 
						self:assert(4 >= orderToken)
						self:assert_equal(event:getTime(), timeMemory)
						orderToken = 0
					end}
				}
			}
		}
		env:execute(6)

		local PRIO1 = 1
		local PRIO2 = 2
		local PRIO3 = 3
		local PRIO4 = 4
		local PRIO5 = 5
		local PRIO6 = 6
		local PRIO7 = 7
		local PRIO8 = 8

		local orderToken = 0 -- Priority test token (position reserved to the Event for this timeslice)
		local timeMemory = 0   -- memory of time test variable 
		self:assert_equal(orderToken, 0)

		local env = Environment{
			firstEnv = Environment{
				clock1 = Timer{
					Event{time = 0, priority = PRIO1, action = function(event) 
						if event:getTime() == timeMemory then 
							self:assert(1 >= orderToken)
						end
						timeMemory = event:getTime()
						orderToken = 1
					end},
					Event{priority = PRIO2, action = function(event) 
						timeMemory = event:getTime()
						self:assert(1 >= orderToken)
						orderToken = 2
					end}
				},
				clock2 = Timer{
					Event{time = 0, period = 2 , priority = PRIO3, action = function(event) 
						timeMemory = event:getTime()
						self:assert(2 >= orderToken)
						orderToken = 3
					end},
					Event{priority = PRIO4, action = function(event) 
						timeMemory = event:getTime()
						self:assert(3 >= orderToken)
						orderToken = 4
					end}
				}
			},
			secondEnv = Environment{
				clock1 = Timer{
					Event{time = 0, priority = PRIO5, action = function(event)
						timeMemory = event:getTime()
						self:assert(4 >= orderToken)
						orderToken = 5
					end},
					Event{priority = PRIO6, action = function(event) 
						timeMemory = event:getTime()
						self:assert(5 >= orderToken)
						orderToken = 6
					end}
				},
				clock2 = Timer{
					Event{time = 0, period = 2 , priority = PRIO7, action = function(event) 
						timeMemory = event:getTime()
						self:assert(6 >= orderToken)
						orderToken = 7
					end},
					Event{priority = PRIO8, action = function(event) 
						self:assert(8 >= orderToken)
						self:assert_equal(event:getTime(), timeMemory)
						orderToken = 0
					end}
				}
			}
		}
		env:execute(6)

		local PRIO1 = 1
		local PRIO2 = 2
		local PRIO3 = 3
		local PRIO4 = 4
		local PRIO5 = 5
		local PRIO6 = 6
		local PRIO7 = 7
		local PRIO8 = 8
		local PRIO9 = 9
		local PRIO10 = 10
		local PRIO11 = 11

		local orderToken
		local timeMemory

		local env = Environment{
			clock1 = Timer{
				Event{time = 0, action = function(event) 
					if event:getTime() == timeMemory then 
						self:assert(-1 >= orderToken)
					end
					timeMemory = event:getTime()
					orderToken = 0
				end},
				Event{priority = PRIO1, action = function(event) 
					timeMemory = event:getTime()
					self:assert(0 >= orderToken)
					orderToken = 1
				end}
			},
			clock2 = Timer{
				Event{time = 0, period = 2 , priority = PRIO2, action = function(event)
					timeMemory = event:getTime()
					self:assert(1 >= orderToken)
					orderToken = 2
				end},
				Event{priority = PRIO3, action = function(event) 
					timeMemory = event:getTime()
					self:assert(2 >= orderToken)
					orderToken = 3
				end}
			},
			firstEnv = Environment{
				clock1 = Timer{
					Event{time = 0, priority = PRIO4, action = function(event) 
						timeMemory = event:getTime()
						self:assert(3 >= orderToken)
						orderToken = 4
					end},
					Event{priority = PRIO5, action = function(event) 
						timeMemory = event:getTime()
						self:assert(4 >= orderToken)
						orderToken = 5
					end}
				},
				clock2 = Timer{
					Event{time = 0, period = 2, priority = PRIO6, action = function(event) 
						timeMemory = event:getTime()
						self:assert(5 >= orderToken)
						orderToken = 6
					end},
					Event{priority = PRIO7, action = function(event) 
						timeMemory = event:getTime()
						self:assert(6 >= orderToken)
						orderToken = 7
					end}
				}
			},
			secondEnv = Environment{
				clock1 = Timer{
					Event{time = 0, priority = PRIO8, action = function(event) 
						timeMemory = event:getTime()
						self:assert(7 >= orderToken)
						orderToken = 8
					end},
					Event{priority = PRIO9, action = function(event) 
						timeMemory = event:getTime()
						self:assert(8 >= orderToken)
						orderToken = 9
					end}
				},
				clock2 = Timer{
					Event{time = 0, period = 2 , priority = PRIO10, action = function(event) 
						timeMemory = event:getTime()
						self:assert(9 >= orderToken)
						orderToken = 10
					end},
					Event{priority = PRIO11, action = function(event)
						timeMemory = event:getTime()
						self:assert(10 >= orderToken)
						orderToken = 0
					end}
				}
			}
		}
		env:execute(6)
	end,
	__tostring = function(unitTest)
		local cs1 = CellularSpace{xdim = 2}
		local ag1 = Agent{}
		local t1 = Timer{}
		local env1 = Environment{id = "env", cs1, ag1, t1}
		unitTest:assert_equal(tostring(env1), [[1      CellularSpace
2      Agent
3      Timer
cObj_  userdata
id     string [env]
]])
	end
}

