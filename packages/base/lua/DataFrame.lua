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
		if not self.data_[idx] then
			self.data_[idx] = {}
			self.parent.columns_[idx] = true
		end

		self.data_[idx][self.pos] = value
	end,
	__index = function(self, idx)
		if not self.data_[idx] then
			return self.parent.instance_[idx]
		end

		return self.data_[idx][self.pos]
	end,
	__tostring = function(self)
		local columns = self.parent:columns()
		local values = {}
		forEachOrderedElement(columns, function(idx)
			values[idx] = self.data_[idx][self.pos]
		end)

		return vardump(values)
	end,
	__len = function(self)
		return getn(self.parent:columns())
	end
}

--- Add a new row.
-- @arg row A named table with the values of the row to be added.
-- @arg idx An optional number describing the position of the row. As
-- default, this function adds the new row after the last one.
-- @usage df = DataFrame{
--     {x = 1, y = 1}
-- }
--
-- df:add{x = 5, y = 2}
-- df:add{x = 4, y = 2}
--
-- print(df[3].x) -- 4
-- print(df.y[2]) -- 2
local function add(self, row, idx)
	if idx == nil then
		table.insert(self.rows_, true)
		idx = getn(self.rows_)
		forEachElement(row, function(midx, value)
			if self.data_[midx] == nil then
				self.columns_[midx] = true
				self.data_[midx] = {}
			end

			self.data_[midx][idx] = value
		end)
	else
		self.rows_[idx] = true
		forEachElement(row, function(midx, value)
			if self.data_[midx] == nil then
				self.columns_[midx] = true
				self.data_[midx] = {}
			end

			self.data_[midx][idx] = value
		end)
	end
end

