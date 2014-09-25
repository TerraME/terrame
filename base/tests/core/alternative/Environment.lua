
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
	add = function(unitTest)
		local env = Environment{}
		local error_func = function()
			env:add(nil)
		end
		unitTest:assert_error(error_func,"Error: Incompatible types. Parameter '#1' expected Agent, Automaton, Cell, CellularSpace, Society, Timer or Trajectory, got nil.")

		error_func = function()
			env:add{}
		end
		unitTest:assert_error(error_func,"Error: Incompatible types. Parameter '#1' expected Agent, Automaton, Cell, CellularSpace, Society, Timer or Trajectory, got table.")
	end,
	createPlacement = function(unitTest)
		local ag1 = Agent{}

		local sc1 = Society{
			instance = ag1,
			quantity = 20
		}

		local cs = CellularSpace{xdim = 5, ydim = 5}

		local env = Environment{cs, sc1}

		local error_func = function()
			env:createPlacement{name = "placement", max = "13"}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'max' expected positive integer number, got string.")

		error_func = function()
			env:createPlacement{strategy = 15, name = "placement", max = 13}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'strategy' expected string, got number.")

		error_func = function()
			env:createPlacement{strategy = "teste1", name = "placement", max = 13}
		end
		unitTest:assert_error(error_func, "Error: 'teste1' is an invalid value for parameter 'strategy'. It must be a string from the set ['random', 'uniform', 'void'].")

		error_func = function()
			-- TODO: se trocar o name abaixo por placement ele da erro dizendo que este placement ja existe. verificar.
			env:createPlacement{strategy = "unifor", name = "placement2", max = 13}
		end
		unitTest:assert_error(error_func, "Error: 'unifor' is an invalid value for parameter 'strategy'. Do you mean 'uniform'?")

		error_func = function()
			env:createPlacement{strategy = "random", name = 15, max = 13}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'name' expected string, got number.")

		error_func = function()
			env:createPlacement{strategy = "random", name = "placement", max = -13}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'max' expected positive integer number, got -13.")

		local cs = CellularSpace{xdim = 10, ydim = 10}
		local ag1 = Agent{}
		local sc1 = Society {instance = ag1, quantity = 20}

		env = Environment{sc1}

		error_func = function()
			env:createPlacement{strategy = "random"}
		end
		unitTest:assert_error(error_func, "Error: The Environment does not contain a CellularSpace.")

		env = Environment{cs}

		error_func = function()
			env:createPlacement{strategy = "random"}
		end
		unitTest:assert_error(error_func, "Error: Could not find a behavioral entity (Society or Agent) within the Environment.")

		env = Environment{cs, sc1}
		env:createPlacement{strategy = "random"}

		error_func = function()
			env:createPlacement{strategy = "random"}
		end
		unitTest:assert_error(error_func, "Error: There is a Society within this Environment that already has this placement.")
	end,
	execute = function(unitTest)
		local env = Environment{}

		local error_func = function()
			env:execute(nil)
		end

		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected number, got nil.")
	end,
	Environment = function(unitTest)
		local state1 = State{
			id = "seco",
			Jump{
				function( event, agent, cell )
					agent.acum = agent.acum + 1
					if (agent.cont < MAX_COUNT) then
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

		local cs = CellularSpace{xdim = 20}

		local at1 = Automaton{
			it = Trajectory{
				target = cs,
				select = function(cell)
					local x = cell.x - 5
					local y = cell.y - 5
					return (x*x) + (y*y) - 16 < 0.1
				end,
				greater = function(cell1, cell2)
					return cell1.x < cell2.x
				end
			},
			acum = 0,
			cont = 0,
			st2 = state2,
			st1 = state1
		}

		local error_func = function()
			envmt = Environment{at1, cs}
		end

		unitTest:assert_error(error_func, "Error: CellularSpace must be added before any Automaton.")
	end,
	notify = function(unitTest)
		local env = Environment{}

		local error_func = function()
			env:notify("not_int")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Event or positive number, got string.")

		error_func = function()
			env:notify(-1)
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter '#1' expected Event or positive number, got -1.")
	end

}

