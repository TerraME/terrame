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
	Society = function(unitTest)
		local ag1 = Agent{}

		local sc1 = Society{
			instance = ag1,
			quantity = 20
		}

		local error_func = function()
			sc2 = Society{
				quantity = 20
			}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'instance' is mandatory.")

		error_func = function()
			sc2 = Society{
				instance = "wrongType",
				quantity = 20
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'instance' expected Agent, got string.")

		error_func = function()
			sc2 = Society{
				instance = ag1
			}
		end
		unitTest:assert_error(error_func,"Error: Parameter 'quantity' is mandatory.")

		error_func = function()
			sc2 = Society{
				instance = ag1,
				quantity = "wrongType"
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'quantity' expected positive integer number (except zero), got string.")

		error_func = function()
			sc2 = Society{
				instance = ag1,
				quantity = -15
			}
		end
		unitTest:assert_error(error_func,"Error: Incompatible values. Parameter 'quantity' expected positive integer number (except zero), got -15.")
	end,
	add = function(unitTest)
		local ag1 = Agent{}

		local sc1 = Society{
			instance = ag1,
			quantity = 20
		}

		local error_func = function()
			sc1:add("wrongType")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected Agent or table, got string.")
	end,
	createSocialNetwork = function(unitTest)
		local ag1 = Agent{}
		local sc1 = Society{instance = ag1, quantity = 20}

		local error_func = function()
			sc1:createSocialNetwork()
		end
		unitTest:assert_error(error_func, "Error: Parameter for 'createSocialNetwork' must be a table.")

		error_func = function()
			sc1:createSocialNetwork(15)
		end
		unitTest:assert_error(error_func, "Error: Parameters for 'createSocialNetwork' must be named.")

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "voi"
			}
		end
		unitTest:assert_error(error_func, "Error: 'voi' is an invalid value for parameter 'strategy'. Do you mean 'void'?")

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "terralab"
			}
		end
		unitTest:assert_error(error_func, "Error: 'terralab' is an invalid value for parameter 'strategy'. It must be a string from the set ['cell', 'func', 'neighbor', 'probability', 'quantity', 'void'].")

		sc1:createSocialNetwork{
			strategy = "void",
			name = "void"
		}

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "void",
				name = "void"
			}
		end
		unitTest:assert_error(error_func, "Error: SocialNetwork 'void' already exists in the Society.")

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "void",
				name = "void2",
				probability = 0.5
			}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'probability' is unnecessary.")

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "quantity"
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'quantity' expected positive integer number (except zero), got nil.")

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "quantity",
				quantity = "terralab"
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'quantity' expected positive integer number (except zero), got string.")

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "quantity",
				quantity = 0
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'quantity' expected positive integer number (except zero), got 0.")

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "quantity",
				quantity = 5,
				probability = 0.2
			}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'probability' is unnecessary.")

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "probability",
				probability = "wrong value"
			}
		end

		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'probability' expected a number between 0 and 1, got string.")

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "probability",
				probability = 0
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'probability' expected a number between 0 and 1, got 0.")

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "probability",
				probability = 0.5,
				quantity = 5	
			}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'quantity' is unnecessary.")

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "probability",
				probability = 1.5,
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'probability' expected a number between 0 and 1, got 1.5.")

		error_func = function()
			sc1:createSocialNetwork{
				strategy = "probability",
				probability = 0.5,
				name = 2
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'name' expected string, got nil.")

		error_func = function()
			sc1:createSocialNetwork{strategy = "cell", name = "c"}
		end

		unitTest:assert_error(error_func, "Error: Society has no placement. Use Environment:createPlacement() first.")

		local cs = CellularSpace{xdim = 5, ydim = 5}
		local ag1 = Agent{}
		local sc1 = Society{instance = ag1, quantity = 20}
		local env = Environment{cs, sc1}
		env:createPlacement{strategy = "random"}

		error_func = function()
			sc1:createSocialNetwork{strategy = "neighbor", name = "c"}
		end
		unitTest:assert_error(error_func, "Error: CellularSpace has no Neighborhood named '1'. Use CellularSpace:createNeighborhood() first.")

		local ag1 = Agent{}
		local sc1 = Society{instance = ag1, quantity = 20}
		local cs = CellularSpace{xdim = 5, ydim = 5}
		cs:createNeighborhood()
		local env = Environment{cs, sc1}

		error_func = function()
			sc1:createSocialNetwork{strategy = "neighbor", name = "c"}
		end
		unitTest:assert_error(error_func, "Error: Society has no placement. Use Environment:createPlacement() first.")

		env:createPlacement{strategy = "random"}
		error_func = function()
			sc1:createSocialNetwork{strategy = "cell", name = "c", quantity = 5}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'quantity' is unnecessary.")

		error_func = function()
			sc1:createSocialNetwork{strategy = "neighbor", name = 22}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'name' expected string, got nil.")

		error_func = function()
			sc1:createSocialNetwork{strategy = "neighbor", quantity = 1}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'quantity' is unnecessary.")

		error_func = function()
			sc1:createSocialNetwork{strategy = "func", name = "c", func = 3}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'func' expected function, got number.")

		error_func = function()
			sc1:createSocialNetwork{strategy = "func", name = "c", func = function(ag) return true end, quantity = 1}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'quantity' is unnecessary.")

		local ag1 = Agent{
			name = "nonfoo",
			init = function(self)
				self.age = TME_GLOBAL_RANDOM:integer(10)
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

		sc:createSocialNetwork{probability = 0.5 , name = "2"}
		forEachAgent(sc, function(ag)
			local error_func = function()
				ag:getSocialNetwork()
			end
			unitTest:assert_error(error_func, "Error: Agent does not have a SocialNetwork named '1'.")
		end)
	end,
	get = function(unitTest)
		local ag1 = Agent{
			name = "nonfoo",
			execute = function(self) end
		}

		local sc1 = Society{
			instance = ag1,
			quantity = 10
		}

		local error_func = function()
			ag1 = sc1:get(nil)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'index' expected positive integer number, got nil.")

		error_func = function()
			ag1 = sc1:get("asdfg")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'index' expected positive integer number, got string.")
	end,
	getAgent = function(unitTest)
		local ag1 = Agent{
			name = "nonfoo",
			execute = function(self) end
		}

		local sc1 = Society{
			instance = ag1,
			quantity = 10
		}

		local error_func = function()
			sc1:getAgent("1")
		end
		unitTest:assert_error(error_func, "Error: Function 'getAgent' is deprecated. Use 'get' instead.")
	end,
	getAgents = function(unitTest)
		local ag1 = Agent{
			name = "nonfoo",
			execute = function(self) end
		}

		local sc1 = Society{
			instance = ag1,
			quantity = 10
		}

		local error_func = function()
			sc1:getAgents()
		end
		unitTest:assert_error(error_func, "Error: Function 'getAgents' is deprecated. Use '.agents' instead.")
	end,
	size = function(unitTest)
		local ag1 = Agent{
			name = "nonfoo",
			execute = function(self) end
		}

		local sc1 = Society{
			instance = ag1,
			quantity = 10
		}

		local error_func = function()
			sc1:size()
		end
		unitTest:assert_error(error_func, "Error: Function 'size' is deprecated. Use 'operator #' instead.")
	end,
	split = function(unitTest)
		local ag1 = Agent{
			name = "nonfoo",
			execute = function(self) end
		}

		local sc1 = Society{
			instance = ag1,
			quantity = 10
		}

		local error_func = function()
			group = sc1:split(nil)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected string or function, got nil.")

		error_func = function()
			group = sc1:split(15)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected string or function, got number.")
	end,
	synchronize = function(unitTest)
		local ag1 = Agent{
			name = "nonfoo",
			execute = function(self) end
		}

		local sc1 = Society{
			instance = ag1,
			quantity = 10
		}

		sc1:synchronize()

		local error_func = function()
			sc1:synchronize("test")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected positive number, got string.")

		error_func = function()
			sc1:synchronize(-13)
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter '#1' expected positive number, got -13.")
	end
}