--- Remove a given row. This function only works properly when the rows are numbered
-- from one to the quantity of elements in the DataFrame.
-- @arg idx A number with the position to be removed.
-- @usage df = DataFrame{
--     {x = 1, y = 1},
--     {x = 2, y = 1},
--     {x = 3, y = 2},
--     {x = 4, y = 2},
--     {x = 5, y = 2}
-- }
--
-- df:remove(3)
--
-- print(#df) -- 4
-- print(df[3].x) -- 4
local function remove(self, idx)
	self.rows_[idx] = nil
	forEachElement(self.data_, function(_, value)
		table.remove(value, idx)
	end)
end

--- Save the DataFrame to a given file.
-- @arg filename A mandatory string with the file name.
-- @usage filename = "dump.lua"
-- df = DataFrame{x = {1}, y = {2}}
-- df:save(filename)
--
-- File(filename):deleteIfExists()
local function save(self, filename)
	mandatoryArgument(1, "string", filename)

	local file = File(filename)
	local stbl = "return"..vardump(self.data_)
	file:writeLine(stbl)
	file:close()
end

--- Return the columns of the DataFrame. It is a named table whose indexes are
-- the column names and the values are true.
-- @usage df = DataFrame{x = {1}, y = {2}}
-- print(vardump(df:columns())) -- {x = true, y = true}
local function columns(self)
	return self.columns_
end

--- Return the rows of the DataFrame. It is a named table whose indexes are
-- the rows positions and the values are true.
-- @usage df = DataFrame{x = {1}, y = {2}}
-- print(vardump(df:rows())) -- {true}
local function rows(self)
	return self.rows_
end

local DataFrameIndex = {
	add = add,
	remove = remove,
	save = save,
	rows = rows,
	columns = columns,
	type_ = "DataFrame"
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
		if type(idx) == "number" then
			local result = self.cache_[idx]

			if result then return result end

			result = {pos = idx, data_ = self.data_, parent = self}

			setmetatable(result, metaTableDataFrameItem_)

			self.cache_[idx] = result

			return result
		elseif type(idx) == "string" then
			if self.data_[idx] then return self.data_[idx] end

			return DataFrameIndex[idx]
		end
	end,
	__newindex = function(self, idx, value)
		if type(idx) == "string" then
			self.data_[idx] = value
			self.columns_[idx] = true
		else
			self:add(value, idx)
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
		return getn(self:rows())
	end,
	__tostring = function(self)
		local result = {}
		local str

		local mcolumns = self:columns()
		local mrows = self:rows()

		local first = true

		forEachOrderedElement(mcolumns, function(value)
			if first then
				str = "\t"..value
				first = false
			else
				str = str.."\t"..value
			end
		end)

		table.insert(result, str)

		forEachOrderedElement(mrows, function(idx)
			first = true

			forEachOrderedElement(mcolumns, function(col)
				if not first then
					str = str.."\t"..tostring(self.data_[col][idx])
				else
					str = idx.."\t"..tostring(self.data_[col][idx])
					first = false
				end
			end)

			table.insert(result, str)
		end)

		return table.concat(result, "\n")
	end
}

--- A two dimensional table. DataFrames can be accessed by row or by column, independently on the way it was created.
-- @arg data.file A string or a File. It must have extension '.lua'.
-- @arg data.first A number with the first index.
-- @arg data.step A number with the interval between two indexes.
-- @arg data.last A number with the last index. This argument is optional.
-- @arg data.instance An optional object used as meta table for the rows of the DataFrame.
-- and only used to check whether it is equals to first plus
-- step times the size of the data vectors.
-- @arg data.... Values for the DataFrame. It can be a vector of named tables or a named table with whose values are vectors.
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
--     first = 2000,
--     step = 10
-- }
--
-- print(df.y[2030]) -- 2
-- print(df[2010].y) -- 2
function DataFrame(data)
	mandatoryArgument(1, "table", data)

	if data.file then
		if type(data.file) == "string" then
			data.file = File(data.file)
		end

		mandatoryTableArgument(data, "file", "File")

		verify(data.file:extension() == "lua", "File '"..data.file:name().."' does not have '.lua' extension.")
		verify(data.file:exists(), resourceNotFoundMsg("file", data.file:name(true)))

		local tbl
		local ok, merror = pcall(function() tbl = dofile(tostring(data.file)) end)
		if not ok then customError("Failed to load file "..merror) end

		verify(type(tbl) == "table", "File '"..data.file:name().."' does not contain a Lua table.")
		return DataFrame(tbl)
	end

	defaultTableValue(data, "first", 1)
	defaultTableValue(data, "step", 1)
	optionalTableArgument(data, "last", "number")

	local first = data.first
	local step = data.step
	local last = data.last
	local instance = data.instance

	data.first = nil
	data.step = nil
	data.last = nil
	data.instance = nil

	if instance then
		if not isTable(instance) then
			customError("Argument 'instance' should be an isTable() object, got "..type(instance)..".")
		end
	else
		instance = {}
	end

	if last then
		local quantity = (last - first) / step

		local rest = quantity % 1
		if rest > 0.00001 then
			local max1 = first + (quantity - rest) * step
			local max2 = first + (quantity - rest + 1) * step
			customError("Invalid 'last' value ("..last.."). It could be "..max1.." or "..max2..".")
		end
	end

	local df = {}
	local mrows = {}
	local mcolumns = {}

	if #data > 0 then
		if getn(data) > #data then
			customError("It is not possible to use named and non-named elements to create a DataFrame.")
		end

		local position = first

		forEachElement(data, function(_, value)
			forEachElement(value, function(midx, mvalue)
				if not df[midx] then
					df[midx] = {}
					mcolumns[midx] = true
				end

				df[midx][position] = mvalue
			end)

			mrows[position] = true
			position = position + step
		end)

		position = position - step
		if last and position ~= last then
			customError("Rows should range until position "..last..", got "..position..".")
		end
	elseif getn(data) > 0 then
		local length
		local lastColumn

		forEachOrderedElement(data, function(idx, value)
			if type(value) ~= "table" then
				customError("All arguments for DataFrame must be table values, got "..type(value).." ('"..idx.."').")
			end

			if length and #value ~= length then
				customError("All arguments for DataFrame must have the same size, got "..length.." ('"..lastColumn.."') and "..#value.." ('"..idx.."').")
			end

			length = #value
			lastColumn = idx

			mcolumns[idx] = true

			if first ~= 1 or step ~= 1 then
				df[idx] = {}

				local position = first
				for i = 1, length do
					df[idx][position] = value[i]
					mrows[position] = true
					position = position + step
				end

				position = position - step
				if last and position ~= last then
					customError("Argument '"..idx.."' should range until position "..last..", got "..position..".")
				end
			else
				df[idx] = value

				forEachElement(value, function(i)
					mrows[i] = true
				end)
			end
		end)
	elseif first ~= 1 or step ~= 1 then
		customError("It is not possible to create a DataFrame from an empty table using arguments 'first' or 'step'.")
	end

	data = {
		data_ = df,
		instance_ = instance,
		rows_ = mrows,
		columns_ = mcolumns,
		cache_ = {}
	}

	setmetatable(data.cache_, {__mode = 'v'})
	setmetatable(data, metaTableDataFrame_)

	return data
end

