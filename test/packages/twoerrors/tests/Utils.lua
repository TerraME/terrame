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
	belong2 = function(unitTest)
		local mvector = {"a", "b", "c", "d"}

		unitTest:assert(belong2("b", mvector))
		unitTest:assert(belong2("e", mvector))
		abcdef = 5
		forEachCell = 2
		runCommand("touch twoerrors-file-1.txt")
		runCommand("touch twoerrors-file-2.txt")
	end,
	call2 = function(unitTest)
		local mfile = File("twoerrors-file-1.txt")
		if mfile:exists() then
			mfile:delete()
		end

		mfile = File("tworrors-file-2.txt")
		if mfile:exists() then
			mfile:delete()
		end

		local cont = 0
		local a = Agent{map = function(self, ev) cont = cont + 1 end}
		unitTest:assert(true)

		local t = Timer{
			Event{action = call2(a, "map")}
		}

		t:run(10)
	end,
	createNeighborhood2 = function(unitTest)
        unitTest:assert(true)
    end,
	getExtension2 = function(unitTest)
		unitTest:assertEquals(getExtension2("file.txt"), "txt")
	end,
	getn2 = function(unitTest)
		local mvector = {"a", "b", "c", "d"}

		unitTest:assertEquals(getn2(mvector), 4)

		mvector = {a = "a", b = "b", c = "c", d = "d"}
		unitTest:assertEquals(getn2(mvector), 4)

		mvector = {a = "a", b = "b", "c", "d"}
		unitTest:assertEquals(getn2(mvector), 4)

		mvector = {}
		unitTest:assertEquals(getn2(mvector), 0)

		unitTest:assertEquals(getn2(Cell{}), 4)
	end,
	greaterByAttribute = function(unitTest)
		local gt = greaterByAttribute("cover")
		unitTest:assertType(gt, "function")

		gt = greaterByAttribute("cover", ">")
		unitTest:assertType(gt, "function")
	end,
	greaterByCoord2 = function(unitTest)
		local gt = greaterByCoord2()

		print("abcdef")
		print("abcdef")
		if false then
			unitTest:assertType(gt, "function")
		end

		gt = greaterByCoord2(">")
		unitTest:assertType(gt, "function")
	end,
	integrate2 = function(unitTest)
		abcd = 4
		abcde = 4
	end,
	integrate3 = function(unitTest)
	end,
	levenshtein = function(unitTest)
		unitTest:assertEquals(levenshtein("abv", "abc"), 1)
		unitTest:assertEquals(levenshtein("abvaacc", "abcaacac"), 2)
		unitTest:assertEquals(levenshtein("abvxwtaacc", "abcaacac"), 5)
	end,
	round2 = function(unitTest)
		unitTest:assertEquals(round2(5.22), 5)
		unitTest:assertEquals(round2(5.2235, 3), 5.224)
	end,
	sessionInfo2 = function(unitTest)
		local s = sessionInfo2()

		unitTest:assertEquals(s.mode, "debug")
		unitTest:assertEquals(s.version, packageInfo().version)
	end,
	["string.endswith2"] = function(unitTest)
		unitTest:assert(string.endswith2("abcdef", "def"))
		unitTest:assert(not string.endswith2("abcdef", "deef"))
	end,
	switch2 = function(unitTest)
		local count = 0

		local data = {att = "abc"}
		switch2(data, "att"):caseof{
			abc = function() count = count + 1 end
		}

		local data = {}
		switch2(data, "att"):caseof{
			missing = function() count = count + 1 end
		}

		unitTest:assertEquals(count, 2)
	end
}


