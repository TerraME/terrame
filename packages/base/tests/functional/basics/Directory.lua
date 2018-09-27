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
	Directory = function(unitTest)
		local dir = packageInfo("base").data
		unitTest:assertType(dir, "Directory")

		local unnecessaryArgument = function()
			dir = Directory{
				name = ".tmp_XXXXX",
				tmp = true,
				tmpd = true,
			}
		end
		unitTest:assertWarning(unnecessaryArgument, unnecessaryArgumentMsg("tmpd", "tmp"))

		unitTest:assert(dir:exists())

		local tmpDir = Directory{
			name = ".tmp_XXXXX",
			tmp = true
		}

		unitTest:assert(tmpDir:exists())
		unitTest:assert(tostring(tmpDir) ~= tostring(dir))

		dir:delete()
		tmpDir:delete()

		dir = Directory{tmp = true}
		unitTest:assert(dir:exists())

		tmpDir = Directory{tmp = true}
		unitTest:assert(tmpDir:exists())
		unitTest:assert(tostring(tmpDir) ~= tostring(dir))

		dir:delete()
		tmpDir:delete()
	end,
	__concat = function(unitTest)
		local dir = Directory("data")

		unitTest:assertEquals(dir.." internal", " internal", 0, true)
		unitTest:assertEquals("Directory: "..dir, "Directory: data", 0, true)
		unitTest:assertEquals("Directory: "..dir.."home", "Directory: home", 0, true)
	end,
	attributes = function(unitTest)
		local dir = packageInfo("base").data
		local attr = dir:attributes()

		local expected = {
			getn = 12,
			mode = "directory",
		}

		if _Gtme.sessionInfo().system ~= "windows" then
			expected.getn = 14
		end

		unitTest:assertEquals(getn(attr), expected.getn)
		unitTest:assertEquals(attr.mode, expected.mode)

		attr = dir:attributes("mode")
		unitTest:assertEquals(attr, expected.mode)
	end,
	create = function(unitTest)
		local dir = Directory("test_dir_create")
		unitTest:assert(dir:create())
		unitTest:assert(dir:exists())

		unitTest:assert(dir:delete())

		local datapath = packageInfo("base").data
		dir = Directory(datapath.."test_dir_create")
		unitTest:assert(dir:create())
		unitTest:assert(dir:exists())

		local attr = dir:attributes("mode")
		unitTest:assertEquals(attr, "directory")

		unitTest:assert(dir:delete())

		local blankSpaceDir = Directory(currentDir().."/da ta")
		unitTest:assert(blankSpaceDir:create())
		unitTest:assert(blankSpaceDir:exists())
		unitTest:assert(blankSpaceDir:delete())

		local validCharacterInDirName = function()
			local d = Directory("dir++")
			unitTest:assert(d:create())
			unitTest:assert(d:delete())
		end

		unitTest:assert(validCharacterInDirName)

		local latinCharacter = function()
			local d = Directory("Ação")
			unitTest:assert(d:create())
			unitTest:assert(d:delete())
		end

		unitTest:assert(latinCharacter)
	end,
	delete = function(unitTest)
		local dir = Directory("test_dir_delete")
		unitTest:assert(dir:create())
		unitTest:assert(dir:exists())

		local attr = dir:attributes("mode")
		unitTest:assertEquals(attr, "directory")

		unitTest:assert(dir:delete())
		unitTest:assert(not dir:exists())
	end,
	exists = function(unitTest)
		local datapath = packageInfo("base").data

		unitTest:assert(datapath:exists())

		local dir = Directory(datapath..sessionInfo().separator.."test_dir_exists")
		unitTest:assert(not dir:exists())

		dir = Directory(filePath("agents.csv", "base"))
		unitTest:assert(dir:exists())

		dir = Directory("")
		unitTest:assertEquals(dir, currentDir())
	end,
	list = function(unitTest)
		local datapath = packageInfo("base").data
		local nfiles = 33

		local d = datapath:list()
		unitTest:assertEquals(#d, nfiles)

		d = datapath:list(true)
		unitTest:assertEquals(#d, nfiles + 2)

		local curDir = currentDir()
		datapath:setCurrentDir()

		d = Directory("."):list()
		unitTest:assertEquals(#d, nfiles)

		d = Directory("."):list(true)
		unitTest:assertEquals(#d, nfiles + 2)

		curDir:setCurrentDir()

		d = Directory("abc123456")
		d:create()
		local files = d:list()

		unitTest:assertEquals(#files, 0)
		d:delete()
	end,
	name = function(unitTest)
		local dir = Directory("/usr/local/lib")

		unitTest:assertEquals(dir:name(), "lib")

		dir = Directory("/usr/local/lib/")

		unitTest:assertEquals(dir:name(), "lib")

		dir = Directory("c:\\terrame\\bin")

		unitTest:assertEquals(dir:name(), "bin")

		dir = Directory("c:\\terrame\\bin\\")

		unitTest:assertEquals(dir:name(), "bin")
	end,
	path = function(unitTest)
		local dir = Directory("/usr/local/lib")

		unitTest:assertEquals(dir:path(), "/usr/local/")

		dir = Directory("/usr/local/lib/")

		unitTest:assertEquals(dir:path(), "/usr/local/")

		dir = Directory("c:\\terrame\\bin")

		unitTest:assertEquals(dir:path(), "c:/terrame/")

		dir = Directory("c:\\terrame\\bin\\")

		unitTest:assertEquals(dir:path(), "c:/terrame/")
	end,
	relativePath = function(unitTest)
		local d = Directory("/a/b/c/d")
		unitTest:assertEquals(d:relativePath("/a/b"), "c/d")

		local path = packageInfo().path
		unitTest:assertEquals(path:relativePath(path), "")
	end,
	setCurrentDir = function(unitTest)
		local info = sessionInfo()
		local cur_dir = currentDir()
		local newpath = info.path.."packages"

		local dir = Directory(newpath)
		dir:setCurrentDir()
		unitTest:assertEquals(tostring(currentDir()), newpath)

		cur_dir:setCurrentDir()
		unitTest:assertEquals(currentDir(), cur_dir)
	end,
	__tostring = function(unitTest)
		local datapath = packageInfo("base").data

		unitTest:assertType(datapath, "Directory")
		unitTest:assertType(tostring(datapath), "string")
	end
}

