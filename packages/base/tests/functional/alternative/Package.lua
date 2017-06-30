-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

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
	filePath = function(unitTest)
		local error_func = function()
			filePath("mriver.shp")
		end

		unitTest:assertError(error_func, "File 'data/mriver.shp' does not exist in package 'base'. Do you mean 'river.shp'?", 2)

		local tlInfo = packageInfo("gis")
		local baseInfo = packageInfo()
		local s = sessionInfo().separator

		os.execute("cp "..tlInfo.data.."amazonia.lua "..baseInfo.data)

		error_func = function()
			filePath("amazonia.tview")
		end

		unitTest:assertError(error_func, "File 'data/amazonia.tview' does not exist in package 'base'. Please run 'terrame -package base -project amazonia' to create it.", 2)

		error_func = function()
			filePath("test"..s.."mriver_lin.shp")
		end

		unitTest:assertError(error_func, "File 'data/test/mriver_lin.shp' does not exist in package 'base'. Do you mean 'river.shp'?")

		error_func = function()
			filePath("error"..s.."csv-error.csv")
		end

		unitTest:assertError(error_func, "Directory '"..baseInfo.data.."error/' does not exist.")

		error_func = function()
			filePath("test"..s.."braz.gdal")
		end

		unitTest:assertError(error_func, "File 'data/test/braz.gdal' does not exist in package 'base'. Do you mean 'brazil.gal'?")

		File(baseInfo.data.."amazonia.lua"):deleteIfExists()
	end,
	filesByExtension = function(unitTest)
		local error_func = function()
			filesByExtension()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			filesByExtension(2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))

		error_func = function()
			filesByExtension("base")
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			filesByExtension("base", 2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))
	end,
	import = function(unitTest)
		local error_func = function()
			import()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			import("asdfgh")
		end

		unitTest:assertError(error_func, "Package 'asdfgh' is not installed.")

		local warning_func = function()
			import("base")
		end

		unitTest:assertWarning(warning_func, "Package 'base' is already loaded.")
	end,
	isLoaded = function(unitTest)
		local error_func = function()
			isLoaded()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))
	end,
	getPackage = function(unitTest)
		local error_func = function()
			getPackage()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			getPackage("asdfgh")
		end

		unitTest:assertError(error_func, "Package 'asdfgh' is not installed.")
	end,
	packageInfo = function(unitTest)
		local error_func = function()
			packageInfo(2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))

		error_func = function()
			packageInfo("asdfgh")
		end

		unitTest:assertError(error_func, "Package 'asdfgh' is not installed.")
	end
}

