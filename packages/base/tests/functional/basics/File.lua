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
-------------------------------------------------------------------------------------------

return{
	File = function(unitTest)
		local file = File("abc.txt")
		unitTest:assertType(file, "File")
	end,
	close = function(unitTest)
		local filename = "test.csv"
		local file = File(filename)

		file.file = io.open(file.name, "a+")
		local close = file:close()

		unitTest:assert(close)
		if isFile(filename) then rmFile(filename) end
	end,
	exists = function(unitTest)
		local file = File(filePath("agents.csv", "base"))
		unitTest:assert(file:exists())

		file = File("abc.lua")
		unitTest:assert(not file:exists())
	end,
	getDir = function(unitTest)
		local file = File("/my/path/file.txt")

		unitTest:assertType(file, "File")
		unitTest:assertEquals(file:getDir(), "/my/path/")
	end,
	getExtension = function(unitTest)
		local file = File("/my/path/file.txt")
		local extension = file:getExtension()

		unitTest:assertType(file, "File")
		unitTest:assertEquals(extension, "txt")
	end,
	getName = function(unitTest)
		local file = File("/my/path/file.txt")

		unitTest:assertType(file, "File")
		unitTest:assertEquals(file:getName(), "file")
	end,
	getNameWithExtension = function (unitTest)
		local file = File("/my/path/file.txt")

		unitTest:assertType(file, "File")
		unitTest:assertEquals(file:getNameWithExtension(), "file.txt")
	end,
	getPath = function(unitTest)
		local file = File("/my/path/file.txt")
		unitTest:assertType(file, "File")
		unitTest:assertNil(file:getPath())

		file = File(filePath("agents.csv", "base"))
		unitTest:assertType(file, "File")
		unitTest:assertEquals(file:getPath(), "C:\\TerraME\\bin\\packages\\base\\data\\agents.csv")
	end,
	read = function(unitTest)
		local file = File(filePath("agents.csv", "base"))
		local csv = file:read()

		unitTest:assertEquals(4, #csv)
		unitTest:assertEquals(20, csv[1].age)
	end,
	readLine = function(unitTest)
		local file = File("/my/path/file.txt")
		local line = file:readLine("2,5,aa", ",")

		unitTest:assertEquals(line[1], "2")
		unitTest:assertEquals(line[2], "5")
		unitTest:assertEquals(line[3], "aa")
	end,
	removeExtension = function(unitTest)
		local file = File("/my/path/file.txt")
		local nameWithExtension = file:getNameWithExtension()

		unitTest:assertType(file, "File")
		unitTest:assertEquals(nameWithExtension, "file.txt")
		unitTest:assertEquals(file:removeExtension(nameWithExtension), "file")
		unitTest:assertEquals(file:removeExtension(), "file")
	end,
	splitNames = function(unitTest)
		local file = File("/my/path/file.txt")
		local path, name, extension = file:splitNames()

		unitTest:assertType(file, "File")
		unitTest:assertEquals(path, "/my/path/")
		unitTest:assertEquals(name, "file")
		unitTest:assertEquals(extension, "txt")
	end,
	write = function(unitTest)
		local example = {
			{age = 1, wealth = 10, vision = 2, metabolism = 1, test = "Foo text"},
			{age = 3, wealth =  8, vision = 1, metabolism = 1, test = "Foo;text"},
			{age = 3, wealth = 15, vision = 2, metabolism = 1, test = "Foo,text"},
			{age = 4, wealth = 12, vision = 2, metabolism = 2, test = "Foo@text"},
			{age = 2, wealth = 10, vision = 3, metabolism = 1, test = "Foo%text"},
			{age = 2, wealth =  9, vision = 2, metabolism = 1, test = "Foo)text"},
			{age = 1, wealth = 11, vision = 2, metabolism = 1, test = "Foo#text"},
			{age = 3, wealth = 15, vision = 1, metabolism = 2, test = "Foo=text"},
			{age = 3, wealth = 13, vision = 1, metabolism = 1, test = "Foo.text"},
			{age = 1, wealth = 10, vision = 3, metabolism = 2, test = "Foo(text"}
		}

		local s = sessionInfo().separator
		local filename = currentDir()..s.."csvwrite.csv"

		local file = File(filename)
		file:write(example)

		file = File(filename)
		local data = file:read()

		unitTest:assertNotNil(data)
		unitTest:assertEquals(#example, #data)

		for i = 1, #example do
			for k in pairs(example[i]) do
				unitTest:assertEquals(example[i][k], data[i][k])
			end
		end

		if isFile(filename) then rmFile(filename) end
	end,
	writeLine = function(unitTest)
		local example = "Some text.."

		local s = sessionInfo().separator
		local filename = currentDir()..s.."abc.txt"

		local file = File(filename)
		file:writeLine(example)

		file = io.open(filename, "r")
		local text = file:read("*all")
		file:close()

		unitTest:assertNotNil(text)
		unitTest:assertEquals(text, example)

		if isFile(filename) then rmFile(filename) end
	end,
	__tostring = function(unitTest)
		local file = File("abc.txt")
		unitTest:assertEquals(tostring(file), [[name  string [abc.txt]
]])
	end
}

