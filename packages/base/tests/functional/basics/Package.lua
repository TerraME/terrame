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
	filePath = function(unitTest)
		unitTest:assertType(filePath("test/simple-cs.csv"), "File")
	end,
	filesByExtension = function(unitTest)
		local files = filesByExtension("base", "csv")

		unitTest:assertType(files, "table")
		unitTest:assertEquals(#files, 1)
		unitTest:assertType(files[1], "File")
	end,
	isLoaded = function(unitTest)
		unitTest:assert(isLoaded("base"))
	end,
	getPackage = function(unitTest)
		local base = getPackage("base")

		local cs = base.CellularSpace{xdim = 10}
		unitTest:assertType(cs, "CellularSpace")

		-- The assert below checks the number of functions in package 'base'.
		unitTest:assertEquals(getn(base), 181)
	end,
	import = function(unitTest)
		forEachCell = nil

		import("base", true)

		unitTest:assertType(forEachCell, "function")

		local warning_func = function()
			import("base")
		end
		unitTest:assertWarning(warning_func, "Package 'base' is already loaded.")
		unitTest:assertType(forEachCell, "function")
	end,
	packageInfo = function(unitTest)
		local r = packageInfo()

		unitTest:assertEquals(r.version, "2.0.0-rc9-dev")
		unitTest:assertEquals(r.package, "base")
		unitTest:assertEquals(r.url, "http://www.terrame.org")
		unitTest:assertType(r.data, "Directory")
		unitTest:assertType(r.path, "Directory")
	end
}

