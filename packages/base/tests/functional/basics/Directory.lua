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
		local dir = Directory(packageInfo("base").data)
		unitTest:assertType(dir, "Directory")

		dir = Directory{
			name = ".tmp_XXXXX",
			tmp = true
		}

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
		local dir = Directory(packageInfo("base").data)

		unitTest:assertType(dir.."internal", "string")
	end,
	attributes = function(unitTest)
		local dir = Directory(packageInfo("base").data)
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
		local s = sessionInfo().separator
		dir = Directory(datapath..s.."test_dir_create")
		unitTest:assert(dir:create())
		unitTest:assert(dir:exists())

		local attr = dir:attributes("mode")
		unitTest:assertEquals(attr, "directory")

		unitTest:assert(dir:delete())
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

		local dir = Directory(datapath)
		unitTest:assert(dir:exists())

		dir = Directory(datapath)
		unitTest:assert(dir:exists())

		dir = Directory(_Gtme.makePathCompatibleToAllOS(datapath))
		unitTest:assert(dir:exists())

		dir = Directory(datapath..sessionInfo().separator.."test_dir_exists")
		unitTest:assert(not dir:exists())

		dir = Directory(filePath("agents.csv", "base"))
		unitTest:assert(not dir:exists())

		dir = Directory("")
		unitTest:assertEquals(tostring(dir), _Gtme.makePathCompatibleToAllOS(currentDir()))
	end,
	list = function(unitTest)
		local datapath = packageInfo("base").data
		local nfiles = 29

		local d = Directory(datapath):list()
		unitTest:assertEquals(#d, nfiles)

		d = Directory(datapath):list(true)
		unitTest:assertEquals(#d, nfiles + 2)

		local curDir = currentDir()
		Directory(packageInfo().data):setCurrentDir()

		d = Directory("."):list()
		unitTest:assertEquals(#d, nfiles)

		d = Directory("."):list(true)
		unitTest:assertEquals(#d, nfiles + 2)

		Directory(curDir):setCurrentDir()
	end,
	setCurrentDir = function(unitTest)
		local info = sessionInfo()
		local s = info.separator
		local cur_dir = currentDir()
		local newpath = info.path..s.."packages"

		local dir = Directory(newpath)
		dir:setCurrentDir()
		unitTest:assertEquals(currentDir(), newpath)

		dir = Directory(cur_dir)
		dir:setCurrentDir()
		unitTest:assertEquals(currentDir(), cur_dir)
	end,
	__tostring = function(unitTest)
		local datapath = packageInfo("base").data
		local dir = Directory(datapath)

		unitTest:assertType(dir, "Directory")
		unitTest:assertEquals(tostring(dir), _Gtme.makePathCompatibleToAllOS(datapath))
	end
}
