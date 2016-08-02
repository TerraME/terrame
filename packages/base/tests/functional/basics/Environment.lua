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
	Environment = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local a = Agent{
			id = "ag1",
			class = "undefined",
			x = 3,
			State{
				id = "stop",
				Jump{function()
						return false
					end,
					target = "stop"
				},
				Flow{function(_, self)
					self.x = self.x + 1
				end}
			}
		}

		local t = Timer{
			Event{action = function(ev)
				a:execute(ev)
			end}
		}

		local env = Environment{cs, a, t}
		env:run(10)
		unitTest:assertEquals(13, a.x)

		env = Environment{}

		env:add(cs)
		env:add(a)
		env:add(t)

		env:run(10)
		unitTest:assertEquals(13, a.x)

		local cellCont = 0
		unitTest:assertEquals(cellCont, 0)
		cs = CellularSpace{xdim = 2}

		forEachCell(cs, function(cell)
			cell.soilType = 0
			cellCont = cellCont + 1
		end)

		unitTest:assertEquals(cellCont, 4)

		forEachCell(cs, function(cell)
			unitTest:assertEquals(cell.soilType, 0)
		end)

		local cont = 0

		local ag1 = Agent{
			it = Trajectory{target = cs},
			cont  = 0,

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

		local at1 = Automaton{
			it = Trajectory{target = cs},
			cont  = 0,
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

		Environment{
			cs, at1, ag1
		}

		local ev = Event{start = 0, action = function() end}
		at1:setTrajectoryStatus(true)
		at1:execute(ev)
		unitTest:assertEquals(44, cont)

		ev = Event{start = 0, action = function() end}
		ag1:setTrajectoryStatus(true)
		ag1:execute(ev)
		unitTest:assertEquals(88, cont)

		M = Model{
			init = function(model)
				model.water = 20
				model.finalTime = 10
				model.timer = Timer{
					Event{action = function()
						model.water = model.water - 1
					end}
				}
			end
		}

		local m1 = M{}
		local m2 = M{}

		local e = Environment{m1, m2}
		e:run(10)

		M = nil -- it is necessary to make it global to verify
		        -- that it is a Model

		unitTest:assertEquals(m1.water, 10)
		unitTest:assertEquals(m2.water, 10)
	end,
	add = function(unitTest)
		local e = Environment{}

		e:add(Event{action = function() end})

		unitTest:assertType(e[1], "Timer")
		unitTest:assertEquals(#e[1], 1)

		local cont = 0

		e:add{period = 2, action = function(event)
			cont = cont + 1
			unitTest:assertType(event, "Event")
			unitTest:assertEquals(2, event:getPeriod())
		end}

		local timer = e[2]
		timer:run(6)

		unitTest:assertEquals(timer:getTime(), 6)
		unitTest:assertEquals(cont, 3)
	end,
	__tostring = function(unitTest)
		local cs1 = CellularSpace{xdim = 2}
		local ag1 = Agent{}
		local t1 = Timer{}
		local env1 = Environment{id = "env", cs1, ag1, t1}
		unitTest:assertEquals(tostring(env1), [[1      CellularSpace
2      Agent
3      Timer
cObj_  userdata
id     string [env]
]])
	end,
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
			quantity = 20
		}

		local ag = Agent{}

		local cs = CellularSpace{xdim = 5}
		cs:createNeighborhood()

		local env = Environment{cs, predators = predators, zag = ag}
		env:createPlacement{}

		local cont = 0
		forEachCell(cs, function(cell)
			cont = cont + #cell.placement
		end)
		unitTest:assertEquals(21, cont)

		cont = 0
		forEachAgent(predators, function(agent)
			cont = cont + #agent.placement
		end)
		unitTest:assertEquals(20, cont)

		forEachAgent(predators, function(agent)
			agent:reproduce{age = 0}
		end)

		predators:execute()
		predators:execute()

		cont = 0
		forEachCell(cs, function(cell)
			cont = cont + #cell.placement
		end)
		unitTest:assertEquals(41, cont)

		cont = 0
		forEachAgent(predators, function(agent)
			cont = cont + #agent.placement
		end)
		unitTest:assertEquals(40, cont)

		predator = Agent{name = "predator"}
		ag = Agent{name = "ag"}

		predators = Society{
			instance = predator,
			quantity = 49
		}

		cs = CellularSpace{xdim = 5}

		env = Environment{cs, pred = predators, zag = ag}
		env:createPlacement{strategy = "uniform"}

		unitTest:assertEquals(#cs.cells[1]:getAgents(), 2)
		unitTest:assertEquals(#cs.cells[2]:getAgents(), 2)
		unitTest:assertEquals(#cs.cells[25]:getAgents(), 2)

		unitTest:assertEquals(cs.cells[25]:getAgents()[1].name, "predator")
		unitTest:assertEquals(cs.cells[25]:getAgents()[2].name, "ag")

		Random():reSeed(12345)

		predator = Agent{
			energy = 40,
			name = "predator",
			execute = function(self)
				local new_cell = self:getCell("house"):getNeighborhood():sample()
				self:move(new_cell, "house")
				self:walk("stay")
			end
		}

		predators = Society{
			instance = predator,
			quantity = 25
		}

		cs = CellularSpace{xdim = 10}
		cs:createNeighborhood()

		env = Environment{cs, predators}
		env:createPlacement{name = "house"}
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
		unitTest:assertEquals(25, count_house)
		unitTest:assertEquals(25, count_stay)
		unitTest:assertEquals(0,  count_wplace)

		local max = 0
		forEachCell(cs, function(cell)
			if max < #cell.house then
				max = #cell.house
			end
		end)
		unitTest:assertEquals(1, max)
		unitTest:assertEquals(1, #cs.cells[25].stay)
		unitTest:assertEquals(0, #cs.cells[26].stay)

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
		unitTest:assertEquals(24, count_house)
		unitTest:assertEquals(24, count_stay)
		unitTest:assertEquals(0,  count_wplace)

		predator = Agent{name = "predator"}

		predators = Society{
			instance = predator,
			quantity = 10
		}

		cs = CellularSpace{xdim = 10}

		env = Environment{cs.cells[1], predators}
		env:createPlacement{max = 200}

		unitTest:assertEquals(#cs.cells[1]:getAgents(), #predators)
	end,
	run = function(unitTest)
		local result = ""

		local env = Environment{
			clock1 = Timer{
				Event{start = 0, action = function(event)
					result = result.."t "..event:getTime().." e 1 p "..event:getPriority().."\n"
				end},
				Event{priority = 1, action = function(event)
					result = result.."t "..event:getTime().." e 2 p "..event:getPriority().."\n"
				end}
			},
			clock2 = Timer{
				Event{start = 0, period = 2, priority = 2, action = function(event)
					result = result.."t "..event:getTime().." e 3 p "..event:getPriority().."\n"
				end},
				Event{priority = 3, action = function(event)
					result = result.."t "..event:getTime().." e 4 p "..event:getPriority().."\n"
				end}
			}
		}

		env:run(6)

		unitTest:assertEquals(result, [[
t 0 e 1 p 0
t 0 e 3 p 2
t 1 e 1 p 0
t 1 e 2 p 1
t 1 e 4 p 3
t 2 e 1 p 0
t 2 e 2 p 1
t 2 e 3 p 2
t 2 e 4 p 3
t 3 e 1 p 0
t 3 e 2 p 1
t 3 e 4 p 3
t 4 e 1 p 0
t 4 e 2 p 1
t 4 e 3 p 2
t 4 e 4 p 3
t 5 e 1 p 0
t 5 e 2 p 1
t 5 e 4 p 3
t 6 e 1 p 0
t 6 e 2 p 1
t 6 e 3 p 2
t 6 e 4 p 3
]])

		result = ""

		env = Environment{
			firstEnv = Environment{
				clock1 = Timer{
					Event{start = 0, action = function(event)
						result = result.."t "..event:getTime().." e 1 p "..event:getPriority().."\n"
					end},
					Event{priority = 1, action = function(event)
						result = result.."t "..event:getTime().." e 2 p "..event:getPriority().."\n"
					end}
				}
			},
			secondEnv = Environment{
				clock2 = Timer{
					Event{start = 0, period = 2, priority = 2, action = function(event)
						result = result.."t "..event:getTime().." e 3 p "..event:getPriority().."\n"
					end},
					Event{priority = 3, action = function(event)
						result = result.."t "..event:getTime().." e 4 p "..event:getPriority().."\n"
					end}
				}
			}
		}

		env:run(6)

		unitTest:assertEquals(result, [[
t 0 e 1 p 0
t 0 e 3 p 2
t 1 e 1 p 0
t 1 e 2 p 1
t 1 e 4 p 3
t 2 e 1 p 0
t 2 e 2 p 1
t 2 e 3 p 2
t 2 e 4 p 3
t 3 e 1 p 0
t 3 e 2 p 1
t 3 e 4 p 3
t 4 e 1 p 0
t 4 e 2 p 1
t 4 e 3 p 2
t 4 e 4 p 3
t 5 e 1 p 0
t 5 e 2 p 1
t 5 e 4 p 3
t 6 e 1 p 0
t 6 e 2 p 1
t 6 e 3 p 2
t 6 e 4 p 3
]])

		result = ""

		env = Environment{
			firstEnv = Environment{
				clock1 = Timer{
					Event{start = 0, priority = 1, action = function(event)
						result = result.."t "..event:getTime().." e 1 p "..event:getPriority().."\n"
					end},
					Event{priority = 2, action = function(event)
						result = result.."t "..event:getTime().." e 2 p "..event:getPriority().."\n"
					end}
				},
				clock2 = Timer{
					Event{start = 0, period = 2, priority = 3, action = function(event)
						result = result.."t "..event:getTime().." e 3 p "..event:getPriority().."\n"
					end},
					Event{priority = 4, action = function(event)
						result = result.."t "..event:getTime().." e 4 p "..event:getPriority().."\n"
					end}
				}
			},
			secondEnv = Environment{
				clock1 = Timer{
					Event{start = 0, priority = 5, action = function(event)
						result = result.."t "..event:getTime().." e 5 p "..event:getPriority().."\n"
					end},
					Event{priority = 6, action = function(event)
						result = result.."t "..event:getTime().." e 6 p "..event:getPriority().."\n"
					end}
				},
				clock2 = Timer{
					Event{start = 0, period = 2, priority = 7, action = function(event)
						result = result.."t "..event:getTime().." e 7 p "..event:getPriority().."\n"
					end},
					Event{priority = 8, action = function(event)
						result = result.."t "..event:getTime().." e 8 p "..event:getPriority().."\n"
					end}
				}
			}
		}

		env:run(4)

		unitTest:assertEquals(result, [[
t 0 e 1 p 1
t 0 e 3 p 3
t 0 e 5 p 5
t 0 e 7 p 7
t 1 e 1 p 1
t 1 e 2 p 2
t 1 e 4 p 4
t 1 e 5 p 5
t 1 e 6 p 6
t 1 e 8 p 8
t 2 e 1 p 1
t 2 e 2 p 2
t 2 e 3 p 3
t 2 e 4 p 4
t 2 e 5 p 5
t 2 e 6 p 6
t 2 e 7 p 7
t 2 e 8 p 8
t 3 e 1 p 1
t 3 e 2 p 2
t 3 e 4 p 4
t 3 e 5 p 5
t 3 e 6 p 6
t 3 e 8 p 8
t 4 e 1 p 1
t 4 e 2 p 2
t 4 e 3 p 3
t 4 e 4 p 4
t 4 e 5 p 5
t 4 e 6 p 6
t 4 e 7 p 7
t 4 e 8 p 8
]])

		result = ""

		env = Environment{
			clock1 = Timer{
				Event{start = 0, action = function(event)
					result = result.."t "..event:getTime().." e 1 p "..event:getPriority().."\n"
				end},
				Event{priority = 1, action = function(event)
					result = result.."t "..event:getTime().." e 2 p "..event:getPriority().."\n"
				end}
			},
			clock2 = Timer{
				Event{start = 0, period = 2, priority = 2, action = function(event)
					result = result.."t "..event:getTime().." e 3 p "..event:getPriority().."\n"
				end},
				Event{priority = 3, action = function(event)
					result = result.."t "..event:getTime().." e 4 p "..event:getPriority().."\n"
				end}
			},
			firstEnv = Environment{
				clock1 = Timer{
					Event{start = 0, priority = 4, action = function(event)
						result = result.."t "..event:getTime().." e 5 p "..event:getPriority().."\n"
					end},
					Event{priority = 5, action = function(event)
						result = result.."t "..event:getTime().." e 6 p "..event:getPriority().."\n"
					end}
				},
				clock2 = Timer{
					Event{start = 0, period = 2, priority = 6, action = function(event)
						result = result.."t "..event:getTime().." e 7 p "..event:getPriority().."\n"
					end},
					Event{priority = 7, action = function(event)
						result = result.."t "..event:getTime().." e 8 p "..event:getPriority().."\n"
					end}
				}
			},
			secondEnv = Environment{
				clock1 = Timer{
					Event{start = 0, priority = 8, action = function(event)
						result = result.."t "..event:getTime().." e 9 p "..event:getPriority().."\n"
					end},
					Event{priority = 9, action = function(event)
						result = result.."t "..event:getTime().." e 10 p "..event:getPriority().."\n"
					end}
				},
				clock2 = Timer{
					Event{start = 0, period = 2, priority = 10, action = function(event)
						result = result.."t "..event:getTime().." e 11 p "..event:getPriority().."\n"
					end},
					Event{priority = 11, action = function(event)
						result = result.."t "..event:getTime().." e 12 p "..event:getPriority().."\n"
					end}
				}
			}
		}

		env:run(4)

		unitTest:assertEquals(result, [[
t 0 e 1 p 0
t 0 e 3 p 2
t 0 e 5 p 4
t 0 e 7 p 6
t 0 e 9 p 8
t 0 e 11 p 10
t 1 e 1 p 0
t 1 e 2 p 1
t 1 e 4 p 3
t 1 e 5 p 4
t 1 e 6 p 5
t 1 e 8 p 7
t 1 e 9 p 8
t 1 e 10 p 9
t 1 e 12 p 11
t 2 e 1 p 0
t 2 e 2 p 1
t 2 e 3 p 2
t 2 e 4 p 3
t 2 e 5 p 4
t 2 e 6 p 5
t 2 e 7 p 6
t 2 e 8 p 7
t 2 e 9 p 8
t 2 e 10 p 9
t 2 e 11 p 10
t 2 e 12 p 11
t 3 e 1 p 0
t 3 e 2 p 1
t 3 e 4 p 3
t 3 e 5 p 4
t 3 e 6 p 5
t 3 e 8 p 7
t 3 e 9 p 8
t 3 e 10 p 9
t 3 e 12 p 11
t 4 e 1 p 0
t 4 e 2 p 1
t 4 e 3 p 2
t 4 e 4 p 3
t 4 e 5 p 4
t 4 e 6 p 5
t 4 e 7 p 6
t 4 e 8 p 7
t 4 e 9 p 8
t 4 e 10 p 9
t 4 e 11 p 10
t 4 e 12 p 11
]])

		local init = function(model)
			model.timer = Timer{
				Event{action = function()
					model.count = model.count + 1
				end}
			}
		end

		local Room = Model{
			count = 0,
			finalTime = 20,
			init = init
		}

		local scenario1 = Room{}
		local scenario2 = Room{count = 20, finalTime = 30}
		local scenario3 = Room{count = 5}

		env = Environment{
			scenario1, scenario2, scenario3
		}

		env:run()

		unitTest:assertEquals(scenario1.count, 0  + 30)
		unitTest:assertEquals(scenario2.count, 20 + 30)
		unitTest:assertEquals(scenario3.count, 5  + 30)
	end,
	getTime = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local t = Timer{
			Event{action = function()
			end}
		}

		mmm = Model{
			init = function(model)
				model.timer = Timer{Event{action = function() end}}
			end,
			finalTime = 100
		}

		local mi = mmm{}

		local env = Environment{cs, t, Environment{}, mi}
		env:run(10)
		unitTest:assertEquals(10, env:getTime())

		mmm = nil
	end
}

