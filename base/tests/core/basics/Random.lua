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
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

return {
	Random = function(self)
		local r = Random()
		self:assertEquals(type(r), "Random")
		self:assertEquals(type(r:integer()), "number")
		self:assertEquals(type(r:number()), "number")

		Random_.cObj_ = nil
		r = Random()
		self:assertEquals(type(r:integer()), "number")
		self:assertEquals(type(r:number()), "number")
	end,
	__tostring = function(unitTest)
		local randomObj = Random{seed = 12345}
		unitTest:assertEquals(tostring(randomObj), "")
	end,
	integer = function(self)
		local randomObj = Random{}
		randomObj:reSeed(123456)
		for i = 1, 10 do
			local v = randomObj:integer()
			self:assert(v >= 0)
			self:assert(v <= 1)
		end

		randomObj = Random{}
		randomObj:reSeed(12345)
		for i = 1, 10 do
			local v = randomObj:integer(10)
			self:assert(v <= 10)
			self:assert(v >= 0)
		end

		local randomObj = Random{}
		randomObj:reSeed(12345)
		for i = 1, 10 do
			local v = randomObj:integer(-10)
			self:assert(v <= 0)
			self:assert(v >= -10)
		end

		local randomObj = Random{}
		randomObj:reSeed(12345)
		for i = 1, 10 do
			local v = randomObj:integer(10, 20)
			self:assert(v <= 20)
			self:assert(v >= 10)
		end

		local randomObj = Random{}
		randomObj:reSeed(12345)
		for i = 1, 10 do
			local v = randomObj:integer(10, 10)
			self:assertEquals(v, 10)
		end

		local randomObj = Random{}
		randomObj:reSeed(12345)
		for i = 1, 10 do
			local v = randomObj:integer(-10, 10)
			self:assert(v <= 10)
			self:assert(v >= -10)
		end

		local randomObj = Random{}
		randomObj:reSeed(12345)
		for i = 1, 10 do
			local v = randomObj:integer(-10, -10)
			self:assertEquals(v, -10)
		end

		randomObj = Random{}
		randomObj:reSeed()
		for i = 1, 10 do
			local v = randomObj:integer(10)
			self:assert(v <= 10)
			self:assert(v >= 0)
		end
	end,
	number = function(self)
		local randomObj = Random{}
		randomObj:reSeed(12345)
		for i = 1, 10 do
			local v = randomObj:number()
			self:assert(v >= 0)
			self:assert(v <= 1)
		end

		self:assertEquals(randomObj:number(), 0.517326)

		local randomObj = Random{}
		randomObj:reSeed(54321)
		for i = 1, 10 do
			local v = randomObj:number(10.1)
			self:assert(v >= 0)
			self:assert(v <= 10.1)
		end

		local randomObj = Random{}
		randomObj:reSeed(54321)
		for i = 1, 10 do
			local v = randomObj:number(-10.1)
			self:assert(v <= 0)
			self:assert(v >= -10.1)
		end

		local randomObj = Random{}
		randomObj:reSeed(12345)
		for i = 1, 10 do
			local v = randomObj:number(10.1, 20.2)
			self:assert(v <= 20.2)
			self:assert(v >= 10.1)
		end

		local randomObj = Random{}
		randomObj:reSeed(12345)
		for i = 1, 10 do
			local v = randomObj:number(10.1, 10.1)
			self:assertEquals(v, 10.1)
		end

		local randomObj = Random{}
		randomObj:reSeed(12345)
		for i = 1, 10 do
			local v = randomObj:number(-10.1, 10.1)
			self:assert(v <= 10.1)
			self:assert(v >= -10.1)
		end

		randomObj = Random{}
		randomObj:reSeed(12345)
		for i = 1, 10 do
			local v = randomObj:number(-10.1, -10.1)
			self:assertEquals(v, -10.1)
		end

		randomObj = Random{}
		randomObj:reSeed(12345)
		for i = 1, 10 do
			local v = randomObj:number(10.1, -10.1)
			self:assert(v <= 10.1)
			self:assert(v >= -10.1)
		end
	end,
	reSeed = function(self)
		local randomObj = Random{}
		randomObj:reSeed(987654321)
		self:assertEquals(randomObj:integer(3), 3)
		self:assertEquals(randomObj:integer(3), 0)
		self:assertEquals(randomObj:integer(3), 3)
		self:assertEquals(randomObj:integer(3), 1)
		self:assertEquals(randomObj:integer(3), 2)

		randomObj:reSeed(987654321)
		self:assertEquals(randomObj:integer(33, 45), 33)
		self:assertEquals(randomObj:integer(33, 45), 44)
		self:assertEquals(randomObj:integer(33, 45), 38)

		randomObj:reSeed(567890123)

		self:assertEquals(randomObj:integer(3), 1)
		self:assertEquals(randomObj:integer(3), 3)
		self:assertEquals(randomObj:integer(3), 3)
		self:assertEquals(randomObj:integer(3), 0)
		self:assertEquals(randomObj:integer(3), 3)
		self:assertEquals(randomObj:integer(3), 1)
		self:assertEquals(randomObj:integer(3), 1)
		self:assertEquals(randomObj:integer(3), 1)
		self:assertEquals(randomObj:integer(3), 0)

		self:assertEquals(randomObj:integer(33, 45), 33)
		self:assertEquals(randomObj:integer(33, 45), 37)
		self:assertEquals(randomObj:integer(33, 45), 34)

		randomObj = Random{seed = 10}
		self:assertEquals(10, Random_.seed[2])
		randomObj:reSeed(12345)
		self:assertEquals(Random_.seed[2], 12345)
	end,
	sample = function(unitTest)
		local r = Random{seed = 123456789}

		local vector = {1, 4, 5, 6}

		unitTest:assertEquals(r:sample(vector), 4)
		unitTest:assertEquals(r:sample(vector), 5)

		r:reSeed(567890123)
		vector = {"a", "b", "c"}
		unitTest:assertEquals(r:sample(vector), "b")
		unitTest:assertEquals(r:sample(vector), "a")
		unitTest:assertEquals(r:sample(vector), "b")
		unitTest:assertEquals(r:sample(vector), "c")
		unitTest:assertEquals(r:sample(vector), "c")
		unitTest:assertEquals(r:sample(vector), "a")
	end
}

