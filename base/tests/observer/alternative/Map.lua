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
-------------------------------------------------------------------------------------------

return{
	Map = function(unitTest)
		local c = CellularSpace{xdim = 5}

		local error_func = function()
			Map{}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("subject"))

		error_func = function()
			Map{subject = Neighborhood()}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("subject", "CellularSpace", Neighborhood()))

		error_func = function()
			Map{subject = c, select = 5}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("select", "string", 5))

		error_func = function()
			Map{subject = c, grouping = "equalsteps"}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("select"))

		error_func = function()
			Map{subject = c, select = "mvalue", grouping = "equalsteps"}
		end
		unitTest:assert_error(error_func, "Selected element 'mvalue' does not belong to the subject.")

		error_func = function()
			Map{subject = c, select = {}}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("select", "string", {}))

		error_func = function()
			Map{subject = c, select = "x", slices = 10, colors = {{1, 2}, "red"}}
		end
		unitTest:assert_error(error_func, "Invalid description for color in position 1. It should have 3 values, got 2.")

		error_func = function()
			Map{subject = c, select = "x", slices = 10, colors = {2, "red"}}
		end
		unitTest:assert_error(error_func, "Invalid description for color in position 1. It should be a table or string, got number.")

		error_func = function()
			Map{subject = c, select = "x", title = 5, slices = 10, colors = {"blue", "red"}}
		end
		unitTest:assert_error(error_func, unnecessaryParameterMsg("title"))

		error_func = function()
			Map{
				subject = c,
				select = "x",
				values = {1, 2, 3},
				colors = {"red", "green"},
				labels = {"1", "2", "3"}
			}
		end
		unitTest:assert_error(error_func, "There should exist colors for each value.")

		error_func = function()
			Map{
				subject = c,
				select = "x",
				values = {1, 2, 3},
				colors = {"red", "green", "blue"},
				labels = {"1", "2"}
			}
		end
		unitTest:assert_error(error_func, "There should exist labels for each value.")

		error_func = function()
			Map{
				subject = c,
				select = "x",
				values = {1, 2, 3},
				colors = {"red", "green", "blues"},
				labels = {"1", "2", "3"}
			}
		end
		unitTest:assert_error(error_func, "Color 'blues' not found. Check the name or use a table with an RGB description.")

		error_func = function()
			Map{
				subject = c,
				select = "x",
				values = {1, 2, 3},
				grouping = "uniquevalue",
				colors = {"red", "green", "blue"},
				labels = {"1", "2", "3"}
			}
		end
		unitTest:assert_error(error_func, switchInvalidParameterSuggestionMsg("uniquevalue", "grouping", "uniquevalues"))
	end
}

