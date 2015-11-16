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
-- Author: Pedro R. Andrade (pedro.andrade@inpe.br)
-------------------------------------------------------------------------------------------

return{
	cleanErrorMessage = function(unitTest)
		local str = "...o/github/terrame/bin/packages/base/lua/CellularSpace.lua:871: "
		local err = "attempt to call field '?' (a string value)"

		unitTest:assertEquals(_Gtme.cleanErrorMessage(str..err), err)
	end,
	stringToLabel = function(unitTest)
        unitTest:assertEquals(_Gtme.stringToLabel("myFirstString"), "My First String")
        unitTest:assertEquals(_Gtme.stringToLabel(255), "255")
        unitTest:assertEquals(_Gtme.stringToLabel("value255Abc"), "Value 255 Abc")
        unitTest:assertEquals(_Gtme.stringToLabel("valueABC233"), "Value ABC 233")
        unitTest:assertEquals(_Gtme.stringToLabel("my_first_string"), "My First String")
        unitTest:assertEquals(_Gtme.stringToLabel("my_first_string_"), "My First String")
        unitTest:assertEquals(_Gtme.stringToLabel("myFirstString_"), "My First String")
        unitTest:assertEquals(_Gtme.stringToLabel("myFirstStr", "myParent"), "My First Str (in My Parent)")
	end
}

