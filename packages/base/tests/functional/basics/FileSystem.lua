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
		if not _Gtme.isWindowsOS() then
			local attr = attributes(filePath("agents.csv", "base"))
			-- local t = filePath("agents.csv", "base")
			unitTest:assertEquals(getn(attr), 14) -- SKIP
			unitTest:assertEquals(attr.mode, "file") -- SKIP
			unitTest:assertEquals(attr.size, 135) -- SKIP

			attr = attributes(filePath("agents.csv", "base"), "mode")
			unitTest:assertEquals(attr, "file") -- SKIP

			attr = attributes(filePath("agents.csv", "base"), "size")
			unitTest:assertEquals(attr, 135) -- SKIP
		else
			unitTest:assert(true) -- SKIP
		end
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
		local files = 37
		local d = dir(packageInfo().data)

		unitTest:assertEquals(#d, files)

		d = dir(packageInfo().data, true)
		unitTest:assertEquals(#d, files + 2)

		dir(".", true)
	end,
	isDir = function(unitTest)
		unitTest:assert(isDir(sessionInfo().path))
		
		local path = _Gtme.makePathCompatibleToAllOS(sessionInfo().path)
		path = path.."/"
		unitTest:assert(isDir(path))
		
        unitTest:assertEquals(isDir(""), false);
        
        unitTest:assert(not isDir(filePath("agents.csv")))	
	end,
	isFile = function(unitTest)
		unitTest:assert(isFile(filePath("agents.csv")))
        
        unitTest:assertEquals(isFile(""), false)

		os.execute("touch zasdc.abc")

		unitTest:assert(not isFile("zasdc.ab*"))
		unitTest:assert(not isFile("zasdc.???"))

		rmFile("zasdc.abc")
	end, 
	isWindowsOS = function(unitTest)
		unitTest:assert(true)
	end,
	linkAttributes = function(unitTest)
		if not _Gtme.isWindowsOS() then
			local pathdata = packageInfo().data

			os.execute("ln -s "..pathdata.."agents.csv "..pathdata.."agentslink")
			local attr = linkAttributes(pathdata.."agentslink")

			unitTest:assertEquals(attr.mode, "link") -- SKIP
			unitTest:assertEquals(attr.nlink, 1) -- SKIP
			--unitTest:assert(attr.size >= 61) -- SKIP

			attr = linkAttributes(pathdata.."agentslink", "mode")
			unitTest:assertEquals(attr, "link") -- SKIP

			attr = linkAttributes(pathdata.."agentslink", "nlink")
			unitTest:assertEquals(attr, 1) -- SKIP

			os.execute("rm \""..pathdata.."agentslink\"")
		else
			unitTest:assert(true) -- SKIP
		end
	end,
	lock = function(unitTest)
		local pathdata = packageInfo().data

		local f = io.open(pathdata.."test.txt", "w+")

		unitTest:assert(lock(f, "w"))
		
		f:close()
		os.execute("rm \""..pathdata.."test.txt\"")
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

		rmDir(pathdata.."test")

		unitTest:assert(not isDir(pathdata.."test"))
	end,
	rmFile = function(unitTest)
		local file = packageInfo().data.."test123"
		os.execute("touch "..file)

		rmFile(file)

		unitTest:assert(not isFile(file))
		
		os.execute("touch abc123.shp")
		os.execute("touch abc123.shx")
		os.execute("touch abc123.dbf")
		os.execute("touch abc123.prj")

		rmFile("abc123.shp")

		unitTest:assert(not isFile("abc123.shp"))
		unitTest:assert(not isFile("abc123.shx"))
		unitTest:assert(not isFile("abc123.dbf"))
		unitTest:assert(not isFile("abc123.prj"))

		os.execute("touch abc123.shp")

		rmFile("abc123.shp")
	end, 
	runCommand = function(unitTest)
		local d, e = runCommand("ls "..packageInfo().data)
		unitTest:assertEquals(#d, 37) -- 37 files
		unitTest:assertEquals(#e, 0)
	end,
	tmpDir = function(unitTest)
		local f = tmpDir()
		local g = tmpDir()

		unitTest:assertEquals(f, g)
		unitTest:assertType(f, "string")
		unitTest:assert(isDir(f))

		rmDir(g)
		g = tmpDir()

		unitTest:assertEquals(f, g)
		unitTest:assertType(f, "string")
		unitTest:assert(isDir(f))

		g = tmpDir("abc123XXXXX")

		unitTest:assert(isDir(g))
		unitTest:assertEquals(string.len(g), 11)
		unitTest:assertType(g, "string")

		rmDir(g)
	end,
	touch = function(unitTest)
		if not _Gtme.isWindowsOS() then
			local pathdata = packageInfo().data

			local f = io.open(pathdata.."testfile.txt", "w+")
			f:write("test")
			f:close()

			unitTest:assert(touch(pathdata.."testfile.txt", 10000, 10000)) -- SKIP

			local attr = attributes(pathdata.."testfile.txt", "access")
			unitTest:assertEquals(attr, 10000) -- SKIP

			attr = attributes(pathdata.."testfile.txt", "modification")
			unitTest:assertEquals(attr, 10000) -- SKIP

			os.execute("rm \""..pathdata.."testfile.txt\"")
		end
		
		unitTest:assert(true)
		
	end, 
	unlock = function(unitTest)
		local pathdata = packageInfo().data

		local f = io.open(pathdata.."testfile.txt", "w+")
		f:write("test")

		unitTest:assert(lock(f, "w"))
		unitTest:assert(unlock(f))

		f:close()
		os.execute("rm \""..pathdata.."testfile.txt\"")
	end
}

