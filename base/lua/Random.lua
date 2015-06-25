--#########################################################################################
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP -- www.terrame.org
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
--          Gilberto Camara (2015) - changed the Mersenne twister to the XORSHIFT generator
--#########################################################################################

Random_ = {
	type_ = "Random",
    --- seed for the 
    seed = { tonumber(tostring(os.time()):reverse():sub(1,6)), tonumber(tostring(os.time()):reverse():sub(1,6))},

	-- Xorshift random number generators are a class of pseudorandom number generators 
    -- that was discovered by George Marsaglia.[1] 
    -- They generate the next number in their sequence by repeatedly taking the exclusive or of a number 
    -- with a bit shifted version of itself. This makes them extremely fast on modern computer architectures. 
    -- They are a subclass of linear feedback shift registers, 
    -- Their simple implementation typically makes them faster and use less space.
    -- Xorshift generators are among the fastest non-cryptographic random number generators.
    
    -- The following xorshift+ generator uses 128 bits of state and has a maximal period of 2^128 − 1.
    -- It passes the BigCrush tests and is considered better than the Mersenne twister.
    xorshift128plus = function (self, max, min)
        local x = self.seed[1];
        local y = self.seed[2];
        self.seed[1] = y;
        x = bit32.bxor (x, bit32.lshift (x, 23))
        x = bit32.bxor (x, bit32.rshift (x, 17))
        x = bit32.bxor (x, bit32.bxor (y, bit32.rshift (y, 26)))    
        self.seed[2] = x;
        return ((x + y) % (max - min + 1)) + min
    end,

    --- Return an integer random number. It uses a discrete uniform distribution.
	-- @arg v1 An integer number. If abscent, integer() will return zero or one.
	-- If it is the only argument, it will return a number between zero and this value.
	-- @arg v2 An integer number. When used, integer() will return a number between the first
	-- argument and the second, inclusive.
	-- @usage value = random:integer() -- 0 or 1
	--
	-- value = random:integer(10) -- from 0 to 10
	--
	-- value = random:integer(5, 10) -- from 5 to 10
	integer = function(self, v1, v2)
		optionalArgument(1, "number", v1)
		optionalArgument(2, "number", v2)

		if v2 ~= 0 then
			integerArgument(2, v2)
			if v1 ~= 0 then
				integerArgument(1, v1)
				return self:xorshift128plus(v1, v2)
			end
		elseif v1 ~= 0 then
			integerArgument(1, v1)
			if v1 < 0 then
				return self:xorshift128plus(v1, 0)
			else
				return self:xorshift128plus(0, v1)
			end
		else
			return self:xorshift128plus(0, 1)
			end
		end
	end,
	--- Return a random real number. 
    --  By default number() will return a value between zero and one.
	-- @arg v1 A number. 
	-- If it is the only argument used, it will return a number from zero to this value.
	-- @arg v2 A number. When used, number() will return a number between the first argument
	-- and the second.
	-- @usage value = random:number() -- between 0 and 1
	--
	-- value = random:number(10) -- between 0 and 10
	--
	-- value = random:number(5, 10) -- between 5 and 10
	number = function(self, v1, v2)
		optionalArgument(1, "number", v1)
		optionalArgument(2, "number", v2)

		if not v1 and not v2 then
			return round (self:xorshift128plus(0, 1000000)/1000000)
		else
			local max
			local min

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
					min = 0
					max = v1
				else
					min = v1
					max = 0
				end
			end
			return (max - min)*(self:xorshift128plus(0, 1000000)/1000000)  + min
		end
	end,
	--- Reset the seed to generate random numbers.
	-- @arg seed An integer number with the new seed.
	-- @usage value = random:reSeed(1)
	reSeed = function(self, seed)
		if seed == nil then 
            seed = tonumber(tostring(os.time()):reverse():sub(1,6))
        end
		self.seed[1] = seed
	end,
	--- Return a random element from a set of values using a discrete uniform distribution.
	-- @arg mtable A non-named table with a set of values.
	-- @usage random:sample{2, 3, 4, 6}
	sample = function(self, mtable)
		mandatoryArgument(1, "table", mtable)

		local int = self:integer(1, #mtable)
		return mtable[int]
	end
}

metaTableRandom_ = {__index = Random_, __tostring = _Gtme.tostring}

--- Type to generate random numbers. 
-- Uses Xorshift generators are among the fastest non-cryptographic random number generators.
-- Random is a singleton, which means that every copy of Random created
-- by the user has the same seed.
-- @arg data.seed A number to generate the pseudo-random numbers.
-- The default value is the current time of the system, which means that
-- every simulation will use different random numbers.
-- Choosing a seed in interesting when the modeler wants to have the same simulation outcomes
-- despite using random numbers.
-- It is a good programming practice to set
-- the seed in the beginning of the simulation and only once.
-- @usage random = Random()
--
-- random = Random{seed = 0}
function Random(data)
	if data == nil then
		data = {}
	end
    local rand = data
	setmetatable(rand, metaTableRandom_)
	return rand
end

