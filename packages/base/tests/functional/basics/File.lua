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

		file = File("ação.txt")
		if sessionInfo().system == "windows" then
			unitTest:assert(tostring(file) ~= currentDir().."ação.txt") -- SKIP
		end
		local f2 = File("ação.txt")
		unitTest:assertEquals(tostring(file), tostring(f2))
	end,
	__concat = function(unitTest)
		local f = File("abcd1234")

		unitTest:assertEquals(f.." does not exist.", "abcd1234 does not exist.", 0, true)
		unitTest:assertEquals("File does not exist: "..f, "File does not exist: abcd1234", 0, true)
	end,
	attributes = function(unitTest)
		local file = filePath("agents.csv", "base")
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

		local warning_func = function()
			file:close()
		end
		unitTest:assertWarning(warning_func, "File is not opened.")

		file.file = io.open(file.filename, "a+")
		local close = file:close()

		unitTest:assert(close)
		local result = File(filename):deleteIfExists()

		unitTest:assertType(result, "File")
	end,
	copy = function(unitTest)
		local dir = Directory("abcd123efg")
		dir:create()

		local file = filePath("river.dbf")
		file:copy(dir)

		local file2 = File(dir.."river.dbf")
		unitTest:assert(file2:exists())
		file2:delete()

		file:copy("abcd123efg")

		unitTest:assert(file2:exists())
		file2:delete()

		local fileShp = filePath("amazonia.shp")
		fileShp:copy(dir)
		unitTest:assert(File(dir.."amazonia.shp"):exists())
		unitTest:assert(File(dir.."amazonia.shx"):exists())
		unitTest:assert(File(dir.."amazonia.dbf"):exists())
		unitTest:assert(File(dir.."amazonia.qix"):exists())
		unitTest:assert(File(dir.."amazonia.prj"):exists())

		fileShp:copy(File(dir.."myshp.shp"))
		unitTest:assert(File(dir.."myshp.shp"):exists())
		unitTest:assert(File(dir.."myshp.shx"):exists())
		unitTest:assert(File(dir.."myshp.dbf"):exists())
		unitTest:assert(File(dir.."myshp.qix"):exists())
		unitTest:assert(File(dir.."myshp.prj"):exists())

		dir:delete()
	end,
	delete = function(unitTest)
		local filepath = packageInfo().data.."test123"
		os.execute("touch \""..filepath.."\"")

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
		os.execute("touch \""..filepath.."\"")

		local file = File(filepath)
		file:deleteIfExists()

		unitTest:assert(not file:exists())

		File("as.dfgwe.ogoei"):deleteIfExists()
	end,
	path = function(unitTest)
		local file = filePath("agents.csv", "base")

		unitTest:assertType(file, "File")
		unitTest:assertEquals(file:path(), packageInfo("base").data.."/")
	end,
	exists = function(unitTest)
		local file = filePath("agents.csv", "base")
		unitTest:assert(file:exists())

		file = File("abc123456.lua")
		unitTest:assert(not file:exists())
	end,
	extension = function(unitTest)
		local file = filePath("agents.csv", "base")
		local extension = file:extension()

		unitTest:assertType(file, "File")
		unitTest:assertEquals(extension, "csv")
	end,
	hasExtension = function(unitTest)
		local file = filePath("agents.csv", "base")
		unitTest:assert(file:hasExtension())

		file = File(packageInfo("base").data.."file")
		os.execute("touch \""..tostring(file).."\"")
		unitTest:assert(not file:hasExtension())
		file:delete()
	end,
	name = function(unitTest)
		local file = filePath("agents.csv", "base")

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
	readLine = function(unitTest)
		local file = filePath("agents.csv", "base")
		file:readLine(",")
		local line = file:readLine(",")

		unitTest:assertType(line, "table")
		unitTest:assertEquals(line[1], "john")
		unitTest:assertEquals(line[2], "20")
		unitTest:assertEquals(line[3], "200")
		unitTest:assertEquals(file.line, 2)

		line = file:readLine()
		unitTest:assertType(line, "string")
		unitTest:assertEquals(line, "\"mary\",18,100,3,1,false")
		unitTest:assertEquals(file.line, 3)
		file:close()
	end,
	read = function(unitTest)
		local file = filePath("agents.csv", "base")
		local csv = file:read()

		unitTest:assertType(csv, "DataFrame")
		unitTest:assertEquals(4, #csv)
		unitTest:assertEquals(20, csv[1].age)

		local s = sessionInfo().separator
		file = filePath("test/error"..s.."csv-error.csv")

		local warning_func = function()
			csv = file:read()
		end
		unitTest:assertWarning(warning_func, "Line 3 ('\"mary\",18,100,3,1') should contain 6 attributes but has 5.")
		unitTest:assertType(csv, "DataFrame")
		unitTest:assertEquals(3, #csv)
		unitTest:assertEquals(20, csv[1].age)
	end,
	split = function(unitTest)
		local file = filePath("agents.csv", "base")
		local path, name, extension = file:split()

		unitTest:assertEquals(path, packageInfo("base").data.."/")
		unitTest:assertEquals(name, "agents")
		unitTest:assertEquals(extension, "csv")

		file = File("myagents")
		path, name, extension = file:split()

		unitTest:assertEquals(path, currentDir().."/")
		unitTest:assertEquals(name, "myagents")
		unitTest:assertNil(extension)
	end,
	touch = function(unitTest)
		if _Gtme.sessionInfo().system ~= "windows" then
			local pathdata = packageInfo().data.."testfile.txt"

			local file = File(pathdata)
			file:writeLine("test")
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
		local example = DataFrame{
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
		local file = File(filename)
		file:write(example)

		file = File(filename)
		local data = file:read()

		unitTest:assertType(data, "DataFrame")
		unitTest:assertEquals(#example, #data)

		for i = 1, #example do
			forEachElement(example:columns(), function(column)
				unitTest:assertEquals(example[column][i], data[column][i])
			end)
		end

		unitTest:assertFile("csvwrite.csv")
	end,
	writeLine = function(unitTest)
		local example = "Some text.."
		local filename = "write-line-1.txt"

		local file = File(filename)
		file:writeLine(example)
		file:writeLine(example)
		file:close()

		unitTest:assertFile(file)

		example = {"a", "b", "c"}
		filename = "write-line-2.txt"

		file = File(filename)
		file:writeLine(example)
		file:writeLine(example)
		file:close()

		unitTest:assertFile(file)

		example = {"a", "b", "c"}
		filename = "write-line-3.txt"

		file = File(filename)
		file:writeLine(example, "-")
		file:writeLine(example, "-")
		file:close()

		unitTest:assertFile(file)
	end,
	__tostring = function(unitTest)
		local file = filePath("agents.csv", "base")

		unitTest:assertType(file, "File")
		unitTest:assertEquals(tostring(file), "agents.csv", 0, true)
	end
}

