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
		local info = sessionInfo()
		local s = info.separator
		local d = dir(info.path..s.."packages"..s.."base"..s.."data")
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
		local info = sessionInfo()
		local s = info.separator

		local pathdata = info.path..s.."packages"..s.."base"..s.."data"
		local dirtab1 = dir(pathdata)

		local dirtab2 = {}
		for f in lfsdir(pathdata) do
			if f ~= "." and f ~= "." then
				table.insert(dirtab2, f)
				local attr = attributes(pathdata..s..f, "mode")
				unitTest:assert(attr == "file" or attr == "directory")
			end
		end

		unitTest:assert(getn(dirtab1) <= getn(dirtab2))
	end,
	lock = function(unitTest)
		local info = sessionInfo()
		local s = info.separator
		local pathdata = info.path..s.."packages"..s.."base"..s.."data"
		local f = io.open(pathdata..s.."teste.txt", "w+")

		unitTest:assert(lock(f, "w"))

		os.execute("rm "..pathdata..s.."teste.txt")
	end,
	mkdir = function(unitTest)
		local info = sessionInfo()
		local s = info.separator
		local pathdata = info.path..s.."packages"..s.."base"..s.."data"

		unitTest:assert(mkdir(pathdata..s.."teste"))

		local attr = attributes(pathdata..s.."teste", "mode")

		unitTest:assert_equal(attr, "directory")

		rmdir(pathdata..s.."teste")
	end,
	rmdir = function(unitTest)
		local info = sessionInfo()
		local s = info.separator
		local pathdata = info.path..s.."packages"..s.."base"..s.."data"

		unitTest:assert(mkdir(pathdata..s.."teste"))

		local attr = attributes(pathdata..s.."teste", "mode")

		unitTest:assert_equal(attr, "directory")

		unitTest:assert(rmdir(pathdata..s.."teste"))
	end, 
	setmode = function(unitTest)
		local info = sessionInfo()
		local s = info.separator
		local pathdata = info.path..s.."packages"..s.."base"..s.."data"

		local f = io.open(pathdata..s.."testefile.txt", "w+")
		f:write("teste")
		local success, mode = setmode(f, "binary")

		unitTest:assert(success)
		if s == "/" then
			unitTest:assert_equal(mode, "binary")
		else
			unitTest:assert_equal(mode, "text")
		end

		success, mode = setmode(f, "text")

		unitTest:assert(success)
		unitTest:assert_equal(mode, "binary")

		f:close()
		os.execute("rm "..pathdata..s.."testefile.txt")
	end,
	symlinkattributes = function(unitTest)
		local info = sessionInfo()
		local s = info.separator
		local pathdata = info.path..s.."packages"..s.."base"..s.."data"

		os.execute("ln -s "..pathdata..s.."agents.csv "..pathdata..s.."agentslink")
		local attr = symlinkattributes(pathdata..s.."agentslink")

		unitTest:assert_equal(attr.mode, "link")
		unitTest:assert_equal(attr.nlink, 1)
		unitTest:assert_equal(attr.size, 93)

		os.execute("rm "..pathdata..s.."agentslink")
	end,
	lock_dir = function(unitTest)
		local info = sessionInfo()
		local s = info.separator
		local pathdata = info.path..s.."packages"..s.."base"..s.."data"

		mkdir(pathdata..s.."teste")

		local f = lock_dir(pathdata..s.."teste")
		unitTest:assert_not_nil(f)

		rmdir(pathdata..s.."teste")
	end,
	touch = function(unitTest)
		local info = sessionInfo()
		local s = info.separator

		local pathdata = info.path..s.."packages"..s.."base"..s.."data"

		local f = io.open(pathdata..s.."testefile.txt", "w+")
		f:write("teste")
		f:close()

		unitTest:assert(touch(pathdata..s.."testefile.txt", 10000, 10000))
		local attr = attributes(pathdata..s.."testefile.txt")

		unitTest:assert_equal(attr.access, 10000)
		unitTest:assert_equal(attr.modification, 10000)

		os.execute("rm "..pathdata..s.."testefile.txt")
	end, 
	unlock = function(unitTest)
		local info = sessionInfo()
		local s = info.separator

		local pathdata = info.path..s.."packages"..s.."base"..s.."data"

		local f = io.open(pathdata..s.."testefile.txt", "w+")
		f:write("teste")

		unitTest:assert(lock(f, "w"))
		unitTest:assert(unlock(f))

		f:close()
		os.execute("rm "..pathdata..s.."testefile.txt")
	end
}