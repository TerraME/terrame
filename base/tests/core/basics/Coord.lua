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
	Coord = function(self)
		local coord1 = Coord()
		self:assert_equal(0, coord1:get().x)	
		self:assert_equal(0, coord1:get().y)
		self:assert_nil(coord1.x)-- to read Coord attributes, use Coord::get()
		self:assert_nil(coord1.y) -- to write Coord attributes, use Coord::set({x = 0, y = 0})

		-- test the Coord type
		local c = Coord{x = 0, y = 99}
		local cOut = c:get()
		self:assert_equal(0, cOut.x)
		self:assert_equal(99,cOut.y)
		self:assert_nil(c.x)
		self:assert_nil(c.y)
		c.x = 10
		c.y = 10

		cOut = c:get()
		self:assert_equal(cOut.x, 0)
		self:assert_equal(cOut.y, 99) 
		c:set({x = 10, y = 10})
		cOut = c:get()
		self:assert_equal(10, cOut.x)
		self:assert_equal(10, cOut.y)	
	end,
	getX = function(unitTest)
		local coord = Coord{x = 10, y = 11}
		unitTest:assert_equal(10, coord:getX())
	end,
	getY = function(unitTest)
		local coord = Coord{x = 10, y = 11}
		unitTest:assert_equal(11, coord:getY())
	end,
	setX = function(unitTest)
		local coord = Coord{x = 10, y = 11}
		coord:setX(12)
		unitTest:assert_equal(12, coord:getX())
	end,
	setY = function(unitTest)
		local coord = Coord{x = 10, y = 11}
		coord:setY(12)
		unitTest:assert_equal(12, coord:getY())
	end,
	__tostring = function(unitTest)
		local c = Coord {x = 1, y = 1}
		unitTest:assert_equal(tostring(c), "cObj_  userdata\n")
	end
}

