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
	State = function(unitTest)
		local error_func = function()
			local s = State(2)
		end
		unitTest:assert_error(error_func, tableArgumentMsg())

		local s = State{
			Jump{
				function(ev, self)
					return true 
				end,
				target = "go"
			},
			Flow{ function(ev, self)
					self.x = self.x + 1
				end}
		}
		unitTest:assert(true)

		unitTest:assert_error(function()
			State{
				id = {},
				Jump{
					function(ev, self)
						return true 
					end,
					target = "go"
				},
				Flow{
					function(ev, self)
						self.x = self.x + 1
					end
				}
			}
		end, incompatibleTypeMsg("id", "string", {}))

		unitTest:assert_error(function()
			State{
				id = 123,
				Jump{ function(ev, self)
						return true 
					end,
					target = "go"
				},
				Flow{ function(ev, self)
						self.x = self.x + 1
					end}
			}
		end, incompatibleTypeMsg("id", "string", 123))

		local s = State{
			id = "IdState",
			Flow{
				function(ev, self)
					self.x = self.x + 1
				end},
			Jump{
				function(self)
					return true 
				end,
				target = "go"
			}
		}
		unitTest:assert(true)

		local s = State{
			id = "IdState",
			Flow{
				function(self)
					self.x = self.x + 1
				end
			},
			Jump{
				function(ev, self)
					return true 
				end,
				target = "go"
			}
		}
		unitTest:assert(true)
	end
}

