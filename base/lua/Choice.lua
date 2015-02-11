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
-- Authors: Pedro R. Andrade (pedro.andrade@inpe.br)
--#########################################################################################

Choice_ = {
	type_ = "Choice",
	--- Return a random element from the available options.
	-- @usage c:sample()
	sample = function(self)
		local r = Random()
		if self.values then
			return self.values[r:integer(#self.values)]
		elseif self.step then
			local quantity = (self.max - self.min) / self.step
			return self.min + self.step * r:integer(0, quantity)
		elseif self.max and self.min then
			return r:number(self.min, self.max)
		end

		customError("It is not possible to retrieve a sample from this Choice.")
	end
}

metaTableChoice_ = {
	__index = Choice_,
	__tostring = tostringTerraME
}

--- Type to define options to be used by the modeler. It can get a set of
-- non-named values as arguments as well as named arguments as follows. This type
-- is particularly useful to define a Model.
-- @arg attrTab.min The minimum value.
-- @arg attrTab.max The maximum value.
-- @arg attrTab.step An optional argument with the possible steps from minimum to maximum.
-- @usage Choice{1, 2, 3}
-- Choice{"low", "medium", "high"}
function Choice(attrTab)
	local result

	if type(attrTab) ~= "table" then
		customError(tableArgumentMsg())
	elseif #attrTab > 0 then
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
				customError("Default value ("..default..") does not belong to Choice.")
			end
		end

		forEachElement(attrTab, function(idx)
			if type(idx) == "string" then
				customWarning(unnecessaryArgumentMsg(idx))
			end
		end)

		result = {values = attrTab, default = default}
	elseif getn(attrTab) > 0 then
		mandatoryTableArgument(attrTab, "min", "number")

		optionalTableArgument(attrTab, "max", "number")
		optionalTableArgument(attrTab, "step", "number")

		defaultTableValue(attrTab, "default", attrTab.min)

		if attrTab.max then
			verify(attrTab.max > attrTab.min, "Argument 'max' should be greater than 'min'.")
		end

		if attrTab.default then
			verify(attrTab.default >= attrTab.min, "Argument 'default' should be greater than or equal to 'min'.")
			if attrTab.max then
				verify(attrTab.default <= attrTab.max, "Argument 'default' should be less than or equal to 'max'.")
			end
		end

		if attrTab.step and not attrTab.max then
			customError("It is not possible to have 'step' and not 'max'.")
		end

		checkUnnecessaryArguments(attrTab, {"default", "min", "max", "step"})

		if attrTab.step then
			local k = (attrTab.max - attrTab.min) / attrTab.step

			local rest = k % 1
			if rest > 0.00001 then
				local max1 = attrTab.min + (k - rest) * attrTab.step
				local max2 = attrTab.min + (k - rest + 1) * attrTab.step
				customError("Invalid 'max' value ("..attrTab.max.."). It could be "..max1.." or "..max2..".")
			end

			if attrTab.default then
				local k = (attrTab.default - attrTab.min) / attrTab.step

				local rest = k % 1
				if rest > 0.00001 then
					local def1 = attrTab.min + (k - rest) * attrTab.step
					local def2 = attrTab.min + (k - rest + 1) * attrTab.step
					customError("Invalid 'default' value ("..attrTab.default.."). It could be "..def1.." or "..def2..".")
				end
			end
		end

		result = attrTab
	else
		customError("There are no options for the Choice (table is empty).")
	end

	setmetatable(result, metaTableChoice_)
	return result
end


