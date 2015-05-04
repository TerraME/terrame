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
	attributes = function(unitTest)
		local attr = attributes(file("agents.csv", "base"))
		unitTest:assertEquals(getn(attr), 14)
		unitTest:assertEquals(attr.mode, "file")
		unitTest:assertEquals(attr.size, 135)

		attr = attributes(file("agents.csv", "base"), "mode")
		unitTest:assertEquals(attr, "file")

		attr = attributes(file("agents.csv", "base"), "size")
		unitTest:assertEquals(attr, 135)
	end, 
	chDir = function(unitTest)
		local info = sessionInfo()
		local s = info.separator
		local cur_dir = currentDir()
		chDir(info.path..s.."packages")
		unitTest:assertEquals(currentDir(), info.path..s.."packages")
		chDir(cur_dir)
	end, 
	currentDir = function(unitTest)
		local info = sessionInfo()
		local cur_dir = currentDir()
		chDir(info.path)
		unitTest:assertEquals(currentDir(), info.path)
		chDir(cur_dir)
	end,
	dir = function(unitTest)
		local files = 22
		local d = dir(packageInfo().data)
		unitTest:assertEquals(#d, files)

		d = dir(packageInfo().data, true)
		unitTest:assertEquals(#d, files + 2)

		d = dir(".", true)
	end,
	isFile = function(unitTest)
		unitTest:assert(isFile(file("agents.csv")))
	end, 
	linkAttributes = function(unitTest)
		local pathdata = packageInfo().data

		os.execute("ln -s "..pathdata.."agents.csv "..pathdata.."agentslink")
		local attr = linkAttributes(pathdata.."agentslink")

		unitTest:assertEquals(attr.mode, "link")
		unitTest:assertEquals(attr.nlink, 1)
		--unitTest:assert(attr.size >= 61)

		attr = linkAttributes(pathdata.."agentslink", "mode")
		unitTest:assertEquals(attr, "link")

		attr = linkAttributes(pathdata.."agentslink", "nlink")
		unitTest:assertEquals(attr, 1)

		os.execute("rm "..pathdata.."agentslink")
	end,
	lock = function(unitTest)
		local pathdata = packageInfo().data

		local f = io.open(pathdata.."test.txt", "w+")

		unitTest:assert(lock(f, "w"))

		os.execute("rm "..pathdata.."test.txt")
	end,
	lockDir = function(unitTest)
		local pathdata = packageInfo().data

		mkDir(pathdata.."test")

		local f = lockDir(pathdata.."test")
		unitTest:assertNotNil(f)

		rmDir(pathdata.."test")
	end,
	mkDir = function(unitTest)
		local pathdata = packageInfo().data

		unitTest:assert(mkDir(pathdata.."test"))

		local attr = attributes(pathdata.."test", "mode")
		unitTest:assertEquals(attr, "directory")

		rmDir(pathdata.."test")
	end,
	rmDir = function(unitTest)
		local pathdata = packageInfo().data

		unitTest:assert(mkDir(pathdata.."test"))

		local attr = attributes(pathdata.."test", "mode")
		unitTest:assertEquals(attr, "directory")

		unitTest:assert(rmDir(pathdata.."test"))
	end, 
	runCommand = function(unitTest)
		local d = runCommand("ls "..packageInfo().data)
		unitTest:assertEquals(#d, 22) -- 22 files
	end,
	setMode = function(unitTest)
		local pathdata = packageInfo().data

		local f = io.open(pathdata.."testfile.txt", "w+")
		f:write("test")
		local success, mode = setMode(f, "binary")

		unitTest:assert(success)
	
		unitTest:assertEquals(mode, "binary")

		success, mode = setMode(f, "text")

		unitTest:assert(success)
		unitTest:assertEquals(mode, "binary") -- #199

		f:close()
		os.execute("rm "..pathdata.."testfile.txt")
	end,
	touch = function(unitTest)
		local pathdata = packageInfo().data

		local f = io.open(pathdata.."testfile.txt", "w+")
		f:write("test")
		f:close()

		unitTest:assert(touch(pathdata.."testfile.txt", 10000, 10000))

		local attr = attributes(pathdata.."testfile.txt", "access")
		unitTest:assertEquals(attr, 10000)

		attr = attributes(pathdata.."testfile.txt", "modification")
		unitTest:assertEquals(attr, 10000)

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

