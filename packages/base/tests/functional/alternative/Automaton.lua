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

local cs = CellularSpace{xdim = 10}

local state1 = State{
	id = "seco",
	Jump{
		function(_, agent)
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
		function(_, agent)
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

return{
	Automaton = function(unitTest)
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
				cont = 0,
				curve = 0,
				st2 = state2,
				st1 = state1
			}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("id", "string", 15))

		error_func = function()
			Automaton()
		end
		unitTest:assertError(error_func, tableArgumentMsg())

		error_func = function()
			Automaton(2)
		end
		unitTest:assertError(error_func, namedArgumentsMsg())
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
			cont = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}

		local error_func = function()
			at1:add()
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "State or Trajectory"))

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
			cont = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}

		error_func = function()
			at1:add("notTrajectoryOrTtate")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "State or Trajectory", "notTrajectoryOrTtate"))
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
			cont = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}

		local error_func = function()
			at1:execute()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

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
			cont = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}

		error_func = function()
			at1:execute("notEvent")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Event", "notEvent"))
	end,
	getState = function(unitTest)
		local a = Automaton{}

		local error_func = function()
			a:getState("abc")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "number", "abc"))
	
		error_func = function()
			a:getState(-2)
		end
		unitTest:assertError(error_func, positiveArgumentMsg(1, -2))
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

		local error_func = function()
			at1:notify(-1)
		end
		unitTest:assertError(error_func, positiveArgumentMsg(1, -1, true))
	end,
	setId = function(unitTest)
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
			cont = 0,
			curve = 0,
			st2 = state2,
			st1 = state1
		}

		local error_func = function()
			at1:setId()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			at1:setId(2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))
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
			st2 = state2,
			st1 = state1
		}

		local error_func = function()
			at1:setTrajectoryStatus("notBoolean")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "boolean", "notBoolean"))
	end
}

