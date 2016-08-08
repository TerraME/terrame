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
	File = function(unitTest)
		local error_func = function()
			File()
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		error_func = function()
			File{}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", {}))

		error_func = function()
			File(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
	end,
	close = function(unitTest)
		local file = File("abc.txt")
		local error_func = function()
			file:close()
		end

		unitTest:assertError(error_func, "File is not opened.")

		file = File("123")
		file.file = true

		error_func = function()
			file:close()
		end

		unitTest:assertError(error_func, resourceNotFoundMsg("file", file.name))
	end,
	read = function(unitTest)
		local filename = "abc.txt"
		local file = File(filename)
		file:writeLine("text...")

		local error_func = function()
			file:read()
		end

		unitTest:assertError(error_func, "Cannot read a file opened for writing.")
		if isFile(filename) then rmFile(filename) end

		file = File(filename)

		error_func = function()
			file:read()
		end

		unitTest:assertError(error_func, resourceNotFoundMsg("file", file.name))

		local s = sessionInfo().separator
		file = File(filePath("error"..s.."csv-error.csv"))

		error_func = function()
			file:read()
		end
		unitTest:assertError(error_func, "Line 2 ('\"mary\",18,100,3,1') should contain 6 attributes but has 5.")
	end,
	readLine = function(unitTest)
		local s = sessionInfo().separator
		local filename = currentDir()..s.."csvwrite.csv"
		local csv = {
			{name = "\"ab\"c"}
		}

		local file = File(filename)
		file:write(csv)

		local error_func = function()
			file:readLine()
		end
		unitTest:assertError(error_func, "Cannot read a file opened for writing.")

		error_func = function()
			file = File(filename)
			file:read()
		end
		unitTest:assertError(error_func, "Line 1 ('\"\"ab\"c\"') is invalid.")

		file:close()
		if isFile(filename) then rmFile(filename) end

		file = File(filePath("agents.csv", "base"))
		error_func = function()
			file:readLine(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	write = function(unitTest)
		local file = File(filePath("agents.csv", "base"))

		local error_func = function()
			file:write()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		local example = {
			{age = 1, wealth = 10, vision = 2, metabolism = 1, test = "Foo text"},
			{age = 3, wealth =  8, vision = 1, metabolism = 1, test = "Foo;text"},
			{age = 3, wealth = 13, vision = 1, metabolism = 1, test = "Foo.text"},
			w3c = {age = 1, wealth = 10, vision = 3, metabolism = 2, test = "Foo(text"}
		}

		error_func = function()
			file:write(example, 2)
		end

		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 2))

		file = File(filePath("agents.csv", "base"))
		file:read()

		error_func = function()
			file:write(example)
		end

		unitTest:assertError(error_func, "Cannot write a file opened for reading.")

		local s = sessionInfo().separator
		local filename = tmpDir()..s.."csvwrite.csv"
		file = File(filename)

		error_func = function()
			file:write(example)
		end
		unitTest:assertError(error_func, "#1 should be a vector.")

		example = {
			[2] = {age = 1, wealth = 10, vision = 2, metabolism = 1, test = "Foo text"},
			[3] = {age = 3, wealth =  8, vision = 1, metabolism = 1, test = "Foo;text"},
			[4] = {age = 3, wealth = 13, vision = 1, metabolism = 1, test = "Foo.text"},
			[5] = {age = 1, wealth = 10, vision = 3, metabolism = 2, test = "Foo(text"}
		}

		error_func = function()
			file:write(example)
		end
		unitTest:assertError(error_func, "#1 does not have position 1.")

		example = {
			{[1] = 1, wealth = 10, vision = 2, metabolism = 1, test = "Foo text"},
			{age = 3, wealth =  8, vision = 1, metabolism = 1, test = "Foo;text"},
			{age = 3, wealth = 13, vision = 1, metabolism = 1, test = "Foo.text"},
			{age = 1, wealth = 10, vision = 3, metabolism = 2, test = "Foo(text"}
		}

		error_func = function()
			file:write(example)
		end
		unitTest:assertError(error_func, "All attributes should be string, got number.")

	end,
	writeLine = function(unitTest)
		local file = File(filePath("agents.csv", "base"))
		file:read()

		local error_func = function()
			file:writeLine("Text")
		end

		unitTest:assertError(error_func, "Cannot write a file opened for reading.")
	end
}
