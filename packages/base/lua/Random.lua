-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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

local function bernoulli(generator, p)
	return function()
		return generator:number() < p
	end
end

local function categorical(generator, values)
	local str = "return function(number)\n"

	local previous = 0
	local sum = {}
	forEachOrderedElement(values, function(idx, value)
		previous = previous + value
		sum[idx] = previous
	end)

	forEachOrderedElement(sum, function(idx, value)
		str = str.."\tif number <= "..value.." then\n"
		         .."\t\treturn \""..idx.."\"\n"
		         .."\tend\n"
	end)

	str = str.."end"

	local func = load(str)()

	return function()
		local number = generator:number()
		return func(number)
	end
end

local function discrete(generator, values)
	local quantity = #values
	return function()
		return values[generator:integer(1, quantity)]
	end
end

local function step(generator, min, max, mstep)
	local quantity = (max - min) / mstep

	return function()
		return min + mstep * generator:integer(0, quantity)
	end
end

local function continuous(generator, min, max)
	return function()
		return generator:number(min, max)
	end
end

-- Xorshift random number generators are a class of pseudorandom number generators
-- that was discovered by George Marsaglia [http://www.jstatsoft.org/v08/i14/paper].
-- They generate the next number in their sequence by repeatedly taking the exclusive or of a number
-- with a bit shifted version of itself. This makes them extremely fast on modern computer architectures.
-- They are a subclass of linear feedback shift registers,
-- Their simple implementation typically makes them faster and use less space.
-- Xorshift generators are among the fastest non-cryptographic random number generators.
-- The following xorshift+ generator uses 128 bits of state and has a maximal period of 2 ^ 128 - 1.
-- It passes the BigCrush tests and is considered better than the Mersenne twister.
local function xorshift128plus(self, min, max)
	local x = self.seed[1]
	local y = self.seed[2]
	Random_.seed[1] = y
	x = bit32.bxor(x, bit32.lshift(x, 23))
	x = bit32.bxor(x, bit32.rshift(x, 17))
	x = bit32.bxor(x, bit32.bxor(y, bit32.rshift(y, 26)))
	Random_.seed[2] = x
	return ((x + y) % (max - min + 1)) + min
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
		optionalArgument(1, "number", v1)
		optionalArgument(2, "number", v2)

		if v2 then
			integerArgument(2, v2)
			if v1 and v2 >= v1 then
				integerArgument(1, v1)
				return xorshift128plus(self, v1, v2)
			else
				customError("It is not possible to sample from an empty object.")
			end
		elseif v1 then
			integerArgument(1, v1)
			if v1 < 0 then
				return xorshift128plus(self, v1, 0)
			else
				return xorshift128plus(self, 0, v1)
			end
		else
			return xorshift128plus(self, 0, 1)
		end
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
		optionalArgument(1, "number", v1)
		optionalArgument(2, "number", v2)

		if not v1 and not v2 then
			return xorshift128plus(self, 0, 1000000) / 1000000
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
			return (max - min) * (xorshift128plus(self, 0, 1000000) / 1000000) + min
		end
	end,
	--- Reset the seed to generate random numbers.
	-- @arg seed An integer number with the new seed.
	-- @usage random = Random()
	--
	-- random:reSeed(12345)
	reSeed = function(self, seed)
		if seed == nil then
			seed = tonumber(tostring(os.time()):reverse():sub(1, 6))
		else
			verify(seed ~= 0, "Argument 'seed' cannot be zero.")
		end

		optionalArgument(1, "number", seed)
		integerArgument(1, seed)

		self.random.seed[1] = 1
		self.random.seed[2] = seed
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
-- Every instance of Random along a simulation has the same seed.
-- @arg data.distrib A string representing the statistical distribution to be used. See the
-- table below.
-- @tabular distrib
-- Distrib & Description & Compulsory Arguments & Optional Arguments \
-- "bernoulli" & A boolean distribution that returns true with probability p. & p & seed \
-- "categorical" & A distribution that has names associated to probabilities. Each name is an
-- argument and has a value between zero and one, indicating the probability to be selected. The
-- sum of all probabilities must be one. & ... & seed \
-- "continuous" & A continuous uniform distribition. It selects real numbers in a given
-- interval. & max, min & seed \
-- "discrete" & A discrete uniform distribition. Elements are described as a vector.
-- & ... & seed \
-- "none" & No distribution. This is useful only when the modeler wants only to set
-- seed. & & seed \
-- "step" & A discrete uniform distribution whose values belong to a given [min, max] interval
-- using step values.
-- & max, min, step & seed \
-- @arg data.max A number indicating the maximum value to be randomly selected.
-- @arg data.min A number indicating the minimum value to be randomly selected.
-- @arg data.p A number between 0 and 1 representing a probability.
-- @arg data.seed A number to generate the pseudo-random numbers.
-- The default value is the current time of the system, which means that
-- every simulation will use different random numbers.
-- Choosing a seed in interesting when the modeler wants to have the same simulation outcomes
-- despite using random numbers.
-- It is a good programming practice to set
-- the seed in the beginning of the simulation and only once.
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
--     --age = Random{mean = 20, sd = 2} TODO
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
		--elseif data.lambda ~= nil then
		--	data.distrib = "poisson"
		--elseif data.mean ~= nil or data.sd ~= nil then
		--	data.distrib = "normal"
		elseif data.min ~= nil and data.max ~= nil and data.step ~= nil then
			data.distrib = "step"
		elseif data.min ~= nil or data.max ~= nil then
			data.distrib = "continuous"
		elseif #data > 0 then
			data.distrib = "discrete"
		elseif getn(data) > 1 or (getn(data) > 0 and data.seed == nil) then
			data.distrib = "categorical"
		else
			data.distrib = "none"
		end
	end

	mandatoryTableArgument(data, "distrib", "string")

	switch(data, "distrib"):caseof{
		bernoulli = function()
			verifyUnnecessaryArguments(data, {"distrib", "seed", "p"})
			data.sample = bernoulli(data, data.p)
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

			data.sample = step(data, data.min, data.max, data.step)
		end,
		discrete = function()
			local count = 1
			if data.seed then count = 2 end

			local values = {}

			forEachElement(data, function(idx, value)
				if idx == "seed" then return end

				table.insert(values, value)
			end)

			verify(#data + count == getn(data), "The only named arguments should be distrib and seed.")
			data.sample = discrete(data, data)
			data.values = values
		end,
		continuous = function()
			verifyUnnecessaryArguments(data, {"distrib", "seed", "max", "min"})
			mandatoryTableArgument(data, "min", "number")
			mandatoryTableArgument(data, "max", "number")
			verify(data.max > data.min, "Argument 'max' should be greater than 'min'.")
			data.sample = continuous(data, data.min, data.max)
		end,
		categorical = function()
			local sum = 0
			local seed = data.seed
			data.seed = nil
			data.distrib = nil

			local values = {}

			forEachElement(data, function(idx, value)
				mandatoryTableArgument(data, idx, "number")
				table.insert(values, idx)
				sum = sum + value
			end)

			verify(math.abs(sum - 1) < sessionInfo().round, "Sum should be one, got "..sum..".")

			data.sample = categorical(data, data)
			data.distrib = "categorical"
			data.seed = seed
			data.values = values
		end,
		none = function()
		end
	}

	if data.seed then
		integerTableArgument(data, "seed")
		verify(data.seed ~= 0, "Argument 'seed' cannot be zero.")
		Random_.seed = {data.seed, data.seed}
		data.seed = nil
	elseif not Random_.seed then
		local seed = tonumber(tostring(os.time()):reverse():sub(1, 6))
		Random_.seed = {seed, seed}
	end

	data.random = Random_
	setmetatable(data, metaTableRandom_)
	return data
end

