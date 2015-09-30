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
	belong = function(unitTest)
		local mvector = {"a", "b", "c", "d"}

		unitTest:assert(belong("b", mvector))
		unitTest:assert(not belong("e", mvector))
	end,
	call = function(unitTest)
		local cont = 0
		local a = Agent{map = function(self, ev) cont = cont + 1 end}

		local t = Timer{
			Event{action = call(a, "map")}
		}

		t:execute(10)
		unitTest:assertEquals(cont, 10)
	end,
	d = function(unitTest)
		local df = function(x, y) return y - x ^ 2 + 1 end
		local a = 0
		local b = 2
		local init = 0.5
		local delta = 0.2
		local x = 0
		local y = 0

		local result1 = integrationEuler(df, init, a, b, delta)
		local result2 = d{df, init, a, b, delta}
		unitTest:assertEquals(4.86578450432, result1, 0.0001)
		unitTest:assertEquals(result1, result2)

		INTEGRATION_METHOD = integrationHeun
		local df = function(x, y) return y - x ^ 2 + 1 end
		local a = 0
		local b = 2
		local init = 0.5
		local delta = 0.2
		local x = 0
		local y = 0

		result1 = integrationHeun(df, init, a, b, delta)
		result2 = d{df, init, a, b, delta}
		unitTest:assertEquals(5.23305, result1, 0.0001)
		unitTest:assertEquals(result1, result2)

		INTEGRATION_METHOD = nil

		local timeStep = 0.5
		local birthPreyRate = 0.2
		local predationRate = 0.01 -- death prey rate
		local birthPredatorPerPreyRate = 0.01 -- birth predator rate
		local deathPredatorRate = 0.1

		local preyFunc = function(t, q)
			return q[1] * birthPreyRate - q[1] * q[2] * predationRate
		end
		
		local predatorFunc = function(t, q)
			return q[2] * q[1] * birthPredatorPerPreyRate - q[2] * deathPredatorRate
		end

		local ag = Agent{preys = 100, predators = 10}
		for t = 0, 10, timeStep do
			ag.preys, ag.predators = d{
				{preyFunc, predatorFunc},
				{ag.preys, ag.predators},
				0,
				timeStep, 
				0.03125
			}
		end

		unitTest:assertEquals(ag.preys, 0.056344145404554)
		unitTest:assertEquals(ag.predators, 77.830055916773)
	end,
	delay = function(unitTest)
		local t1 = os.time()
		delay()
		local t2 = os.time()

		unitTest:assert(t2 - t1 >= 1)

		local t1 = os.time()
		delay(.5)
		local t2 = os.time()

		unitTest:assert(t2 - t1 >= .5)
	end,
	elapsedTime = function(unitTest)
		unitTest:assertType(elapsedTime(50), "string")
	end,
	forEachAgent = function(unitTest)
		local a = Agent{value = 2}
		local soc = Society{instance = a, quantity = 10}

		local count = 0
		forEachAgent(soc, function(ag)
			unitTest:assertEquals(ag.value, 2)
			count = count + 1
		end)
		unitTest:assertEquals(count, 10)

		count = 0
		forEachAgent(soc, function(ag)
			count = count + 1
			if count > 5 then return false end
		end)
		unitTest:assertEquals(count, 6)

		local g = Group{target = soc}

		count = 0
		forEachAgent(g, function(ag)
			unitTest:assertEquals(ag.value, 2)
			count = count + 1
		end)
		unitTest:assertEquals(count, 10)

		local cs = CellularSpace{xdim = 2}
		local e = Environment{soc, cs}

		e:createPlacement()

		count = 0
		forEachCell(cs, function(cell)
			forEachAgent(cell, function(ag)
				unitTest:assertEquals(ag.value, 2)
				count = count + 1
			end)
		end)
		unitTest:assertEquals(count, 10)
	end,
	forEachCell = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		forEachCell(cs, function(cell) unitTest:assertType(cell, "Cell") end)

		forEachCell(cs, function(cell) cell.value = 2 end)
		forEachCell(cs, function(cell) unitTest:assertEquals(cell.value, 2) end)

		local t = Trajectory{target = cs}
		forEachCell(t, function(cell) cell.value = 4 end)
		forEachCell(cs, function(cell) unitTest:assertEquals(cell.value, 4) end)

		local a = Agent{}
		local env = Environment{cs, a}
		env:createPlacement{strategy = "void"}

		a.placement:add(cs:sample())
		a.placement:add(cs:sample())
		a.placement:add(cs:sample())

		local r

		r = forEachCell(a, function(cell) unitTest:assertEquals(cell.value, 4) end)

		unitTest:assert(r)

		local count = 0
		r = forEachCell(cs, function(cell)
			count = count + 1
			if count > 10 then return false end
		end)

		unitTest:assert(not r)
		unitTest:assertEquals(count, 11)
	end,
	forEachCellPair = function(unitTest)
		local cs1 = CellularSpace{xdim = 10}
		local cs2 = CellularSpace{xdim = 10}
		local count = 0
		local r

		r = forEachCellPair(cs1, cs2, function()
			count = count + 1
		end)

		unitTest:assert(r)
		unitTest:assertEquals(count, 100)

		count = 0
		r = forEachCellPair(cs1, cs2, function()
			count = count + 1
			if count > 10 then return false end
		end)

		unitTest:assert(not r)
		unitTest:assertEquals(count, 11)
	end,
	forEachConnection = function(unitTest)
		local a = Agent{value = 2}
		local soc = Society{instance = a, quantity = 10}

		soc:createSocialNetwork{quantity = 3}

		local count = 0
		local r
		local s = soc:sample()

		r = forEachConnection(s, function(ag1, ag2, w)
			unitTest:assertType(ag2, "Agent")
			unitTest:assertEquals(ag1, s)
			unitTest:assertType(w, "number")
			count = count + 1
		end)

		unitTest:assert(r)
		unitTest:assertEquals(count, 3)

		count = 0
		r = forEachConnection(s, function()
			count = count + 1
			return false
		end)

		unitTest:assert(not r)
		unitTest:assertEquals(count, 1)
	end,
	forEachElement = function(unitTest)
		local mvector = {a = "a", b = "b", c = "c", d = "d"}
		local count = 0

		forEachElement(mvector, function(idx, value, mtype)
			unitTest:assertType(idx, "string")
			unitTest:assertType(value, "string")
			unitTest:assertEquals(mtype, "string")
			count = count + 1
		end)
		unitTest:assertEquals(count, 4)

		mvector = {1, 2, 3, 4, 5}
		count = 0
		local r

		r = forEachElement(mvector, function(idx, value, mtype)
			unitTest:assertType(idx, "number")
			unitTest:assertType(value, "number")
			unitTest:assertEquals(mtype, "number")
			count = count + 1
		end)

		unitTest:assert(r)
		unitTest:assertEquals(count, 5)

		count = 0
		r = forEachElement(mvector, function()
			count = count + 1
			if count > 2 then return false end
		end)

		unitTest:assert(not r)
		unitTest:assertEquals(count, 3)
	end,
	forEachFile = function(unitTest)
	
		if not _Gtme.isWindowsOS() then
			local count = 0
			local r

			r = forEachFile(file("", "base"), function(file)
				count = count + 1
				unitTest:assertType(file, "string") -- SKIP
			end)

			unitTest:assert(r) -- SKIP
			unitTest:assertEquals(count, 23) -- SKIP

			local count2 = 0
			forEachFile(dir(file("", "base"), true), function(file)
				count2 = count2 + 1
			end)

			unitTest:assertEquals(count2, count + 2) -- SKIP

			count = 0

			r = forEachFile(file("", "base"), function(file)
				count = count + 1
				if count > 1 then return false end
			end)

			unitTest:assert(not r) -- SKIP
			unitTest:assertEquals(count, 2) -- SKIP
		else
			unitTest:assert(true) -- SKIP
		end
	end,
	forEachNeighbor = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		cs:createNeighborhood()

		local count = 0
		local c = cs.cells[1]
		local r

		r = forEachNeighbor(c, function(cell1, cell2, w)
			unitTest:assertType(cell2, "Cell")
			unitTest:assertEquals(cell1, c)
			unitTest:assertType(w, "number")
			count = count + 1
		end)
		unitTest:assert(r)
		unitTest:assertEquals(count, 3)

		count = 0
		r = forEachNeighbor(c, function()
			count = count + 1
			if count > 1 then return false end
		end)
		unitTest:assert(not r)
		unitTest:assertEquals(count, 2)
	end,
	forEachNeighborhood = function(unitTest)
		local c1 = Cell{}
		local c2 = Cell{}
		local c3 = Cell{}

		local n1 = Neighborhood()
		n1:add(c2)
		n1:add(c3)

		local n2 = Neighborhood()
		n2:add(c2)
		n2:add(c3)

		c1:addNeighborhood(n1, "1")
		c1:addNeighborhood(n2, "2")

		local count = 0
		local r
		local neighbors = 0

		r = forEachNeighborhood(c1, function(idx)
			unitTest:assertType(idx, "string")
			forEachNeighbor(c1, idx, function()
				neighbors = neighbors + 1
			end)

			count = count + 1
		end)
		unitTest:assert(r)
		unitTest:assertEquals(count, 2)
		unitTest:assertEquals(neighbors, 4)

		local count = 0
		r = forEachNeighborhood(c1, function()
			count = count + 1
			return false
		end)
		unitTest:assert(not r)
		unitTest:assertEquals(count, 1)
	end,
	forEachOrderedElement = function(unitTest)
		local result = {1, 2, 3, "a", "b", "c"}
		local list = {[1] = 1, [3] = 3, [2] = 2, a = "a", b = "b", c = "c"}

		local cont = 0
		local r
		r = forEachOrderedElement(list, function(idx, value, mtype)
			cont = cont + 1
			unitTest:assertEquals(mtype, type(result[cont]))

			unitTest:assertEquals(idx, result[cont])
			unitTest:assertEquals(value, result[cont])
		end)
		unitTest:assert(r)
		unitTest:assertEquals(cont, 6)

		local cont = 0
		r = forEachOrderedElement(list, function()
			cont = cont + 1
			return false
		end)
		unitTest:assert(not r)
		unitTest:assertEquals(cont, 1)
	end,
	forEachSocialNetwork = function(unitTest)
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

		r = forEachSocialNetwork(a1, function(idx)
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
		r = forEachSocialNetwork(a1, function()
			count = count + 1
			return false
		end)
		unitTest:assert(not r)
		unitTest:assertEquals(count, 1)
	end,
	getExtension = function(unitTest)
		unitTest:assertEquals(getExtension("file.txt"), "txt")
	end,
	getn = function(unitTest)
		local mvector = {"a", "b", "c", "d"}

		unitTest:assertEquals(getn(mvector), 4)

		mvector = {a = "a", b = "b", c = "c", d = "d"}
		unitTest:assertEquals(getn(mvector), 4)

		mvector = {a = "a", b = "b", "c", "d"}
		unitTest:assertEquals(getn(mvector), 4)

		mvector = {}
		unitTest:assertEquals(getn(mvector), 0)

		unitTest:assertEquals(getn(Cell{}), 4)
	end,
	greaterByAttribute = function(unitTest)
		local gt = greaterByAttribute("cover")
		unitTest:assertType(gt, "function")

		gt = greaterByAttribute("cover", ">")
		unitTest:assertType(gt, "function")
	end,
	greaterByCoord = function(unitTest)
		local gt = greaterByCoord()
		unitTest:assertType(gt, "function")

		gt = greaterByCoord(">")
		unitTest:assertType(gt, "function")
	end,
	integrate = function(unitTest)
		local f = function(x) return x^3 end

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			step = 0.1
		}

		unitTest:assertEquals(16.48360, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			step = 0.01
		}

		unitTest:assertEquals(20.11522, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			step = 0.001
		}

		unitTest:assertEquals(20.23650, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			step = 0.0001
		}

		unitTest:assertEquals(20.24595, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "rungekutta",
			step = 0.1
		}

		unitTest:assertEquals(17.682025, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "rungekutta",
			step = 0.01
		}

		unitTest:assertEquals(20.25, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "rungekutta",
			step = 0.001
		}

		unitTest:assertEquals(20.25, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "rungekutta",
			step = 0.0001
		}

		unitTest:assertEquals(20.24730, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "heun",
			step = 0.1
		}

		unitTest:assertEquals(17.70305, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "heun",
			step = 0.01
		}

		unitTest:assertEquals(20.250225, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "heun",
			step = 0.001
		}

		unitTest:assertEquals(20.25, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "heun",
			step = 0.0001
		}

		unitTest:assertEquals(20.24730, v, 0.0001)

		local df = function(x, y) return y - x ^ 2 + 1 end
		local v = integrate{
			equation = df,
			initial = 0.5,
			a = 0,
			b = 2,
			method = "heun",
			step = 0.2
		}

		unitTest:assertEquals(5.23305, v, 0.0001)

		local eq1 = function(t, y)
			return t - 0.1
		end

		local event = Event{start = 2, period = 2, priority = 1, action = function(event) end}

		local v = integrate{
			equation = df,
			method = "heun",
			step = 0.2,
			initial = 0.5,
			event = event
		}

		unitTest:assertEquals(5.23305, v, 0.0001)

		local v = integrate{
			equation = {eq1, eq1},
			initial = {0, 0},
			a = 0,
			b = 100,
			step = 0.1
		}

		unitTest:assertType(v, "number")

		local v = integrate{
			equation = {eq1, eq1},
			method = "heun",
			initial = {0, 0},
			a = 0,
			b = 100,
			step = 0.1
		}

		unitTest:assertType(v, "number")

		local v = integrate{
			equation = {eq1, eq1},
			method = "rungekutta",
			initial = {0, 0},
			a = 0,
			b = 100,
			step = 0.1
		}

		unitTest:assertType(v, "number")
	
		-- integrate with a set of functions
		local timeStep = 0.5
		local birthPreyRate = 0.2
		local predationRate = 0.01 -- death prey rate
		local birthPredatorPerPreyRate = 0.01 -- birth predator rate
		local deathPredatorRate = 0.1

		local preyFunc = function(t, q)
			return q[1] * birthPreyRate - q[1] * q[2] * predationRate
		end
		
		local predatorFunc = function(t, q)
			return q[2] * q[1] * birthPredatorPerPreyRate - q[2] * deathPredatorRate
		end

		local ag = Agent{preys = 100, predators = 10}
		for t = 0, 10, timeStep do
			ag.preys, ag.predators = integrate{
				equation = {preyFunc, predatorFunc},
				initial = {ag.preys, ag.predators},
				a = 0,
				b = timeStep, 
				step = 0.03125
			}
		end

		unitTest:assertEquals(ag.preys, 0.056344145404554)
		unitTest:assertEquals(ag.predators, 77.830055916773)

		ag = Agent{preys = 100, predators = 10}
		for t = 0, 10, timeStep do
			ag.preys, ag.predators = integrate{
				equation = {preyFunc, predatorFunc},
				initial = {ag.preys, ag.predators},
				a = 0,
				b = timeStep, 
				method = "heun",
				step = 0.03125
			}
		end

		unitTest:assertEquals(ag.preys, 0.064490405763652)
		unitTest:assertEquals(ag.predators, 77.393465378403)

		ag = Agent{preys = 100, predators = 10}
		for t = 0, 10, timeStep do
			ag.preys, ag.predators = integrate{
				equation = {preyFunc, predatorFunc},
				initial = {ag.preys, ag.predators},
				a = 0,
				b = timeStep, 
				method = "rungekutta",
				step = 0.03125
			}
		end

		unitTest:assertEquals(ag.preys, 0.062817338900899)
		unitTest:assertEquals(ag.predators, 77.645421917421)
	end,
	integrationHeun = function(unitTest)
		unitTest:assert(true)
	end,
	integrationEuler = function(unitTest)
		unitTest:assert(true)
	end,
	integrationRungeKutta = function(unitTest)
		unitTest:assert(true)
	end,
	levenshtein = function(unitTest)
		unitTest:assertEquals(levenshtein("abv", "abc"), 1)
		unitTest:assertEquals(levenshtein("abvaacc", "abcaacac"), 2)
		unitTest:assertEquals(levenshtein("abvxwtaacc", "abcaacac"), 5)
	end,
	round = function(unitTest)
		unitTest:assertEquals(round(5.22), 5)
		unitTest:assertEquals(round(5.2235, 3), 5.224)
	end,
	sessionInfo = function(unitTest)
		local s = sessionInfo()

		unitTest:assertEquals(s.mode, "debug")
		unitTest:assertEquals(s.version, packageInfo().version)
	end,
	["string.endswith"] = function(unitTest)
		unitTest:assert(string.endswith("abcdef", "def"))
		unitTest:assert(not string.endswith("abcdef", "deef"))
	end,
	toLabel = function(unitTest)
		sessionInfo().interface = true
		unitTest:assertEquals(toLabel("myFirstString"), "'My First String'")
		unitTest:assertEquals(toLabel(255), "'255'")
		unitTest:assertEquals(toLabel("my_first_string"), "'My First String'")
		unitTest:assertEquals(toLabel("my_first_string_"), "'My First String'")
		unitTest:assertEquals(toLabel("myFirstString_"), "'My First String'")
		unitTest:assertEquals(toLabel("myFirstStr", "myParent"), "'My First Str' (in 'My Parent')")

		sessionInfo().interface = false
		unitTest:assertEquals(toLabel("myFirstString"), "'myFirstString'")
		unitTest:assertEquals(toLabel(255), "'255'")
		unitTest:assertEquals(toLabel("my_first_string"), "'my_first_string'")
		unitTest:assertEquals(toLabel("my_first_string_"), "'my_first_string_'")
		unitTest:assertEquals(toLabel("myFirstString_"), "'myFirstString_'")
		unitTest:assertEquals(toLabel("myFirstStr", "myParent"), "'myParent.myFirstStr'")
	end,
	switch = function(unitTest)
		local count = 0

		local data = {att = "abc"}
		switch(data, "att"):caseof{
			abc = function() count = count + 1 end
		}

		local data = {}
		switch(data, "att"):caseof{
			missing = function() count = count + 1 end
		}

		unitTest:assertEquals(count, 2)
	end,
	tmpDir = function(unitTest)
		local f = tmpDir()
		local g = tmpDir()

		unitTest:assertEquals(f, g)
		unitTest:assertType(f, "string")
	end,
	type = function(unitTest)
		local c = Cell{}

		unitTest:assertEquals(type(c), "Cell")
	end,
	vardump = function(unitTest)
		local x = {a = 2, b = 3, w = {2, 3, 4}}

		unitTest:assertEquals(vardump(x), [[{
    ['a'] = '2', 
    ['b'] = '3', 
    ['w'] =     {
        [1] = '2', 
        [2] = '3', 
        [3] = '4'
    }
}]])
	end
}

