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
	add = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		local cs2 = CellularSpace{xdim = 10}

		local error_func = function()
			cs:add(2)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "Cell", 2))

		error_func = function()
			cs:add(cs2:sample())
		end
		unitTest:assert_error(error_func, "The cell already has a parent.")

		local c = Cell{x = 30, y = 30}
		local c2 = Cell{x = 30, y = 30}

		cs:add(c)

		error_func = function()
			cs:add(c2)
		end
		unitTest:assert_error(error_func, "Cell (30, 30) already belongs to the CellularSpace.")
	end,
	CellularSpace = function(unitTest)
		local error_func = function()
			local cs = CellularSpace{
				xdm = 0
			}
		end
		unitTest:assert_error(error_func, "Not enough information to build the CellularSpace.")

		local error_func = function()
			local cs = CellularSpace{
				xdim = 0,
				ydim = 30
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("xdim", "positive integer number", 0))

		error_func = function()
			local cs = CellularSpace{
				xdim = 5,
				ydim = 0
			}
		end
		unitTest:assert_error(error_func,  incompatibleValueMsg("ydim", "positive integer number", 0))

		error_func = function()
			local cs = CellularSpace{
				xdim = "terralab",
				ydim = 30
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("xdim", "number", "terralab"))

		error_func = function()
			local cs = CellularSpace{
				xdim = -123,
				ydim = 30
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("xdim", "positive integer number", -123))

		error_func = function()
			local cs = CellularSpace{
				xdim = 30,
				ydim = "terralab"
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("ydim", "number", "terralab"))

		error_func = function()
			cs = CellularSpace{
				xdim = 30,
				ydim = -123
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("ydim", "positive integer number", -123))
	end,
	get = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			cs:get()
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			cs:get(2)
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			cs:get(2.3, 4)
		end
		unitTest:assert_error(error_func, incompatibleValueMsg(1, "positive integer number", 2.3))

		error_func = function()
			cs:get(4, 2.3)
		end
		unitTest:assert_error(error_func, incompatibleValueMsg(2, "positive integer number", 2.3))

		error_func = function()
			cs:get("4", 2.3)
		end
		unitTest:assert_error(error_func, "As #1 is string, #2 should be nil, but got number.")	
	end,
	getCell = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			cs:getCell(1, 2)
		end
		unitTest:assert_error(error_func, deprecatedFunctionMsg("getCell", "get"))
	end,
	getCells = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			cs:getCells()
		end
		unitTest:assert_error(error_func, deprecatedFunctionMsg("getCells", ".cells"))
	end,
	getCellByID = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			cs:getCellByID("C0L0")
		end
		unitTest:assert_error(error_func, deprecatedFunctionMsg("getCellByID", "get"))
	end,
	createNeighborhood = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		local cs2 = CellularSpace{xdim = 10}

		local error_func = function()
			cs:createNeighborhood("dataTest")
		end
		unitTest:assert_error(error_func, namedArgumentsMsg())
	
		error_func = function()
			cs:createNeighborhood{strategy = "teste"}
		end

		local options = {
			["3x3"] = true,
			coord = true,
			["function"] = true,
			moore = true,
			mxn = true,
			vonneumann = true
		}

		unitTest:assert_error(error_func, switchInvalidArgumentMsg("teste", "strategy", options))

		error_func = function()
			cs:createNeighborhood{strategy = 50}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("strategy", "string", 50))

		error_func = function()
			cs:createNeighborhood{name = 50}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("name", "string", 50))

		error_func = function()
			cs:createNeighborhood{
				name = {}
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("name", "string", {}))
	
		error_func = function()
			cs:createNeighborhood{
				name = "my_neighborhood",
				self = "true"
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("self", "boolean", "true"))
	
		error_func = function()
			cs:createNeighborhood{
				name = "my_neighborhood",
				wrap = "true"
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("wrap", "boolean", "true"))
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "vonneumann",
				name = "my_neighborhood",
				self = "true"
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("self", "boolean", "true"))
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "vonneumann",
				name = "my_neighborhood",
				wrap = "true"
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("wrap", "boolean", "true"))
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "3x3",
				name = "my_neighborhood",
				filter = "teste"
			}
		end
		unitTest:assert_error(error_func, deprecatedFunctionMsg("createNeighborhood with strategy 3x3", "mxn"))
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = "teste",
				n = 5,
				filter = function() return true end,
				weight = function() return 1 end
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("m", "number", "teste"))
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = -1
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("m", "positive integer number (greater than zero)", -1))
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = 0
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("m", "positive integer number (greater than zero)", 0))

		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = 1.3
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("m", "positive integer number (greater than zero)", 1.3))

		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = 5,
				n = "teste",
				filter = function() return true end,
				weight = function() return 1 end
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("n", "number", "teste"))
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = 5,
				n = -1
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("n", "positive integer number (greater than zero)", -1))

		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = 5,
				n = 0
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("n", "positive integer number (greater than zero)", 0))

		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = 5,
				n = 1.3
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("n", "positive integer number (greater than zero)", 1.3))

		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = 5,
				filter = true
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("filter", "function", true))
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = 5,
				filter = function() end,
				weight = true
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("weight", "function", true))
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = 5,
				n = 5,
				filter = function() end,
				weight = function() end
			}
		end
		unitTest:assert_error(error_func, defaultValueMsg("n", 5))
		
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				target = "teste",
				m = 5,
				filter = function() end,
				weight = function() end
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("target", "CellularSpace", "teste"))

		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = 4
			}
		end
		unitTest:assert_error(error_func, "Argument 'm' is even. It will be increased by one to keep the Cell in the center of the Neighborhood.")

		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = 5,
				n = 4
			}
		end
		unitTest:assert_error(error_func, "Argument 'n' is even. It will be increased by one to keep the Cell in the center of the Neighborhood.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				target = cs2,
				m = "teste",
				n = 5,
				filter = function()
					return true
				end,
				weight = function()
					return 1
				end
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("m", "number", "teste"))
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				target = cs2,
				m = -1
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("m", "positive integer number (greater than zero)", -1))

		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				target = cs2,
				m = 0
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("m", "positive integer number (greater than zero)", 0))

		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				target = cs2,
				m = 5,
				n = "teste",
				filter = function() return true end,
				weight = function() return 1 end
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("n", "number", "teste"))
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				target = cs2,
				m = 5, 
				n = -1
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("n", "positive integer number (greater than zero)", -1))

		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				target = cs2,
				m = 5, 
				n = 0
			}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("n", "positive integer number (greater than zero)", 0))

		error_func = function()
			cs:createNeighborhood{
				strategy = "function"
			}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("filter"))

		error_func = function()
			cs:createNeighborhood{
				strategy = "function",
				name = "my_neighborhood"
			}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("filter"))

		error_func = function()
			cs:createNeighborhood{
				strategy = "function",
				name = "my_neighborhood",
				filter = true
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("filter", "function", true))
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "function",
				name = "my_neighborhood",
				weight = weightFunction
			}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("filter"))

		error_func = function()
			cs:createNeighborhood{
				strategy = "function",
				name = "my_neighborhood",
				filter = function() end,
				weight = 3
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("weight", "function", 3))

		local cs = CellularSpace{xdim = 10}

		cs:createNeighborhood{name = "abc"}

		error_func = function()
			cs:createNeighborhood{name = "abc"}
		end
		unitTest:assert_error(error_func, "Neighborhood 'abc' already exists.")
	end,
	notify = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			cs:notify("not_int")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "number", "not_int"))

		error_func = function()
			cs:notify(-1)
		end
		unitTest:assert_error(error_func, incompatibleValueMsg(1, "positive number", -1))
	end,
	size = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			cs:size()
		end
		unitTest:assert_error(error_func, deprecatedFunctionMsg("size", "operator #"))
	end,
	split = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			cs:split()
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			cs:split(34)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "string or function", 34))

		error_func = function()
			cs:split({})
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "string or function", {}))
	end,
	synchronize = function(unitTest)
		local cs = CellularSpace{xdim = 5}

		local error_func = function()
			cs:synchronize(true)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "string, table or nil", true))

		error_func = function()
			cs:synchronize{123, "height_"}
		end
		unitTest:assert_error(error_func, "Argument 'values' should contain only strings.")
	end
}

