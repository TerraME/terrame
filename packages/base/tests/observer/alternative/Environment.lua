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

return{
	Environment = function(unitTest)
		local init = function(model)
			local contacts = 6

			model.timer = Timer{
				Event{action = function()
					local proportion = model.susceptible / 
						(model.susceptible + model.infected + model.recovered)

					local newInfected = model.infected * contacts * model.probability * proportion

					local newRecovered = model.infected / model.duration

					model.susceptible = model.susceptible - newInfected
					model.recovered = model.recovered + newRecovered
					model.infected = model.infected + newInfected - newRecovered
				end},
				Event{action = function()
					if model.infected >= model.maximum then
						contacts = contacts / 2
						return false
					end
				end}
			}
		end

		local SIR = Model{
			susceptible = 9998,
			infected = 2,
			recovered = 0,
			duration = 2,
			finalTime = 30,
			maximum = 1000,
			probability = 0.25,
			init = init
		}

		local e = Environment{
			max1000 = SIR{maximum = 1000},
			max2000 = SIR{maximum = 2000}
		}

		local error_func = function()
			c = Chart{
				target = Environment{},
				select = "infected"
			}
		end
		unitTest:assertError(error_func, "There is no Model instance within the Environment.")

		error_func = function()
			c = Chart{
				target = e,
				select = "infected",
				title = "Infected"
			}
		end
		unitTest:assertError(error_func, defaultValueMsg("title", "Infected"))

		error_func = function()
			c = Chart{
				target = e
			}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("select"))

		error_func = function()
			c = Chart{
				target = e,
				select = "infected",
				color = {"blue", "red", "green"}
			}
		end
		unitTest:assertError(error_func, "Arguments 'select' and 'color' should have the same size, got 2 and 3.")
	end
}

