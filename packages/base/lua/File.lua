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

-- This function was taken from http://lua-users.org/wiki/LuaCsv.
local function parseLine(line, sep, cline)
	mandatoryArgument(1, "string", line)
	optionalArgument(2, "string", sep)
	optionalArgument(3, "number", cline)

	if cline == nil then cline = 1 end

	local res = {}
	local pos = 1
	while true do
		local c = string.sub(line, pos, pos)
		if c == "" then break end
		if c == '"' then
			-- quoted value (ignore separator within)
			local txt = ""
			repeat
				local startp, endp = string.find(line, '^%b""', pos)
				txt = txt..string.sub(line, startp + 1, endp - 1)
				pos = endp + 1
				c = string.sub(line, pos, pos)
				if c == '"' then txt = txt..'"' end
				-- check first char AFTER quoted string, if it is another
				-- quoted string without separator, then append it
				-- this is the way to "escape" the quote char in a quote. example:
				-- value1,"blub""blip""boing",value3 will result in blub"blip"boing for the middle
			until (c ~= '"')
			table.insert(res, txt)
			verify(c == sep or c == "", "Line "..cline.." ('"..line.."') is invalid.")
			pos = pos + 1
		else
			-- no quotes used, just look for the first separator
			local startp, endp = string.find(line, sep, pos)
			if startp then
				table.insert(res,string.sub(line, pos, startp - 1))
				pos = endp + 1
			else
				-- no separator found -> use rest of string and terminate
				table.insert(res, string.sub(line, pos))
				break
			end
		end
	end

	for i = 1, #res do
		res[i] = res[i]:match("^%s*(.-)%s*$")
	end

	return res
end

