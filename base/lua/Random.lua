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
--#########################################################################################


--[[  Parameters for the LCG random number generator 

The Lehmer random number generator, sometimes also referred to as the Park–Miller 
random number generator, is a variant of linear congruential generator (LCG) 
that operates in multiplicative group of integers modulo n. 

--]]


--[[

A linear congruential generator (LCG) is an algorithm that yields a sequence of 
randomized numbers calculated with a linear equation. 
The method represents one of the oldest and best-known pseudorandom number generator algorithms
]]

Random_ = {
	type_ = "Random",
	LCGprevious   = tonumber(tostring(os.time()):reverse():sub(1,6)),
	LCGnext       = 0,
	LCGmodulus    = 2^31 - 1, 	-- Mersenne prime M31
	LCGmultiplier = 48271,   	-- ISO IEC standard for C++
	LCGincrement  = 0
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

	randomLCG = function (self, v1, v2)
    			self.LCGnext = (self.LCGmultiplier*self.LCGprevious + self.LCGincrement) % self.LCGmodulus 
				local rand = (self.LCGnext % (max - min + 1)) + min  
				self.LCGprevious = self.LCGnext
			return rand
	end,

	integer = function(self, v1, v2)
		optionalArgument(1, "number", v1)
		optionalArgument(2, "number", v2)

		if v2 then
			integerArgument(2, v2)
			if v1 then
				integerArgument(1, v1)
				return self.randomLCG(v1, v2)
			end
		elseif v1 then
			integerArgument(1, v1)
			if v1 < 0 then
				return self.randomLCG(v1, 0)
			else
				return self.randomLCG(0, v1)
			end
		else
			return self.randomLCG(0, 1)
		end
	end,
	--- Return a random real number. It uses a continuous uniform distribution.
	-- @arg v1 A number. If abscent, number() will return a value between zero and one. If
	-- it is the only argument used, it will return a number from zero to this value.
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
			return round (self.randomLCG(0, 1000000)/1000000)
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
			return (max - min)*(self.randomLCG(0, 1000000)/1000000)  + min
		end
	end,
	--- Reset the seed to generate random numbers.
	-- @arg seed An integer number with the new seed.
	-- @usage value = random:reSeed(1)
	reSeed = function(self, seed)
		if seed == nil then seed = os.time() end

		optionalArgument(1, "number", seed)
		integerArgument(1, seed)

		self.LCGprevious = seed
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

--- Type to generate random numbers. It uses RandomLib (http://randomlib.sourceforge.net),
-- a C++ interface to the Mersenne Twister
-- random number generator MT19937 and to the SIMD-oriented Fast Mersenne Twister random number
-- generator, SFMT19937. Random is a singleton, which means that every copy of Random created
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
	else
		verifyNamedTable(data)
	end

	verifyUnnecessaryArguments(data, {"seed"})

	if data.seed then
		integerTableArgument(data, "seed")
		Random_.LCGprevious = data.seed
		data.seed = nil
	end

	setmetatable(data, metaTableRandom_)
	return data
end

