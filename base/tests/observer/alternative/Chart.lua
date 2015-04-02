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
	Chart = function(unitTest)
		local c = Cell{value = 5}

		local error_func = function()
			Chart{}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("subject"))

		local e = Event{action = function() end}
		error_func = function()
			Chart{subject = e}
		end
		unitTest:assert_error(error_func, "Invalid type. Charts only work with Cell, CellularSpace, Agent, and Society.")

		local error_func = function()
			Chart{subject = c, select = 5}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("select", "table", 5))

		local error_func = function()
			Chart{subject = c, select = "mvalue"}
		end
		unitTest:assert_error(error_func, "Selected element 'mvalue' does not belong to the subject.")

		local error_func = function()
			Chart{subject = c, xLabel = 5}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("xLabel", "string", 5))

		local error_func = function()
			Chart{subject = c, yLabel = 5}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("yLabel", "string", 5))

		local error_func = function()
			Chart{subject = c, title = 5}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("title", "string", 5))

		local error_func = function()
			Chart{subject = c, xAxis = 5}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("xAxis", "string", 5))

		local error_func = function()
			Chart{subject = c, xAxis = "value"}
		end
		unitTest:assert_error(error_func, "The subject does not have at least one valid numeric attribute to be used.")

		local error_func = function()
			Chart{subject = c, xwc = 5}
		end
		unitTest:assert_error(error_func, unnecessaryArgumentMsg("xwc"))

		local error_func = function()
			Chart{subject = c, select = {}}
		end
		unitTest:assert_error(error_func, "Charts must select at least one attribute.")

		local cell = Cell{
			value1 = 2,
			value2 = 3
		}

		local error_func = function()
			Chart{subject = cell, select = {"value1", "value2"}, size = "a"}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("size", "table", "a"))

		local error_func = function()
			Chart{subject = cell, select = {"value1", "value2"}, style = 2}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("style", "table", 2))

		local error_func = function()
			Chart{subject = cell, select = {"value1", "value2"}, width = -3}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("width", "greater than zero", -3))

		local error_func = function()
			Chart{subject = cell, select = {"value1", "value2"}, size = -3}
		end
		unitTest:assert_error(error_func, positiveArgumentMsg("size", -3))

		local symbolTable = {
			square = 1,
			diamond = 2,
			triangle = 3,
			ltriangle = 4,
			-- triangle = 5,
			dtriangle = 6, -- downwards triangle
			rtriangle = 7,
			cross = 8,
			vcross = 9, -- vertical cross
			hline = 10,
			vline = 11,
			asterisk = 12,
			star = 13,
			hexagon = 14,
			none = 15
		}

		local styleTable = {
			lines = true,
			dots = true,
			none = true,
			steps = true,
			sticks = true
		}

		local penTable = {
			solid = 1,
			dash = 2,
			dot = 3,
			dashdot = 4,
			dashdotdot = 5
		}

		local error_func = function()
			Chart{subject = cell, select = {"value1", "value2"}, pen = "abc"}
		end
		unitTest:assert_error(error_func, switchInvalidArgumentMsg("abc", "pen", penTable))

		local error_func = function()
			Chart{subject = cell, select = {"value1", "value2"}, pen = "solyd"}
		end
		unitTest:assert_error(error_func, switchInvalidArgumentSuggestionMsg("solyd", "pen", "solid"))

		local error_func = function()
			Chart{subject = cell, select = {"value1", "value2"}, style = "abc"}
		end
		unitTest:assert_error(error_func, switchInvalidArgumentMsg("abc", "style", styleTable))

		local error_func = function()
			Chart{subject = cell, select = {"value1", "value2"}, style = "line"}
		end
		unitTest:assert_error(error_func, switchInvalidArgumentSuggestionMsg("line", "style", "lines"))

		local error_func = function()
			Chart{subject = cell, select = {"value1", "value2"}, symbol = -3}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("symbol", "table", -3))

		local error_func = function()
			Chart{subject = cell, select = {"value1", "value2"}, symbol = "abc"}
		end
		unitTest:assert_error(error_func, switchInvalidArgumentMsg("abc", "symbol", symbolTable))

		local error_func = function()
			Chart{subject = cell, select = {"value1", "value2"}, symbol = "dyamond"}
		end
		unitTest:assert_error(error_func, switchInvalidArgumentSuggestionMsg("dyamond", "symbol", "diamond"))

		local world = CellularSpace{
			xdim = 10,
			value = "aaa"
		}

		local error_func = function()
			Chart{subject = world}
		end
		unitTest:assert_error(error_func, "The subject does not have at least one valid numeric attribute to be used.")

		world.msum = 5

		local error_func = function()
			Chart{subject = world, label = {"sss"}}
		end
		unitTest:assert_error(error_func, "As select is nil, it is not possible to use label.")

		local error_func = function()
			Chart{subject = world, select = "value"}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("value", "number or function", "value"))

		local cell = Cell{
			value = 3
		}

		local c = Chart{subject = cell}

		local error_func = function()
			c:save("file.wrongext")
		end
		unitTest:assert_error(error_func, invalidFileExtensionMsg("#1", "wrongext"))

		local cell = Cell{}

		for i = 1, 15 do
			cell["v"..i] = 5
		end

		local error_func = function()
			Chart{subject = cell}
		end
		unitTest:assert_error(error_func, "Argument color is compulsory when using more than 10 attributes.")

		local error_func = function()
			Chart{subject = cell, select = {"v1", "v2", "v3"}, label = {"V1", "V2"}}
		end
		unitTest:assert_error(error_func, "Arguments 'select' and 'label' should have the same size.")
	end
}

