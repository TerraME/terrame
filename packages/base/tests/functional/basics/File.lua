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
	__concat = function(unitTest)
    	local f = File("abcd1234")

		unitTest:assertEquals(f.." does not exist.", "/abcd1234 does not exist.", 0, true)
		unitTest:assertEquals("File does not exist: "..f, "File does not exist: /abcd1234", 0, true)
	end,
	attributes = function(unitTest)
		local file = File(filePath("agents.csv", "base"))
		local attr = file:attributes()

		unitTest:assertEquals(getn(attr), 12, 2)
		unitTest:assertEquals(attr.mode, "file")
		unitTest:assertEquals(attr.size, 140, 5)

		attr = file:attributes("mode")
		unitTest:assertEquals(attr, "file")

		attr = file:attributes("size")
		unitTest:assertEquals(attr, 140, 5)
	end,
	close = function(unitTest)
		local filename = "test.csv"
		local file = File(filename)

		file.file = io.open(file.filename, "a+")
		local close = file:close()

		unitTest:assert(close)
		File(filename):deleteIfExists()
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
	deleteIfExists = function(unitTest)
		local filepath = packageInfo().data.."test123"
		os.execute("touch "..filepath)

		local file = File(filepath)
		file:deleteIfExists()

		unitTest:assert(not file:exists())

		File("as.dfgwe.ogoei"):deleteIfExists()
	end,
	directory = function(unitTest)
		local file = File(filePath("agents.csv", "base"))

		unitTest:assertType(file, "File")
		unitTest:assertEquals(file:directory(), _Gtme.makePathCompatibleToAllOS(packageInfo("base").data).."/")
	end,
	exists = function(unitTest)
		local file = File(filePath("agents.csv", "base"))
		unitTest:assert(file:exists())

		file = File("abc123456.lua")
		unitTest:assert(not file:exists())
	end,
	extension = function(unitTest)
		local file = File(filePath("agents.csv", "base"))
		local extension = file:extension()

		unitTest:assertType(file, "File")
		unitTest:assertEquals(extension, "csv")
	end,
	hasExtension = function(unitTest)
		local file = File(filePath("agents.csv", "base"))
		unitTest:assert(file:hasExtension())

		file = File(packageInfo("base").data.."file")
		os.execute("touch "..tostring(file))
		unitTest:assert(not file:hasExtension())
		file:delete()
	end,
	name = function(unitTest)
		local file = File(filePath("agents.csv", "base"))

		unitTest:assertEquals(file:name(), "agents.csv")

		file = File("myagents")

		unitTest:assertEquals(file:name(), "myagents")
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

		file:delete()
	end,
	read = function(unitTest)
		local file = File(filePath("agents.csv", "base"))
		file:read(",")
		local line = file:read(",")

		unitTest:assertType(line, "table")
		unitTest:assertEquals(line[1], "john")
		unitTest:assertEquals(line[2], "20")
		unitTest:assertEquals(line[3], "200")
		unitTest:assertEquals(file.line, 2)

		line = file:read()
		unitTest:assertType(line, "string")
		unitTest:assertEquals(line, "\"mary\",18,100,3,1,false")
		unitTest:assertEquals(file.line, 3)
		file:close()
	end,
	readTable = function(unitTest)
		local file = File(filePath("agents.csv", "base"))
		local csv = file:readTable()

		unitTest:assertEquals(4, #csv)
		unitTest:assertEquals(20, csv[1].age)
	end,
	split = function(unitTest)
		local file = File(filePath("agents.csv", "base"))
		local path, name, extension = file:split()
		local s = sessionInfo().separator

		unitTest:assertEquals(path, _Gtme.makePathCompatibleToAllOS(packageInfo("base").data).."/")
		unitTest:assertEquals(name, "agents")
		unitTest:assertEquals(extension, "csv")

		file = File("myagents")
		local path, name, extension = file:split()

		unitTest:assertEquals(path, currentDir()..s)
		unitTest:assertEquals(name, "myagents")
		unitTest:assertNil(extension)
	end,
	touch = function(unitTest)
		if _Gtme.sessionInfo().system ~= "windows" then
			local pathdata = packageInfo().data.."testfile.txt"

			local file = File(pathdata)
			file:write("test")
			file:close()

			unitTest:assert(file:touch(10000, 10000)) -- SKIP

			local attr = _Gtme.File(pathdata):attributes("access")
			unitTest:assertEquals(attr, 10000) -- SKIP

			attr = _Gtme.File(pathdata):attributes("modification")
			unitTest:assertEquals(attr, 10000) -- SKIP

			File(pathdata):delete()
		end

		unitTest:assert(true)
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

		local filename = currentDir().."csvwrite.csv"
		local file = File("csvwrite.csv")
		file:write(example)

		file = File(filename)
		local data = file:readTable()

		unitTest:assertNotNil(data)
		unitTest:assertEquals(#example, #data)

		for i = 1, #example do
			for k in pairs(example[i]) do
				unitTest:assertEquals(example[i][k], data[i][k])
			end
		end

		file:deleteIfExists()

		example = "Some text.."
		filename = currentDir().."abc.txt"

		file = File(filename)
		file:write(example)
		file:close()

		file = File(filename):open()
		data = file:read("*all")
		file:close()

		unitTest:assertNotNil(data)
		unitTest:assertEquals(data, example)

		File(filename):deleteIfExists()
	end,
	__tostring = function(unitTest)
		local path = filePath("agents.csv", "base")
		local file = File(path)

		unitTest:assertType(file, "File")
		unitTest:assertEquals(tostring(file), _Gtme.makePathCompatibleToAllOS(path))
	end
}

