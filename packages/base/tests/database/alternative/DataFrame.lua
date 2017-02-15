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
	DataFrame = function(unitTest)
		local error_func = function()
			DataFrame{file = "dump"}
		end
		unitTest:assertError(error_func, "File 'dump' does not have '.lua' extension.")

		local file = File("dump.lua")

		error_func = function()
			DataFrame{file = file:name(true)}
		end
		unitTest:assertError(error_func, resourceNotFoundMsg("file", file:name(true)))

		file:writeLine("!!#$@12334")
		file:close()
		error_func = function()
			DataFrame{file = tostring(file)}
		end
		unitTest:assertError(error_func, "Failed to load file dump.lua:1: unexpected symbol near '!'", 110)

		file = File("dump.lua")
		file:writeLine("local x = 2")
		file:close()
		error_func = function()
			DataFrame{file = file}
		end
		unitTest:assertError(error_func, "File '"..file:name().."' does not contain a Lua table.")

		file:deleteIfExists()
	end,
	save = function(unitTest)
		local df = DataFrame{x = {1}, y = {2}}

		local error_func = function()
			df:save()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			df:save(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
	end
}

