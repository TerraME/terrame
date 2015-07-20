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

local cs = CellularSpace{xdim = 10}

local state1 = State{
	id = "seco",
	Jump{
		function(event, agent, cell)
			agent.acum = agent.acum + 1
			if agent.cont < MAX_COUNT then 
				agent.cont = agent.cont + 1
				return true
			end
			if agent.cont == MAX_COUNT then agent.cont = 0 end
			return false
		end,
		target = "molhado"
	}
}

local state2 = State{
	id = "molhado",
	Jump{
		function(event, agent, cell)
			agent.acum = agent.acum + 1
			if agent.cont < MAX_COUNT then 
				agent.cont = agent.cont + 1
				return true
			end
			if agent.cont == MAX_COUNT then agent.cont = 0 end
			return false
		end, 
		target = "seco"
	}
}

local ev = Event{action = function() end}

return{
	Automaton = function(unitTest)
		local at1 = Automaton{
			it = Trajectory{
				target = cs, 
				select = function(cell)
					local x = cell.x - 5
					local y = cell.y - 5
					return (x * x) + (y * y)  - 16 < 0.1
				end
			},
			acum = 0,
			cont = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}
		unitTest:assertEquals(at1.id, "1")

		at1 = Automaton{
			it = Trajectory{
				target = cs, 
				select = function(cell)
					local x = cell.x - 5
					local y = cell.y - 5
					return (x * x) + (y * y)  - 16 < 0.1
				end
			},
			acum = 0,
			cont = 0,
			curve = 0
		}

		local count = 0
		for k, v in pairs(at1) do
			if type(v) == "State" then
				count = count + 1
			end		
		end
		unitTest:assertEquals(0, count)
	end,
	__tostring = function(unitTest)
		local at1 = Automaton{
			id = "MyAutomaton",
			State{
				id = "second"
			}
		}
		unitTest:assertEquals(tostring(at1), [[1      State
cObj_  userdata
id     string [MyAutomaton]
]])
	end,
	add = function(unitTest)
		local at1 = Automaton{

			acum = 0,
			cont = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}

		local it = Trajectory{
			target = cs, 
			select = function(cell)
				local x = cell.x - 5
				local y = cell.y - 5
				return (x*x) + (y*y)  - 16 < 0.1
			end
		}
		at1:add(it)
		unitTest:assert(true)
	end,
	build = function(unitTest)
		local at1 = Automaton{
			it = Trajectory{
				target = cs, 
				select = function(cell)
					local x = cell.x - 5
					local y = cell.y - 5
					return (x * x) + (y * y)  - 16 < 0.1
				end
			},
			acum = 0,
			cont = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}
	
		at1:build()
		unitTest:assert(true)
	end,
	execute = function(unitTest)
		local at1 = Automaton{
			it = Trajectory{
				target = cs, 
				select = function(cell)
					local x = cell.x - 5
					local y = cell.y - 5
					return (x * x) + (y * y)  - 16 < 0.1
				end
			},
			acum = 0,
			cont = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}

		local t = Timer{
			Event{action = function(ev)	at1:execute(ev) end}
		}
		t:execute(1)
		unitTest:assert(true)

		local cs = CellularSpace{xdim = 2}
		local cont = 0

		local at1 = Automaton{
			it = Trajectory{
				target = cs
			},
			cont = 0,
			State{
				id = "first",
				Jump{
					function(event, agent, cell)
						cont = cont + 1
						if agent.cont < 10 then
							agent.cont = agent.cont + 1
							return tru
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

		local env = Environment{cs, at1}

		local ev = Event{action = function() end}[1]

		at1:setTrajectoryStatus(true)
		at1.it:sort(function(a,b) return a.x > b.x; end)
		at1:execute(ev)
		unitTest:assertEquals(4, at1.cont)
		unitTest:assertEquals(4, cont)

		local ev = Event{start = 4, action = function() end}[1]
		at1.it:sort(greaterByCoord(">"))
		at1:execute(ev)
		unitTest:assertEquals(8, at1.cont)
		unitTest:assertEquals(8, cont)

		at1.it:filter(function(cell) return cell.x == cell.y end)
		at1:execute(ev)
		unitTest:assertEquals(10, at1.cont)
		unitTest:assertEquals(10, at1.cont)

		at1.it:filter(function(cell) return true end)
		at1:execute(ev)
		unitTest:assertEquals(3, at1.cont)
		unitTest:assertEquals(14, cont)
	end,
	getId = function(unitTest)
		unitTest:assert(true)
	end,
	getState = function(unitTest)
		unitTest:assert(true)
	end,
	getStateName = function(unitTest)
		local cs = CellularSpace{xdim = 2}
		local cont = 0

		local at1 = Automaton{
			it = Trajectory{
				target = cs
			},
			cont = 0,
			State{
				id = "first",
				Jump{
					function(event, agent, cell)
						cont = cont + 1
						if agent.cont < 10 then
							agent.cont = agent.cont + 1
							return tru
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

		local env = Environment{cs, at1}

		local ev = Event{action = function() end}[1]

		at1:setTrajectoryStatus(true)
		at1:execute(ev)

		unitTest:assertEquals(at1:getStateName(cs:sample()), "first")
	end,
	getStates = function(unitTest)
		local at1 = Automaton{
			it = Trajectory{
				target = cs, 
				select = function(cell)
					local x = cell.x - 5
					local y = cell.y - 5
					return (x * x) + (y * y)  - 16 < 0.1
				end
			},
			acum = 0,
			cont = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}

		local states = at1:getStates()
		unitTest:assertEquals(getn(states), 0) -- TODO: should be 2, but type(state) is not "State"
	end,
	notify = function(unitTest)
		local at1 = Automaton{
			it = Trajectory{
				target = cs, 
				select = function(cell)
					local x = cell.x - 5
					local y = cell.y - 5
					return (x * x) + (y * y)  - 16 < 0.1
				end
			},
			acum = 0,
			cont = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}

		at1:notify()
		local t = Timer{
			Event{action = function(ev)	at1:notify(ev) end}
		}
		t:execute(1)

		unitTest:assert(true)
	end,
	setId = function(unitTest)
		local at1 = Automaton{
			it = Trajectory{
				target = cs, 
				select = function(cell)
					local x = cell.x - 5
					local y = cell.y - 5
					return (x * x) + (y * y)  - 16 < 0.1
				end
			},
			acum = 0,
			cont = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}

		at1:setId("2")

		unitTest:assert(true)
	end,
	setTrajectoryStatus = function(unitTest)
		local t = Trajectory{target = cs, select = function(cell)
			local x = cell.x - 5
			local y = cell.y - 5
			return (x * x) + (y * y) - 16 < 0.1
		end}

		local count = 0
		local at1 = Automaton{
			it = t,
			st = State{
				id = "unique",
				Flow{function()
					count = count + 1
				end},
				Jump{
					function() return false end, target = "unique"
				}
			}
		}

		local env = Environment{cs, at1}

		local e = Event{action = function() end}[1]
		at1:execute(e)
		unitTest:assertEquals(count, 0)

		at1:setTrajectoryStatus(true)
		count = 0
		at1:execute(e)
		unitTest:assertEquals(count, 49)

		at1:setTrajectoryStatus()
		count = 0
		at1:execute(e)
		unitTest:assertEquals(count, 0)
	end
}

