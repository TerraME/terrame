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

		local r = Random()
		forEachCell(c, function(cell)
			cell.value = r:number()
			cell.nvalue = r:integer(1, 3)
			cell.bvalue = false
		end)

		local error_func = function()
			Map{}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("target"))

		error_func = function()
			Map{target = Neighborhood()}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("target", "CellularSpace", Neighborhood()))

		error_func = function()
			Map{target = c}
		end
		unitTest:assertError(error_func, "It was not possible to infer argument 'grouping'.")

		error_func = function()
			Map{target = c, select = 5}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 5))

		error_func = function()
			Map{target = c, select = "x", slices = 10, color = 5}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("color", "string or table", 5))

		error_func = function()
			Map{target = c, select = "x", slices = "abc", color = {{1, "red", 3}}}
		end
		unitTest:assertError(error_func, "All the elements of an RGB composition should be numbers, got 'string' in position 1.")

		-- equalsteps
		error_func = function()
			Map{target = c, select = "x", label = 5, slices = 10, color = {"blue", "red"}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("label", "table", 5))

		error_func = function()
			Map{target = c, grouping = "equalsteps"}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("select"))

		error_func = function()
			Map{target = c, select = "mvalue", grouping = "equalsteps"}
		end
		unitTest:assertError(error_func, "Selected element 'mvalue' does not belong to the target.")

		error_func = function()
			Map{target = c, select = "bvalue", grouping = "equalsteps"}
		end
		unitTest:assertError(error_func, "Selected element should be number or function, got boolean.")

		error_func = function()
			Map{target = c, select = {}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", {}))

		error_func = function()
			Map{target = c, select = "x", slices = "abc", color = {{1, 2, 3}}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("slices", "number", "abc"))

		error_func = function()
			Map{target = c, select = "x", slices = 0, min = 5, max = 8, color = {{1, 2, 3}}}
		end
		unitTest:assertError(error_func, "Argument 'slices' (0) should be greater than one.")

		error_func = function()
			Map{target = c, select = "x", slices = 2, min = "abc", color = {{1, 2, 3}}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("min", "number", "abc"))

		error_func = function()
			Map{target = c, select = "x", slices = 2, min = 3, max = "abc", color = {{1, 2, 3}}}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("max", "number", "abc"))

		error_func = function()
			Map{target = c, select = "x", slices = 2, min = 5, max = 3, color = {{1, 2, 3}}}
		end
		unitTest:assertError(error_func, "Argument 'min' (5) should be less than 'max' (3).")

		error_func = function()
			Map{target = c, select = "x", slices = 10, color = {{1, 2}, "red"}}
		end
		unitTest:assertError(error_func, "RGB composition should have 3 values, got 2 values in position 1.")

		error_func = function()
			Map{target = c, select = "x", slices = 10, color = {2, "red"}}
		end
		unitTest:assertError(error_func, "Invalid description for color in position 1. It should be a table or string, got number.")

		error_func = function()
			Map{target = c, select = "x", title = 5, slices = 10, color = {"blue", "red"}}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("title"))

		error_func = function()
			Map{
				target = c,
				select = "x",
				slices = 3,
				color = {"red", "green", "blue"}
			}
		end
		unitTest:assertError(error_func, "Strategy 'equalsteps' requires only two colors, got 3.")

		error_func = function()
			Map{
				target = c,
				select = "x",
				slices = 10,
				color = "Pastel1"
			}
		end
		unitTest:assertError(error_func, "Color 'Pastel1' does not support 10 slices.")

		error_func = function()
			Map{
				target = c,
				select = "x",
				slices = 3,
				color = "Xxx",
				label = {"1", "2", "3"}
			}
		end
		unitTest:assertError(error_func, "Invalid color 'Xxx'.")

		error_func = function()
			Map{
				target = c,
				select = "x",
				slices = 3,
				color = "Pastei1",
				label = {"1", "2", "3"}
			}
		end
		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("Pastei1", "color", "Pastel1"))

		error_func = function()
			Map{target = c, slices = 3, color = {"red", "blu", "green"}}
		end
		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("blu", "color", "blue"))

		error_func = function()
			Map{target = c, slices = 3, color = {"red", {0, 0}, "green"}}
		end
		unitTest:assertError(error_func, "RGB composition should have 3 values, got 2 values in position 2.")	

		-- uniquevalue
		error_func = function()
			Map{target = c, select = "mvalue", value = {1, 2, 3}, grouping = "uniquevalue"}
		end
		unitTest:assertError(error_func, "Selected element 'mvalue' does not belong to the target.")

		error_func = function()
			Map{target = c, select = "bvalue", value = {1, 2, 3}, grouping = "uniquevalue"}
		end
		unitTest:assertError(error_func, "Selected element should be string, number, or function, got boolean.")

		error_func = function()
			Map{
				target = c,
				select = "x",
				value = {1, 2, 3},
				color = {"red", "green"},
				label = {"1", "2", "3"}
			}
		end
		unitTest:assertError(error_func, "There should exist colors for each value. Got 2 colors and 3 values.")

		error_func = function()
			Map{
				target = c,
				select = "x",
				value = {1, 2, 3},
				color = {"red", "blue", "gren"},
				label = {"1", "2", "3"}
			}
		end
		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("gren", "color", "green"))

		error_func = function()
			Map{
				target = c,
				select = "x",
				value = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
				color = "Pastel1"
			}
		end
		unitTest:assertError(error_func, "Color 'Pastel1' does not support 10 slices.")

		error_func = function()
			Map{
				target = c,
				select = "x",
				value = {1, 2, 3},
				color = {"red", "green", "blue"},
				label = {"1", "2"}
			}
		end
		unitTest:assertError(error_func, "There should exist labels for each value. Got 2 labels and 3 values.")

		error_func = function()
			Map{
				target = c,
				select = "x",
				value = {1, 2, 3},
				color = {"red", "green", "blues"},
				label = {"1", "2", "3"}
			}
		end
		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("blues", "color", "blue"))

		error_func = function()
			Map{
				target = c,
				select = "x",
				value = {1, 2, 3},
				color = {"red", "green", "xxxxx"},
				label = {"1", "2", "3"}
			}
		end
		unitTest:assertError(error_func, "Color 'xxxxx' not found. Check the name or use a table with an RGB description.")

		error_func = function()
			Map{
				target = c,
				select = "x",
				value = {1, 2, 3},
				grouping = "uniquevalues",
				color = {"red", "green", "blue"},
				label = {"1", "2", "3"}
			}
		end
		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("uniquevalues", "grouping", "uniquevalue"))

		error_func = function()
			Map{
				target = c,
				select = "x",
				value = {1, 2, 3},
				color = "Bluess",
				label = {"1", "2", "3"}
			}
		end
		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("Bluess", "color", "Blues"))

		error_func = function()
			Map{
				target = c,
				select = "x",
				value = {1, 2, 3},
				color = "Xxx",
				label = {"1", "2", "3"}
			}
		end
		unitTest:assertError(error_func, "Invalid color 'Xxx'.")

		error_func = function()
			Map{
				target = c,
				select = "x",
				value = {1, 2, "3"},
				color = "Blues",
				label = {"1", "2", "3"}
			}
		end
		unitTest:assertError(error_func, "All values should have the same type, got number and string.")

		error_func = function()
			Map{
				target = c,
				select = "x",
				value = {1, 2, 1},
				color = "Blues",
				label = {"1", "2", "3"}
			}
		end
		unitTest:assertError(error_func, "There should not exist repeated elements in 'value'.")

		error_func = function()
			Map{target = c, select = "x", title = 5, value = {1, 2}, color = {"blue", "red"}}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("title"))

		-- background
		error_func = function()
			Map{target = c, grouping = "background", title =  "aaa"}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("title"))

		error_func = function()
			Map{target = c, grouping = "background"}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("color"))

		error_func = function()
			Map{target = c, grouping = "background", color = {"blue", "red"}}
		end
		unitTest:assertError(error_func, "Strategy 'background' requires only one color, got 2.")	

		error_func = function()
			Map{target = c, grouping = "background", color = {"blues"}}
		end
		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("blues", "color", "blue"))

		error_func = function()
			Map{target = c, grouping = "background", color = "Blues"}
		end
		unitTest:assertError(error_func, "Strategy 'background' cannot use ColorBrewer.")
	end,
	save = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local r = Random()

		forEachCell(cs, function(cell)
			cell.value = r:number()
		end)

		local m = Map{
			target = cs,
			select = "value",
			min = 0,
			max = 1,
			slices = 10,
			color = "Blues"
		}

		local error_func = function()
			m:save("file.csv")
		end
		unitTest:assertError(error_func, invalidFileExtensionMsg(1, "csv"))

		unitTest:clear()

		error_func = function()
			m:save("file.bmp")
		end
		unitTest:assertError(error_func, "Trying to use a function of an observer that was destroyed.")
	end
}

