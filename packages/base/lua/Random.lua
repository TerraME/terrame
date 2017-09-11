-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.

-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this software and its documentation.
--
-------------------------------------------------------------------------------------------

local MersenneTwister
local UniformReal
local TerraLib = getPackage("gis").TerraLib

local function getMT()
	MersenneTwister()
	return MersenneTwister
end

local function categorical(values)
	local str = "return function(number)\n"

	forEachOrderedElement(values, function(idx, value)
		str = str.."\tif number <= "..value.." then\n"
		         .."\t\treturn \""..idx.."\"\n"
		         .."\tend\n"
	end)

	str = str.."end"
	return load(str)()
end

Random_ = {
	type_ = "Random",
	--- Return an integer random number. It uses a discrete uniform distribution.
	-- @arg v1 An integer number. If abscent, integer() will return zero or one.
	-- If it is the only argument, it will return a number between zero and this value.
	-- @arg v2 An integer number. When used, integer() will return a number between the first
	-- argument and the second, inclusive.
	-- @usage random = Random()
	--
	-- value = random:integer() -- 0 or 1
	-- value = random:integer(10) -- from 0 to 10
	-- value = random:integer(5, 10) -- from 5 to 10
	integer = function(self, v1, v2)
		optionalArgument(0, "Random", self)
		optionalArgument(1, "number", v1)
		optionalArgument(2, "number", v2)

		if v2 then
			integerArgument(2, v2)
			if v1 and v2 >= v1 then
				integerArgument(1, v1)
			else
				customError("It is not possible to sample from an empty object.")
			end
		elseif v1 then
			integerArgument(1, v1)
			if v1 < 0 then
				v2 = 0
			else
				v2 = v1
				v1 = 0
			end
		else
			v1 = 0
			v2 = 1
		end

		v1 = math.floor(v1)
		v2 = math.floor(v2)

		if not UniformReal then
			UniformReal = TerraLib().random().UniformRealDistribution(getMT(), 0, 1)
		end

		return math.floor(v1 + UniformReal() * (v2 - v1 + 1))
	end,
	--- Return a random real number.
	--  By default number() will return a value between zero and one.
	-- @arg v1 A number.
	-- If it is the only argument used, it will return a number from zero to this value.
	-- @arg v2 A number. When used, number() will return a number between the first argument
	-- and the second.
	-- @usage random = Random()
	--
	-- value = random:number() -- between 0 and 1
	-- value = random:number(10) -- between 0 and 10
	-- value = random:number(5, 10) -- between 5 and 10
	number = function(self, v1, v2)
		optionalArgument(0, "Random", self)
		optionalArgument(1, "number", v1)
		optionalArgument(2, "number", v2)

		if not UniformReal then
			UniformReal = TerraLib().random().UniformRealDistribution(getMT(), 0, 1)
		end

		if not v1 and not v2 then
			return UniformReal()
		else
			local max = 1
			local min = 0

			if v1 and v2 then
				if v1 > v2 then
					min = v2
					max = v1
				else
					min = v1
					max = v2
				end
			elseif v1 then
				if v1 > 0 then
					max = v1
				else
					min = v1
					max = 0
				end
			end

			return (max - min) * UniformReal() + min
		end
	end,
	--- Set the seed to generate random numbers. This seed will be used in new instances
	-- of Random. All Random objecs previously created will still use the previous seed.
	-- @arg seed An integer number with the new seed.
	-- @usage random = Random()
	--
	-- random:reSeed(12345)
	reSeed = function(self, seed)
		optionalArgument(0, "Random", self)
		if seed == nil then
			seed = os.time()
		else
			verify(seed ~= 0, "Argument 'seed' cannot be zero.")
		end

		optionalArgument(1, "number", seed)
		integerArgument(1, seed)

		MersenneTwister = TerraLib().random().MersenneTwister(seed)
	end,
	--- Return a random element from the chosen distribution.
	-- @usage random = Random{2, 3, 4, 6}
	--
	-- random:sample()
	sample = function()
		customError("Cannot return a random number.")
	end
}

metaTableRandom_ = {__index = Random_, __tostring = _Gtme.tostring}

