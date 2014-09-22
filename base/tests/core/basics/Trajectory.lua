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
	Trajectory = function(unitTest)
		local cs = CellularSpace{
			xdim = 10,
			ydim = 10
		}

		local it = Trajectory{
			target = cs
		}

		local cont = 0
		forEachCell(cs, function(cell)
			cont = cont + 1
			unitTest:assert(cell.id == it.cells[cont].id)
		end)

		unitTest:assert_type(it, "Trajectory")
		unitTest:assert_nil(it.select)
		unitTest:assert_nil(it.greater)

		cont = 0
		unitTest:assert_equal(100, #it)
		forEachCell(it, function(cell)
			cont = cont + 1
			unitTest:assert_type(cell, "Cell")
		end)

		unitTest:assert_equal(100, cont)

		local tr = Trajectory{
			target = cs,
			build = false
		}

		unitTest:assert_equal(#tr, 0)

		local t = Trajectory{
			target = cs,
			select = function(c)
				if c.x > 7 and c.y > 5 then return true end
			end,
			greater = function(a, b)
				return a.y > b.y
			end
		}

		local cont = 0
		local orderMemory = 10

		forEachCell(t, function(cell)
			cont = cont + 1
			unitTest:assert_type(cell, "Cell")
			unitTest:assert(cell.x > 7)
			unitTest:assert(cell.y > 5)
			unitTest:assert(cell.y <= orderMemory)
			orderMemory = cell.y 
		end)
		unitTest:assert_equal(8, cont)

		-- Trajectory inside of another trajectory
		local cellSpace = CellularSpace{
			xdim = 5,
			ydim = 5
		}

		local cont = 1

		forEachCell(cellSpace, function(cell)
			cell.value = cont
			cont = cont + 1
		end)

		local trajectoryAll = Trajectory{
			target = cellSpace,
			select = function(cell)
				return cell.value > 10
			end
		}

		local trajectoryInner = Trajectory{
			target = trajectoryAll,
			select = function(cell)
				return cell.value < 15
			end
		}

		unitTest:assert_equal(#trajectoryAll, 15)
		unitTest:assert_equal(#trajectoryInner, 4)

		local resultInner = {11, 12, 13, 14}

		cont = 1
		forEachCell(trajectoryInner,function(cell)
			unitTest:assert_equal(cell.value,resultInner[cont])
			cont = cont + 1
		end)

		-- Inherited functions
		local c = Cell{
			k = 2,
			w = 4
		}

		local cs = CellularSpace{
			xdim = 5,
			ydim = 5,
			instance = c
		}

		t = Trajectory{
			target = cs,
			select = function(c) return c.x > 2 end
		}

		unitTest:assert(t:k() == 20)
		unitTest:assert(t:w() == 40)
	end,
	add = function(unitTest)
		local cs = CellularSpace{
			xdim = 10,
			ydim = 10
		}

		local it = Trajectory{
			target = cs,
			build = false
		}

		it:add(cs.cells[1])
		it:add(cs.cells[2])
		it:add(cs.cells[3])

		unitTest:assert(#it == 3)
		unitTest:assert(it.cells[1] == cs.cells[1])
		unitTest:assert(it.cells[2] == cs.cells[2])
		unitTest:assert(it.cells[3] == cs.cells[3])
	end,
	clone = function(unitTest)
		local cs = CellularSpace{
			xdim = 10,
			ydim = 10
		}

		local t = Trajectory{
			target = cs,
			select = function(c)
				if c.x > 7 and c.y > 5 then return true end
			end,
			greater = function(a, b)
				return a.y > b.y
			end
		}

		local t2 = t:clone()

		unitTest:assert(#t == #t2)
		unitTest:assert(t.select == t2.select)
		unitTest:assert(t.greater == t2.greater)
		unitTest:assert(t.parent == t2.parent)
		unitTest:assert(t.cells[1] == t2.cells[1])
	end,
	filter = function(unitTest)
		local cs = CellularSpace{
			xdim = 10,
			ydim = 10
		}

		local it = Trajectory{
			target = cs
		}

		it:filter(function(c)
			if c.x < 9 and c.x > 7 and c.y > 5 then return true end
		end)

		forEachCell(it, function(cell)
			unitTest:assert(cell.x < 9)
			unitTest:assert(cell.x > 7)
			unitTest:assert(cell.y > 5)
		end)
		unitTest:assert_equal(4, #it)
	end,
	get = function(unitTest)
		local cs = CellularSpace{
			xdim = 10,
			ydim = 10
		}

		local it = Trajectory{
			target = cs
		}

		unitTest:assert_equal(8, it:get(8, 9).x)
		unitTest:assert_equal(9, it:get(8, 9).y)
	end,
	randomize = function(unitTest)
		local cs = CellularSpace{
			xdim = 10,
			ydim = 10
		}

		local it = Trajectory{target = cs}

		it:randomize()

		forEachCell(it, function(cell)
			unitTest:assert_type(cell, "Cell")
		end)

		unitTest:assert_equal(100, #it)
	end,
	sort = function(unitTest)
		local cs = CellularSpace{
			xdim = 10,
			ydim = 10
		}

		local it = Trajectory{
			target = cs
		}

		it:sort(function(a, b)
			return a.y > b.y
		end)

		local orderMemory = 10e10
		forEachCell(it, function(cell)
			unitTest:assert(cell.y <= orderMemory)
			orderMemory = cell.y
		end)

		local xMemory = 0
		local yMemory = 0
		local cont = 0
		it:sort(greaterByCoord("<"))
		forEachCell(it, function(cell)
			unitTest:assert(cell.x >= xMemory)
			if cell.x == xMemory then
				unitTest:assert(cell.y >= yMemory)
			end
			xMemory = cell.x
			yMemory = cell.y
			cont = cont + 1
		end)
		unitTest:assert_equal(100, cont)
	end,
	rebuild = function(unitTest) 
		local cs = CellularSpace{
			xdim = 5,
			ydim = 5
		}

		forEachCell(cs, function(cell)
			cell.value = math.random(12)
		end)

		local g = function(a, b)
			return a.value > b.value
		end

		local s = function(cell)
			return cell.value > 5
		end

		local tr = Trajectory{
			target = cs,
			greater = g,
			select = s
		}

		unitTest:assert_equal(tr.parent, cs)
		unitTest:assert_equal(tr.select, s)
		unitTest:assert_equal(tr.greater, g)
		unitTest:assert_equal(#tr, 15)

		forEachCell(cs, function(cell)
			cell.value = cell.value + 10
		end)

		tr:rebuild()

		unitTest:assert_equal(tr.parent, cs)
		unitTest:assert_equal(tr.select, s)
		unitTest:assert_equal(tr.greater, g)
		unitTest:assert_equal(#tr, 25)

		tr.select = function(cell)
			return cell.x > 2
		end

		unitTest:assert_equal(#tr, 25)

		tr:rebuild()
		forEachCell(tr, function(cell)
			unitTest:assert(cell.x > 2)
		end)

		unitTest:assert_equal(#tr, 10)
	end,
	__len = function(unitTest)
		local cs1 = CellularSpace{
			xdim = 10,
			ydim = 20
		}

		local tr1 = Trajectory{
			target = cs1
		}
		unitTest:assert(#tr1, 200)
	end,
	__tostring = function(unitTest)
		local cs1 = CellularSpace{
			xdim = 10,
			ydim = 20,
			xyz = function() end,
			vvv = 333}

		local tr1 = Trajectory{
			target = cs1,
			select = function() return true end
		}
		unitTest:assert_equal(tostring(tr1), [[cells   table of size 200
cObj_   userdata
load    function
parent  CellularSpace
select  function
xyz     function
]])
	end
}