File_ = {
	type_ = "File",
	--- Return a table with the file attributes corresponding to filepath (or nil followed by an error
	-- message in case of error). The attributes are
	-- described as follows; attribute mode is a string, all the others are numbers, and the time
	-- related attributes use the same time reference of os.time.
	-- This function uses stat internally thus if the given filepath is a symbolic link, it is followed
	-- (if it points to another link the chain is followed recursively) and the information is about the
	-- file it refers to.
	-- @arg attributename A string with the name of the attribute to be read.
	-- @tabular attributename
	-- Attribute & Description \
	-- "dev" &
	-- on Unix systems, this represents the device that the inode resides on. On Windows
	-- systems, represents the drive number of the disk containing the file \
	-- "ino" &
	-- on Unix systems, this represents the inode number. On Windows systems this has no meaning \
	-- "mode" &
	-- string representing the associated protection mode (the values could be file, directory,
	-- link, socket, named pipe, char device, block device or other) \
	-- "nlink" &
	-- number of hard links to the file \
	-- "uid" &
	-- user-id of owner (Unix only, always 0 on Windows) \
	-- "gid" &
	-- group-id of owner (Unix only, always 0 on Windows) \
	-- "rdev" &
	-- on Unix systems, represents the device type, for special file inodes. On Windows systems
	-- represents the same as dev \
	-- "access" &
	-- time of last access \
	-- "modification" &
	-- time of last data modification \
	-- "change" &
	-- time of last file status change \
	-- "size" &
	-- file size, in bytes \
	-- "blocks" &
	-- block allocated for file; (Unix only) \
	-- "blksize" &
	-- optimal file system I/O blocksize; (Unix only)
	-- @usage filePath("river.shp"):attributes("mode")
	attributes = function(self, attributename)
		optionalArgument(1, "string", attributename)

		return lfs.attributes(self.filename, attributename)
	end,
	--- Close an opened file.
	-- @usage -- DONTRUN
	-- file = File("abc.txt")
	-- file:close()
	close = function(self)
		if not self.file then
			return customWarning("File is not opened.")
		end

		if io.type(self.file) == "file" then
			io.close(self.file)
			return true
		else
			resourceNotFoundError("file", self.filename)
		end
	end,
	--- Remove an existing file. If the file does not exist or it cannot be removed,
	-- this function stops with an error.
	-- If the file to be removed is a shapefile, it also removes
	-- the respective dbf, shx, prj, and qix files if they exist.
	-- @usage filename = "myfile.txt"
	-- file = File(filename)
	-- file:write("Some text..")
	-- file:close()
	-- file:delete()
	delete = function(self)
		if not self:exists() then
			resourceNotFoundError(1, self.filename)
		end

		local directory = Directory{name = "tmpXXXXXXXX", tmp = true}
		local s = sessionInfo().separator

		local result = os.execute("rm -f \""..self.filename.."\" 2> "..directory..s.."a.txt")
		directory:delete()

		if result ~= true then
			if result == nil then -- SKIP
				result = "Could not remove file '"..self.filename.."'." -- SKIP
			end

			customError(tostring(result)) -- SKIP
		end

		if string.endswith(self.filename, ".shp") then
			local dbf = File(string.sub(self.filename, 1, -4).."dbf")
			local shx = File(string.sub(self.filename, 1, -4).."shx")
			local prj = File(string.sub(self.filename, 1, -4).."prj")
			local qix = File(string.sub(self.filename, 1, -4).."qix")

			dbf:deleteIfExists()
			shx:deleteIfExists()
			prj:deleteIfExists()
			qix:deleteIfExists()
		end
	end,
	--- Remove a file if it exists. It does not stop with an error when the file does not exist.
	-- @usage filename = "myfile.txt"
	-- file = File(filename)
	-- file:write("Some text..")
	-- file:close()
	-- file:deleteIfExists()
	deleteIfExists = function(self)
		if self:exists() then
			self:delete()
		end
	end,
	--- Return the path to the file.
	-- @usage file = filePath("agents.csv", "base")
	-- print(file:path())
	path = function(self)
		local result, _, _ = self:split()

		return result
	end,
	--- Return whether the file stored in the computer.
	-- @usage file = filePath("agents.csv", "base")
	-- print(file:exists())
	exists = function(self)
		local fopen = io.open(self.filename)

		if fopen then
			fopen:close()
			return true
		end

		return false
	end,
	--- Return the extension of the file. It returns the substring after the last dot.
	-- If it does not have a dot, an empty string is returned.
	-- @usage file = filePath("agents.csv", "base")
	-- print(file:extension()) -- "csv"
	extension = function(self)
		local s = sessionInfo().separator

		for i = self.filename:len() - 1, 1, -1 do
			local sub = self.filename:sub(i, i)
			if sub == "." then
				return self.filename:sub(i + 1, self.filename:len())
			elseif sub == s or sub == "/" then
				return ""
			end
		end

		return ""
	end,
	--- Return a boolean value if the file has an extension.
	-- @usage file = filePath("agents.csv", "base")
	-- print(file:hasExtension()) -- true
	hasExtension = function(self)
		return not (self:extension() == "")
	end,
	--- Return the file name removing its path.
	-- @usage file = filePath("agents.csv", "base")
	-- print(file:name()) -- "agents.csv"
	name = function(self)
		local split = {self:split()}

		if split[3] then
			return split[2].."."..split[3]
		else
			return split[2]
		end
	end,
	--- Open the file for reading or writing. An opened file must be closed after being used.
	-- @arg mode A string with the mode. It can be "w" for writing or "r" for reading.
	-- @see File:close
	-- @usage -- DONTRUN
	-- file = File("myfile.txt")
	-- file:open()
	open = function(self, mode)
		mode = mode or "r"
		mandatoryArgument(1, "string", mode)

		if self.mode then
			customError("File '"..self.filename.."' is already open.")
		else
			self.mode = mode
		end

		local fopen = io.open(self.filename, self.mode)
		if fopen == nil then
			resourceNotFoundError("file", self.filename)
		else
			self.file = fopen
			return fopen
		end
	end,
	--- Read a line from the file. It stores the position of the line internally in case of
	-- some error occur. Therefore no line number will be used as argument for this function.
	-- @arg sep A string with the separator. Parse a single CSV line.
	-- It returns a vector of strings with the i-th value in the position i.
	-- This function was taken from http://lua-users.org/wiki/LuaCsv.
	-- @usage file = filePath("agents.csv", "base")
	-- line = file:read(",")
	-- print(line[1]) -- john
	-- print(line[2]) -- 20
	-- print(line[3]) -- 200
	--
	-- line = file:read()
	-- print(line) -- "mary",18,100,3,1,false
	read = function(self, sep)
		optionalArgument(1, "string", sep)

		if not self.mode then
			self.line = 0
			self.file = self:open("r")
		elseif self.mode ~= "r" then
			customError("Cannot read a file opened for writing.")
		end

		local line = self.file:read()

		if line then
			self.line = self.line + 1
		end

		if not sep then
			return line
		end

		if line == nil then return {} end
		return  parseLine(line, sep, self.line)
	end,
	--- Read a file. It returns a vector (whose indexes are line numbers)
	-- containing named tables (whose indexes are attribute names).
	-- The first line of the file list the attribute names. This function
	-- automatically closes the file.
	-- @arg sep A string with the separator. The default value is ','.
	-- @usage file = filePath("agents.csv", "base")
	-- csv = file:readTable()
	-- print(csv[1].age) -- 20
	readTable = function(self, sep)
		optionalArgument(1, "string", sep)

		if not self.mode then
			self.line = 1
			self.file = self:open("r")
		elseif self.mode ~= "r" then
			customError("Cannot read a file opened for writing.")
		end

		sep = sep or ','
		local data = {}

		local fields = parseLine(self.file:read(), sep, self.line)
		local line = self.file:read()

		while line do
			local element = {}
			local tuple = parseLine(line, sep, self.line)
			if #tuple == #fields then
				for k, v in ipairs(fields) do
					element[v] = tonumber(tuple[k]) or tuple[k]
				end

				table.insert(data, element)
			else
				customError("Line "..self.line.." ('"..line.."') should contain "..#fields.." attributes but has "..#tuple..".")
			end

			line = self.file:read()
			self.line = self.line + 1
		end

		self:close()

		return data
	end,
	--- Split the path, name, and extension of the file into three returning values.
	-- @usage file = filePath("agents.csv", "base")
	-- directory, name, extension = file:split()
	-- print(directory) -- "/base/data/"
	-- print(name) -- "agents",
	-- print(extension) -- "csv"
	split = function(self)
		local filePath, nameWithExtension, extension = string.match(self.filename, "(.-)([^\\/]-%.?([^%.\\/]*))$")

		if nameWithExtension == extension then
			return filePath, nameWithExtension
		end

		local _, _, fileName = string.find(nameWithExtension, "^(.*)%.[^%.]*$")

		return filePath, fileName, extension
	end,
	--- Set access and modification times for the file.
	-- Times are provided in seconds (which should be generated with Lua
	-- standard function os.time). If the modification time is omitted, the access time provided is used;
	-- if both times are omitted, the current time is used.
	-- Returns true if the operation was successful; in case of error, it returns nil plus an error string.
	-- @arg atime The new access time (in seconds).
	-- @arg mtime The new modification time (in seconds).
	-- @usage filePath("river.shp"):touch(0, 0)
	touch = function(self, atime, mtime)
		mandatoryArgument(1, "number", atime)
		mandatoryArgument(2, "number", mtime)

		return lfs.touch(self.filename, atime, mtime)
	end,
	--- Write a given string or table into the file.
	-- @arg data A string or table to be saved. A table it must be a vector (whose indexes are line numbers)
	-- containing named-tables (whose indexes are attribute names).
	-- When writing a table, he first line of the file will list the attributes of the table.
	-- @arg sep A string with the separator. The default value is ' ' for string and ',' for table.
	-- @usage mytable = {
	--     {age = 1, wealth = 10, vision = 2},
	--     {age = 3, wealth =  8, vision = 1},
	--     {age = 3, wealth = 15, vision = 2}
	-- }
	--
	-- file = File( "file.csv")
	-- file:write(mytable, ";")
	-- file:deleteIfExists()
	--
	-- file = File("file.txt")
	-- file:write("Some text..")
	-- file:close()
	-- file:deleteIfExists()
	write = function(self, data, sep)
		if type(data) == "string" then
			data = {data}
		end

		mandatoryArgument(1, "table", data)
		optionalArgument(2, "string", sep)

		if not self.mode then
			self.file = self:open("w")
		elseif self.mode ~= "w" then
			customError("Cannot write a file opened for reading.")
		end

		if data[1] == nil then
			customError("#1 does not have position 1.")
		elseif #data ~= getn(data) then
			customError("#1 should be a vector.")
		end

		if type(data[1]) == "table" then
			sep = sep or ","
			local fields = {}
			for k in pairs(data[1]) do
				if type(k) ~= "string" then
					customError("All attributes should be string, got "..type(k)..".")
				end

				table.insert(fields, k)
			end

			self.file:write(table.concat(fields, sep))
			self.file:write("\n")
			for _, tuple in ipairs(data) do
				local line = {}
				for _, k in ipairs(fields) do
					local value = tuple[k]
					local t = type(value)
					if t ~= "number" then
						value = "\""..tostring(value) .."\""
					end

					table.insert(line, value)
				end

				self.file:write(table.concat(line, sep))
				self.file:write("\n")
			end

			self:close()
		else
			sep = sep or " "
			self.file:write(table.concat(data, sep))
		end
	end
}

metaTableFile_ = {
	__index = File_,
	__tostring = function(self)
		return self.filename
	end,
	--- Concatenate the file.
	-- @arg value A string or an object that can be concatenated.
	-- @usage print(File("abcd1234").." does not exist.")
	__concat = function(self, value)
		if type(self) == "File" then
			return self.filename..value
		elseif type(value) == "File" then
			return self..value.filename
		end
	end
}

--- An abstract representation of a file. Whenever an instance of File is created, it only verifies
-- whether it is possible to have a file with the given name and if its directory exists
-- (in case of explicitly specified). It will not stop with an error if the file does not exist.
-- The file is only opened when a read function is called. The file is only created if a 
-- write function is called.
-- @arg data.name A string with the file name. This argument is mandatory.
-- @usage file = File("agents.csv")
function File(data)
	mandatoryArgument(1, "string", data)

	if not (data:match("\\") or data:match("/")) then
		data = currentDir()..sessionInfo().separator..data
	end

	data = {filename = _Gtme.makePathCompatibleToAllOS(data)}

	setmetatable(data, metaTableFile_)

	local dir = data:path()
	if not Directory(dir):exists() then
		customError("Directory '"..dir.."' does not exist.")
	end

	local invalidChar = data.filename:find("[&*{}<>?|\"+]")
	if invalidChar then
		customError("Filename '"..data.filename.."' cannot contain character '"..data.filename:sub(invalidChar, invalidChar).."'.")
	end

	return data
end

