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
-- Authors: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--          Pedro R. Andrade (pedro.andrade@inpe.br)
-------------------------------------------------------------------------------------------

return{
	dir = function(unitTest)
		local d = dir(packageInfo().data)
		unitTest:assert_equal(#d, 21) -- 21 files
	end,
	isfile = function(unitTest)
		unitTest:assert(isfile(file("agents.csv")))
	end, 
	attributes = function(unitTest)
		local attr = attributes(file("agents.csv", "base"))
		unitTest:assert_equal(getn(attr), 14)
		unitTest:assert_equal(attr.mode, "file")
		unitTest:assert_equal(attr.size, 135)
	end, 
	chdir = function(unitTest)
		local info = sessionInfo()
		local s = info.separator
		local cur_dir = currentdir()
		chdir(info.path..s.."packages")
		unitTest:assert_equal(currentdir(), info.path..s.."packages")
		chdir(cur_dir)
	end, 
	currentdir = function(unitTest)
		local info = sessionInfo()
		local cur_dir = currentdir()
		chdir(info.path)
		unitTest:assert_equal(currentdir(), info.path)
		chdir(cur_dir)
	end,
	lfsdir = function(unitTest)
		local pathdata = packageInfo().data

		local dirtab1 = dir(pathdata)

		local dirtab2 = {}
		for f in lfsdir(pathdata) do
			if f ~= "." and f ~= "." then
				table.insert(dirtab2, f)
				local attr = attributes(pathdata..f, "mode")
				unitTest:assert(attr == "file" or attr == "directory")
			end
		end

		unitTest:assert(getn(dirtab1) <= getn(dirtab2))
	end,
	lock = function(unitTest)
		local pathdata = packageInfo().data

		local f = io.open(pathdata.."test.txt", "w+")

		unitTest:assert(lock(f, "w"))

		os.execute("rm "..pathdata.."test.txt")
	end,
	mkdir = function(unitTest)
		local pathdata = packageInfo().data

		unitTest:assert(mkdir(pathdata.."test"))

		local attr = attributes(pathdata.."test", "mode")

		unitTest:assert_equal(attr, "directory")

		rmdir(pathdata.."test")
	end,
	rmdir = function(unitTest)
		local pathdata = packageInfo().data

		unitTest:assert(mkdir(pathdata.."test"))

		local attr = attributes(pathdata.."test", "mode")

		unitTest:assert_equal(attr, "directory")

		unitTest:assert(rmdir(pathdata.."test"))
	end, 
	setmode = function(unitTest)
		local pathdata = packageInfo().data

		local f = io.open(pathdata.."testfile.txt", "w+")
		f:write("test")
		local success, mode = setmode(f, "binary")

		unitTest:assert(success)
	
		unitTest:assert_equal(mode, "binary")

		success, mode = setmode(f, "text")

		unitTest:assert(success)
		unitTest:assert_equal(mode, "binary") -- #199

		f:close()
		os.execute("rm "..pathdata.."testfile.txt")
	end,
	symlinkattributes = function(unitTest)
		local pathdata = packageInfo().data

		os.execute("ln -s "..pathdata.."agents.csv "..pathdata.."agentslink")
		local attr = symlinkattributes(pathdata.."agentslink")

		unitTest:assert_equal(attr.mode, "link")
		unitTest:assert_equal(attr.nlink, 1)
		unitTest:assert(attr.size >= 61)

		os.execute("rm "..pathdata.."agentslink")
	end,
	lock_dir = function(unitTest)
		local pathdata = packageInfo().data

		mkdir(pathdata.."test")

		local f = lock_dir(pathdata.."test")
		unitTest:assert_not_nil(f)

		rmdir(pathdata.."test")
	end,
	touch = function(unitTest)
		local pathdata = packageInfo().data

		local f = io.open(pathdata.."testfile.txt", "w+")
		f:write("test")
		f:close()

		unitTest:assert(touch(pathdata.."testfile.txt", 10000, 10000))
		local attr = attributes(pathdata.."testfile.txt")

		unitTest:assert_equal(attr.access, 10000)
		unitTest:assert_equal(attr.modification, 10000)

		os.execute("rm "..pathdata.."testfile.txt")
	end, 
	unlock = function(unitTest)
		local pathdata = packageInfo().data

		local f = io.open(pathdata.."testfile.txt", "w+")
		f:write("test")

		unitTest:assert(lock(f, "w"))
		unitTest:assert(unlock(f))

		f:close()
		os.execute("rm "..pathdata.."testfile.txt")
	end
}

