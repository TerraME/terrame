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
		local bern = Random{p = 0.3}

		unitTest:assertEquals(tostring(bern), [[distrib  string [bernoulli]
p        number [0.3]
random   Random
sample   function
]])
	end,
	integer = function(self)
		local randomObj = Random{}
		randomObj:reSeed(123456)
		for _ = 1, 10 do
			local v = randomObj:integer()
			self:assert(v >= 0)
			self:assert(v <= 1)
		end

		randomObj = Random{}
		randomObj:reSeed(12345)
		for _ = 1, 10 do
			local v = randomObj:integer(10)
			self:assert(v <= 10)
			self:assert(v >= 0)
		end

		randomObj = Random{}
		randomObj:reSeed(12345)
		for _ = 1, 10 do
			local v = randomObj:integer(-10)
			self:assert(v <= 0)
			self:assert(v >= -10)
		end

		randomObj = Random{}
		randomObj:reSeed(12345)
		for _ = 1, 10 do
			local v = randomObj:integer(10, 20)
			self:assert(v <= 20)
			self:assert(v >= 10)
		end

		randomObj = Random{}
		randomObj:reSeed(12345)
		for _ = 1, 10 do
			local v = randomObj:integer(10, 10)
			self:assertEquals(v, 10)
		end

		randomObj = Random{}
		randomObj:reSeed(12345)
		for _ = 1, 10 do
			local v = randomObj:integer(-10, 10)
			self:assert(v <= 10)
			self:assert(v >= -10)
		end

		randomObj = Random{}
		randomObj:reSeed(12345)
		for _ = 1, 10 do
			local v = randomObj:integer(-10, -10)
			self:assertEquals(v, -10)
		end

		randomObj = Random{}
		randomObj:reSeed()
		for _ = 1, 10 do
			local v = randomObj:integer(10)
			self:assert(v <= 10)
			self:assert(v >= 0)
		end
	end,
	number = function(self)
		local randomObj = Random{}
		randomObj:reSeed(12345)
		for _ = 1, 10 do
			local v = randomObj:number()
			self:assert(v >= 0)
			self:assert(v <= 1)
		end

		self:assertEquals(randomObj:number(), 0.517326)

		randomObj = Random{}
		randomObj:reSeed(54321)
		for _ = 1, 10 do
			local v = randomObj:number(10.1)
			self:assert(v >= 0)
			self:assert(v <= 10.1)
		end

		randomObj = Random{}
		randomObj:reSeed(54321)
		for _ = 1, 10 do
			local v = randomObj:number(-10.1)
			self:assert(v <= 0)
			self:assert(v >= -10.1)
		end

		randomObj = Random{}
		randomObj:reSeed(12345)
		for _ = 1, 10 do
			local v = randomObj:number(10.1, 20.2)
			self:assert(v <= 20.2)
			self:assert(v >= 10.1)
		end

		randomObj = Random{}
		randomObj:reSeed(12345)
		for _ = 1, 10 do
			local v = randomObj:number(10.1, 10.1)
			self:assertEquals(v, 10.1)
		end

		randomObj = Random{}
		randomObj:reSeed(12345)
		for _ = 1, 10 do
			local v = randomObj:number(-10.1, 10.1)
			self:assert(v <= 10.1)
			self:assert(v >= -10.1)
		end

		randomObj = Random{}
		randomObj:reSeed(12345)
		for _ = 1, 10 do
			local v = randomObj:number(-10.1, -10.1)
			self:assertEquals(v, -10.1)
		end

		randomObj = Random{}
		randomObj:reSeed(12345)
		for _ = 1, 10 do
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
		local bern = Random{p = 0.3}
		local counter = 0

		unitTest:assertType(bern:sample(), "boolean")

		for _ = 1, 1000 do
			if bern:sample() then
				counter = counter + 1
			end
		end

		unitTest:assertEquals(counter, 301)

		local continuous = Random{min = 0, max = 10}
		local sum = 0

		unitTest:assertType(continuous:sample(), "number")

		for _ = 1, 1000 do
			local sample = continuous:sample()
			sum = sum + sample
			unitTest:assert(sample <= 10)
			unitTest:assert(sample >= 0)
		end

		unitTest:assertEquals(sum, 5140.55, 0.01)

		local discrete = Random{1, 2, 5, 6}
		sum = 0

		unitTest:assertType(discrete:sample(), "number")

		for _ = 1, 1000 do
			local sample = discrete:sample()
			sum = sum + sample
			unitTest:assert(sample <= 6)
			unitTest:assert(sample >= 1)
		end

		unitTest:assertEquals(sum, 3634)

		discrete = Random{"a", "b", "c"}
		sum = {
			a = 0,
			b = 0,
			c = 0
		}

		unitTest:assertType(discrete:sample(), "string")

		for _ = 1, 200 do
			local sample= discrete:sample()
			sum[sample] = sum[sample] + 1
		end

		unitTest:assertEquals(sum.a, 64)
		unitTest:assertEquals(sum.b, 72)
		unitTest:assertEquals(sum.c, 64)

		local step = Random{min = 1, max = 4, step = 1}
		sum = {0, 0, 0, 0}

		unitTest:assertType(step:sample(), "number")

		for _ = 1, 200 do
			local sample = step:sample()
			sum[sample] = sum[sample] + 1
		end

		unitTest:assertEquals(sum[1], 54)
		unitTest:assertEquals(sum[2], 41)
		unitTest:assertEquals(sum[3], 53)
		unitTest:assertEquals(sum[4], 52)

		local cat = Random{poor = 0.5, middle = 0.33, rich = 0.17}
		sum = {
			poor = 0,
			middle = 0,
			rich = 0
		}

		unitTest:assertType(cat:sample(), "string")

		for _ = 1, 200 do
			local sample = cat:sample()
			sum[sample] = sum[sample] + 1
		end

		unitTest:assertEquals(sum.poor, 106)
		unitTest:assertEquals(sum.middle, 60)
		unitTest:assertEquals(sum.rich, 34)

		cat = Random{poor = 0.5, middle = 0.33, rich = 0.1700001}

		unitTest:assertEquals(cat:sample(), "middle")
		unitTest:assertEquals(cat:sample(), "poor")
		unitTest:assertEquals(cat:sample(), "middle")
		unitTest:assertEquals(cat:sample(), "poor")

		local normal = Random{mean = 0, sd = 2}
		sum = 0

		unitTest:assertType(normal:sample(), "number")

		for _ = 1, 1000 do
			local sample = normal:sample()
			sum = sum + sample
			unitTest:assert(sample <= 7)
			unitTest:assert(sample >= -7)

			if sample > 7 or sample < -7 then print(sample) end
		end

		unitTest:assertEquals(sum / 1000, 0, 0.02)

		local lognormal = Random{distrib = "lognormal", mean = 0, sd = 2}
		sum = 0

		unitTest:assertType(lognormal:sample(), "number")

		for _ = 1, 1000 do
			local sample = lognormal:sample()
			sum = sum + sample
			unitTest:assert(sample <= 280)
			unitTest:assert(sample >= 0)

			if sample > 280 or sample < 0 then print(sample) end
		end

		unitTest:assertEquals(sum / 1000, 5.26, 0.04)

		local poisson = Random{lambda = 4}
		sum = 0

		unitTest:assertType(poisson:sample(), "number")

		for _ = 1, 5000 do
			local sample = poisson:sample()
			sum = sum + sample
			unitTest:assert(sample <= 15)
			unitTest:assert(sample >= 0)

			if sample > 15 or sample < 0 then print(sample) end
		end

		unitTest:assertEquals(sum / 5000, 4, 0.02)

		local exponential = Random{distrib = "exponential"}
		sum = 0

		unitTest:assertType(exponential:sample(), "number")

		for _ = 1, 5000 do
			local sample = exponential:sample()
			sum = sum + sample
			unitTest:assert(sample <= 15)
			unitTest:assert(sample >= 0)

			if sample > 15 or sample < 0 then print(sample) end
		end

		unitTest:assertEquals(sum / 5000, 1, 0.02)

		local logistic = Random{scale = 2}
		sum = 0

		unitTest:assertType(logistic:sample(), "number")

		for _ = 1, 5000 do
			local sample = logistic:sample()
			sum = sum + sample
			unitTest:assert(sample <= 17)
			unitTest:assert(sample >= -15)

			if sample > 17 or sample < -15 then print(sample) end
		end

		unitTest:assertEquals(sum / 5000, 1, 0.04)

		local power = Random{min = 0, max = 10, lambda = 2}
		sum = 0

		unitTest:assertType(power:sample(), "number")

		for _ = 1, 5000 do
			local sample = power:sample()
			sum = sum + sample
			unitTest:assert(sample <= 10)
			unitTest:assert(sample >= 0)

			if sample > 10 or sample < 0 then print(sample) end
		end

		unitTest:assertEquals(sum / 5000, 7.5, 0.02)
	end
}

