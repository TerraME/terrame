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

		forEachCell(c, function(cell)
			cell.value = math.random()
			cell.bvalue = false
		end)

		local error_func = function()
			Map{}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("subject"))

		error_func = function()
			Map{subject = Neighborhood()}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("subject", "CellularSpace", Neighborhood()))

		error_func = function()
			Map{subject = c}
		end
		unitTest:assert_error(error_func, "It was not possible to infer argument 'grouping'.")

		error_func = function()
			Map{subject = c, select = 5}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("select", "string", 5))

		-- equalsteps
		error_func = function()
			Map{subject = c, select = "x", labels = 5, slices = 10, colors = {"blue", "red"}}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("labels", "table", 5))

		error_func = function()
			Map{subject = c, grouping = "equalsteps"}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("select"))

		error_func = function()
			Map{subject = c, select = "mvalue", grouping = "equalsteps"}
		end
		unitTest:assert_error(error_func, "Selected element 'mvalue' does not belong to the subject.")

		error_func = function()
			Map{subject = c, select = "bvalue", grouping = "equalsteps"}
		end
		unitTest:assert_error(error_func, "Selected element should be number, got boolean.")

		error_func = function()
			Map{subject = c, select = {}}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("select", "string", {}))

		error_func = function()
			Map{subject = c, select = "x", slices = "abc", colors = {{1, 2}}}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("slices", "number", "abc"))

		error_func = function()
			Map{subject = c, select = "x", slices = 0, min = 5, max = 8, colors = {{1, 2}}}
		end
		unitTest:assert_error(error_func, "Argument 'slices' (0) should be greater than one.")

		error_func = function()
			Map{subject = c, select = "x", slices = 2, min = "abc", colors = {{1, 2}}}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("min", "number", "abc"))

		error_func = function()
			Map{subject = c, select = "x", slices = 2, min = 3, max = "abc", colors = {{1, 2}}}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("max", "number", "abc"))

		error_func = function()
			Map{subject = c, select = "x", slices = 2, min = 5, max = 3, colors = {{1, 2}}}
		end
		unitTest:assert_error(error_func, "Argument 'min' (5) should be less than 'max' (3).")

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
		unitTest:assert_error(error_func, unnecessaryArgumentMsg("title"))

		error_func = function()
			Map{
				subject = c,
				select = "x",
				slices = 3,
				colors = {"red", "green", "blue"}
			}
		end
		unitTest:assert_error(error_func, "Strategy 'equalsteps' requires only two colors, got 3.")

		error_func = function()
			Map{
				subject = c,
				select = "x",
				slices = 10,
				colors = "Pastel1"
			}
		end
		unitTest:assert_error(error_func, "Color 'Pastel1' does not support 10 slices.")

		error_func = function()
			Map{
				subject = c,
				select = "x",
				slices = 3,
				colors = "xxx",
				labels = {"1", "2", "3"}
			}
		end
		unitTest:assert_error(error_func, "Invalid color 'xxx'.")
	
		-- uniquevalue
		error_func = function()
			Map{subject = c, select = "mvalue", grouping = "uniquevalue"}
		end
		unitTest:assert_error(error_func, "Selected element 'mvalue' does not belong to the subject.")

		error_func = function()
			Map{subject = c, select = "bvalue", grouping = "uniquevalue"}
		end
		unitTest:assert_error(error_func, "Selected element should be string or number, got boolean.")

		error_func = function()
			Map{
				subject = c,
				select = "x",
				values = {1, 2, 3},
				colors = {"red", "green"},
				labels = {"1", "2", "3"}
			}
		end
		unitTest:assert_error(error_func, "There should exist colors for each value. Got 2 colors and 3 values.")

		error_func = function()
			Map{
				subject = c,
				select = "x",
				values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
				colors = "Pastel1"
			}
		end
		unitTest:assert_error(error_func, "Color 'Pastel1' does not support 10 slices.")

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
		unitTest:assert_error(error_func, switchInvalidArgumentSuggestionMsg("blues", "colors", "blue"))

		error_func = function()
			Map{
				subject = c,
				select = "x",
				values = {1, 2, 3},
				colors = {"red", "green", "xxxxx"},
				labels = {"1", "2", "3"}
			}
		end
		unitTest:assert_error(error_func, "Color 'xxxxx' not found. Check the name or use a table with an RGB description.")

		error_func = function()
			Map{
				subject = c,
				select = "x",
				values = {1, 2, 3},
				grouping = "uniquevalues",
				colors = {"red", "green", "blue"},
				labels = {"1", "2", "3"}
			}
		end
		unitTest:assert_error(error_func, switchInvalidArgumentSuggestionMsg("uniquevalues", "grouping", "uniquevalue"))

		error_func = function()
			Map{
				subject = c,
				select = "x",
				values = {1, 2, 3},
				colors = "Bluess",
				labels = {"1", "2", "3"}
			}
		end
		unitTest:assert_error(error_func, switchInvalidArgumentSuggestionMsg("Bluess", "colors", "Blues"))

		error_func = function()
			Map{
				subject = c,
				select = "x",
				values = {1, 2, 3},
				colors = "xxx",
				labels = {"1", "2", "3"}
			}
		end
		unitTest:assert_error(error_func, "Invalid color 'xxx'.")

		error_func = function()
			Map{subject = c, select = "x", title = 5, values = {1, 2}, colors = {"blue", "red"}}
		end
		unitTest:assert_error(error_func, unnecessaryArgumentMsg("title"))

		-- background
		error_func = function()
			Map{subject = c, grouping = "background", title =  "aaa"}
		end
		unitTest:assert_error(error_func, unnecessaryArgumentMsg("title"))

		error_func = function()
			Map{subject = c, grouping = "background"}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("colors"))

		error_func = function()
			Map{subject = c, grouping = "background", colors = {1, 2}}
		end
		unitTest:assert_error(error_func, "Strategy 'background' requires only one color, got 2.")	

		error_func = function()
			Map{subject = c, grouping = "background", colors = {"blues"}}
		end
		unitTest:assert_error(error_func, switchInvalidArgumentSuggestionMsg("blues", "colors", "blue"))
	end
}

