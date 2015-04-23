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

Random_ = {
	type_ = "Random",
	--- Reset the seed to generate random numbers.
	-- @arg seed A positive integer number.
	-- @usage value = random:reSeed(1)
	reSeed = function(self, seed)
		if seed == nil then seed = os.time() end

		optionalArgument(1, "number", seed)
		integerArgument(1, seed)

		self.seed = seed
		self.cObj_:reseed(seed)
	end,
	--- Return a random element of a table.
	-- @arg mtable A table with indexes as numbers.
	-- @usage random:sample{2, 3, 4, 6}
	sample = function(self, mtable)
		mandatoryArgument(1, "table", mtable)

		local int = self:integer(1, #mtable)
		return mtable[int]
	end,
	--- Generate an integer random number.
	-- @arg v1 An integer number. If abscent, integer() will generate numbers between zero and
	-- one. If it is the only argument used, it will generate numbers from zero to this value.
	-- @arg v2 An integer number. When used, integer() will generate numbers between the first
	-- argument and the second, inclusive.
	-- @usage value = random:integer() -- 0 or 1
	--
	-- value = random:integer(10) -- from 0 to 10
	--
	-- value = random:integer(5, 10) -- from 5 to 10
	integer = function(self, v1, v2)
		optionalArgument(1, "number", v1)
		optionalArgument(2, "number", v2)

		if v2 then
			integerArgument(2, v2)
			if v1 then
				integerArgument(1, v1)
				return self.cObj_:randomInteger(v1, v2)
			end
		elseif v1 then
			integerArgument(1, v1)
			if v1 < 0 then
				return self.cObj_:randomInteger(v1, 0)
			else
				return self.cObj_:randomInteger(0, v1)
			end
		else
			return round(self.cObj_:random(-1, -1), 0)
		end
	end,
	--- Generate a real number randomly.
	-- @arg v1 A number. If abscent, number() will generate numbers between zero and one. If
	-- it is the only argument used, it will generate numbers from zero to this value.
	-- @arg v2 A number. When used, number() will generate numbers between the first argument
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
			return self.cObj_:random(-1, -1)
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
			return self.cObj_:random(-1, -1) * (max - min) + min
		end
	end
}

metaTableRandom_ = {__index = Random_, __tostring = tostringTerraME}

--- Type to generate random numbers. It uses RandomLib (http://randomlib.sourceforge.net), a C++ interface to the Mersenne Twister
-- random number generator MT19937 and to the SIMD-oriented Fast Mersenne Twister random number
-- generator, SFMT19937. Random is a singleton, which means that every copy of Random created
-- by the user has the same seed.
-- @arg data.seed A number to generate the pseudo-random numbers.
-- Default is the current time of the system.
-- @usage random = Random()
--
-- random = Random{seed = 0}
function Random(data)
	if data == nil then
		data = {}
	else
		verifyNamedTable(data)
	end

	checkUnnecessaryArguments(data, {"seed"})

	if data.seed then
		integerTableArgument(data, "seed")
		Random_.cObj_ = RandomUtil(data.seed)
		Random_.seed = data.seed
		data.seed = nil
	elseif not Random_.cObj_ then
		data.seed = os.time()
		Random_.seed = data.seed
		Random_.cObj_ = RandomUtil(data.seed)
	end

	setmetatable(data, metaTableRandom_)
	data.cObj_:setReference(data)
	return data
end

