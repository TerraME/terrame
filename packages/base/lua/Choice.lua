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

Choice_ = {
	type_ = "Choice",
	--- Return a random element from the available options. If the Choice was built
	-- from a vector or it has a step, it returns a random value following a
	-- discrete uniform distribution. If it has maximum and minimum then it returns a random
	-- value using a continuous uniform distribution. When sampling from
	-- Choices that have maximum but not minimum, or minimum but not maximum, it uses
	-- 2^52 as maximum or -2^52 as minimum.
	-- @usage c = Choice{1, 2, 5, 6}
	-- c:sample()
	sample = function(self)
		local r = Random()
		if self.values then
			return self.values[r:integer(#self.values - 1) + 1]
		elseif self.step then
			local quantity = (self.max - self.min) / self.step
			return self.min + self.step * r:integer(0, quantity)
		elseif self.max and self.min then
			return r:number(self.min, self.max)
		elseif self.max then
			return r:number(-2^52, self.max)
		else
			return r:number(self.min, 2^52)
		end
	end
}

metaTableChoice_ = {
	__index = Choice_,
	__tostring = _Gtme.tostring
}

--- Type to define options to be used by the modeler. It can get a vector a argument or
-- named arguments as follows. This type is useful to define parameters of a Model.
-- @arg attrTab.min The minimum value (optional).
-- @arg attrTab.max The maximum value (optional).
-- @arg attrTab.default The default value for the choice. The default value
-- for this argument depends on the other arguments used. If using min then it
-- is the default value. Otherwise, if using max then it is the default value.
-- If using a vector as argument, the default value is the first element
-- of the table.
-- @arg attrTab.step An optional argument with the step from minimum to maximum.
-- Note that max should be equals to min plus k times step, where k is an integer
-- number. When using this argument, min and max become mandatory.
-- @arg attrTab.slices An optional argument with the number of values between minimum and maximum.
-- It must be an integer number greater than two. When using this argument, min and max become mandatory.
-- @output values A vector with the possible values for the Choice.
-- @usage c1 = Choice{1, 2, 3}
-- c2 = Choice{"low", "medium", "high"}
-- c3 = Choice{min = 2, max = 5, step = 0.1}
-- c4 = Choice{min = 2, max = 20, slices = 4}
function Choice(attrTab)
	local result

	if type(attrTab) ~= "table" then
		customError(tableArgumentMsg())
	elseif #attrTab > 0 then
		if #attrTab == 1 then
			strictWarning("Choice has only one available value.")
		end

		if not belong(type(attrTab[1]), {"number", "string"}) then
			customError("The elements should be number or string, got "..type(attrTab[1])..".")
		end
		local type1 = type(attrTab[1])

		forEachElement(attrTab, function(_, _, mtype)
			if type1 ~= mtype then
				customError("All the elements of Choice should have the same type.")
			end
		end)

		local default
		if attrTab.default == nil then
			default = attrTab[1]
		else
			default = attrTab.default
			attrTab.default = nil

			if default == attrTab[1] then
				customWarning(defaultValueWarning("default", default))
			elseif not belong(default, attrTab) then
				customError("The default value ("..default..") does not belong to Choice.")
			end
		end

		forEachElement(attrTab, function(idx)
			if type(idx) == "string" then
				customWarning(unnecessaryArgumentMsg(idx))
			end
		end)

		result = {values = attrTab, default = default}
	elseif getn(attrTab) > 0 then
		verifyUnnecessaryArguments(attrTab, {"default", "min", "max", "step", "slices"})

		optionalTableArgument(attrTab, "min", "number")
		optionalTableArgument(attrTab, "max", "number")
		optionalTableArgument(attrTab, "step", "number")
		optionalTableArgument(attrTab, "slices", "number")

		if attrTab.min then
			defaultTableValue(attrTab, "default", attrTab.min)
		elseif attrTab.max then
			defaultTableValue(attrTab, "default", attrTab.max)
		end

		if attrTab.max and attrTab.min then
			verify(attrTab.max > attrTab.min, "Argument 'max' should be greater than 'min'.")
		end

		if attrTab.default then
			if attrTab.min then
				verify(attrTab.default >= attrTab.min, "Argument 'default' should be greater than or equal to 'min'.")
			end

			if attrTab.max then
				verify(attrTab.default <= attrTab.max, "Argument 'default' should be less than or equal to 'max'.")
			end
		end

		if attrTab.step and not (attrTab.max and attrTab.min) then
			customError("Attribute 'step' requires 'max' and 'min'.")
		end

		if attrTab.slices and not (attrTab.max and attrTab.min) then
			customError("Attribute 'slices' requires 'max' and 'min'.")
		end

		if attrTab.slices and attrTab.step then
			customError("It is not possible to use arguments 'step' and 'slices' at the same time.")
		end

		if attrTab.step then
			local k = (attrTab.max - attrTab.min) / attrTab.step

			local rest = k % 1
			if rest > sessionInfo().round and rest < (1 - sessionInfo().round) then
				local max1 = attrTab.min + (k - rest) * attrTab.step
				local max2 = attrTab.min + (k - rest + 1) * attrTab.step
				customError("Invalid 'max' value ("..attrTab.max.."). It could be "..max1.." or "..max2..".")
			end

			if attrTab.default then
				local mk = (attrTab.default - attrTab.min) / attrTab.step

				local mrest = mk % 1
				if mrest > sessionInfo().round and mrest < (1 - sessionInfo().round) then
					local def1 = attrTab.min + (mk - mrest) * attrTab.step
					local def2 = attrTab.min + (mk - mrest + 1) * attrTab.step
					customError("Invalid 'default' value ("..attrTab.default.."). It could be "..def1.." or "..def2..".")
				end
			end
		end

		if attrTab.slices then
			verify(attrTab.slices > 2, "Argument 'slices' ("..attrTab.slices..") should be greater than two.")
			verify(attrTab.slices == math.floor(attrTab.slices), "Invalid 'slices' value ("..attrTab.slices.."). It could be "..math.floor(attrTab.slices).." or "..math.ceil(attrTab.slices)..".")

			attrTab.step = (attrTab.max - attrTab.min) / (attrTab.slices - 1)
			attrTab.values = {}

			local value = attrTab.min
			for _ = 1, attrTab.slices do
				table.insert(attrTab.values, value)
				value = value + attrTab.step
			end

		end

		result = attrTab
	else
		customError("There are no options for the Choice (table is empty).")
	end

	setmetatable(result, metaTableChoice_)
	return result
end

