-- random number generation library
Random_ = {
	type_ = "Random",
  --- Reset the seed to generate random numbers.
	-- @param seed A positive integer number.
	-- @usage value = random:reSeed(1)
	reSeed = function(self, seed)
		if (seed == nil) then seed = os.time() end
		self.seed = seed
		self.cObj_:reseed(seed)
	end,
  --- Generate an integer random number.
	-- @param v1 An integer number. If abscent, integer() will generate numbers between zero and one. If it is the only parameter used, it will generate numbers from zero to this value.
	-- @param v2 An integer number. When used, integer() will generate numbers between the first parameter and the second, inclusive.
	-- @usage value = random:integer() -- 0 or 1
	--
	-- value = random:integer(10) -- from 0 to 10
	--
	-- value = random:integer(5, 10) -- from 5 to 10
	integer = function(self,v1,v2)
		if(v2) then
			if(v1) then
				return self.cObj_:randomInteger(v1,v2)
			end
		else
			if(v1) then
				if(v1 < 0) then
					return self.cObj_:randomInteger(v1,0)
				else
					return self.cObj_:randomInteger(0,v1)          
				end
			else
				return round(self.cObj_:random(-1,-1),0)
			end
		end
	end,
  --- Generate a real number randomly.
	-- @param v1 A number. If abscent, number() will generate numbers between zero and one. If it is the only parameter used, it will generate numbers from zero to this value.
	-- @param v2 A number. When used, number() will generate numbers between the first parameter and the second.
	-- @usage value = random:number() -- between 0 and 1
	--
	-- value = random:number(10) -- between 0 and 10
	--
	-- value = random:number(5, 10) -- between 5 and 10
	number = function(self, v1, v2)
		if(not v1 and not v2) then
			return self.cObj_:random(-1,-1)
		else
			local max
			local min

			if(v1 and v2) then
				if(v1 > v2) then
					min = v2
					max = v1
				else
					min = v1
					max = v2				
				end
			else
				if(v1) then
					if(v1 > 0) then
						min = 0
						max = v1
					else
						min = v1
						max = 0
					end
				end
			end
			return self.cObj_:random(-1,-1) * (max - min) + min
		end
	end
}

local metaTableRandom_ = {__index = Random_}

--- Type to generate random numbers. It uses RandomLib, a C++ interface to the Mersenne Twister random number generator MT19937 and to the SIMD-oriented Fast Mersenne Twister random number generator, SFMT19937. Every instance of Random has its own random seed.
-- @param data.seed An integer number to generate the pseudo-random numbers. Default is the current time of the system.
-- @usage random = Random()
--
-- random = Random { seed = 0 }
function Random(data)
	if(not data) then data = {} end

	if(data["seed"]) then
		data.cObj_ = RandomUtil(data["seed"])
		--data.seed = data["seed"]
	else
		local sd = os.time()
		data.cObj_ = RandomUtil(sd)
		data.seed = sd
	end

	setmetatable(data, metaTableRandom_)
	data.cObj_:setReference(data)
	return data
end
