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
	integrate = function(unitTest)
		local f = function(x) return x^3 end

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			step = 0.1
		}

		unitTest:assert_equal(16.48360, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			step = 0.01
		}

		unitTest:assert_equal(20.11522, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			step = 0.001
		}

		unitTest:assert_equal(20.23650, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			step = 0.0001
		}

		unitTest:assert_equal(20.24595, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "rungekutta",
			step = 0.1
		}

		unitTest:assert_equal(17.682025, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "rungekutta",
			step = 0.01
		}

		unitTest:assert_equal(20.25, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "rungekutta",
			step = 0.001
		}

		unitTest:assert_equal(20.25, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "rungekutta",
			step = 0.0001
		}

		unitTest:assert_equal(20.24730, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "heun",
			step = 0.1
		}

		unitTest:assert_equal(17.70305, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "heun",
			step = 0.01
		}

		unitTest:assert_equal(20.250225, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "heun",
			step = 0.001
		}

		unitTest:assert_equal(20.25, v, 0.0001)

		local v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "heun",
			step = 0.0001
		}

		unitTest:assert_equal(20.24730, v, 0.0001)

		local df = function(x, y) return y - x ^ 2 + 1 end
		local v = integrate{
			equation = df,
			initial = 0.5,
			a = 0,
			b = 2,
			method = "heun",
			step = 0.2
		}

		unitTest:assert_equal(5.23305, v, 0.0001)

		local eq1 = function(t, y)
			return t - 0.1
		end

		local event = Event{time = 2, period = 2, priority = 1, action = function(event) end}[1]

		local v = integrate{
			equation = df,
			method = "heun",
			step = 0.2,
			initial = 0.5,
			event = event
		}

		unitTest:assert_equal(5.23305, v, 0.0001)

		-- TODO: verify results using more than one equation
		local v = integrate{
			equation = {eq1, eq1},
			initial = {0, 0},
			a = 0,
			b = 100,
			step = 0.1
		}

		local v = integrate{
			equation = {eq1, eq1},
			method = "heun",
			initial = {0, 0},
			a = 0,
			b = 100,
			step = 0.1
		}

		local v = integrate{
			equation = {eq1, eq1},
			method = "rungekutta",
			initial = {0, 0},
			a = 0,
			b = 100,
			step = 0.1
		}

		unitTest:assert_type(v, "number")
	
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

		unitTest:assert_equal(ag.preys, 0.056344145404554)
		unitTest:assert_equal(ag.predators, 77.830055916773)

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

		unitTest:assert_equal(ag.preys, 0.064490405763652)
		unitTest:assert_equal(ag.predators, 77.393465378403)

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

		unitTest:assert_equal(ag.preys, 0.062817338900899)
		unitTest:assert_equal(ag.predators, 77.645421917421)
	end,
	belong = function(unitTest)
		local mvector = {"a", "b", "c", "d"}

		unitTest:assert(belong("b", mvector))
		unitTest:assert(not belong("e", mvector))
	end,
	["string.endswith"] = function(unitTest)
		unitTest:assert(string.endswith("abcdef", "def"))
		unitTest:assert(not string.endswith("abcdef", "deef"))
	end,
	call = function(unitTest)
		local cont = 0
		local a = Agent{map = function(self, ev) cont = cont + 1 end}

		local t = Timer{
			Event{action = call(a, "map")}
		}

		t:execute(10)
		unitTest:assert_equal(cont, 10)
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
	levenshtein = function(unitTest)
		unitTest:assert_equal(levenshtein("abv", "abc"), 1)
		unitTest:assert_equal(levenshtein("abvaacc", "abcaacac"), 2)
		unitTest:assert_equal(levenshtein("abvxwtaacc", "abcaacac"), 5)
	end,
	forEachAgent = function(unitTest)
		local a = Agent{value = 2}
		local soc = Society{instance = a, quantity = 10}

		local count = 0
		forEachAgent(soc, function(ag)
			unitTest:assert_equal(ag.value, 2)
			count = count + 1
		end)
		unitTest:assert_equal(count, 10)

		count = 0
		forEachAgent(soc, function(ag)
			count = count + 1
			if count > 5 then return false end
		end)
		unitTest:assert_equal(count, 6)

		local g = Group{target = soc}

		count = 0
		forEachAgent(g, function(ag)
			unitTest:assert_equal(ag.value, 2)
			count = count + 1
		end)
		unitTest:assert_equal(count, 10)

		local cs = CellularSpace{xdim = 2}
		local e = Environment{soc, cs}

		e:createPlacement()

		count = 0
		forEachCell(cs, function(cell)
			forEachAgent(cell, function(ag)
				unitTest:assert_equal(ag.value, 2)
				count = count + 1
			end)
		end)
		unitTest:assert_equal(count, 10)
	end,
	forEachCell = function(unitTest)
		local cs = CellularSpace{xdim = 10}

		forEachCell(cs, function(cell) unitTest:assert_type(cell, "Cell") end)

		forEachCell(cs, function(cell) cell.value = 2 end)
		forEachCell(cs, function(cell) unitTest:assert_equal(cell.value, 2) end)

		local t = Trajectory{target = cs}
		forEachCell(t, function(cell) cell.value = 4 end)
		forEachCell(cs, function(cell) unitTest:assert_equal(cell.value, 4) end)

		local a = Agent{}
		local env = Environment{cs, a}
		env:createPlacement{strategy = "void"}

		a.placement:add(cs:sample())
		a.placement:add(cs:sample())
		a.placement:add(cs:sample())

		local r

		r = forEachCell(a, function(cell) unitTest:assert_equal(cell.value, 4) end)

		unitTest:assert(r)

		local count = 0
		r = forEachCell(cs, function(cell)
			count = count + 1
			if count > 10 then return false end
		end)

		unitTest:assert(not r)
		unitTest:assert_equal(count, 11)
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
		unitTest:assert_equal(count, 100)

		count = 0
		r = forEachCellPair(cs1, cs2, function()
			count = count + 1
			if count > 10 then return false end
		end)

		unitTest:assert(not r)
		unitTest:assert_equal(count, 11)
	end,
	forEachConnection = function(unitTest)
		local a = Agent{value = 2}
		local soc = Society{instance = a, quantity = 10}

		soc:createSocialNetwork{quantity = 3}

		local count = 0
		local r
		local s = soc:sample()

		r = forEachConnection(s, function(ag1, ag2, w)
			unitTest:assert_type(ag2, "Agent")
			unitTest:assert_equal(ag1, s)
			unitTest:assert_type(w, "number")
			count = count + 1
		end)

		unitTest:assert(r)
		unitTest:assert_equal(count, 3)

		count = 0
		r = forEachConnection(s, function()
			count = count + 1
			return false
		end)

		unitTest:assert(not r)
		unitTest:assert_equal(count, 1)
	end,
	forEachElement = function(unitTest)
		local mvector = {a = "a", b = "b", c = "c", d = "d"}
		local count = 0

		forEachElement(mvector, function(idx, value, mtype)
			unitTest:assert_type(idx, "string")
			unitTest:assert_type(value, "string")
			unitTest:assert_equal(mtype, "string")
			count = count + 1
		end)
		unitTest:assert_equal(count, 4)

		mvector = {1, 2, 3, 4, 5}
		count = 0
		local r

		r = forEachElement(mvector, function(idx, value, mtype)
			unitTest:assert_type(idx, "number")
			unitTest:assert_type(value, "number")
			unitTest:assert_equal(mtype, "number")
			count = count + 1
		end)

		unitTest:assert(r)
		unitTest:assert_equal(count, 5)

		count = 0
		r = forEachElement(mvector, function()
			count = count + 1
			if count > 2 then return false end
		end)

		unitTest:assert(not r)
		unitTest:assert_equal(count, 3)
	end,
	forEachFile = function(unitTest)
		local count = 0
		local r

		r = forEachFile(file("", "base"), function(file)
			count = count + 1
			unitTest:assert_type(file, "string")
		end)

		unitTest:assert(r)
		unitTest:assert_equal(count, 22)

		local count2 = 0
		forEachFile(dir(file("", "base"), true), function(file)
			count2 = count2 + 1
		end)

		unitTest:assert_equal(count2, count + 2)

		count = 0

		r = forEachFile(file("", "base"), function(file)
			count = count + 1
			if count > 1 then return false end
		end)

		unitTest:assert(not r)
		unitTest:assert_equal(count, 2)
	end,
	forEachNeighbor = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		cs:createNeighborhood()

		local count = 0
		local c = cs.cells[1]
		local r

		r = forEachNeighbor(c, function(cell1, cell2, w)
			unitTest:assert_type(cell2, "Cell")
			unitTest:assert_equal(cell1, c)
			unitTest:assert_type(w, "number")
			count = count + 1
		end)
		unitTest:assert(r)
		unitTest:assert_equal(count, 3)

		count = 0
		r = forEachNeighbor(c, function()
			count = count + 1
			if count > 1 then return false end
		end)
		unitTest:assert(not r)
		unitTest:assert_equal(count, 2)
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

		r = forEachNeighborhood(c1, function()
			count = count + 1
		end)
		unitTest:assert(r)
		unitTest:assert_equal(count, 2)

		local count = 0
		r = forEachNeighborhood(c1, function()
			count = count + 1
			return false
		end)
		unitTest:assert(not r)
		unitTest:assert_equal(count, 1)
	end,
	forEachOrderedElement = function(unitTest)
		local result = {1, 2, 3, "a", "b", "c"}
		local list = {[1] = 1, [3] = 3, [2] = 2, a = "a", b = "b", c = "c"}

		local cont = 0
		local r
		r = forEachOrderedElement(list, function(idx, value, mtype)
			cont = cont + 1
			unitTest:assert_equal(mtype, type(result[cont]))

			unitTest:assert_equal(idx, result[cont])
			unitTest:assert_equal(value, result[cont])
		end)
		unitTest:assert(r)
		unitTest:assert_equal(cont, 6)

		local cont = 0
		r = forEachOrderedElement(list, function()
			cont = cont + 1
			return false
		end)
		unitTest:assert(not r)
		unitTest:assert_equal(cont, 1)
	end,
	getExtension = function(unitTest)
		unitTest:assert_equal(getExtension("file.txt"), "txt")
	end,
	getn = function(unitTest)
		local mvector = {"a", "b", "c", "d"}

		unitTest:assert_equal(getn(mvector), 4)

		mvector = {a = "a", b = "b", c = "c", d = "d"}
		unitTest:assert_equal(getn(mvector), 4)

		mvector = {a = "a", b = "b", "c", "d"}
		unitTest:assert_equal(getn(mvector), 4)

		mvector = {}
		unitTest:assert_equal(getn(mvector), 0)

		unitTest:assert_equal(getn(Cell{}), 4)
	end,
	round = function(unitTest)
		unitTest:assert_equal(round(5.22), 5)
		unitTest:assert_equal(round(5.2235, 3), 5.224)
	end,
	greaterByAttribute = function(unitTest)
		local gt = greaterByAttribute("cover")
		unitTest:assert_type(gt, "function")

		gt = greaterByAttribute("cover", ">")
		unitTest:assert_type(gt, "function")
	end,
	greaterByCoord = function(unitTest)
		local gt = greaterByCoord()
		unitTest:assert_type(gt, "function")

		gt = greaterByCoord(">")
		unitTest:assert_type(gt, "function")
	end,
	elapsedTime = function(unitTest)
		unitTest:assert_type(elapsedTime(50), "string")
	end,
	sessionInfo = function(unitTest)
		local s = sessionInfo()

		unitTest:assert_equal(s.mode, "debug")
		unitTest:assert_equal(s.version, packageInfo().version)
	end,
	type = function(unitTest)
		local c = Cell{}

		unitTest:assert_equal(type(c), "Cell")
	end,
	vardump = function(unitTest)
		local x = {a = 2, b = 3, w = {2, 3, 4}}

		unitTest:assert_equal(vardump(x), [[{
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

