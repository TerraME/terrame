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
	Directory = function(unitTest)
		local error_func = function()
			Directory()
		end

		unitTest:assertError(error_func, tableArgumentMsg())

		error_func = function()
			Directory(1)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))

		error_func = function()
			Directory("abc\"")
		end

		unitTest:assertError(error_func, "Directory path 'abc\"' contains invalid character '\"'.")

		error_func = function()
			Directory{}
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg("name"))

		error_func = function()
			Directory{name = 1}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("name", "string", 1))

		error_func = function()
			Directory(packageInfo("base").path.."data/agents.csv")
		end
		unitTest:assertError(error_func, "'agents.csv' is a file, and not a directory.", 0, true)
	end,
	attributes = function(unitTest)
		local dir = Directory("/my/path/my_dir")
		local error_func = function()
			dir:attributes(1)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
	end,
	delete = function(unitTest)
		local dir = Directory("abc123456")
		local error_func = function()
			dir:delete()
		end

		unitTest:assertError(error_func, resourceNotFoundMsg("directory", tostring(dir)))
	end,
	list = function(unitTest)
		local dir = Directory("abc123456")
		local error_func = function()
			dir:list()
		end

		unitTest:assertError(error_func, resourceNotFoundMsg("directory", tostring(dir)))
	end,
	relativePath = function(unitTest)
		local dir = Directory("/a/b/c/d")

		local error_func = function()
			dir:attributes(1)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
	end
}

