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
		unitTest:assert_error(error_func, "Error: Parameter 'subject' is mandatory.")

		local error_func = function()
			Map{subject = Neighborhood()}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'subject' expected CellularSpace, got Neighborhood.")

		local error_func = function()
			Map{subject = c}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'select' is mandatory.")

		local error_func = function()
			Map{subject = c, select = 5}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'select' expected table, got number.")

		local error_func = function()
			Map{subject = c, select = "mvalue"}
		end
		unitTest:assert_error(error_func, "Error: Selected element 'mvalue' does not belong to the subject.")

		local error_func = function()
			Map{subject = c, select = "x", title = 5}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'title' is unnecessary.")

		local error_func = function()
			Map{subject = c, select = {}}
		end
		unitTest:assert_error(error_func, "Error: Maps must select at least one attribute.")

	end
}

