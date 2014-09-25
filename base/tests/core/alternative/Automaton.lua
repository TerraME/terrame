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

local cs = CellularSpace{xdim = 10, ydim = 10}

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

local ev = Event{time = 1, period = 1, priority = 1, action = function() return true end}

return{
	Automaton = function(unitTest)
		local at1 = Automaton{
			id = nil,
			it = Trajectory{
				target = cs, 
				select = function(cell)
					local x = cell.x - 5
					local y = cell.y - 5
					return (x * x) + (y * y)  - 16 < 0.1
				end
			},
			acum = 0,
			cont  = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}
		unitTest:assert_equal(at1.id, "1")

		local error_func = function()
			at1 = Automaton{
				id = 15,
				it = Trajectory{
					target = cs, 
					select = function(cell)
						local x = cell.x - 5
						local y = cell.y - 5
						return (x * x) + (y * y) - 16 < 0.1
					end
				},
				acum = 0,
				cont  = 0,
				curve = 0,
				st2 = state2,
				st1 = state1
			}
		end

		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'id' expected string, got number.")

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
			cont  = 0,
			curve = 0
		}

		local count = 0
		for k, v in pairs(at1) do
			if type(v) == "State"	then
				count = count + 1
			end		
		end
		unitTest:assert_equal(0, count)
	end,
	add = function(unitTest)
		local at1 = Automaton{
			it = Trajectory{
				target = cs, 
				select = function(cell)
					local x = cell.x - 5
					local y = cell.y - 5
					return (x*x) + (y*y)  - 16 < 0.1
				end
			},
			acum = 0,
			cont  = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}

		local error_func = function()
			at1:add()
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected State or Trajectory, got nil.")

		at1 = Automaton{
			it = Trajectory{
				target = cs, 
				select = function(cell)
					local x = cell.x - 5
					local y = cell.y - 5
					return (x * x) + (y * y) - 16 < 0.1
				end
			},
			acum = 0,
			cont  = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}

		local error_func = function()
			at1:add("notTrajectoryOrTtate")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected State or Trajectory, got string.")
	end,
	execute = function(unitTest)
		local at1 = Automaton{
			it = Trajectory{
				target = cs, 
				select = function(cell)
					local x = cell.x - 5
					local y = cell.y - 5
					return (x * x) + (y * y) - 16 < 0.1
				end
			},
			acum = 0,
			cont  = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}

		local error_func = function()
			at1:execute()
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Event, got nil.")

		at1 = Automaton{
			it = Trajectory{
				target = cs, 
				select = function(cell)
					local x = cell.x - 5
					local y = cell.y - 5
					return (x * x) + (y * y) - 16 < 0.1
				end
			},
			acum = 0,
			cont  = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}

		error_func = function()
			at1:execute("notEvent")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Event, got string.")
	end,
	setTrajectoryStatus = function(unitTest)	
		local at1 = Automaton{
			it = Trajectory{
				target = cs, 
				select = function(cell)
					local x = cell.x - 5
					local y = cell.y - 5
					return (x * x) + (y * y) - 16 < 0.1
				end
			},
			acum = 0,
			cont  = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}
		at1:setTrajectoryStatus(nil)
		unitTest:assert(true)

		at1 = Automaton{
			it = Trajectory{
				target = cs, 
				select = function(cell)
					local x = cell.x - 5
					local y = cell.y - 5
					return (x * x) + (y * y) - 16 < 0.1
				end
			},
			acum = 0,
			cont  = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}

		local error_func = function()
			at1:setTrajectoryStatus("notBoolean")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected boolean, got string.")
	end
}

