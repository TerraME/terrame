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
	attributes = function(unitTest)
		local file = File(filePath("agents.csv", "base"))
		local attr = file:attributes()

		local expected = {
			getn = 12,
			mode = "file",
			size = 140.0
		}

		if not _Gtme.sessionInfo().system == "windows" then
			expected.getn = 14
			expected.size = 135
		end

		unitTest:assertEquals(getn(attr), expected.getn)
		unitTest:assertEquals(attr.mode, expected.mode)
		unitTest:assertEquals(attr.size, expected.size)

		attr = file:attributes("mode")
		unitTest:assertEquals(attr, expected.mode)

		attr = file:attributes("size")
		unitTest:assertEquals(attr, expected.size)
	end,
	close = function(unitTest)
		local filename = "test.csv"
		local file = File(filename)

		file.file = io.open(file.filename, "a+")
		local close = file:close()

		unitTest:assert(close)
		if File(filename):exists() then File(filename):delete() end
	end,
	delete = function(unitTest)
		local filepath = packageInfo().data.."test123"
		os.execute("touch "..filepath)

		local file = File(filepath)
		file:delete()

		unitTest:assert(not file:exists())

		os.execute("touch abc123.shp")
		os.execute("touch abc123.shx")
		os.execute("touch abc123.dbf")
		os.execute("touch abc123.prj")

		File("abc123.shp"):delete()

		unitTest:assert(not File("abc123.shp"):exists())
		unitTest:assert(not File("abc123.shx"):exists())
		unitTest:assert(not File("abc123.dbf"):exists())
		unitTest:assert(not File("abc123.prj"):exists())

		os.execute("touch abc123.shp")

		File("abc123.shp"):delete()
	end,
	directory = function(unitTest)
		local file = File("/my/path/file.txt")

		unitTest:assertType(file, "File")
		unitTest:assertEquals(file:directory(), "/my/path/")
	end,
	exists = function(unitTest)
		local file = File(filePath("agents.csv", "base"))
		unitTest:assert(file:exists())

		file = File("abc.lua")
		unitTest:assert(not file:exists())
	end,
	extension = function(unitTest)
		local file = File("/my/path/file.txt")
		local extension = file:extension()

		unitTest:assertType(file, "File")
		unitTest:assertEquals(extension, "txt")
	end,
	hasExtension = function(unitTest)
		local file = File("/my/path/file.txt")
		local extension = file:hasExtension()
		unitTest:assert(extension)

		file = File("/my/path/file")
		extension = file:hasExtension()
		unitTest:assert(not extension)
	end,
	lock = function(unitTest)
		local filepath = packageInfo().data.."test.txt"
		local file = File(filepath)

		file:open("w+")

		unitTest:assert(file:lock("w"))

		file:close()
		File(filepath):delete()
	end,
	name = function(unitTest)
		local file = File("/my/path/file.txt")

		unitTest:assertType(file, "File")
		unitTest:assertEquals(file:name(), "file")
		unitTest:assertEquals(file:name(true), "file.txt")
	end,
	open = function(unitTest)
		local file = File("test.csv")
		local fopen = file:open("a+")
		local sfile = fopen:read("*all")

		unitTest:assertEquals(sfile, "")
		file:close()

		file = File("test.csv")
		fopen = file:open()
		sfile = fopen:read()
		unitTest:assertNil(sfile)
		file:close()

		File("test.csv"):delete()
	end,
	read = function(unitTest)
		local file = File(filePath("agents.csv", "base"))
		local csv = file:read()

		unitTest:assertEquals(4, #csv)
		unitTest:assertEquals(20, csv[1].age)
	end,
	readLine = function(unitTest)
		local file = File(filePath("agents.csv", "base"))
		file:readLine()
		local line = file:readLine()

		unitTest:assertEquals(line[1], "john")
		unitTest:assertEquals(line[2], "20")
		unitTest:assertEquals(line[3], "200")
	end,
	split = function(unitTest)
		local file = File("/my/path/file.txt")
		local path, name, extension, nameWithExtension = file:split()

		unitTest:assertType(file, "File")
		unitTest:assertEquals(path, "/my/path/")
		unitTest:assertEquals(name, "file")
		unitTest:assertEquals(extension, "txt")
		unitTest:assertEquals(nameWithExtension, "file.txt")
	end,
	touch = function(unitTest)
		if not _Gtme.sessionInfo().system == "windows" then
			local pathdata = packageInfo().data.."testfile.txt"

			local file = File(pathdata)
			file:writeLine("test")

			unitTest:assert(file:touch(10000, 10000)) -- SKIP

			local attr = _Gtme.File(pathdata):attributes("access")
			unitTest:assertEquals(attr, 10000) -- SKIP

			attr = _Gtme.File(pathdata):attributes("modification")
			unitTest:assertEquals(attr, 10000) -- SKIP

			File(pathdata):delete()
		end

		unitTest:assert(true)
	end,
	unlock = function(unitTest)
		local filepath = packageInfo().data.."test.txt"
		local file = File(filepath)

		file:open("w+")

		unitTest:assert(file:lock("w"))
		unitTest:assert(file:unlock())

		file:close()
		File(filepath):delete()
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

		if File(filename):exists() then File(filename):delete() end
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

		if File(filename):exists() then File(filename):delete() end
	end,
	__tostring = function(unitTest)
		local path = filePath("agents.csv", "base")
		local  file = File(path)

		unitTest:assertType(file, "File")
		unitTest:assertEquals(tostring(file), _Gtme.makePathCompatibleToAllOS(path))
	end
}

