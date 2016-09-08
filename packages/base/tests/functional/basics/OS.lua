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
	currentDir = function(unitTest)
		local info = sessionInfo()
		local cur_dir = currentDir()
		Directory(info.path):setCurrentDir()
		unitTest:assertEquals(currentDir(), info.path)
		Directory(cur_dir):setCurrentDir()
	end,
	runCommand = function(unitTest)
		local d, e = runCommand("ls "..packageInfo().data)
		unitTest:assertEquals(#d, 29) -- 29 files
		unitTest:assertEquals(#e, 0)
	end,
	sessionInfo = function(unitTest)
		local s = sessionInfo()

		unitTest:assertEquals(s.mode, "debug")
		unitTest:assertEquals(s.version, packageInfo().version)
		unitTest:assertEquals(s.system == "windows", s.separator == "\\")
	end,
	tmpDir = function(unitTest)
		local f = tmpDir()
		local g = tmpDir()

		unitTest:assertEquals(f, g)
		unitTest:assertType(f, "string")
		unitTest:assert(Directory(f):exists())

		Directory(g):delete()
		g = tmpDir()

		unitTest:assertEquals(f, g)
		unitTest:assertType(f, "string")
		unitTest:assert(Directory(f):exists())

		g = tmpDir("abc123XXXXX")

		unitTest:assert(Directory(g):exists())
		unitTest:assertEquals(string.len(g), 11)
		unitTest:assertType(g, "string")

		Directory(g):delete()
	end
}

