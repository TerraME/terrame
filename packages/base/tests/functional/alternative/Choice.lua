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
	Choice = function(unitTest)
		local error_func = function()
			Choice()
		end
		unitTest:assertError(error_func, tableArgumentMsg())

		error_func = function()
			Choice{}
		end
		unitTest:assertError(error_func, "There are no options for the Choice (table is empty).")

		error_func = function()
			Choice{1}
		end
		unitTest:assertError(error_func, "Choice has only one available value.")


		error_func = function()
			Choice{1, 2, "3"}
		end
		unitTest:assertError(error_func, "All the elements of Choice should have the same type.")

		error_func = function()
			Choice{1, 2, 3, default = 1}
		end
		unitTest:assertError(error_func, defaultValueMsg("default", 1))

		error_func = function()
			Choice{1, 2, 3, default = 4}
		end
		unitTest:assertError(error_func, "The default value (4) does not belong to Choice.")

		error_func = function()
			Choice{1, 2, 3, max = 4}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("max"))

		error_func = function()
			Choice{false, true}
		end
		unitTest:assertError(error_func, "The elements should be number or string, got boolean.")

		error_func = function()
			Choice{min = false}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("min", "number", false))

		error_func = function()
			Choice{min = 2, max = false}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("max", "number", false))

		error_func = function()
			Choice{min = 2, default = 1}
		end
		unitTest:assertError(error_func, "Argument 'default' should be greater than or equal to 'min'.")

		error_func = function()
			Choice{max = false}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("max", "number", false))

		error_func = function()
			Choice{max = 2, default = 3}
		end
		unitTest:assertError(error_func, "Argument 'default' should be less than or equal to 'max'.")

		error_func = function()
			Choice{min = 2, max = 4, step = false}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("step", "number", false))

		error_func = function()
			Choice{min = 2, max = 4, w = false}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("w"))

		error_func = function()
			Choice{10, 20, "30"}
		end
		unitTest:assertError(error_func, "All the elements of Choice should have the same type.")

		error_func = function()
			Choice{min = 1, max = 10, step = 1, default = 1}
		end
		unitTest:assertError(error_func, defaultValueMsg("default", 1))

		error_func = function()
			Choice{min = 1, max = 10, step = 1, default = "a"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("default", "number", "a"))

		error_func = function()
			Choice{min = 1, max = 10, step = 1, default = 1.2}
		end
		unitTest:assertError(error_func, "Invalid 'default' value (1.2). It could be 1.0 or 2.0.")

		error_func = function()
			Choice{min = 1, max = 10, step = 1, default = 11}
		end
		unitTest:assertError(error_func, "Argument 'default' should be less than or equal to 'max'.")

		error_func = function()
			Choice{min = 1, max = 10, step = 1, default = 0}
		end
		unitTest:assertError(error_func, "Argument 'default' should be greater than or equal to 'min'.")

		error_func = function()
			Choice{min = 1, max = 0}
		end
		unitTest:assertError(error_func, "Argument 'max' should be greater than 'min'.")

		error_func = function()
			Choice{min = 1, max = 10, step = 1, default = 1}
		end
		unitTest:assertError(error_func, defaultValueMsg("default", 1))

		error_func = function()
			Choice{min = 1, max = 10, step = 4}
		end
		unitTest:assertError(error_func, "Invalid 'max' value (10). It could be 9.0 or 13.0.")

		error_func = function()
			Choice{min = 1, step = 3}
		end
		unitTest:assertError(error_func, "Attribute 'step' requires 'max' and 'min'.")

		error_func = function()
			Choice{min = 1, max = 4, step = 1, slices = 4}
		end
		unitTest:assertError(error_func, "It is not possible to use arguments 'step' and 'slices' at the same time.")

		error_func = function()
			Choice{min = 2, max = 20, slices = "abc"}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("slices", "number", "abc"))

		error_func = function()
			Choice{min = 2, max = 20, slices = 1}
		end
		unitTest:assertError(error_func, "Argument 'slices' (1) should be greater than two.")

		error_func = function()
			Choice{min = 2, max = 20, slices = 2.5}
		end
		unitTest:assertError(error_func, "Invalid 'slices' value (2.5). It could be 2 or 3.")
	end
}

