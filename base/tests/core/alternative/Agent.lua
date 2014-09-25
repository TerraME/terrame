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

return {
	Agent = function(unitTest)
		local test_function = function()
			local ag1 = Agent{id = 123}
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter 'id' expected string or nil, got number.")
	end,
	add = function(unitTest)
		local ag1 = Agent{}

		local test_function = function()
			ag1:add()
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#1' expected State or Trajectory, got nil.")

		test_function = function()
			ag1:add(123)
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#1' expected State or Trajectory, got number.")

		test_function = function()
			ag1:add("notstate")
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#1' expected State or Trajectory, got string.")

		test_function = function()
			ag1:add(ag1)
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#1' expected State or Trajectory, got Agent.")
	end,
	addSocialnetwork = function(unitTest)
		local ag1 = Agent{}

		local test_function = function()
			ag1:addSocialNetwork(nil,"friends")
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#1' expected SocialNetwork, got nil.")

		local test_function = function()
			local ag1 = Agent{}
			ag1:addSocialNetwork({},"friends")
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#1' expected SocialNetwork, got table.")

		local ag1 = Agent{}
		local sn = SocialNetwork{}
		local test_function = function()
			ag1:addSocialNetwork(sn,123)
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#2' expected string, got number.")
	end,
	enter = function(unitTest)
		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3, ydim = 3}
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void", name = "placement"}
		local cell = cs.cells[1]
		local test_function = function()
			ag1:enter(nil, "placement")
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#1' expected Cell, got nil.")

		local test_function = function()
			local ag1 = Agent{}
			local cs = CellularSpace{xdim = 3, ydim = 3}
			local myEnv = Environment{cs, ag1}

			myEnv:createPlacement{strategy = "void", name = "placement"}
			cell = cs.cells[1]
			ag1:enter({}, "placement")
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#1' expected Cell, got table.")

		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3, ydim = 3}
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void", name = "placement"}
		cell = cs.cells[1]
		local test_function = function()
			ag1:enter(cell, 123)
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#2' expected string, got number.")
	end,
	execute = function(unitTest)
		local ag1 = Agent{
			id = "MyFirst",
			State{
				id = "first"
			},
		}
		local test_function = function()
			ag1:execute(nil)
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#1' expected Event, got nil.")

		local test_function = function()
			ag1 = Agent{
				id = "MyFirst",
				State{
					id = "first"
				},
			}
			ag1:execute({})
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#1' expected Event, got table.")
	end,
	getSocialNetwork = function(unitTest)
		local ag1 = Agent{}

		local sn = SocialNetwork{}
		ag1:addSocialNetwork(sn)
		local test_function = function()
			sn2 = ag1:getSocialNetwork{}
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#1' expected string, got table.")

		local ag1 = Agent{}
		sn = SocialNetwork{}

		ag1:addSocialNetwork(sn, "friends")
		local test_function = function()
			sn2 = ag1:getSocialNetwork("notfriends")		
		end
		unitTest:assert_error(test_function, "Error: Agent does not have a SocialNetwork named 'notfriends'.")
	end,
	leave = function(unitTest)
		local test_function = function()
			local ag1 = Agent{}
			local cs = CellularSpace{xdim = 3, ydim = 3}
			local myEnv = Environment{cs, ag1}

			myEnv:createPlacement{strategy = "void", name = "placement"}
			local cell = cs.cells[1]
			ag1:enter(cell, "placement")
			ag1:leave(cell, {})
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#2' expected string, got table.")

		local test_function = function()
			local ag1 = Agent{}
			local cs = CellularSpace{xdim = 3, ydim = 3}
			local myEnv = Environment{cs, ag1}

			myEnv:createPlacement{strategy = "void", name = "placement"}
			local cell = cs.cells[1]
			ag1:enter(cell, "placement")
			ag1:leave(cell, 123)
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#2' expected string, got number.")

		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3, ydim = 3}
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void", name = "placement"}
		local cell = cs.cells[1]
		ag1:enter(cell,"placement")
		local test_function = function()
			ag1:leave(cell,"notplacement")
		end
		unitTest:assert_error(test_function, "Error: Value 'notplacement' not found for parameter '#1'.")
	end,
	message = function(unitTest)
		local test_function = function()
			local ag = Agent{}

			local sc = Society{instance = ag, quantity = 2}
			local ag1 = sc.agents[1]		

			ag1:message()
		end
		unitTest:assert_error(test_function, "Error: Parameter for 'message' must be a table.")

		local test_function = function()
			local ag = Agent{}

			local sc = Society{instance = ag, quantity = 2}
			local ag1 = sc.agents[1]		

			ag1:message(123)
		end
		unitTest:assert_error(test_function, "Error: Parameters for 'message' must be named.")

		local ag = Agent{}
		local sc = Society{instance = ag, quantity = 2}
		local ag1 = sc.agents[1]		
		local test_function = function()
			ag1:message{}
		end
		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter 'receiver' expected Agent, got nil.")

		local ag = Agent{}	
		local sc = Society{instance = ag, quantity = 2}
		local ag1 = sc.agents[1]		
		local ag2 = sc.agents[2]		
		unitTest:assert_error(function()
			ag1:message{
				receiver = ag2,
				delay = "not_number",
				content = "money"
			}

		end,"Error: Incompatible types. Parameter 'delay' expected positive integer number, got string.")

		local ag = Agent{}

		sc = Society{instance = ag, quantity = 2}
		local ag1 = sc.agents[1]		
		local ag2 = sc.agents[2]		
		local test_function = function()
			ag1:message{
				receiver = ag2,
				delay = -1,
				content = "money"
			}
		end
		unitTest:assert_error(test_function, "Error: Incompatible values. Parameter 'delay' expected positive integer number, got -1.")
	end,
	move = function(unitTest)
		local test_function = function()
			local ag1 = Agent{}
			local cs = CellularSpace{ xdim = 3, ydim = 3}
			local myEnv = Environment {cs, ag1}

			myEnv:createPlacement{strategy = "void", name = "renting"}
			local c1 = cs.cells[1]
			ag1:enter(c1,"renting")
			local c1 = cs.cells[4]
			ag1:move()
		end
		unitTest:assert_error(test_function, "Error: Parameter '#1' is mandatory.")

		local ag1 = Agent{}
		local ag2 = Agent{}
		local cs = CellularSpace{ xdim = 3, ydim = 3}
		local myEnv = Environment {cs, ag1}

		myEnv:createPlacement{strategy = "void", name = "renting"}
		local c1 = cs.cells[1]
		ag1:enter(c1, "renting")
		c1 = cs.cells[4]
		local error_func = function()
			ag1:move(ag2, "renting")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Cell, got Agent.")

		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3, ydim = 3}
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void", name = "test"}

		local c1 = cs.cells[1]
		local error_func = function()
			ag1:enter(c1)
		end
		--forEachElement(ag1, print)
		unitTest:assert_error(error_func, "Error: Placement 'placement' was not found.")

		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3, ydim = 3}
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void", name = "renting"}
		myEnv:createPlacement{strategy = "void", name = "placement"}

		local c1 = cs.cells[1]
		ag1:enter(c1, "renting")
		--ag1:enter(c1,nil)
		
		local test_function = function()
			ag1:move(c1, 123)
		end

		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#2' expected string, got number.")

		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3, ydim = 3}
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void", name = "renting"}
		c1 = cs.cells[1]
		ag1:enter(c1, "renting")
		c1 = cs.cells[4]

		local test_function = function()
			ag1:move(c1,"not_placement")
		end
		unitTest:assert_error(test_function, "Error: Value 'not_placement' not found for parameter '#2'.")
	end,
	randomWalk = function(unitTest)
		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3, ydim = 3}
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void", name = "placement"}
		local c1 = cs.cells[1]
		ag1:enter(c1)
		local test_function = function()
			ag1:randomWalk()
		end
		unitTest:assert_error(test_function, "Error: Function 'randomWalk' is deprecated. Use 'walk' instead.")
	end,
	reproduce = function(unitTest)
		local a = Agent{}
		local error_func = function()
			a:reproduce()
		end
		unitTest:assert_error(error_func, "Error: Agent should belong to a Society to be able to reproduce.")
	end,
	walk = function(unitTest)
		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3, ydim = 3}
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void", name = "placement"}
		local c1 = cs.cells[1]
		ag1:enter(c1)
		local test_function = function()
			ag1:walk()
		end
		unitTest:assert_error(test_function, "Error: Value '1' not found for parameter '#2'.")

		local test_function = function()
			local ag1 = Agent{}
			local cs = CellularSpace{xdim = 3, ydim = 3}
			local myEnv = Environment{cs, ag1}

			myEnv:createPlacement{strategy = "void", name = "placement"}
			c1 = cs.cells[1]
			ag1:enter(c1)
			ag1:walk(123)
		end

		unitTest:assert_error(test_function, "Error: Incompatible types. Parameter '#1' expected string, got number.")

		local ag1 = Agent{}
		local cs = CellularSpace{xdim = 3, ydim = 3}
		local myEnv = Environment{cs, ag1}

		myEnv:createPlacement{strategy = "void", name = "placement"}
		c1 = cs.cells[1]
		ag1:enter(c1,"placement")
		local test_function = function()
			ag1:walk("123")
		end
		unitTest:assert_error(test_function, "Error: Value '123' not found for parameter '#1'.")
	end
}

