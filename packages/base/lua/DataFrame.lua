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

local metaTableDataFrameItem_ = {
	__newindex = function(self, idx, value)
		self.data[idx][self.pos] = value
	end,
	__index = function(self, idx)
		return self.data[idx][self.pos]
	end
}

metaTableDataFrame_ = {
	--- Return a row or a column of the DataFrame.
	-- @arg idx An index. If it is a number this function returns the given row
	-- as a named table. If it is a string this function returns the 
	-- entire column as a vector.
	-- @usage df = DataFrame{
	--     x = {1, 1, 2, 2},
	--     y = {1, 2, 1, 2}
	-- }
	--
	-- print(df.x[1]) -- 1
	--
	-- df.x[1] = 5
	-- df[1].x = df[1].x + 1
	--
	-- print(df.x[1]) -- 6
	__index = function(self, idx)
		if idx == "type_" then return "DataFrame" end

		if type(idx) == "number" then
			local result = {pos = idx, data = self.data}

			setmetatable(result, metaTableDataFrameItem_)

			return result
		elseif type(idx) == "string" then
			return self.data[idx]
		end
	end,
	--- Return the number of rows in the DataFrame.
	-- @usage df = DataFrame{
	--     x = {1, 1, 2, 2},
	--     y = {1, 2, 1, 2}
	-- }
	--
	-- print(#df) -- 4
	__len = function(self)
		local names = getNames(self.data)
		return #self.data[names[1]]
	end,
	__tostring = function(self)
		local result = {}
		local str

		local names = getNames(self.data)
		local first = true

		forEachElement(names, function(_, value)
			if first then
				str = value
				first = false
			else
				str = str.."\t"..value
			end
		end)

		table.insert(result, str)

		for i = 1, #self do
			first = true

			forEachElement(names, function(_, value)
				if first then
					str = self.data[value][i]
					first = false
				else
				str = str.."\t"..self.data[value][i]
				end
			end)

			table.insert(result, str)
		end

		return table.concat(result, "\n")
	end
}

--- A two dimensional table. DataFrames can be accessed by row or by column, independently on the way it was created.
-- @arg data A two dimensional table. It can be a vector of named tables or a named table with whose values are vectors.
-- @usage -- named table with vectors
-- df = DataFrame{
--     x = {1, 1, 2, 2},
--     y = {1, 2, 1, 2}
-- }
--
-- print(df.x[1]) -- 1
-- print(df[1].x) -- 1
--
-- -- vector of named tables
-- df = DataFrame{
--     {x = 1, y = 1},
--     {x = 1, y = 2},
--     {x = 2, y = 1},
--     {x = 2, y = 2},
-- }
--
-- print(df.y[4]) -- 2
-- print(df[4].y) -- 2
function DataFrame(data)
	mandatoryArgument(1, "table", data)

	local df = {}

	if #data > 0 then
		if getn(data) > #data then
			customError("It is not possible to use named and non-named elements to create a DataFrame.")
		end

		forEachElement(data, function(_, value)
			forEachElement(value, function(midx, mvalue)
				if not df[midx] then df[midx] = {} end

				table.insert(df[midx], mvalue)
			end)
		end)
	elseif getn(data) > 0 then
		local length

		forEachOrderedElement(data, function(idx, value)
			if type(value) ~= "table" then
				customError("All arguments for DataFrame must be table values.")
			end

			if length and #value ~= length then
				customError("All arguments for DataFrame must have the same size, got "..length.." and "..#value..".")
			end

			length = #value
			df[idx] = value
		end)
	else
		customError("It is not possible to create a DataFrame from an empty table.")
	end

	data = {data = df}
	setmetatable(data, metaTableDataFrame_)

	return data
end

