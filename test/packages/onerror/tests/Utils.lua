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
		unitTest:assert(not belong2("e", mvector))
		runCommand("touch onerror-file-1.txt")
	end,
	call2 = function(unitTest)
		if isFile("onerror-file-1.txt") then
			rmFile("onerror-file-1.txt")
		end

		local cont = 0
		local a = Agent{map = function(self, ev) cont = cont + 1 end}
		unitTest:assert(true)

		local t = Timer{
			Event{action = call2(a, "map")}
		}

		t:run(10)
	end,
	elapsedTime2 = function(unitTest)
		unitTest:assertType(elapsedTime2(50), "string")
	end,
	forEachAgent2 = function(unitTest)
		unitTest:assert(true)
	end,
	forEachCell2 = function(unitTest)
		unitTest:assert(true)
	end,
	createNeighborhood2 = function(unitTest)
        unitTest:assert(true)
    end,
	forEachCellPair2 = function(unitTest)
		local cs1 = CellularSpace{xdim = 10}
		local cs2 = CellularSpace{xdim = 10}
		local count = 0
		local r

		r = forEachCellPair2(cs1, cs2, function()
			count = count + 1
		end)

		unitTest:assert(r)
		unitTest:assertEquals(count, 100)

		count = 0
		r = forEachCellPair2(cs1, cs2, function()
			count = count + 1
			if count > 10 then return false end
		end)

		unitTest:assert(not r)
		unitTest:assertEquals(count, 11)
	end,
	forEachElement2 = function(unitTest)
		local mvector = {a = "a", b = "b", c = "c", d = "d"}
		local count = 0

		forEachElement2(mvector, function(idx, value, mtype)
			unitTest:assertType(idx, "string")
			unitTest:assertType(value, "string")
			unitTest:assertEquals(mtype, "string")
			count = count + 1
		end)
		unitTest:assertEquals(count, 4)

		mvector = {1, 2, 3, 4, 5}
		count = 0
		local r

		r = forEachElement2(mvector, function(idx, value, mtype)
			unitTest:assertType(idx, "number")
			unitTest:assertType(value, "number")
			unitTest:assertEquals(mtype, "number")
			count = count + 1
		end)

		unitTest:assert(r)
		unitTest:assertEquals(count, 5)

		count = 0
		r = forEachElement2(mvector, function()
			count = count + 1
			if count > 2 then return false end
		end)

		unitTest:assert(not r)
		unitTest:assertEquals(count, 3)
	end,
	forEachFile2 = function(unitTest)
		local count = 0
		local r

		r = forEachFile2(filePath("", "base"), function(file)
			count = count + 1
			unitTest:assertType(file, "string")
		end)

		unitTest:assert(r)
		unitTest:assertEquals(count, 29)

		local count2 = 0
		forEachFile2(Directory(filePath("", "base")):list(true), function(file)
			count2 = count2 + 1
		end)

		unitTest:assertEquals(count2, count + 2)

		count = 0

		r = forEachFile2(filePath("", "base"), function(file)
			count = count + 1
			if count > 1 then return false end
		end)

		unitTest:assert(not r)
		unitTest:assertEquals(count, 2)
	end,
	forEachNeighbor2 = function(unitTest)
		unitTest:assert(true)
	end,
	forEachOrderedElement2 = function(unitTest)
		local result = {1, 2, 3, "a", "b", "c"}
		local list = {[1] = 1, [3] = 3, [2] = 2, a = "a", b = "b", c = "c"}

		local cont = 0
		local r
		r = forEachOrderedElement2(list, function(idx, value, mtype)
			cont = cont + 1
			unitTest:assertEquals(mtype, type(result[cont]))

			unitTest:assertEquals(idx, result[cont])
			unitTest:assertEquals(value, result[cont])
		end)
		unitTest:assert(r)
		unitTest:assertEquals(cont, 6)

		local cont = 0
		r = forEachOrderedElement2(list, function()
			cont = cont + 1
			return false
		end)
		unitTest:assert(not r)
		unitTest:assertEquals(cont, 1)
	end,
	forEachSocialNetwork2 = function(unitTest)
		local a1 = Agent{id = "111"}
		local a2 = Agent{id = "222"}
		local a3 = Agent{id = "333"}

		local s1 = SocialNetwork()
		s1:add(a2)
		s1:add(a3)

		local s2 = SocialNetwork()
		s2:add(a2)
		s2:add(a3)

		a1:addSocialNetwork(s1, "1")
		a1:addSocialNetwork(s2, "2")

		local count = 0
		local r
		local connections = 0

		r = forEachSocialNetwork2(a1, function(idx)
			unitTest:assertType(idx, "string")
			forEachConnection(a1, idx, function()
				connections = connections + 1
			end)

			count = count + 1
		end)
		unitTest:assert(r)
		unitTest:assertEquals(count, 2)
		unitTest:assertEquals(connections, 4)

		local count = 0
		r = forEachSocialNetwork2(a1, function()
			count = count + 1
			return false
		end)
		unitTest:assert(not r)
		unitTest:assertEquals(count, 1)
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
	greaterByAttribute2 = function(unitTest)
		local gt = greaterByAttribute2("cover")
		unitTest:assertType(gt, "function")

		gt = greaterByAttribute2("cover", ">")
		unitTest:assertType(gt, "function")
	end,
	greaterByCoord2 = function(unitTest)
		local gt = greaterByCoord2()

		print("abcdef")
		if false then
			unitTest:assertType(gt, "function")
		end

		gt = greaterByCoord2(">")
		unitTest:assertType(gt, "function")
	end,
	integrate2 = function(unitTest)
		abcd = 4
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
	end,
	type2 = function(unitTest)
		local c = Cell{}

		unitTest:assertEquals(type2(c), "Cell")
	end,
	vardump2 = function(unitTest)
		local x = {a = 2, b = 3, w = {2, 3, 4}}

		unitTest:assertEquals(vardump2(x), [[{
    ['a'] = 2, 
    ['b'] = 3, 
    ['w'] = {
        2, 
        3, 
        4
    }
}]])
	end
}

