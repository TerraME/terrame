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
	CellularSpace = function(unitTest)
		local error_func = function()
			local cs = CellularSpace{
				xdim = 0,
				ydim = 30
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'xdim' expected positive integer number, got 0.")

		error_func = function()
			local cs = CellularSpace{
				xdim = 5,
				ydim = 0
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'ydim' expected positive integer number, got 0.")

		error_func = function()
			local cs = CellularSpace{
				xdim = "terralab",
				ydim = 30
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'xdim' expected positive integer number, got string.")

		error_func = function()
			local cs = CellularSpace{
				xdim = -123,
				ydim = 30
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'xdim' expected positive integer number, got -123.")


		error_func = function()
			local cs = CellularSpace{
				xdim = 30,
				ydim = "terralab"
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'ydim' expected positive integer number, got string.")

		error_func = function()
			cs = CellularSpace{
				xdim = 30,
				ydim = -123
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'ydim' expected positive integer number, got -123.")
	end,
	get = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			cs:get()
		end
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")

		error_func = function()
			cs:get(2)
		end
		unitTest:assert_error(error_func, "Error: Parameter '#2' is mandatory.")
	end,
	getCell = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			cs:getCell(1, 2)
		end
		unitTest:assert_error(error_func, "Error: Function 'getCell' is deprecated. Use 'get' instead.")
	end,
	getCells = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			cs:getCells()
		end
		unitTest:assert_error(error_func, "Error: Function 'getCells' is deprecated. Use '.cells' instead.")
	end,
	getCellByID = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			cs:getCellByID("C0L0")
		end
		unitTest:assert_error(error_func, "Error: Function 'getCellByID' is deprecated. Use 'get' instead.")
	end,

	createNeighborhood = function(unitTest)
		local cs = CellularSpace{xdim = 10, ydim = 10}
		local cs2 = CellularSpace{xdim = 10, ydim = 10}

		local error_func = function()
			cs:createNeighborhood("dataTest")
		end
		unitTest:assert_error(error_func, "Error: Parameters for 'createNeighborhood' must be named.")
	
		error_func = function()
			cs:createNeighborhood{strategy = "teste"}
		end
		unitTest:assert_error(error_func, "Error: 'teste' is an invalid value for parameter 'strategy'. It must be a string from the set ['3x3', 'coord', 'function', 'moore', 'mxn', 'vonneumann']."
		)

		error_func = function()
			cs:createNeighborhood{strategy = 50}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'strategy' expected string, got number.")

		error_func = function()
			cs:createNeighborhood{strategy = "moore", name = 50}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'name' expected string, got number.")

		error_func = function()
			cs:createNeighborhood{
				strategy = "moore",
				name = {}
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'name' expected string, got table.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "moore",
				name = "my_neighborhood",
				self = "true"
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'self' expected boolean, got string.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "moore",
				name = "my_neighborhood",
				self = true,
				wrap = "true"
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'wrap' expected boolean, got string.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "vonneumann",
				name = "my_neighborhood",
				self = "true"
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'self' expected boolean, got string.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "vonneumann",
				name = "my_neighborhood",
				self = false,
				wrap = "true"
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'wrap' expected boolean, got string.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "3x3",
				name = "my_neighborhood",
				filter = "teste"
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'filter' expected function, got string.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "3x3",
				name = "my_neighborhood",
				filter = function() return true end,
				weight = true
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'weight' expected function, got boolean.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn"
			}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'm' is mandatory.")

		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood"
			}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'm' is mandatory.")

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
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'm' expected positive integer number (greater than zero), got string.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = -1
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'm' expected positive integer number (greater than zero), got -1.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = 0
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'm' expected positive integer number (greater than zero), got 0.")

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
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'n' expected positive integer number (greater than zero), got string.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = 5,
				n = -1
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'n' expected positive integer number (greater than zero), got -1.")

		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = 5,
				n = 0
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'n' expected positive integer number (greater than zero), got 0.")

		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = 5,
				n = 5,
				filter = true
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'filter' expected function, got boolean.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				m = 5,
				n = 5,
				filter = function() end,
				weight = true
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'weight' expected function, got boolean.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				target = "teste",
				m = 5,
				n = 5,
				filter = function() end,
				weight = function() end
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'target' expected CellularSpace or nil, got string.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				target = cs,
				m = 4,
				n = 5
			}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'm' is even. It will be increased by one to keep the Cell in the center of the Neighborhood.")

		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				target = cs,
				m = 5,
				n = 4
			}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'n' is even. It will be increased by one to keep the Cell in the center of the Neighborhood.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				target = cs2
			}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'm' is mandatory.")

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
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'm' expected positive integer number (greater than zero), got string.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				target = cs2,
				m = -1
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'm' expected positive integer number (greater than zero), got -1.")

		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				target = cs2,
				m = 0
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'm' expected positive integer number (greater than zero), got 0.")

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
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'n' expected positive integer number (greater than zero), got string.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				target = cs2,
				m = 5, 
				n = -1
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'n' expected positive integer number (greater than zero), got -1.")

		error_func = function()
			cs:createNeighborhood{
				strategy = "mxn",
				name = "my_neighborhood",
				target = cs2,
				m = 5, 
				n = 0
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'n' expected positive integer number (greater than zero), got 0.")

		error_func = function()
			cs:createNeighborhood{
				strategy = "function"
			}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'filter' is mandatory.")

		error_func = function()
			cs:createNeighborhood{
				strategy = "function",
				name = "my_neighborhood"
			}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'filter' is mandatory.")

		error_func = function()
			cs:createNeighborhood{
				strategy = "function",
				name = "my_neighborhood",
				filter = true
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'filter' expected function, got boolean.")
	
		error_func = function()
			cs:createNeighborhood{
				strategy = "function",
				name = "my_neighborhood",
				weight = weightFunction
			}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'filter' is mandatory.")

		error_func = function()
			cs:createNeighborhood{
				strategy = "function",
				name = "my_neighborhood",
				filter = function() end,
				weight = 3
			}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'weight' expected function, got number.")
	end,
	size = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			cs:size()
		end
		unitTest:assert_error(error_func, "Error: Function 'size' is deprecated. Use 'operator #' instead.")
	end,
	split = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		local error_func = function()
			cs:split()
		end
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")

		error_func = function()
			cs:split(34)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected string or function, got number.")

		error_func = function()
			cs:split({})
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected string or function, got table.")
	end,
	synchronize = function(unitTest)
		local cs = CellularSpace{xdim = 5}

		local error_func = function()
			cs:synchronize(true)
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected string, table or nil, got boolean.")

		error_func = function()
			cs:synchronize{123, "height_"}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'values' should contain only strings.")
	end,
	load = function(unitTest)
		local csK = CellularSpace{xdim = 2}
		local error_func = function()
			csK:load()
		end
		unitTest:assert_error(error_func, "Error: Cannot load volatile cellular spaces.")
	end
}

