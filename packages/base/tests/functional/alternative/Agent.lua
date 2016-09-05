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

return {
	Agent = function(unitTest)
		local error_func = function()
			Agent(2)
		end
		unitTest:assertError(error_func, tableArgumentMsg())
	
		error_func = function()
			Agent{id = 123}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("id", "string", 123))
	end,
	add = function(unitTest)
		local ag1 = Agent{}

		local error_func = function()
			ag1:add()
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "State or Trajectory", nil))

		error_func = function()
			ag1:add(123)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "State or Trajectory", 123))
	end,
	addSocialNetwork = function(unitTest)
		local ag1 = Agent{}

		local error_func = function()
			ag1:addSocialNetwork(nil, "friends")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			Agent{}
			ag1:addSocialNetwork({}, "friends")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "SocialNetwork", {}))

		ag1 = Agent{}
		local sn = SocialNetwork()
		error_func = function()
			ag1:addSocialNetwork(sn, 123)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 123))
	end,
	die = function(unitTest)
		local ag = Agent{
			on_message = function() end
		}

		ag:die()

		local test_function = function()
			ag:execute()
		end
		unitTest:assertError(test_function, "Trying to execute a dead agent.")

		local ag2 = Agent{}

		test_function = function()
			ag2:message{
				receiver = ag
			}
		end
		unitTest:assertError(test_function, "Trying to use a function or an attribute of a dead Agent.")
	end,
	enter = function(unitTest)
		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3}
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void"}
		local error_func = function()
			ag1:enter(nil, "placement")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			ag1 = Agent{}
			cs = CellularSpace{xdim = 3}
			myEnv = Environment{cs, ag1}

			myEnv:createPlacement{strategy = "void"}
			ag1:enter({}, "placement")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Cell", {}))

		ag1 = Agent{}
		cs = CellularSpace{xdim = 3}
		myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void"}
		local cell = cs.cells[1]
		error_func = function()
			ag1:enter(cell, 123)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 123))

		local predator = Agent{}

		local predators = Society{
			instance = predator, 
			quantity = 5
		}

		cs = CellularSpace{xdim = 5}

		local e = Environment{predators, cs}
		e:createPlacement()

		local c = Cell{}

		error_func = function()
			predators:sample():enter(c)
		end
		unitTest:assertError(error_func, "Agent is already inside of a Cell. Use Agent:move() instead.")

		local ag = predators:sample()

		ag:leave()

		error_func = function()
			ag:enter(c)
		end
		unitTest:assertError(error_func, "Placement 'placement' was not found in the Cell.")
	end,
	execute = function(unitTest)
		local ag1 = Agent{
			id = "MyFirst",
			State{
				id = "first"
			},
		}
		local error_func = function()
			ag1:execute()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			ag1 = Agent{
				id = "MyFirst",
				State{
					id = "first"
				},
			}
			ag1:execute({})
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Event", {}))
	end,
	getCell = function(unitTest)
		local ag1 = Agent{pl = 2}
		
		local error_func = function()
			ag1:getCell()
		end
		unitTest:assertError(error_func, "Default placement does not exist. Please call 'Environment:createPlacement' first.")

		error_func = function()
			ag1:getCell("pl")
		end
		unitTest:assertError(error_func, "Placement 'pl' should be a Trajectory, got number.")
	end,
	getCells = function(unitTest)
		local ag1 = Agent{pl = 2}
		
		local error_func = function()
			ag1:getCells("pl")
		end
		unitTest:assertError(error_func, "Placement 'pl' should be a Trajectory, got number.")
	end,
	getId = function(unitTest)
		local ag1 = Agent{}
		local error_func = function()
			ag1:getId()
		end
		unitTest:assertError(error_func, deprecatedFunctionMsg("getId", ".id"))
	end,
	getSocialNetwork = function(unitTest)
		local ag1 = Agent{}

		local sn = SocialNetwork()
		ag1:addSocialNetwork(sn)
		local error_func = function()
			sn2 = ag1:getSocialNetwork{}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", {}))
	end,
	leave = function(unitTest)
		local error_func = function()
			local ag1 = Agent{}
			local cs = CellularSpace{xdim = 3}
			local myEnv = Environment{cs, ag1}

			myEnv:createPlacement{strategy = "void"}
			local cell = cs.cells[1]
			ag1:enter(cell, "placement")
			ag1:leave({})
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", {}))

		error_func = function()
			local ag1 = Agent{}
			local cs = CellularSpace{xdim = 3}
			local myEnv = Environment{cs, ag1}

			myEnv:createPlacement{strategy = "void"}
			local cell = cs.cells[1]
			ag1:enter(cell, "placement")
			ag1:leave(123)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 123))

		error_func = function()
			local ag1 = Agent{}
			local cs = CellularSpace{xdim = 3}
			local myEnv = Environment{cs, ag1}

			myEnv:createPlacement{strategy = "void"}
			ag1:leave()
		end
		unitTest:assertError(error_func, "Agent should belong to a Cell in order to leave().")

		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3}
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void"}
		local cell = cs.cells[1]
		ag1:enter(cell, "placement")
		error_func = function()
			ag1:leave("notplacement")
		end
		unitTest:assertError(error_func, valueNotFoundMsg(1, "notplacement"))

		ag1 = Agent{pl = 2}

		error_func = function()
			ag1:leave("pl")
		end
		unitTest:assertError(error_func, "Placement 'pl' should be a Trajectory, got number.")
	end,
	message = function(unitTest)
		local error_func = function()
			local ag = Agent{}

			local sc = Society{instance = ag, quantity = 2}
			local ag1 = sc.agents[1]		

			ag1:message()
		end
		unitTest:assertError(error_func, tableArgumentMsg())

		error_func = function()
			local ag = Agent{}

			local sc = Society{instance = ag, quantity = 2}
			local ag1 = sc.agents[1]		

			ag1:message(123)
		end
		unitTest:assertError(error_func, namedArgumentsMsg())

		local ag = Agent{}
		local sc = Society{instance = ag, quantity = 2}
		local ag1 = sc.agents[1]		
		error_func = function()
			ag1:message{}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("receiver"))

		ag = Agent{}	
		sc = Society{instance = ag, quantity = 2}
		ag1 = sc.agents[1]		
		local ag2 = sc.agents[2]		
		error_func = function()
			ag1:message{
				receiver = ag2,
				delay = "not_number",
				content = "money"
			}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("delay", "number", "money"))

		ag = Agent{}

		sc = Society{instance = ag, quantity = 2}
		ag1 = sc.agents[1]		
		ag2 = sc.agents[2]		
		error_func = function()
			ag1:message{
				receiver = ag2,
				delay = -1,
				content = "money"
			}
		end
		unitTest:assertError(error_func, positiveArgumentMsg("delay", -1, true))

		error_func = function()
			ag1:message{
				receiver = ag2,
				subject = 2
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("subject", "string", 2))
	end,
	move = function(unitTest)
		local error_func = function()
			local ag1 = Agent{}
			local cs = CellularSpace{ xdim = 3}
			local myEnv = Environment {cs, ag1}

			myEnv:createPlacement{strategy = "void", name = "renting"}
			local c1 = cs.cells[1]
			ag1:enter(c1,"renting")
			ag1:move()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		local ag1 = Agent{}
		local ag2 = Agent{}
		local cs = CellularSpace{ xdim = 3}
		local myEnv = Environment {cs, ag1}

		myEnv:createPlacement{strategy = "void", name = "renting"}
		local c1 = cs.cells[1]
		ag1:enter(c1, "renting")

		error_func = function()
			ag1:move(ag2, "renting")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "Cell", ag2))

		ag1 = Agent{}
		cs = CellularSpace{xdim = 3}
		myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void", name = "test"}

		c1 = cs.cells[1]
		error_func = function()
			ag1:enter(c1)
		end
		unitTest:assertError(error_func, "Placement 'placement' was not found in the Agent.")

		ag1 = Agent{}
		cs = CellularSpace{xdim = 3}
		myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void", name = "renting"}
		myEnv:createPlacement{strategy = "void"}

		c1 = cs.cells[1]
		ag1:enter(c1, "renting")
		
		error_func = function()
			ag1:move(c1, 123)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 123))

		ag1 = Agent{}
		cs = CellularSpace{xdim = 3}
		myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void", name = "renting"}
		c1 = cs.cells[1]
		ag1:enter(c1, "renting")
		c1 = cs.cells[4]

		error_func = function()
			ag1:move(c1, "not_placement")
		end
		unitTest:assertError(error_func, valueNotFoundMsg(2, "not_placement"))

		ag1:leave("renting")

		error_func = function()
			ag1:move(c1, "renting")
		end
		unitTest:assertError(error_func, "Agent should belong to a Cell in order to move().")
	end,
	notify = function(unitTest)
		local ag = Agent{x = 1, y = 1}

		local error_func = function()
			ag:notify("not_int")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "number", "not_int"))

		error_func = function()
			ag:notify(-1)
		end
		unitTest:assertError(error_func, positiveArgumentMsg(1, -1, true))
	end,
	on_message = function(unitTest)
		local ag1 = Agent{}
		local ag2 = Agent{}

		local error_func = function()
			ag1:message{receiver = ag2}
		end
		unitTest:assertError(error_func, "Agent 'nil' cannot get a message from 'nil' because it does not implement 'on_message'.")
	end,
	randomWalk = function(unitTest)
		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3}
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void"}
		local c1 = cs.cells[1]
		ag1:enter(c1)
		local error_func = function()
			ag1:randomWalk()
		end
		unitTest:assertError(error_func, deprecatedFunctionMsg("randomWalk", "walk"))
	end,
	reproduce = function(unitTest)
		local a = Agent{}
		local s = Society{
			instance = a,
			quantity = 5
		}

		local error_func = function()
			a:reproduce()
		end
		unitTest:assertError(error_func, "Agent should belong to a Society to be able to reproduce.")

		error_func = function()
			s:sample():reproduce(2)
		end
		unitTest:assertError(error_func, namedArgumentsMsg())
	end,
	setId = function(unitTest)
		local ag1 = Agent{}
		local error_func = function()
			ag1:setId("aa")
		end
		unitTest:assertError(error_func, deprecatedFunctionMsg("setId", ".id"))
	end,
	walk = function(unitTest)
		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3}
		local myEnv = Environment{cs, ag1}

		local error_func = function()
			ag1:walk()
		end
		unitTest:assertError(error_func, "The Agent does not have a default placement. Please call 'Environment:createPlacement' first.")

		error_func = function()
			ag1:walk("placement2")
		end
		unitTest:assertError(error_func, valueNotFoundMsg(1, "placement2"))

		myEnv:createPlacement{strategy = "void"}
		local c1 = cs.cells[1]
		ag1:enter(c1)

		error_func = function()
			ag1:walk()
		end
		unitTest:assertError(error_func, "The CellularSpace does not have a default neighborhood. Please call 'CellularSpace:createNeighborhood' first.")

		error_func = function()
			ag1:walk("placement", "2")
		end
		unitTest:assertError(error_func, "Neighborhood '2' does not exist.")

		error_func = function()
			ag1 = Agent{}
			cs = CellularSpace{xdim = 3}
			myEnv = Environment{cs, ag1}

			myEnv:createPlacement{strategy = "void"}
			c1 = cs.cells[1]
			ag1:enter(c1)
			ag1:walk(123)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 123))

		ag1 = Agent{}
		cs = CellularSpace{xdim = 3}
		myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void"}
		c1 = cs.cells[1]
		ag1:enter(c1,"placement")

		error_func = function()
			ag1:walk("123")
		end
		unitTest:assertError(error_func, valueNotFoundMsg(1, "123"))
	end
}

