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
	["table.load"] = function(unitTest)
		local error_func = function()
			table.load("dump")
		end
		unitTest:assertError(error_func, "File 'dump' does not have a valid extension.")

		local file = File("dump.lua")

		error_func = function()
			table.load(file:name(true))
		end
		unitTest:assertError(error_func, resourceNotFoundMsg("file", file:name(true)))

		file:writeLine("!!#$@12334")
		error_func = function()
			table.load(tostring(file))
		end
		unitTest:assertError(error_func, "Failed to load file '"..tostring(file).."': "..tostring(file).."unexpected symbol near '!'", 30) -- TODO(#1383)

		file = File("dump.lua")
		file:writeLine("local x = 2")
		error_func = function()
			table.load(tostring(file))
		end
		unitTest:assertError(error_func, "File '"..tostring(file).."' does not contain a Lua table.")

		if file:exists() then file:delete() end
	end,
	["table.save"] = function(unitTest)
		local error_func = function()
			table.save()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			table.save({})
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(2))

		error_func = function()
			table.save("", "dump.lua")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "table", ""))

		error_func = function()
			table.save({}, 1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 1))
	end
}

