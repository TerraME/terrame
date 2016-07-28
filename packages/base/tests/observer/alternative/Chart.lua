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
	Chart = function(unitTest)
		local c = Cell{value = 5}

		local error_func = function()
			Chart(2)
		end
		unitTest:assertError(error_func, namedArgumentsMsg())

		error_func = function()
			Chart{}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("target"))

		error_func = function()
			Chart{target = 2}
		end
		unitTest:assertError(error_func, "Invalid type. Charts only work with Cell, CellularSpace, Agent, Society, table, and instance of Model, got number.")

		error_func = function()
			Chart{target = c, select = 5}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("select", "table", 5))

		error_func = function()
			Chart{target = c, select = "mvalue"}
		end
		unitTest:assertError(error_func, "Selected element 'mvalue' does not belong to the target. Do you mean 'value'?")

		error_func = function()
			Chart{target = c, select = "abcd"}
		end
		unitTest:assertError(error_func, "Selected element 'abcd' does not belong to the target.")

		error_func = function()
			Chart{target = c, xLabel = 5}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("xLabel", "string", 5))

		error_func = function()
			Chart{target = c, yLabel = 5}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("yLabel", "string", 5))

		error_func = function()
			Chart{target = c, title = 5}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("title", "string", 5))

		error_func = function()
			Chart{target = c, xAxis = 5}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("xAxis", "string", 5))

		error_func = function()
			Chart{target = c, xAxis = "value"}
		end
		unitTest:assertError(error_func, "The target does not have at least one valid numeric attribute to be used.")

		error_func = function()
			Chart{target = c, select = "value", xAxis = "value"}
		end
		unitTest:assertError(error_func, "Attribute 'value' cannot belong to argument 'select' as it was already selected as 'xAxis'.")

		error_func = function()
			Chart{target = c, xwc = 5}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("xwc"))

		error_func = function()
			Chart{target = c, select = {}}
		end
		unitTest:assertError(error_func, "Charts must select at least one attribute.")

		local cell = Cell{
			value1 = 2,
			value2 = 3
		}

		error_func = function()
			Chart{target = cell, select = {"value1", "value2"}, size = "a"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("size", "table", "a"))

		error_func = function()
			Chart{target = cell, select = {"value1", "value2"}, style = 2}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("style", "table", 2))

		error_func = function()
			Chart{target = cell, select = {"value1", "value2"}, width = -3}
		end
		unitTest:assertError(error_func, incompatibleValueMsg("width", "greater than zero", -3))

		error_func = function()
			Chart{target = cell, select = {"value1", "value2"}, size = -3}
		end
		unitTest:assertError(error_func, positiveArgumentMsg("size", -3))

		error_func = function()
			Chart{target = Environment{}, select = "value1"}
		end
		unitTest:assertError(error_func, "There is no Model instance within the Environment.")

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

		error_func = function()
			Chart{target = cell, select = {"value1", "value2"}, pen = "abc"}
		end
		unitTest:assertError(error_func, switchInvalidArgumentMsg("abc", "pen", penTable))

		error_func = function()
			Chart{target = cell, select = {"value1", "value2"}, pen = "solyd"}
		end
		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("solyd", "pen", "solid"))

		error_func = function()
			Chart{target = cell, select = {"value1", "value2"}, style = "abc"}
		end
		unitTest:assertError(error_func, switchInvalidArgumentMsg("abc", "style", styleTable))

		error_func = function()
			Chart{target = cell, select = {"value1", "value2"}, style = "line"}
		end
		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("line", "style", "lines"))

		error_func = function()
			Chart{target = cell, select = {"value1", "value2"}, symbol = -3}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("symbol", "table", -3))

		error_func = function()
			Chart{target = cell, select = {"value1", "value2"}, symbol = "abc"}
		end
		unitTest:assertError(error_func, switchInvalidArgumentMsg("abc", "symbol", symbolTable))

		error_func = function()
			Chart{target = cell, select = {"value1", "value2"}, symbol = "dyamond"}
		end
		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("dyamond", "symbol", "diamond"))

		local world = CellularSpace{
			xdim = 10,
			value = "aaa"
		}

		error_func = function()
			Chart{target = world}
		end
		unitTest:assertError(error_func, "The target does not have at least one valid numeric attribute to be used.")

		world.msum = 5

		error_func = function()
			Chart{target = world, label = {"sss"}}
		end
		unitTest:assertError(error_func, "As select is nil, it is not possible to use label.")

		error_func = function()
			Chart{target = world, select = "value"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("value", "number or function", "value"))

		cell = Cell{
			value = 3
		}

		c = Chart{target = cell}

		error_func = function()
			c:save("file.wrongext")
		end
		unitTest:assertError(error_func, invalidFileExtensionMsg("#1", "wrongext"))

		cell = Cell{}

		for i = 1, 15 do
			cell["v"..i] = 5
		end

		error_func = function()
			Chart{target = cell}
		end
		unitTest:assertError(error_func, "Argument color is compulsory when using more than 10 attributes.")

		error_func = function()
			Chart{target = cell, select = {"v1", "v2", "v3"}, label = {"V1", "V2"}}
		end
		unitTest:assertError(error_func, "Arguments 'select' and 'label' should have the same size, got 3 and 2.")

		error_func = function()
			Chart{target = cell, select = {"v1", "v2", "v3"}, color = {"red", "blue"}}
		end
		unitTest:assertError(error_func, "Arguments 'select' and 'color' should have the same size, got 3 and 2.")

		error_func = function()
			Chart{target = cell, select = {"v1", "v2", "v3"}, color = {"red", "blu", "green"}}
		end
		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("blu", "color", "blue"))

		error_func = function()
			Chart{target = cell, select = {"v1", "v2", "v3"}, color = {"red", "xxx", "green"}}
		end
		unitTest:assertError(error_func, "Color 'xxx' not found. Check the name or use a table with an RGB description.")

		error_func = function()
			Chart{target = cell, select = {"v1", "v2", "v3"}, color = {"red", {0, 0}, "green"}}
		end
		unitTest:assertError(error_func, "RGB composition should have 3 values, got 2 values in position 2.")

		error_func = function()
			Chart{target = cell, select = {"v1", "v2", "v3"}, color = {"red", {0, 0, "red"}, "green"}}
		end
		unitTest:assertError(error_func, "All the elements of an RGB composition should be numbers, got 'string' in position 2.")

		-- chart using data
		local tab = makeDataTable{
			first = 2000,
			step = 10,
			demand = {7, 8, 9, 10},
			limit = {0.1, 0.04, 0.3, 0.07}
		}

		error_func = function()
			Chart{
			    data = tab,
			    select = "limit",
				target = cell,
			    xAxis = "demand",
			    color = "blue"
			}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("target"))
		
		error_func = function()
			Chart{
			    data = "limit",
			    select = "limit",
			    xAxis = "demand",
			    color = "blue"
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("data", "table", "limit"))
	
		error_func = function()
			Chart{
			    data = tab,
			    select = "limit",
			    xAxis = "demand2",
			    color = "blue"
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("data.demand2", "table"))


		error_func = function()
			Chart{
			    data = tab,
			    select = "limit2",
			    xAxis = "demand",
			    color = "blue"
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("data.limit2", "table"))
	
		tab.demand = {7, 8, 9}

		error_func = function()
			Chart{
			    data = tab,
			    select = "limit",
			    xAxis = "demand",
			    color = "blue"
			}
		end
		unitTest:assertError(error_func, "Argument 'data.demand' should have 4 elements, got 3.")

		tab = makeDataTable{
			first = 2000,
			step = 10,
			demand = {7, 8, 9, 10},
			limit = {0.1, 0.04, 0.3, 0.07}
		}

		tab.limit = "abc"

		error_func = function()
			Chart{
			    data = tab,
			    select = "limit",
			    xAxis = "demand",
			    color = "blue"
			}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("data.limit", "table", "abc"))

		tab = makeDataTable{
			first = 2000,
			step = 10,
			demand = {7, 8, 9, 10},
			limit = {0.1, 0.04, 0.3, 0.07}
		}

		tab.limit = {0.1, 0.04, 0.3}

		error_func = function()
			Chart{
			    data = tab,
			    select = {"limit", "demand"},
			    color = "blue"
			}
		end
		unitTest:assertError(error_func, "Argument 'data.demand' should have 3 elements, got 4.")
	
		error_func = function()
			Chart{
			    data = tab,
			    select = "limit",
			    xAxis = "demand",
			    color = "blue"
			}
		end
		unitTest:assertError(error_func, "Argument 'data.demand' should have 3 elements, got 4.")
	end,
	save = function(unitTest)
		local c = Cell{value = 5}

		local chart = Chart{target = c}

		unitTest:clear()

		local error_func = function()
			chart:save("file.bmp")
		end
		unitTest:assertError(error_func, "Trying to call a function of an observer that was destroyed.")
	end
}

