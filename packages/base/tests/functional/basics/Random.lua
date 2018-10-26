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

local TestDistributions = Model{
	finalTime = 1000,
	distribution = Choice{"exponential", "normal", "lognormal", "beta"},
	beta = function()
		return Random{distrib = "beta"}
	end,
	exponential = function()
		return Random{distrib = "exponential"}
	end,
	normal = function()
		return Random{distrib = "normal", mean = 0}
	end,
	lognormal = function()
		return Random{distrib = "lognormal", sd = 0.5}
	end,
	init = function(model)
		Random{seed = 10}
		model.data = {}
		model.expected = {}
		model.random = model[model.distribution](model)
		local file = filePath("test/"..model.distribution.."_data.csv")
		model.csv = file:read()
		model.timer = Timer{
			Event{action = function()
				table.insert(model.data, model.random:sample())
				table.insert(model.expected, model.csv[model.timer:getTime()].x)
			end}
		}
	end,
	mean = function(_, data)
		local s = 0
		for _, v in pairs(data) do
			s = s + v
		end

		return s / #data
	end,
	sd = function(self, data)
		local mean = self:mean(data)
		local sd = 0
		for i = 1, #data do
			sd = sd + (math.pow(data[i] - mean, 2)) / (#data - 1)
		end

		return math.sqrt(sd)
	end,
	meanSquaredError = function(_, data1, data2)
		local sortedData1 = {}
		for _, v in pairs(data1) do
			table.insert(sortedData1, v)
		end

		table.sort(sortedData1)

		local sortedData2 = {}
		for _, v in pairs(data2) do
			table.insert(sortedData2, v)
		end

		table.sort(sortedData2)

		local mse = 0
		for i = 1, #data1 do
			mse = mse + math.pow(sortedData1[i] - sortedData2[i], 2)
		end

		return mse / #data1
	end
}

return {
	Random = function(unitTest)
		local r = Random()
		unitTest:assertEquals(type(r), "Random")
		unitTest:assertEquals(type(r:integer()), "number")
		unitTest:assertEquals(type(r:number()), "number")

		local warning_func = function()
			r = Random{lambda = 1}
		end
		unitTest:assertWarning(warning_func, defaultValueMsg("lambda", 1))
		unitTest:assertEquals(type(r), "Random")
		unitTest:assertEquals(type(r:integer()), "number")
		unitTest:assertEquals(type(r:number()), "number")

		warning_func = function()
			r = Random{mean = 0.5, sd = 0.5, abc = 2}
		end
		unitTest:assertWarning(warning_func, unnecessaryArgumentMsg("abc"))
		unitTest:assertEquals(type(r), "Random")
		unitTest:assertEquals(type(r:integer()), "number")
		unitTest:assertEquals(type(r:number()), "number")

		warning_func = function()
			r = Random{p = 0.3, w = 2}
		end
		unitTest:assertWarning(warning_func, unnecessaryArgumentMsg("w"))
		unitTest:assertEquals(type(r), "Random")
		unitTest:assertEquals(type(r:integer()), "number")
		unitTest:assertEquals(type(r:number()), "number")

		warning_func = function()
			r = Random{min = 2, max = 5, w = 2}
		end
		unitTest:assertWarning(warning_func, unnecessaryArgumentMsg("w"))
		unitTest:assertEquals(type(r), "Random")
		unitTest:assertEquals(type(r:integer()), "number")
		unitTest:assertEquals(type(r:number()), "number")

		warning_func = function()
			Random{mean = 0.5, sd = 1}
		end
		unitTest:assertWarning(warning_func, defaultValueMsg("sd", 1))
		unitTest:assertEquals(type(r), "Random")
		unitTest:assertEquals(type(r:integer()), "number")
		unitTest:assertEquals(type(r:number()), "number")

		warning_func = function()
			Random{mean = 1, sd = 0.5}
		end
		unitTest:assertWarning(warning_func, defaultValueMsg("mean", 1))
		unitTest:assertEquals(type(r), "Random")
		unitTest:assertEquals(type(r:integer()), "number")
		unitTest:assertEquals(type(r:number()), "number")

		Random_.cObj_ = nil
		r = Random()
		unitTest:assertEquals(type(r:integer()), "number")
		unitTest:assertEquals(type(r:number()), "number")

		Random{seed = 1}

		local nd = Random{min = 1, max = 6}
		local v1 = nd:sample()
		local v2 = nd:sample()
		local v3 = nd:sample()

		nd = Random{min = 1, max = 6}
		unitTest:assert(v1 ~= nd:sample())
		unitTest:assert(v2 ~= nd:sample())
		unitTest:assert(v3 ~= nd:sample())

		Random{seed = 1}

		nd = Random{min = 1, max = 6}
		unitTest:assertEquals(v1, nd:sample())
		unitTest:assertEquals(v2, nd:sample())
		unitTest:assertEquals(v3, nd:sample())

		local modelNormal = TestDistributions{distribution = "normal"}
		modelNormal:run()
		unitTest:assertEquals(modelNormal:mean(modelNormal.data), modelNormal:mean(modelNormal.expected), 0.03)
		unitTest:assertEquals(modelNormal:sd(modelNormal.data), modelNormal:sd(modelNormal.expected), 0.03)
		unitTest:assertEquals(modelNormal:meanSquaredError(modelNormal.data, modelNormal.expected), 0, 0.03)

		local modelExponential = TestDistributions{distribution = "exponential"}
		modelExponential:run()
		unitTest:assertEquals(modelExponential:mean(modelExponential.data), modelExponential:mean(modelExponential.expected), 0.12)
		unitTest:assertEquals(modelExponential:sd(modelExponential.data), modelExponential:sd(modelExponential.expected), 0.1)
		unitTest:assertEquals(modelExponential:meanSquaredError(modelExponential.data, modelExponential.expected), 0, 0.03)

		-- Need revision: Seems lognormal does not work properly for some parameters.
		local modelLognormal = TestDistributions{distribution = "lognormal"}
		modelLognormal:run()
		unitTest:assertEquals(modelLognormal:mean(modelLognormal.data), modelLognormal:mean(modelLognormal.expected), 0.15)
		unitTest:assertEquals(modelLognormal:sd(modelLognormal.data), modelLognormal:sd(modelLognormal.expected), 0.11)
		unitTest:assertEquals(modelLognormal:meanSquaredError(modelLognormal.data, modelLognormal.expected), 0, 0.05)

		local modelBeta = TestDistributions{distribution = "beta"}
		modelBeta:run()
		unitTest:assertEquals(modelBeta:mean(modelBeta.data), modelBeta:mean(modelBeta.expected), 0.02)
		unitTest:assertEquals(modelBeta:sd(modelBeta.data), modelBeta:sd(modelBeta.expected), 0.02)
		unitTest:assertEquals(modelBeta:meanSquaredError(modelBeta.data, modelBeta.expected), 0, 0.02)
	end,
	__tostring = function(unitTest)
		local bern = Random{p = 0.3}

		unitTest:assertEquals(tostring(bern), [[distrib  string [bernoulli]
p        number [0.3]
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

		self:assertEquals(randomObj:number(), 0.9563, 0.001)

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
		self:assertEquals(randomObj:integer(3), 1)
		self:assertEquals(randomObj:integer(3), 0)
		self:assertEquals(randomObj:integer(3), 3)
		self:assertEquals(randomObj:integer(3), 1)
		self:assertEquals(randomObj:integer(3), 1)

		randomObj:reSeed(987654321)
		self:assertEquals(randomObj:integer(33, 45), 36)
		self:assertEquals(randomObj:integer(33, 45), 35)
		self:assertEquals(randomObj:integer(33, 45), 42)
		self:assertEquals(randomObj:integer(33, 45), 39)

		randomObj:reSeed(567890123)

		self:assertEquals(randomObj:integer(3), 0)
		self:assertEquals(randomObj:integer(3), 3)
		self:assertEquals(randomObj:integer(3), 0)
		self:assertEquals(randomObj:integer(3), 3)
		self:assertEquals(randomObj:integer(3), 1)
		self:assertEquals(randomObj:integer(3), 3)
		self:assertEquals(randomObj:integer(3), 1)
		self:assertEquals(randomObj:integer(3), 1)
		self:assertEquals(randomObj:integer(3), 0)

		self:assertEquals(randomObj:integer(33, 45), 45)
		self:assertEquals(randomObj:integer(33, 45), 36)
		self:assertEquals(randomObj:integer(33, 45), 43)
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

		unitTest:assertEquals(counter, 307) -- exact average: 300

		local continuous = Random{min = 0, max = 10}
		local sum = 0

		unitTest:assertType(continuous:sample(), "number")

		for _ = 1, 1000 do
			local sample = continuous:sample()
			sum = sum + sample
			unitTest:assert(sample <= 10)
			unitTest:assert(sample >= 0)
		end

		unitTest:assertEquals(sum, 4874.248, 0.01) -- exact average: 5000

		local discrete = Random{1, 2, 5, 6}
		sum = 0

		unitTest:assertType(discrete:sample(), "number")

		for _ = 1, 1000 do
			local sample = discrete:sample()
			sum = sum + sample
			unitTest:assert(sample <= 6)
			unitTest:assert(sample >= 1)
		end

		unitTest:assertEquals(sum, 3419)

		discrete = Random{"a", "b", "c"}
		sum = {
			a = 0,
			b = 0,
			c = 0
		}

		unitTest:assertType(discrete:sample(), "string")

		for _ = 1, 2000 do
			local sample= discrete:sample()
			sum[sample] = sum[sample] + 1
		end

		unitTest:assertEquals(sum.a, 653)
		unitTest:assertEquals(sum.b, 685)
		unitTest:assertEquals(sum.c, 662)

		local step = Random{min = 1, max = 4, step = 1}
		sum = {0, 0, 0, 0}

		unitTest:assertType(step:sample(), "number")

		for _ = 1, 2000 do
			local sample = step:sample()
			sum[sample] = sum[sample] + 1
		end

		unitTest:assertEquals(sum[1], 487)
		unitTest:assertEquals(sum[2], 494)
		unitTest:assertEquals(sum[3], 535)
		unitTest:assertEquals(sum[4], 484)

		local cat = Random{poor = 0.5, middle = 0.33, rich = 0.17, none = 0}
		sum = {
			poor = 0,
			middle = 0,
			rich = 0
		}

		unitTest:assertEquals(#cat.values, 4)
		unitTest:assertType(cat:sample(), "string")

		for _ = 1, 2000 do
			local sample = cat:sample()
			sum[sample] = sum[sample] + 1
		end

		unitTest:assertEquals(sum.poor, 1026)
		unitTest:assertEquals(sum.middle, 643)
		unitTest:assertEquals(sum.rich, 331)

		cat = Random{poor = 0.5, middle = 0.33, rich = 0.1700001}

		unitTest:assertEquals(cat:sample(), "poor")
		unitTest:assertEquals(cat:sample(), "poor")
		unitTest:assertEquals(cat:sample(), "poor")
		unitTest:assertEquals(cat:sample(), "poor")
		unitTest:assertEquals(cat:sample(), "middle")
		unitTest:assertEquals(cat:sample(), "rich")
		unitTest:assertEquals(cat:sample(), "poor")
		unitTest:assertEquals(cat:sample(), "rich")
		unitTest:assertEquals(cat:sample(), "middle")

		local normal = Random{mean = 0, sd = 2}
		sum = 0

		unitTest:assertType(normal:sample(), "number")

		for _ = 1, 5000 do
			local sample = normal:sample()
			sum = sum + sample
			unitTest:assert(sample <= 8)
			unitTest:assert(sample >= -8)

			if sample > 8 or sample < -8 then print(sample) end
		end

		unitTest:assertEquals(sum / 5000, 0, 0.02)

		local lognormal = Random{distrib = "lognormal", sd = 2}
		sum = 0

		unitTest:assertType(lognormal:sample(), "number")

		for _ = 1, 5000 do
			local sample = lognormal:sample()
			sum = sum + sample

			unitTest:assert(sample <= 45)
			unitTest:assert(sample >= 0)

			if sample > 45 or sample < 0 then print(sample) end
		end

		unitTest:assertEquals(sum / 5000, 0.99826, 0.0001)

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

		unitTest:assertEquals(sum / 5000, 3.96, 0.01)

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

		unitTest:assertEquals(sum / 5000, 1.0032177891723, 1e-13)

		local weibull = Random{lambda = 2, k = 2}
		sum = 0

		unitTest:assertType(weibull:sample(), "number")

		for _ = 1, 5000 do
			local sample = weibull:sample()
			sum = sum + sample
			unitTest:assert(sample <= 10)
			unitTest:assert(sample >= 0)
		end

		unitTest:assertEquals(sum / 5000, 1.7522, 0.001)

		local beta = Random{alpha = 2, beta = 2}
		sum = 0

		unitTest:assertType(beta:sample(), "number")

		for _ = 1, 5000 do
			local sample = beta:sample()
			sum = sum + sample
			unitTest:assert(sample <= 15)
			unitTest:assert(sample >= 0)
		end

		unitTest:assertEquals(sum / 5000, 0.496, 0.001)
	end
}

