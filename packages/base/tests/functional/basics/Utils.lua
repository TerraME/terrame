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
		local count = 0
		local a = Agent{map = function() count = count + 1 end}

		local t = Timer{
			Event{action = call(a, "map")}
		}

		t:run(10)
		unitTest:assertEquals(count, 10)
	end,
	clone = function(unitTest)
		local animal = {
			age = 5,
			dim = {10, 8}
		}

		local copy = clone(animal)

		unitTest:assertEquals(copy.dim[1], 10)
		unitTest:assertEquals(copy.age, 5)
		copy.age = 2

		unitTest:assertEquals(animal.age, 5)
	end,
	d = function(unitTest)
		local df = function(x, y) return y - x ^ 2 + 1 end
		local a = 0
		local b = 2
		local init = 0.5
		local delta = 0.2

		local result1 = integrationEuler(df, init, a, b, delta)
		local result2 = d{df, init, a, b, delta}
		unitTest:assertEquals(4.86578450432, result1, 0.0001)
		unitTest:assertEquals(result1, result2)

		INTEGRATION_METHOD = integrationHeun
		df = function(mx, my) return my - mx ^ 2 + 1 end
		a = 0
		b = 2
		init = 0.5
		delta = 0.2

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

		local preyFunc = function(_, q)
			return q[1] * birthPreyRate - q[1] * q[2] * predationRate
		end

		local predatorFunc = function(_, q)
			return q[2] * q[1] * birthPredatorPerPreyRate - q[2] * deathPredatorRate
		end

		local ag = Agent{preys = 100, predators = 10}
		for _ = 0, 10, timeStep do
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

		t1 = os.time()
		delay(.5)
		t2 = os.time()

		unitTest:assert(t2 - t1 >= .5)
	end,
	equals = function(unitTest)
		unitTest:assert(equals(2, 2.00000001))
		unitTest:assert(not equals(2, 2.1))
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
		forEachAgent(soc, function()
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

		e:createPlacement{max = 8}

		count = 0
		forEachCell(cs, function(cell)
			forEachAgent(cell, function(ag)
				unitTest:assertEquals(ag.value, 2)
				count = count + 1
			end)
		end)

		unitTest:assertEquals(count, 10)

		e:createPlacement{max = 8, name = "workplace"}

		count = 0
		forEachCell(cs, function(cell)
			forEachAgent(cell, "workplace", function(ag)
				unitTest:assertEquals(ag.value, 2)
				count = count + 1
			end)
		end)

		unitTest:assertEquals(count, 10)
	end,
	forEachAttribute = function(unitTest)
		local a = Agent{}
		local soc = Society{instance = a, quantity = 10}
		local cell = Cell{}
		local cs = CellularSpace{xdim = 6, instance = cell}
		local e = Environment{soc, cs}

		e:createPlacement{}

		a = soc:sample()
		a.value1 = 2
		a.value2 = 3

		local count = 0
		forEachAttribute(a, function(idx, value)
			unitTest:assert(belong(idx, {"value1", "value2"}))
			unitTest:assert(value >= 2)
			unitTest:assert(value <= 3)
			count = count + 1
		end)

		unitTest:assertEquals(count, 2)

		count = 0
		cell = cs:sample()

		cell.v1 = 2
		cell.v2 = 3

		forEachAttribute(cell, function(idx, value)
			unitTest:assert(belong(idx, {"v1", "v2"}))
			unitTest:assert(value >= 2)
			unitTest:assert(value <= 3)
			count = count + 1
		end)

		unitTest:assertEquals(count, 2)
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
		r = forEachCell(cs, function()
			count = count + 1
			if count > 10 then return false end
		end)

		unitTest:assert(not r)
		unitTest:assertEquals(count, 11)

		a = Agent{}
		local soc = Society{instance = a, quantity = 20}
		env = Environment{cs, soc}
		env:createPlacement{strategy = "void", name = "workplace"}

		forEachAgent(soc, function(agent)
			agent.workplace:add(cs:sample())
			agent.workplace:add(cs:sample())
		end)

		r = 0

		forEachAgent(soc, function(agent)
			forEachCell(agent, "workplace", function()
				r = r + 1
			end)
		end)

		unitTest:assertEquals(r, 40)
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

		r = forEachConnection(s, function(ag2, w, ag1)
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
	forEachDirectory = function(unitTest)
		local count = 0
		local r

		r = forEachDirectory(packageInfo("base").path.."data", function(dir)
			count = count + 1
			unitTest:assertType(dir, "Directory")
		end)

		unitTest:assert(r)
		unitTest:assertEquals(count, 1)
	end,
	forEachFile = function(unitTest)
		local count = 0
		local r

		r = forEachFile(packageInfo("base").path.."data", function(file)
			count = count + 1
			unitTest:assertType(file, "File")
		end)

		unitTest:assert(r)
		unitTest:assertEquals(count, 32)

		count = 0

		r = forEachFile(packageInfo("base").path.."data", function()
			count = count + 1
			if count > 1 then return false end
		end)

		unitTest:assert(not r)
		unitTest:assertEquals(count, 2)
	end,
	forEachModel = function(unitTest)
		local MyTube = Model{
			water = 200,
			sun = Choice{min = 0, default = 10},
			init = function(model)
				model.finalTime = 100

				model.timer = Timer{
					Event{action = function() end}
				}
			end
		}

		local e = Environment{
			scenario0 = MyTube{},
			scenario1 = MyTube{water = 100},
			scenario2 = MyTube{water = 100, sun = 5},
			scenario3 = MyTube{water = 100, sun = 10}
		}

		local count = 0

		forEachModel(e, function(model, name)
			unitTest:assert(isModel(model))
			unitTest:assertType(name, "string")
			count = count + 1
		end)

		unitTest:assertEquals(count, 4)

		count = 0

		forEachModel(e, function()
			count = count + 1
			return false
		end)

		unitTest:assertEquals(count, 1)
	end,
	forEachNeighbor = function(unitTest)
		local cs = CellularSpace{xdim = 10}
		cs:createNeighborhood()

		local count = 0
		local c = cs.cells[1]
		local r

		r = forEachNeighbor(c, function(cell2, w, cell1)
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
	forEachNeighborAgent = function(unitTest)
		Random():reSeed(12345)
		local predator = Agent{}

		local predators = Society{
			instance = predator,
			quantity = 20
		}

		local cs = CellularSpace{xdim = 5}

		local env = Environment{cs, predators}
		env:createPlacement{}
		cs:createNeighborhood()

		local count = 0

		forEachNeighborAgent(predators:sample(), function()
			count = count + 1
		end)

		unitTest:assertEquals(count, 5)
	end,
	forEachNeighborhood = function(unitTest)
		local c1 = Cell{id = "1"}
		local c2 = Cell{id = "2"}
		local c3 = Cell{id = "3"}

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

		count = 0
		r = forEachNeighborhood(c1, function()
			count = count + 1
			return false
		end)

		unitTest:assert(not r)
		unitTest:assertEquals(count, 1)
	end,
	forEachOrderedElement = function(unitTest)
		local list = {aaB = "aaB", aAB = "aAB", aab = "aab", aAb = "aAb", aaBa = "aaBa", aa = "aa"}
		local result = {"aAB", "aAb", "aa", "aaB", "aaBa", "aab"}

		local count = 0
		local r
		r = forEachOrderedElement(list, function(idx, value, mtype)
			count = count + 1
			unitTest:assertEquals(mtype, type(result[count]))

			unitTest:assertEquals(idx, result[count])
			unitTest:assertEquals(value, result[count])
		end)

		unitTest:assert(r)
		unitTest:assertEquals(count, #result)

		list = {[1] = 1, [3] = 3, [2] = 2, a = "a", A = "A", b = "b", c = "c"}
		result = {1, 2, 3, "A", "a", "b", "c"}

		count = 0
		r = forEachOrderedElement(list, function(idx, value, mtype)
			count = count + 1
			unitTest:assertEquals(mtype, type(result[count]))

			unitTest:assertEquals(idx, result[count])
			unitTest:assertEquals(value, result[count])
		end)

		unitTest:assert(r)
		unitTest:assertEquals(count, #result)

		count = 0
		r = forEachOrderedElement(list, function()
			count = count + 1
			return false
		end)

		unitTest:assert(not r)
		unitTest:assertEquals(count, 1)

		list = {cObj = 1, cPbj = 2, cell = 3, cells = 4, cem = 5, value1 = 6, value2 = 7}
		result = {1, 2, 3, 4, 5, 6, 7}

		count = 0
		r = forEachOrderedElement(list, function(_, value, _)
			count = count + 1

			unitTest:assertEquals(value, result[count])
		end)

		unitTest:assert(r)
		unitTest:assertEquals(count, #result)

		local files = {
			["lua/Tube.lua"]    = 1,
			["lua/Tube2.lua"]   = 2,
			["lua/Utils.lua"]   = 3,
			["lua/Utils2m.lua"] = 4,
			["lua/Utilsm.lua"]  = 5,
			["lua/Utilsm2.lua"] = 6
		}

		count = 1

		forEachOrderedElement(files, function(_, value)
			unitTest:assertEquals(value, count)
			count = count + 1
		end)
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

		count = 0
		r = forEachSocialNetwork(a1, function()
			count = count + 1
			return false
		end)

		unitTest:assert(not r)
		unitTest:assertEquals(count, 1)
	end,
	getLuaFile = function(unitTest)
		local version = getLuaFile(packageInfo("base").path.."description.lua").version

		unitTest:assertType(version, "string")
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

		unitTest:assertEquals(getn(Cell{}), 5)
	end,
	getNames = function(unitTest)
		local t = {
			cover = "forest",
			area = 200,
			water = false
		}

		local result = getNames(t)

		unitTest:assertType(result, "table")
		unitTest:assertEquals(#result, 3)
		unitTest:assertEquals(result[1], "area")
		unitTest:assertEquals(result[3], "water")
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

		local warning_func = function()
			v = integrate{
				equation = f,
				initial = 0,
				a = 0,
				b = 3,
				step = 0.01,
				metod = 3
			}
		end
		unitTest:assertWarning(warning_func, unnecessaryArgumentMsg("metod", "method"))

		unitTest:assertEquals(20.11522, v, 0.0001)

		warning_func = function()
			v = integrate{
				equation = f,
				initial = 0,
				a = 0,
				b = 3,
				step = 0.001,
				method = "euler"
			}
		end
		unitTest:assertWarning(warning_func, defaultValueMsg("method", "euler"))

		unitTest:assertEquals(20.23650, v, 0.0001)

		v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			step = 0.0001
		}

		unitTest:assertEquals(20.24595, v, 0.0001)

		v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "rungekutta",
			step = 0.1
		}

		unitTest:assertEquals(17.682025, v, 0.0001)

		v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "rungekutta",
			step = 0.01
		}

		unitTest:assertEquals(20.25, v, 0.0001)

		v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "rungekutta",
			step = 0.001
		}

		unitTest:assertEquals(20.25, v, 0.0001)

		v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "rungekutta",
			step = 0.0001
		}

		unitTest:assertEquals(20.24730, v, 0.0001)

		v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "heun",
			step = 0.1
		}

		unitTest:assertEquals(17.70305, v, 0.0001)

		v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "heun",
			step = 0.01
		}

		unitTest:assertEquals(20.250225, v, 0.0001)

		v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "heun",
			step = 0.001
		}

		unitTest:assertEquals(20.25, v, 0.0001)

		v = integrate{
			equation = f,
			initial = 0,
			a = 0,
			b = 3,
			method = "heun",
			step = 0.0001
		}

		unitTest:assertEquals(20.24730, v, 0.0001)

		local df = function(x, y) return y - x ^ 2 + 1 end
		v = integrate{
			equation = df,
			initial = 0.5,
			a = 0,
			b = 2,
			method = "heun",
			step = 0.2
		}

		unitTest:assertEquals(5.23305, v, 0.0001)

		local eq1 = function(t)
			return t - 0.1
		end

		local event = Event{period = 2, priority = 1, action = function() end}

		v = integrate{
			equation = df,
			method = "heun",
			step = 0.2,
			initial = 0.5,
			event = event
		}

		unitTest:assertEquals(5.23305, v, 0.0001)

		v = integrate{
			equation = {eq1, eq1},
			initial = {0, 0},
			a = 0,
			b = 100,
			step = 0.1
		}

		unitTest:assertType(v, "number")

		v = integrate{
			equation = {eq1, eq1},
			method = "heun",
			initial = {0, 0},
			a = 0,
			b = 100,
			step = 0.1
		}

		unitTest:assertType(v, "number")

		v = integrate{
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

		local preyFunc = function(_, q)
			return q[1] * birthPreyRate - q[1] * q[2] * predationRate
		end

		local predatorFunc = function(_, q)
			return q[2] * q[1] * birthPredatorPerPreyRate - q[2] * deathPredatorRate
		end

		local ag = Agent{preys = 100, predators = 10}
		for _ = 0, 10, timeStep do
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
		for _ = 0, 10, timeStep do
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
		for _ = 0, 10, timeStep do
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
	isModel = function(unitTest)
		local M = Model{
			init = function(model)
				model.finalTime = 10
				model.timer = Timer{}
			end
		}

		unitTest:assert(not isModel(2))
		unitTest:assert(isModel(M))
		unitTest:assert(isModel(M{}))
	end,
	isTable = function(unitTest)
		local c = Cell{}

		unitTest:assert(isTable(c))
		unitTest:assert(isTable({2, 3}))
		unitTest:assert(not isTable(2))
	end,
	levenshtein = function(unitTest)
		unitTest:assertEquals(levenshtein("abv", "abc"), 1)
		unitTest:assertEquals(levenshtein("abvaacc", "abcaacac"), 2)
		unitTest:assertEquals(levenshtein("abvxwtaacc", "abcaacac"), 5)
		unitTest:assertEquals(levenshtein("abc", "n"), 3)
		unitTest:assertEquals(levenshtein("abcd", ""), 4)
	end,
	round = function(unitTest)
		unitTest:assertEquals(round(5.22), 5)
		unitTest:assertEquals(round(5.2235, 3), 5.224)
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

		switch(data, "att"):caseof{
			default = function() count = count + 1 end
		}

		unitTest:assertEquals(count, 2)
	end,
	type = function(unitTest)
		local c = Cell{}

		unitTest:assertEquals(type(c), "Cell")
	end,
	vardump = function(unitTest)
		local actual = vardump{}

		unitTest:assertEquals(actual, "{}")

		actual = vardump{a = 2, b = 3, w = {2, 3, [4] = 4}}

		unitTest:assertEquals(actual, [[{
    a = 2,
    b = 3,
    w = {
        2,
        3,
        [4] = 4
    }
}]])

		actual = vardump{abc = 2, be2 = 3, ["2bx"] = {2, 3, 4}}

		unitTest:assertEquals(actual, [[{
    ["2bx"] = {
        2,
        3,
        4
    },
    abc = 2,
    be2 = 3
}]])

		actual = vardump{name = "john", age = 20, [false] = 5}

		unitTest:assertEquals(actual, [[{
    [false] = 5,
    age = 20,
    name = "john"
}]])

		actual = "Phrase 1. \nPhrase 2."
		local expected = "\"Phrase 1. \\nPhrase 2.\""

		unitTest:assertEquals(vardump(actual), expected)

		actual = vardump{
			name = "john",
			age = 20,
			phrase = "Phrase 1. \nPhrase 2."
		}

		expected = [[{
    age = 20,
    name = "john",
    phrase = "Phrase 1. \nPhrase 2."
}]]

		unitTest:assertEquals(actual, expected, 1)

        local t = {x = true}

        local y = (vardump(t))

		unitTest:assertEquals(y, [[{
    x = true
}]])

		local cs = CellularSpace{xdim = 1}

        y = (vardump(cs))

		unitTest:assertEquals(y, [[CellularSpace{
    cObj_ = "TeCellularSpace(0x7fad0da0e840)",
    cells = {
        Cell{
            cObj_ = "TeCell(0x7fad0da19a00)",
            neighborhoods = {},
            parent = "CellularSpace",
            past = {},
            x = 0,
            y = 0
        }
    },
    load = "function: 0x7fad0a66aff0",
    source = "virtual",
    xMax = 0,
    xMin = 0,
    xdim = 1,
    yMax = 0,
    yMin = 0,
    ydim = 1
}]], 50)

		local tab = {
			a = 2,
			b = 3
		}

		tab.c = tab

		unitTest:assertEquals(vardump(tab), [[{
    a = 2,
    b = 3,
    c = "<copy of another table above>"
}]])

		tab = {}

		local tab2 = {
			tab,
			tab
		}

		unitTest:assertEquals(vardump(tab2), [[{
    {},
    "<copy of another table above>"
}]])
	end,
	forEachRecursiveDirectory = function(unitTest)
		local count = 0

		forEachRecursiveDirectory(packageInfo("base").path.."data", function(file)
			count = count + 1
			unitTest:assertType(file, "File")
		end)

		unitTest:assertEquals(count, 84)

		local dir = Directory(packageInfo("base").path.."data")
		count = 0

		forEachRecursiveDirectory(dir, function(file)
			count = count + 1
			unitTest:assertType(file, "File")
		end)

		unitTest:assertEquals(count, 84)
	end,
	replaceLatinCharacters = function(unitTest)
		local str = "action"
		unitTest:assertEquals(replaceLatinCharacters(str), "action")

		str = "ação"
		unitTest:assertEquals(replaceLatinCharacters(str), "a\xE7\xE3o")
	end
}