--- Type to generate random numbers.
-- It uses Xorshift generators are among the fastest non-cryptographic random number generators.
-- Xorshift random number generators are a class of pseudorandom number generators
-- that was discovered by George Marsaglia (http://www.jstatsoft.org/v08/i14/paper).
-- All the instances of Random along a given simulation have the same seed. The distribution
-- can be inferred according to the selected arguments, as shown below.
-- @tabular NONE
-- Arguments & Default distribution \
-- p & "bernoulli" \
-- lambda & "poisson" \
-- mean (or) sd & "normal" \
-- min, max, step & "step" \
-- min, max  & "continuous" \
-- (set of values) & "discrete" \
-- (set of named values) & "categorical"
-- @arg data.distrib A string representing the statistical distribution to be used. See the
-- table below.
-- @tabular distrib
-- Distrib & Description & Compulsory Arguments & Optional Arguments \
-- "bernoulli" & A boolean distribution that returns true with probability p. & p & seed \
-- "beta" & A family of continuous probability distributions defined on the interval [0, 1]
-- parametrized by two positive shape parameters, denoted by alpha and beta, that appear as
-- exponents of the random variable and control the shape of the distribution. & & alpha, beta, seed \
-- "categorical" & A distribution that has names associated to probabilities. Each name is an
-- argument and has a value between zero and one, indicating the probability to be selected. The
-- sum of all probabilities must be one. & ... & seed \
-- "continuous" & A continuous uniform distribition. It selects real numbers in a given
-- interval. & max, min & seed \
-- "discrete" & A discrete uniform distribition. Elements are described as a vector.
-- & ... & seed \
-- "exponential" & Generate exponentialy distributed pseudo random numbers from a uniformly
-- distributed number in the range [0,1]. For this purpose, it uses the Inverse Transform Samplig
-- method & & lambda, seed \
-- "lognormal" & Generate log-normally distributed pseudo random numbers from a normaly
-- distributed number in the range [0,1] using the Box-Muller (1978) method. & & mean, sd, seed \
-- "none" & No distribution. This is useful only when the modeler wants only to set
-- seed. & & seed \
-- "normal" & Generate Normally (Gaussian) distributed pseudo random numbers from a uniformly
-- distributed number in the range [0,1] using the Box-Muller (1978) method . & & mean, sd, seed \
-- "poisson" & Generate Poisson distributed pseudo random numbers from a uniformly distributed
-- number in the range [0,1]. For this purpose, it uses the Inverse Transform Samplig method.
-- & & lambda, seed \
-- "step" & A discrete uniform distribution whose values belong to a given [min, max] interval
-- using step values.
-- & max, min, step & seed \
-- "weibull" & The Weibull distribution is a real valued distribution with two parameters a and b, producing values
-- greater than or equals to zero. & & k \
-- @arg data.lambda An argument of some distributions. It might be interpreted as mean or as scale, according
-- to the given distribution. The default value is 1.
-- @arg data.k The shape parameter for Weibull distribution. The default value is 1.
-- @arg data.alpha Argument of beta distribution. The default value is 1.
-- @arg data.beta Argument of beta distribution. The default value is 1.
-- @arg data.max A number indicating the maximum value to be randomly selected.
-- @arg data.mean A number indicating the mean value. The default value is 1.
-- @arg data.min A number indicating the minimum value to be randomly selected.
-- @arg data.p A number between 0 and 1 representing a probability.
-- @arg data.seed A number to generate the pseudo-random numbers.
-- The default value is the current time of the system, which means that
-- every simulation will use different random numbers.
-- Choosing a seed in interesting when the modeler wants to have the same simulation outcomes
-- despite using random numbers.
-- It is a good programming practice to set
-- the seed in the beginning of the simulation and only once.
-- @arg data.sd A number indicating the standard deviation. The default value is 1.
-- @arg attrTab.step The step where possible values are computed from minimum to maximum.
-- When using this argument, min and max become mandatory.
-- @arg attrTab.... Other values to build a categorical or discrete uniform distribution.
-- @output distrib The distribution of the Random object. All the other parameters of the
-- distribution are also attributes.
-- @usage random = Random()
--
-- bernoulli = Random{p = 0.4}
-- print(bernoulli:sample())
--
-- range = Random{min = 3, max = 7}
-- print(range:sample())
--
-- step = Random{min = 1, max = 9, step = 2}
-- print(step:sample())
--
-- gender = Random{male = 0.49, female = 0.51}
-- print(gender:sample())
--
-- age = Random{1, 2, 4, 8, 16, 32}
-- print(age:sample())
--
-- cover = Random{"pasture", "forest", "clearcut"}
-- print(cover:sample())
--
-- person = Agent{
--     gender = Random{male = 0.49, female = 0.51},
--     age = Random{mean = 20, sd = 2},
--     contacts = Random{lambda = 5}
-- }
--
-- soc = Society{
--     instance = person,
--     quantity = 10
-- }
--
-- print(soc:gender().male)
function Random(data)
	if data == nil then
		data = {}
	elseif type(data) ~= "table" then
		customError(tableArgumentMsg())
	end

	if not data.distrib then
		if data.p ~= nil then
			data.distrib = "bernoulli"
		elseif data.lambda and data.k then
			data.distrib = "weibull"
		elseif data.lambda ~= nil then
			data.distrib = "poisson"
		elseif data.mean ~= nil or data.sd ~= nil then
			data.distrib = "normal"
		elseif data.min ~= nil and data.max ~= nil and data.step ~= nil then
			data.distrib = "step"
		elseif data.min ~= nil and data.max ~= nil then
			data.distrib = "continuous"
		elseif data.alpha or data.beta then
			data.distrib = "beta"
		elseif #data > 0 then
			data.distrib = "discrete"
		elseif getn(data) > 1 or (getn(data) > 0 and data.seed == nil) then
			data.distrib = "categorical"
		else
			data.distrib = "none"
		end
	end

	mandatoryTableArgument(data, "distrib", "string")

	if data.seed then
		integerTableArgument(data, "seed")
		verify(data.seed ~= 0, "Argument 'seed' cannot be zero.")

		MersenneTwister = TerraLib().random().MersenneTwister(data.seed)
		data.seed = nil
	elseif not MersenneTwister then
		local seed = os.time() -- SKIP
		MersenneTwister = TerraLib().random().MersenneTwister(seed) -- SKIP
	end

	switch(data, "distrib"):caseof{
		bernoulli = function()
			verifyUnnecessaryArguments(data, {"distrib", "p"})
			local bd = TerraLib().random().BernoulliDistribution(getMT(), data.p)
			data.sample = function() return bd() end
		end,
		step = function()
			mandatoryTableArgument(data, "min", "number")
			mandatoryTableArgument(data, "max", "number")
			mandatoryTableArgument(data, "step", "number")
			verify(data.max > data.min, "Argument 'max' should be greater than 'min'.")

			local k = (data.max - data.min) / data.step

			local rest = k % 1
			if rest > sessionInfo().round then
				local max1 = data.min + (k - rest) * data.step
				local max2 = data.min + (k - rest + 1) * data.step
				customError("Invalid 'max' value ("..data.max.."). It could be "..max1.." or "..max2..".")
			end

			local ud = TerraLib().random().UniformIntDistribution(getMT(), 0, k)
			local min = data.min
			local step = data.step

			data.sample = function()
				return min + step * ud()
			end
		end,
		discrete = function()
			local values = {}
			data.distrib = nil

			forEachElement(data, function(_, value)
				table.insert(values, value)
			end)

			verify(#data == getn(data), "The only named arguments should be distrib and seed.")
			data.distrib = "discrete"

			local dd = TerraLib().random().UniformIntDistribution(getMT(), 1, #values)
			data.sample = function() return values[dd()] end
		end,
		continuous = function()
			verifyUnnecessaryArguments(data, {"distrib", "max", "min"})
			mandatoryTableArgument(data, "min", "number")
			mandatoryTableArgument(data, "max", "number")
			verify(data.max > data.min, "Argument 'max' should be greater than 'min'.")

			local urd = TerraLib().random().UniformRealDistribution(getMT(), data.min, data.max)

			data.sample = function() return urd() end
		end,
		categorical = function()
			local sum = 0
			data.distrib = nil

			local values = {}
			local probabilities = {}

			forEachOrderedElement(data, function(idx, value)
				mandatoryTableArgument(data, idx, "number")
				sum = sum + value
				probabilities[idx] = sum
				table.insert(values, idx)
			end)

			verify(math.abs(sum - 1) < sessionInfo().round, "Sum should be one, got "..sum..".")

			local categoricalFunc = categorical(probabilities)
			local discrete = Random{min = 0, max = 1}

			data.sample = function() return categoricalFunc(discrete:sample()) end
			data.distrib = "categorical"
			data.values = values
		end,
		exponential = function()
			defaultTableValue(data, "lambda", 1)

			verifyUnnecessaryArguments(data, {"distrib", "lambda"})

			local exp = TerraLib().random().ExponentialDistribution(getMT(), data.lambda)

			data.sample = function()
				return exp()
			end
		end,
		normal = function()
			defaultTableValue(data, "mean", 1)
			defaultTableValue(data, "sd", 1)

			verifyUnnecessaryArguments(data, {"distrib", "mean", "sd"})

			local nd = TerraLib().random().NormalDistribution(getMT(), data.mean, data.sd)
			data.sample = function() return nd() end
		end,
		lognormal = function()
			defaultTableValue(data, "mean", 1)
			defaultTableValue(data, "sd", 1)

			positiveTableArgument(data, "mean")
			positiveTableArgument(data, "sd")

			verifyUnnecessaryArguments(data, {"distrib", "mean", "sd"})

			local ln = TerraLib().random().LogNormalDistribution(getMT(), data.mean, data.sd)
			data.sample = function() return ln() end
		end,
		none = function()
		end,
		poisson = function()
			defaultTableValue(data, "lambda", 1)

			verifyUnnecessaryArguments(data, {"distrib", "lambda"})

			local pd = TerraLib().random().PoissonDistribution(getMT(), data.lambda)
			data.sample = function() return pd() end
		end,
		weibull = function()
			defaultTableValue(data, "lambda", 1)
			defaultTableValue(data, "k", 1)

			positiveTableArgument(data, "lambda")
			positiveTableArgument(data, "k")

			local wd = TerraLib().random().WeibullDistribution(getMT(), data.k, data.lambda)
			data.sample = function() return wd() end
		end,
		beta = function()
			defaultTableValue(data, "alpha", 1)
			defaultTableValue(data, "beta", 1)

			positiveTableArgument(data, "alpha")
			positiveTableArgument(data, "beta")

			local betad = TerraLib().random().BetaDistribution(data.alpha, data.beta)
			local urd = TerraLib().random().UniformRealDistribution(getMT(), 0, 1)

			data.sample = function() return betad(urd()) end
		end
	}

	setmetatable(data, metaTableRandom_)
	return data
end

