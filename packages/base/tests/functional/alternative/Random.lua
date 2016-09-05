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
	Random = function(unitTest)
		local error_func = function()
			Random(12345)
		end
		unitTest:assertError(error_func, tableArgumentMsg())

		error_func = function()
			Random{min = false}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("min", "number", false))

		error_func = function()
			Random{min = 2, max = false}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("max", "number", false))

		error_func = function()
			Random{min = 20, max = 5}
		end
		unitTest:assertError(error_func, "Argument 'max' should be greater than 'min'.")
	
		error_func = function()
			Random{min = 2, max = 5, w = 2}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("w"))
	
		error_func = function()
			Random{p = 0.3, w = 2}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("w"))
		
		error_func = function()
			Random{1, 2, 4, 5, 6, w = 2}
		end
		unitTest:assertError(error_func, "The only named arguments should be distrib and seed.")

		error_func = function()
			Random{min = 2, max = 5, step = 2}
		end
		unitTest:assertError(error_func, "Invalid 'max' value (5). It could be 4.0 or 6.0.")

		error_func = function()
			Random{min = 2, max = 5, step = false}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("step", "number", false))

		error_func = function()
			Random{min = "2", max = 5, step = 2}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("min", "number", "2"))

		error_func = function()
			Random{min = 2, max = "5", step = 2}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("max", "number", "5"))

		error_func = function()
			Random{min = 20, max = 5, step = 2}
		end
		unitTest:assertError(error_func, "Argument 'max' should be greater than 'min'.")

		error_func = function()
			Random{male = 0.4, female = "0.6"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("female", "number", "0.6"))

		error_func = function()
			Random{male = 0.4, female = 0.5}
		end
		unitTest:assertError(error_func, "Sum should be one, got 0.9.")
	end,
	integer = function(unitTest)
		local randomObj = Random{}

		local error_func = function()
			randomObj:integer("terralab")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "number", "terralab"))

		error_func = function()
			randomObj:integer(2.5)
		end
		unitTest:assertError(error_func, integerArgumentMsg(1, 2.5))

		error_func = function()
			randomObj:integer(2, "terralab")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "number", "terralab"))

		error_func = function()
			randomObj:integer(1, 2.5)
		end
		unitTest:assertError(error_func, integerArgumentMsg(2, 2.5))

		error_func = function()
			randomObj:integer(1, 0)
		end
		unitTest:assertError(error_func, "It is not possible to sample from an empty object.")
	end,
	number = function(unitTest)
		local randomObj = Random{}

		local error_func = function()
			randomObj:number("terralab")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "number", "terralab"))

		error_func = function()
			randomObj:number(2.5, "terralab")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "number", "terralab"))
	end,
	reSeed = function(unitTest)
		local randomObj = Random{}
		local error_func = function()
			randomObj:reSeed("terralab")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "number", "terralab"))

		error_func = function()
			randomObj:reSeed(2.3)
		end
		unitTest:assertError(error_func, integerArgumentMsg(1, 2.3))

		error_func = function()
			randomObj:reSeed(0)
		end
		unitTest:assertError(error_func, "Argument 'seed' cannot be zero.")
	end
}

