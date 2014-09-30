-------------------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------------------

Random_ = {
	type_ = "Random",
	--- Reset the seed to generate random numbers.
	-- @param seed A positive integer number.
	-- @usage value = random:reSeed(1)
	reSeed = function(self, seed)
		if seed == nil then seed = os.time() end

		if type(seed) ~= "number" then
			incompatibleTypeError("#1", "number", type(seed), 3)
		end

		self.seed = seed
		self.cObj_:reseed(seed)
	end,
	sample = function(self, vector)
		local int = self:integer(1, #vector)
		return vector[int]
	end,
	--- Generate an integer random number.
	-- @param v1 An integer number. If abscent, integer() will generate numbers between zero and
	-- one. If it is the only parameter used, it will generate numbers from zero to this value.
	-- @param v2 An integer number. When used, integer() will generate numbers between the first
	-- parameter and the second, inclusive.
	-- @usage value = random:integer() -- 0 or 1
	--
	-- value = random:integer(10) -- from 0 to 10
	--
	-- value = random:integer(5, 10) -- from 5 to 10
	integer = function(self, v1, v2)
		if type(v1) ~= "number" and v1 ~= nil then
			incompatibleTypeError("#1", "number or nil", type(v1), 3)
		end

		if type(v2) ~= "number" and v2 ~= nil then
			incompatibleTypeError("#2", "number or nil", type(v2), 3)
		end

		if v2 then
			if v1 then
				return self.cObj_:randomInteger(v1, v2)
			end
		elseif v1 then
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
	-- @param v1 A number. If abscent, number() will generate numbers between zero and one. If
	-- it is the only parameter used, it will generate numbers from zero to this value.
	-- @param v2 A number. When used, number() will generate numbers between the first parameter
	-- and the second.
	-- @usage value = random:number() -- between 0 and 1
	--
	-- value = random:number(10) -- between 0 and 10
	--
	-- value = random:number(5, 10) -- between 5 and 10
	number = function(self, v1, v2)
		if type(v1) ~= "number" and v1 ~= nil then
			incompatibleTypeError("#1", "number or nil", type(v1), 3)
		end

		if type(v2) ~= "number" and v2 ~= nil then
			incompatibleTypeError("#2", "number or nil", type(v2), 3)
		end

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

--- Type to generate random numbers. It uses RandomLib, a C++ interface to the Mersenne Twister
-- random number generator MT19937 and to the SIMD-oriented Fast Mersenne Twister random number
-- generator, SFMT19937. Every instance of Random has its own random seed.
-- @param data.seed An integer number to generate the pseudo-random numbers.
-- Default is the current time of the system.
-- @usage random = Random()
--
-- random = Random {seed = 0}
function Random(data)
	if type(data) ~= "table" then
		if data == nil then
			data = {}
		else
			tableParameterError("Random", 3)
		end
	end

	checkUnnecessaryParameters(data, {"seed"}, 3)

	if data.seed then
		data.cObj_ = RandomUtil(data.seed)
	else
		local sd = os.time()
		data.cObj_ = RandomUtil(sd)
		data.seed = sd
	end

	setmetatable(data, metaTableRandom_)
	data.cObj_:setReference(data)
	return data
end

