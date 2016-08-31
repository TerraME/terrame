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

local function parseLine(line, sep, cline)
	mandatoryArgument(1, "string", line)
	optionalArgument(2, "string", sep)
	optionalArgument(3, "number", cline)

	if cline == nil then cline = 1 end

	local res = {}
	local pos = 1
	sep = sep or ','
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
	-- message in case of error). If the second optional argument is given, then only the value of the
	-- named attribute is returned (this use is equivalent to lfs.attributes(filepath).aname, but the
	-- table is not created and only one attribute is retrieved from the O.S.). The attributes are
	-- described as follows; attribute mode is a string, all the others are numbers, and the time
	-- related attributes use the same time reference of os.time.
	-- This function uses stat internally thus if the given filepath is a symbolic link, it is followed
	-- (if it points to another link the chain is followed recursively) and the information is about the
	-- file it refers to.
	-- @arg filepath A string with the file path.
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
	-- @usage File(packageInfo("base").path):attributes("mode")
	attributes = function(self, attributename)
		optionalArgument(1, "string", attributename)

		return lfs.attributes(self.name, attributename)
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
			resourceNotFoundError("file", self.name)
		end
	end,
	--- Return whether a given string represents a file stored in the computer.
	-- A directory is also considered a file.
	-- @usage file = File(filePath("agents.csv", "base"))
	-- print(file:exists())
	exists = function(self)
		local fopen = io.open(self.name)

		if fopen then
			fopen:close()
			return true
		end

		return false
	end,
	--- Return the directory of a file given its path.
	-- @usage file = File("/my/path/file.txt")
	-- print(file:getDir()) -- "/my/path"
	getDir = function(self)
		local path, _, _ = self:splitNames()

		return path
	end,
	--- Return the extension of a given file name. It returns the substring after the last dot.
	-- If it does not have a dot, an empty string is returned.
	-- @usage file = File("/my/path/file.txt")
	-- print(file:getExtension()) -- "txt"
	getExtension = function(self)
		local s = sessionInfo().separator

		for i = self.name:len() - 1, 1, -1 do
			local sub = self.name:sub(i, i)
			if sub == "." then
				return self.name:sub(i + 1, self.name:len())
			elseif sub == s or sub == "/" then
				return ""
			end
		end

		return ""
	end,
	--- Return the file name removing its path and extension.
	-- @usage file = File("/my/path/file.txt")
	-- print(file:getName()) -- "file"
	getName = function(self)
		return self:removeExtension()
	end,
	--- Return the file name removing its path.
	-- @usage file = File("/my/path/file.txt")
	-- print(file:getNameWithExtension()) -- "file.txt"
	getNameWithExtension = function (self)
		local _, nameWithExtension, _ = string.match(self.name, "(.-)([^\\/]-%.?([^%.\\/]*))$")

		return nameWithExtension
	end,
	--- Return the path if the file exists.
	-- @usage file = File(filePath("agents.csv", "base"))
	-- print(file:getPath())
	getPath = function(self)
		if isFile(self.name) then
			return _Gtme.makePathCompatibleToAllOS(self.name)
		end
	end,
	--- Return a boolean value if a given file name has extension.
	-- @usage file = File("/my/path/file.txt")
	-- print(file:hasExtension()) -- true
	hasExtension = function(self)
		return not (self:getExtension() == "")
	end,
	--- Open a file for reading or writing. An opened file must be closed after being used.
	-- @arg mode A string with the mode. It can be "w" for writing or "r" for reading.
	-- @see File:close
	-- @usage -- DONTRUN
	-- file = File("myfile.txt")
	-- file:open()
	open = function(self, mode)
		mode = mode or "r"
		mandatoryArgument(1, "string", mode)

		if self.mode then
			customError("File '"..self.name.."' is already open.")
		else
			self.mode = mode
		end

		local fopen = io.open(self.name, self.mode)
		if fopen == nil then
			resourceNotFoundError("file", self.name)
		else
			self.file = fopen
			return fopen
		end
	end,
	--- Read a file. It returns a vector (whose indexes are line numbers)
	-- containing named tables (whose indexes are attribute names).
	-- The first line of the file list the attribute names.
	-- @arg sep A string with the separator. The default value is ','.
	-- @usage file = File(filePath("agents.csv", "base"))
	-- csv = file:read()
	-- print(csv[1].age) -- 20
	read = function(self, sep)
		optionalArgument(1, "string", sep)

		if not self.mode then
			self.line = 1
			self.file = self:open("r")
		elseif self.mode ~= "r" then
			customError("Cannot read a file opened for writing.")
		end

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
	--- Read a line from the file. It stores the position
	-- of the line internally in case of some error occur. Therefore no line number
	-- will be used as argument for this function.
	--- Parse a single CSV line. It returns a vector of strings with the i-th value in the position i.
	-- This function was taken from http://lua-users.org/wiki/LuaCsv.
	-- @arg sep A string with the separator. The default value is ','.
	-- @usage file = File(filePath("agents.csv", "base"))
	-- line = file:readLine()
	-- print(line[1])
	-- print(line[2])
	-- print(line[3])
	readLine = function(self, sep)
		optionalArgument(1, "string", sep)

		if not self.mode then
			self.line = 1
			self.file = self:open("r")
		elseif self.mode ~= "r" then
			customError("Cannot read a file opened for writing.")
		end

		local data = {}
		local line = self.file:read()

		if line then
			data = parseLine(line, sep, self.line)
			self.line = self.line + 1
		end

		return data
	end,
	--- Return the file name removing its extension.
	-- @arg nameWithExtension An optional string with the file with extension.
	-- @usage file = File("/my/path/file.txt")
	-- print(file:removeExtension())
	removeExtension = function(self, nameWithExtension)
		if not nameWithExtension then nameWithExtension = self:getNameWithExtension() end

		local _, _, fileName = string.find(nameWithExtension, "^(.*)%.[^%.]*$")

		return fileName
	end,
	--- Split the path, file name, and extension from a given string.
	-- @usage file = File("/my/path/file.txt")
	-- print(file:splitNames()) -- "/my/path/", "file", "txt"
	splitNames = function(self)
		local filePath, nameWithExtension, extension = string.match(self.name, "(.-)([^\\/]-%.?([^%.\\/]*))$")
		local fileName = self:removeExtension(nameWithExtension)

		return filePath, fileName, extension
	end,
	--- Write a given table into a file.
	-- The first line of the file will list the attributes of each table.
	-- @arg data A table to be saved. It must be a vector (whose indexes are line numbers)
	-- containing named-tables (whose indexes are attribute names).
	-- @arg sep A string with the separator. The default value is ','.
	-- @usage mytable = {
	--     {age = 1, wealth = 10, vision = 2},
	--     {age = 3, wealth =  8, vision = 1},
	--     {age = 3, wealth = 15, vision = 2}
	-- }
	--
	-- file = File( "file.csv")
	-- file:write(mytable, ";")
	-- rmFile("file.csv")
	write = function(self, data, sep)
		mandatoryArgument(1, "table", data)
		optionalArgument(2, "string", sep)

		if not self.mode then
			self.file = self:open("w")
		elseif self.mode ~= "w" then
			customError("Cannot write a file opened for reading.")
		end

		sep = sep or ","
		local fields = {}

		if data[1] == nil then
			customError("#1 does not have position 1.")
		elseif #data ~= getn(data) then
			customError("#1 should be a vector.")
		end

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
	end,
	--- Write a given text to the file.
	-- @arg text A string to be saved.
	-- @usage file = File( "file.txt")
	-- file:writeLine("Text...")
	-- rmFile("file.txt")
	writeLine = function(self, text)
		mandatoryArgument(1, "string", text)

		if not self.mode then
			self.file = self:open("w")
		elseif self.mode ~= "w" then
			customError("Cannot write a file opened for reading.")
		end

		self.file:write(text)
		self:close()
	end
}

metaTableFile_ = {
	__index = File_,
	__tostring = _Gtme.tostring
}

--- An abstract representation of file and directory pathnames. This type provide access to additional
-- file operations and file attributes.
-- @arg data.name A string with the file name. This argument is mandatory.
-- @usage file = File("/my/path/file.txt")
function File(data)
	mandatoryArgument(1, "string", data)
	data = {name = data}

	setmetatable(data, metaTableFile_)

	return data
end
