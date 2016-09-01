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
		local files = 43

		local d = dir(packageInfo().data)
		unitTest:assertEquals(#d, files)

		d = dir(packageInfo().data, true)
		unitTest:assertEquals(#d, files + 2)

		local curDir = currentDir()
		chDir(packageInfo().data)

		d = dir(".")
		unitTest:assertEquals(#d, files)

		d = dir(".", true)
		unitTest:assertEquals(#d, files + 2)

		d = dir()
		unitTest:assertEquals(#d, files)

		d = dir(nil, true)
		unitTest:assertEquals(#d, files + 2)

		chDir(curDir)
	end,
	isDir = function(unitTest)
		unitTest:assert(isDir(sessionInfo().path))
		
		local path = _Gtme.makePathCompatibleToAllOS(sessionInfo().path)
		path = path.."/"
		unitTest:assert(isDir(path))
		
        unitTest:assertEquals(isDir(""), false);
        
        unitTest:assert(not isDir(filePath("agents.csv")))	
	end,
	isWindowsOS = function(unitTest)
		unitTest:assert(true)
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

		local attr = _Gtme.File(pathdata.."test"):attributes("mode")
		unitTest:assertEquals(attr, "directory")

		rmDir(pathdata.."test")
	end,
	rmDir = function(unitTest)
		local pathdata = packageInfo().data

		unitTest:assert(mkDir(pathdata.."test"))

		local attr = _Gtme.File(pathdata.."test"):attributes("mode")
		unitTest:assertEquals(attr, "directory")

		rmDir(pathdata.."test")

		unitTest:assert(not isDir(pathdata.."test"))
	end,
	rmFile = function(unitTest)
		local file = packageInfo().data.."test123"
		os.execute("touch "..file)

		rmFile(file)

		unitTest:assert(not File(file):exists())
		
		os.execute("touch abc123.shp")
		os.execute("touch abc123.shx")
		os.execute("touch abc123.dbf")
		os.execute("touch abc123.prj")

		rmFile("abc123.shp")

		unitTest:assert(not File("abc123.shp"):exists())
		unitTest:assert(not File("abc123.shx"):exists())
		unitTest:assert(not File("abc123.dbf"):exists())
		unitTest:assert(not File("abc123.prj"):exists())

		os.execute("touch abc123.shp")

		rmFile("abc123.shp")
	end, 
	runCommand = function(unitTest)
		local d, e = runCommand("ls "..packageInfo().data)
		unitTest:assertEquals(#d, 43) -- 43 files
		unitTest:assertEquals(#e, 0)
	end,
	sessionInfo = function(unitTest)
		local s = sessionInfo()

		unitTest:assertEquals(s.mode, "debug")
		unitTest:assertEquals(s.version, packageInfo().version)
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
	end
}

